#include "EquipmentCore.as";
#include "CHitters.as";
#include "DamageModCommon.as";


class CSwordEquipment : CEquipmentCore
{
	int chargetime;
	int timetocharge;
	bool disabled;
	int currslash;
	bool lastjab;
	float lastdir;
	int jabtime;
	int slashtime;
	float lungespeed;
	
	float damage;
	float range;
	float speed;
	float knockback;
	bool jabonly;
	
	int hittype;
	
	array<u16> hitblobs;

	CSwordEquipment(float damage, float range, float speed, float knockback, bool jabonly, int jabtime, int slashtime, float lungespeed)
	{
		super();
		this.damage = damage;
		this.range = range;
		this.speed = speed;
		this.knockback = knockback;
		this.jabonly = jabonly;
		this.jabtime = jabtime;
		this.slashtime = slashtime;
		this.lungespeed = lungespeed;
		
		//array<u16> hitblobs;
		
		chargetime = 0;
		timetocharge = 0;
		currslash = 0;
		lastdir = 0;
		hittype = Hitters::sword;
	}

	void useWeapon(CBlob@ blob, CBlob@ user, bool useold = false)
	{

		bool dontHitMore = false;
		Vec2f pos = user.getPosition();
		float aimangle = -((user.getAimPos() - pos).Angle());
		if(useold)
		{
			aimangle = lastdir;
		}
		//aimangle = (aimangle / 180) * 3.14159;
		CMap@ map = getMap();
		HitInfo@[] hitInfos;
		
		bool jab = chargetime < timetocharge || jabonly;
		if(!useold)
		{
			chargetime = -(jab ? jabtime : slashtime);
			lastjab = jab;
			lastdir = aimangle;
		}
		else
			jab = lastjab;
		
		if((!jab || jabonly) && !useold)
		{
			Vec2f normal = (user.getAimPos() - pos);
			normal.Normalize();
			user.setVelocity(user.getVelocity() + normal * lungespeed);
		}
		
		
		//totally didnt steal this from knightlogic
		if (getLocalPlayerBlob() is user && map.getHitInfosFromArc(pos, aimangle, jab ? 45 : 90, range, user, @hitInfos))
		{
			//HitInfo objects are sorted, first come closest hits
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ b = hi.blob;
				if (b !is null && !dontHitMore) // blob
				{
					if(hitblobs.find(b.getNetworkID()) >= 0)
						continue;
					if (b.hasTag("ignore sword") || b.getTeamNum() == user.getTeamNum()) continue;

					//big things block attacks
					const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();
					
					hitblobs.push_back(b.getNetworkID());
					if (!dontHitMore)
					{
						CBitStream params;
						params.write_u32(EquipmentBitStreams::Tu16 | EquipmentBitStreams::Tf32);
						params.write_u16(hi.blob.getNetworkID());
						params.write_f32(jab && !jabonly ? damage / 2.0 : damage);
						blob.SendCommandOnlyServer(blob.getCommandID("partcmd"), params);
					}
				}
			}
		}
	}
	void onTick(CSprite@ sprite, CBlob@ user)
	{
		CSprite@ usersprite = user.getSprite();
		if(usersprite is null)
			return;
		if(chargetime < 0 && (lastjab ? chargetime < -(jabtime - 6) : chargetime < -(slashtime - 6)))
		{
			if(usersprite.getSpriteLayer("equipslashfx") is null)
			{
				CSpriteLayer@ layer = lastjab ? 
					usersprite.addSpriteLayer("equipslashfx", "SwordJabFx.png", 32, 32) :
					usersprite.addSpriteLayer("equipslashfx", "KnightMale.png", 32, 32);
					
				layer.SetFrame(lastjab ? 0 : 35);
				layer.RotateBy(lastdir + (user.isFacingLeft() ? 180 : 0), Vec2f_zero);
				layer.ScaleBy(Vec2f(range / 18.0, range / 18.0));
				layer.SetIgnoreParentFacing(true);//Wish I knew this was a thing earlier, oh well
				layer.SetFacingLeft(user.isFacingLeft());
				
				if(usersprite.getSpriteLayer("equipswordfx") is null)
				{
					CSpriteLayer@ bladelayer = usersprite.addSpriteLayer("equipswordfx", sprite.getFilename(), sprite.getFrameWidth(), sprite.getFrameHeight());
					
					
					bladelayer.SetIgnoreParentFacing(true);
					bladelayer.SetFacingLeft(user.isFacingLeft());
					Vec2f tempoffset = spriteoffset;
					if(user.isFacingLeft())
						tempoffset.x *= -1;
					bladelayer.TranslateBy(tempoffset);
					bladelayer.RotateBy(lastdir + (lastjab ? (user.isFacingLeft() ? 180 : 0) : (user.isFacingLeft() ? 255 : -45)), Vec2f_zero);
					bladelayer.ScaleBy(Vec2f(1, 1) * spritescale);
					bladelayer.SetRelativeZ(5);
				}
			}
			else 
			{
				CSpriteLayer@ layer = usersprite.getSpriteLayer("equipslashfx");
				CSpriteLayer@ bladelayer = usersprite.getSpriteLayer("equipswordfx");
				if(!lastjab)
				{
					//Best not to ask whats going on here
					float chargeratio = float((-chargetime) - (1 + Maths::Max(-6 + slashtime, 0))) / float(Maths::Min(slashtime, 6));
					layer.SetFrame(
					chargeratio < 0.32 ? 63 :
					chargeratio < 0.65 ? 43 : 35);
					
					if(bladelayer !is null)
					{
						bladelayer.ResetTransform();
						Vec2f tempoffset = spriteoffset;
						if(bladelayer.isFacingLeft())
							tempoffset.x *= -1;
						bladelayer.TranslateBy(tempoffset);
							
						bladelayer.RotateBy(
						chargeratio < 0.32 ? lastdir + (bladelayer.isFacingLeft() ? 135 : 45) :
						chargeratio < 0.65 ? lastdir + (bladelayer.isFacingLeft() ? 180 : 0) : 
						lastdir + (bladelayer.isFacingLeft() ? 225 : -45), Vec2f_zero);
					}
				}
				else
				{
					Vec2f transdir = Vec2f(1, 0);
					transdir.RotateBy(lastdir);
					layer.TranslateBy(transdir);
					if(bladelayer !is null)
					{
						bladelayer.TranslateBy(transdir);
					}
				}
			}
		}
		else
		{
			if(usersprite.getSpriteLayer("equipslashfx") !is null)
			{
				usersprite.RemoveSpriteLayer("equipslashfx");
			}
			if(usersprite.getSpriteLayer("equipswordfx") !is null)
			{
				usersprite.RemoveSpriteLayer("equipswordfx");
			}
		}
	}
	void onTick(CBlob@ blob, CBlob@ user)
	{
		Vec2f pos = user.getPosition();
		const bool myplayer = user.isMyPlayer();
		CSprite@ sprite = user.getSprite();
		keys usekey = attachedPoint == "FRONT_ARM" ? key_action1 :
						attachedPoint == "BACK_ARM" ? key_action2 :
						key_action1;
						
		if(chargetime < 0)
		{
			if(speed + chargetime < 7)
				useWeapon(blob, user, true);
			chargetime++;
			return;
		}
		else if(chargetime == 0)
		{
			hitblobs.clear();
		}
		
		
		if(user.isKeyPressed(usekey) && chargetime == 0)
		{
			disabled = false;
			timetocharge = speed;
		}
		if(user.isKeyPressed(usekey) && !jabonly)
		{
			if(!disabled)
			{
				chargetime++;
			}
			if(usekey == key_action2)
			{
				if(user.isKeyJustPressed(key_action1))
				{
					chargetime = 0;
					disabled = true;
					if(sprite !is null)
						sprite.PlaySound("PopIn.ogg");
				}
			}
			else
			{
				if(user.isKeyJustPressed(key_action2))
				{
					chargetime = 0;
					disabled = true;
					if(sprite !is null)
						sprite.PlaySound("PopIn.ogg");
				}
			}
		}
		if((!jabonly && chargetime != 0 && user.isKeyJustReleased(usekey) && timetocharge != 0) || (jabonly && user.isKeyJustPressed(usekey)))
		{
			//if(user is getLocalPlayerBlob())
			//{
				useWeapon(blob, user);
			//}
			//chargetime = 0;
			
			if(sprite !is null && chargetime >= timetocharge)
			{
				Sound::Play("/ArgLong", user.getPosition());
				Sound::Play("/SwordSlash", user.getPosition());
			}
			else if(sprite !is null)
			{
				Sound::Play("/SwordSlash", user.getPosition());
			}
			timetocharge = 0;
		}
		if(chargetime == 1 && !jabonly)
		{
			//Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
		}
		if(chargetime == timetocharge && sprite !is null && chargetime != 0)
		{
			Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
		}
	}
	
	void onEquip(CBlob@ blob, CBlob@ user)
	{
		//CBaseWeapon::onEquip(blob, special);
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{
		if(user.isMyPlayer())
		{
			getHUD().SetDefaultCursor();
		}
		CSprite@ usersprite = user.getSprite();
		if(usersprite !is null && usersprite.getSpriteLayer("equipslashfx") !is null)
		{
			usersprite.RemoveSpriteLayer("equipslashfx");
		}
		chargetime = 0;
	}
	
	
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		CBlob@ target = null; 
		uint16 blobid = 0;
		if(blob is null || user is null)
			return bits;
		if(EquipmentBitStreams::Nextu16 & bits == EquipmentBitStreams::Tu16)
		{
			blobid = params.read_u16();
			bits &= ~EquipmentBitStreams::Tu16;
			@target = getBlobByNetworkID(blobid); 
		}
		float damagetemp = 0;
		if(EquipmentBitStreams::Nextf32 & bits == EquipmentBitStreams::Tf32)
		{
			damagetemp = params.read_f32();
			bits &= ~EquipmentBitStreams::Tf32;
		}
		if(target is null)
			return bits;
		
		Vec2f normal = target.getPosition() - user.getPosition();
		normal.Normalize();
		
		if(target !is null)
		{
			user.server_Hit(target, target.getPosition(), normal, calcAllDamageMods(user, target, damagetemp, hittype), hittype, false);
			target.setVelocity(target.getVelocity() + normal * knockback);
		}
		return bits;
	}
	void onRender(CBlob@ blob, CBlob@ user)
	{
		if(user.isMyPlayer())
		{
			if (getHUD().hasButtons())
			{
				getHUD().SetDefaultCursor();
			}
			else
			{
				getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-32, -32));
				
				int frame = 0;
				if(jabonly)
				{
					float currcoolratio = float(Maths::Abs(chargetime)) / float(jabtime);
					if(chargetime < jabtime)
						frame = 2 + int(currcoolratio * 8) * 2;
					if(chargetime == jabtime)
						frame = 1;
					if(chargetime == 0)
						frame = 0;
				}
				else
				{
					if(chargetime > 0 && timetocharge != 0)
						frame = 2 + int(float(chargetime) / float(timetocharge) * 8) * 2;
					if(chargetime >= timetocharge)
						frame = 1;
					if(chargetime == 0)
						frame = 0;
				}
				getHUD().SetCursorFrame(frame);
			}
		}
	}
}