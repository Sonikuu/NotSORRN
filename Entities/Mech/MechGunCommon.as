#include "MechCommon.as";
#include "Hitters.as";
#include "MaterialCommon.as";
#include "ParticleSparks.as";

const u32 firecmdbits = MechBitStreams::Tu32 | MechBitStreams::Tf32;

class CMechGun : CMechCore
{
	int cooldown;
	CSpriteLayerManager@ manager;
	
	float damage;
	int firerate;
	int shotcount;
	float spread;
	float heatpershot;
	
	CMechGun(float damage = 2.0, int firerate = 10, int shotcount = 1, float spread = 10.0, float heatpershot = 5.0)
	{
		this.firerate = firerate;
		this.damage = damage;
		this.shotcount = shotcount;
		this.spread = spread;
		this.heatpershot = heatpershot;
		
		cooldown = 0;
		@manager = @CSpriteLayerManager();
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		cooldown--;
		
		if(driver !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? driver.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyPressed(key_action2) :
							false;
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			CSprite@ sprite = part.getSprite();
			if(sprite !is null)
				manager.updateAll(sprite);
			
			if(part !is null)
			{
				//This doesnt seem to work properly for client :V
				//Fixed by setting SetMouseTaken to false on driver attachmentpoint
				float angle = (((driver.getAimPos() - part.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
				if(angle >= 90 && angle < 270)// should just test for positive or negative X on difference vector but eh
				{
					part.SetFacingLeft(true);
					angle += 180;
				}
				else
				{
					part.SetFacingLeft(false);
				}
				part.setAngleDegrees(angle);
				//printFloat("Angle: ", (driver.getAimPos() - driver.getPosition()).Angle());
			}
			
			if(actionkey && part !is null && cooldown < 0 && driver is getLocalPlayerBlob())
			{
				const bool facingleft = part.isFacingLeft();
				Vec2f direction = Vec2f(1, 0).RotateBy(part.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
				float angle =  direction.Angle() * -1;
				u32 seed = XORRandom(0x7FFFFFFF);
				CBitStream params;
				params.write_u8(blob.getAttachments().getAttachmentPoint(attachedPoint).getID());
				params.write_u32(firecmdbits);
				
				params.write_u32(seed);
				params.write_f32(angle);
				
				//print("CMD Sent");
				blob.SendCommand(blob.getCommandID("partcommand"), params);
				
				cooldown = firerate;
			}
		}
	}
	
	void onTick(CSprite@ sprite, CBlob@ driver)
	{
	
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params)
	{
		if(bits == firecmdbits && driver !is null)
		{
			
			
			CMap@ map = getMap();
			bits &= ~firecmdbits;
			u32 seed = params.read_u32();
			Random random(seed);
			f32 aimdef = params.read_f32();
			
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			
			CSprite@ sprite = part.getSprite();//If we're firing fast we need to remove old shots when we make new ones
			/*while(sprite.getSpriteLayer(1) !is null)
			{
				sprite.RemoveSpriteLayer(sprite.getSpriteLayer(1).name);
			}*/
			
			/*int initcount = sprite.getSpriteLayerCount();
			for (uint i = 0; i < initcount; i++)
			{
				if(sprite.getSpriteLayer(i) !is null)
					sprite.RemoveSpriteLayer(sprite.getSpriteLayer(i).name);
			}*/
			addHeat(blob, heatpershot);
			
			for (uint x = 0; x < shotcount; x++)
			{
				float endpoint = 512;
				f32 offset = (random.NextFloat() * spread) - spread / 2.0;
				f32 aimdir = aimdef + offset;
				HitInfo@[] hitInfos;
				if (map.getHitInfosFromRay(part.getPosition(), aimdir, 512, driver, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						HitInfo@ hi = hitInfos[i];

						if (hi.blob !is null) // blob
						{
							if(hi.blob.getTeamNum() != driver.getTeamNum() && !hi.blob.isAttachedTo(blob))
							{
								driver.server_Hit(hi.blob, hi.hitpos, hi.blob.getPosition() - part.getPosition(), damage, 0);
							}
						}
						else // map
						{
							if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
								continue;

							TileType tile = hi.tile;

							if (getNet().isServer())
							{
								map.server_DestroyTile(hi.hitpos, 1.0f, part);
							}
							endpoint = (hi.hitpos - part.getPosition()).Length();
						}
					}
				}
				if(getNet().isClient())
				{
					const bool facingleft = part.isFacingLeft();
					offset += (facingleft ? 180.0f : 0.0f);
					
					CSpriteLayer@ layer = @manager.addLayer(sprite, "tracer");
					layer.ReloadSprite("PixelYellow.png", 1, 1);
					layer.ScaleBy(Vec2f(endpoint, 1));
					layer.RotateBy(offset, Vec2f(endpoint / 2, 0));
					layer.TranslateBy(Vec2f(endpoint / 2, 0));	
					layer.SetRelativeZ(-1);
				}
			}
		}
		return bits;
	}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		CMechCore::onAttach(blob, part);
	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{		
		if(part is null) return;
		CSprite@ sprite = part.getSprite();
		manager.clearAll(sprite);
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "BACK_ARM" || slot == "FRONT_ARM")
			return true;
		return false;
	}
}

class CMechSpoolGun : CMechGun
{
	int spoollimit;//This is how much below base firerate we can go
	float spoolspeed;//amount per shot to reduce firerate
	
	float spooltime;//current spool speed
	CMechSpoolGun(float damage = 2.0, int firerate = 10, int shotcount = 1, float spread = 10.0, float heatpershot = 5.0, int spoollimit = 9, float spoolspeed = 1)
	{
		this.firerate = firerate;
		this.damage = damage;
		this.shotcount = shotcount;
		this.spread = spread;
		this.heatpershot = heatpershot;
		this.spoollimit = spoollimit;
		this.spoolspeed = spoolspeed;
		
		cooldown = 0;
		spooltime = 0;
		@manager = @CSpriteLayerManager();
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		cooldown--;
		
		if(driver !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? driver.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyPressed(key_action2) :
							false;
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			CSprite@ sprite = part.getSprite();
			if(sprite !is null)
				manager.updateAll(sprite);
			
			if(part !is null)
			{
				//This doesnt seem to work properly for client :V
				//Fixed by setting SetMouseTaken to false on driver attachmentpoint
				float angle = (((driver.getAimPos() - part.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
				if(angle >= 90 && angle < 270)// should just test for positive or negative X on difference vector but eh
				{
					part.SetFacingLeft(true);
					angle += 180;
				}
				else
				{
					part.SetFacingLeft(false);
				}
				part.setAngleDegrees(angle);
				//printFloat("Angle: ", (driver.getAimPos() - driver.getPosition()).Angle());
			}
			
			if(!actionkey)
				spooltime -= spoolspeed;
			
			if(actionkey && part !is null && cooldown < 0 && driver is getLocalPlayerBlob())
			{
				spooltime += spoolspeed;
				spooltime = Maths::Min(spoollimit, spooltime);
				spooltime = Maths::Max(0, spooltime);
				const bool facingleft = part.isFacingLeft();
				Vec2f direction = Vec2f(1, 0).RotateBy(part.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
				float angle =  direction.Angle() * -1;
				u32 seed = XORRandom(0x7FFFFFFF);
				CBitStream params;
				params.write_u8(blob.getAttachments().getAttachmentPoint(attachedPoint).getID());
				params.write_u32(firecmdbits);
				
				params.write_u32(seed);
				params.write_f32(angle);
				
				//print("CMD Sent");
				blob.SendCommand(blob.getCommandID("partcommand"), params);
				
				cooldown = firerate - spooltime;
			}
		}
	}
}

class CSpriteLayerManager
{
	array<string> layernames;
	array<int> timetodie;
	CSpriteLayerManager()
	{
		array<string> layernames();
		array<int> timetodie();
	}
	void updateAll(CSprite@ sprite)
	{
		for (uint i = 0; i < timetodie.length; i++)
		{
			timetodie[i]--;
			if(timetodie[i] <= 0)
			{
				sprite.RemoveSpriteLayer(layernames[i]);
				timetodie.removeAt(i);
				layernames.removeAt(i);
				i--;
			}
		}
	}
	CSpriteLayer@ addLayer(CSprite@ sprite, string name, int starttime = 3)
	{
		int number = 0;
		while(nameExists(name + formatInt(number, "")))
			number++;
		CSpriteLayer@ layer = sprite.addSpriteLayer(name + formatInt(number, ""));
		layernames.push_back(name + formatInt(number, ""));
		timetodie.push_back(starttime);
		return @layer;
	}
	void clearAll(CSprite@ sprite)
	{
		while(timetodie.length > 0)
		{
			sprite.RemoveSpriteLayer(layernames[0]);
			timetodie.removeAt(0);
			layernames.removeAt(0);
		}
	}
	bool nameExists(string name)
	{
		if(layernames.find(name) >= 0)
		{
			return true;
		}
		return false;
	}
}