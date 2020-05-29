#include "MechCommon.as";
#include "Hitters.as";

class CMechFlamer : CMechCore
{
	array<Vec2f> flamepos;
	array<Vec2f> flamevel;
	array<int> flametime;
	CMechFlamer()
	{
		//lel
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		//Updating flames
		array<u16> hitblobs;
		array<int> hitcounts;
		CMap@ map = getMap();
		
		const float flamerange = 16;
		const int hitratio = 6;//hits every x ticks, to not spam hit networks stuff too much
		//effects damage so you can change this and leave damage alone
		for (uint i = 0; i < flametime.length; i++)
		{
			flametime[i]++;
			flamepos[i] += flamevel[i];
			if(flametime[i] >= 80 || map.isTileSolid(flamepos[i]))
			{
				if(map.isTileWood(map.getTile(flamepos[i]).type) && !map.isInFire(flamepos[i]))
				{
					map.server_setFireWorldspace(flamepos[i], true);
				}
				flamepos.removeAt(i);
				flametime.removeAt(i);
				flamevel.removeAt(i);
				i--;
			}
			else
			{
				if(getNet().isServer() && flametime[i] <= 60 && flametime[i] % hitratio == 0)
				{
					//doing fire damage stuff
					CBlob@[] bloblist;
					if(map.getBlobsInRadius(flamepos[i], flamerange, @bloblist))
					{
						for (uint j = 0; j < bloblist.length; j++)
						{
							if(blob.getTeamNum() == bloblist[j].getTeamNum())
								continue;
							int findpos = hitblobs.find(bloblist[j].getNetworkID());
							if(findpos >= 0)
							{
								hitcounts[findpos]++;
							}
							else
							{
								hitblobs.push_back(bloblist[j].getNetworkID());
								hitcounts.push_back(1);
							}
						}
					}
				}
			}
		}
		//this seems like a really low amount of damage but trust, its still stronk
		const float basedamage = 0.03125 * hitratio;
		for (uint i = 0; i < hitcounts.length; i++)
		{
			CBlob@ thishit = getBlobByNetworkID(hitblobs[i]);
			if(thishit is null)
				continue;
				blob.server_Hit(thishit, thishit.getPosition(), Vec2f_zero, basedamage * hitcounts[i], Hitters::fire);
		}
	
		if(driver !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? driver.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyPressed(key_action2) :
							false;
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			
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
				
				
				//Making flames
				if(actionkey)
				{
					//Should be able to move this to onCommand easily
					addHeat(blob, 1.3);
					for (uint i = 0; i < 1; i++)
					{
						const bool facingleft = part.isFacingLeft();
						Vec2f direction = Vec2f(1, 0).RotateBy(part.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
						float angle =  direction.Angle() * -1;
						
						const float spread = 30;
						const float speed = 3;
						
						Random random(XORRandom(0x7FFFFFFF));
						//Look, its just easier to random.nextfloat than it is to use XORRandom and convert to float and blahblahblah....
						
						f32 offset = (random.NextFloat() * spread) - spread / 2.0;
						f32 aimdir = angle + offset;
						
						f32 aimrad = ((aimdir / 180) * Maths::Pi);
						
						flamevel.push_back(Vec2f(Maths::Cos(aimrad), Maths::Sin(aimrad)) * (speed + random.NextFloat() * speed) + blob.getVelocity() * 0.5);
						flamepos.push_back(part.getPosition() + (Vec2f(Maths::Cos(((angle / 180) * Maths::Pi)), Maths::Sin(((angle / 180) * Maths::Pi))) * 32));
						flametime.push_back(XORRandom(6));
					}
				}
			}
		}
	}
	
	void onTick(CSprite@ sprite, CBlob@ driver)
	{
		
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params)
	{
		return bits;
	}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		
	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{
		//we could try and move flame ticking to script instead of part but lazy
		flamepos.clear();
		flamevel.clear();
		flametime.clear();
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "FRONT_ARM" || slot == "BACK_ARM")
			return true;
		return false;
	}
}

void renderFlames(CBlob@ this, int id)
{
	IMechPart@ part = @getMechPart(this);
	CMechFlamer@ core = cast<CMechFlamer>(part);
	if(core is null) return;
	
	array<Vertex> vertlist(0);
	
	float framex = 16.0;
	float framey = 16.0;
	//					frame size / image size
	float spritesizex = framex / 16.0;
	float spritesizey = framey / 96.0;
		
	float sizemult = 0.5;
	
	
	CMap@ map = getMap();

	for (uint i = 0; i < core.flametime.length; i++)
	{
		Vec2f basepos = core.flamepos[i] + core.flamevel[i] * getInterpolationFactor();
		
		
		u32 color = 0xFFFFFFFF;
		//fire frames
		int thisframe = (core.flametime[i] / 3) % 4;
		if(core.flametime[i] > 60)//smoke frames
		{
			thisframe = ((core.flametime[i] / 10) % 2) + 4;
			if(map !is null)
			{
				SColor mapcolor = map.getColorLight(core.flamepos[i]);
				color = (0xFF << 24) | (mapcolor.getRed() << 16) | (mapcolor.getGreen() << 8) | (mapcolor.getBlue());
			}
		}

		//oh man these lines are a mess
		vertlist.push_back(Vertex(basepos.x - framex * sizemult, basepos.y - framey * sizemult, 30, 0, thisframe * spritesizey, color));
		vertlist.push_back(Vertex(basepos.x + framex * sizemult, basepos.y - framey * sizemult, 30, spritesizex, thisframe * spritesizey, color));
		vertlist.push_back(Vertex(basepos.x + framex * sizemult, basepos.y + framey * sizemult, 30, spritesizex, spritesizey + thisframe * spritesizey, color));
		vertlist.push_back(Vertex(basepos.x - framex * sizemult, basepos.y + framey * sizemult, 30, 0, spritesizey + thisframe * spritesizey, color));
	}
	Render::RawQuads("Fiah.png", vertlist);
}

void onInit(CBlob@ this)
{
	CMechFlamer part();
	setMechPart(this, @part);
	
	Render::addBlobScript(Render::layer_objects, this, "MechFlamer.as", "renderFlames");
}

void onTick(CBlob@ this)
{

}

void onTick(CSprite@ this)
{
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if(blob.hasTag("flesh"))
		return false;
	return true;
}
