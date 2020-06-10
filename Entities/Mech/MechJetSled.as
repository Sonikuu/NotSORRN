#include "MechCommon.as";

shared class CMechJetSled : CMechCore
{
	CMechJetSled()
	{
		//lel
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		const int maxdistance = 64;
		const float maxangle = 30;
		CMap@ map = getMap();
		Vec2f distance;
		HitInfo@[] hitInfos;
		if(driver !is null)
		{
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			if(part !is null)
			{
				if(driver.isKeyPressed(key_left) || driver.isKeyPressed(key_right))
				{
					float jetangle = ((part.getAngleDegrees() + (part.isFacingLeft() ? 180 : 0)) / 180) * 3.14159;
					blob.setVelocity(blob.getVelocity() + (Vec2f(Maths::Cos(jetangle), Maths::Sin(jetangle)) * 0.6));
					addHeat(blob, 1);//pretty expensive heatwise, but this thing is fast so
				}
				
				if(driver.isKeyPressed(key_left))
				{
					blob.SetFacingLeft(true);
					
					//Dont need this for legit jetsled, but ill keep it around in case i need it later
					/*if(map.getHitInfosFromArc(blob.getAttachments().getAttachmentPoint(attachedPoint).getPosition(), 180 + maxangle / 2, maxangle, maxdistance, driver, true, @hitInfos))
					{
						bool isblock = false;
						int i = 0;
						while(!isblock && i < hitInfos.length)
						{
							if(hitInfos[i].blob is null)
								isblock = true;
							i++;
						}
						if(isblock)
							blob.setAngularVelocity(blob.getAngularVelocity() + (3 + blob.getVelocity().Length()));
					}*/
				}
				if(driver.isKeyPressed(key_right))
				{
					blob.SetFacingLeft(false);
						
					//checking if we need to climb
					/*if(map.getHitInfosFromArc(blob.getAttachments().getAttachmentPoint(attachedPoint).getPosition(), 360 - maxangle / 2, maxangle, maxdistance, driver, true, @hitInfos))
					{
						bool isblock = false;
						int i = 0;
						while(!isblock && i < hitInfos.length)
						{
							if(hitInfos[i].blob is null)
								isblock = true;
							i++;
						}
						if(isblock)
							blob.setAngularVelocity(blob.getAngularVelocity() - (3 + blob.getVelocity().Length()));
					}*/
				}
				
				float anglerad = 0;
				if(driver.isKeyPressed(key_up))
				{
					if(blob.isFacingLeft())
						anglerad = 45;
					else
						anglerad = 315;
				}
					
				float handrot = blob.getAngleDegrees();
				
				float handmult = Maths::Min(4,  Maths::Abs(handrot - anglerad) / 90.0);
				if (Maths::Abs((handrot - anglerad)) > 180)
				{
					handmult = Maths::Min(4, Maths::Abs((360 -  Maths::Abs(handrot - anglerad))) / 90.0);
				}
				float rotspeed = 0;
				if(handrot < anglerad) 
				{
					if(Maths::Abs(handrot - anglerad) < 180)
					   rotspeed += 1.6 * handmult;
					else rotspeed -= 1.6 * handmult;
				}
				else 
				{
					if(Maths::Abs(handrot - anglerad) < 180)
					   rotspeed -= 1.6 * handmult;
					else rotspeed += 1.6 * handmult;
				}
				blob.setAngularVelocity(blob.getAngularVelocity() + rotspeed);
			}
		}
	}
	
	void onTick(CSprite@ sprite, CBlob@ driver)
	{
		CBlob@ blob = sprite.getBlob();
		CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
		if(part !is null)
		{
			CSprite@ partsp = part.getSprite();
			if(partsp !is null)
			{
				if(driver !is null && (driver.isKeyPressed(key_left) || driver.isKeyPressed(key_right)))
				{
					partsp.SetAnimation("active");
					
					Vec2f random = Vec2f(XORRandom(32) - 16, XORRandom(32) - 16);
					float jetangle = part.getAngleDegrees();
					Vec2f enginepos(-30, 0);
					if(part.isFacingLeft())
						enginepos *= -1;
					enginepos.RotateBy(jetangle);
					
					ParticleAnimated("Explosion.png", part.getPosition() + random + enginepos, Vec2f(0, 0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
				}
				else
					partsp.SetAnimation("default");
			}
		}
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params)
	{
		return bits;
	}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		CShapeManager@ manager;
		blob.get("shapemanager", @manager);
		if(manager !is null)
		{
			CShape@ shape = blob.getShape();

			Vec2f[] newshape(6);
			Vec2f startpoint(16, 24);
			newshape[0] = startpoint + Vec2f(-24, 0);
			newshape[1] = startpoint + Vec2f(24, 0);
			newshape[2] = startpoint + Vec2f(32, 8);
			newshape[3] = startpoint + Vec2f(24, 16);
			newshape[4] = startpoint + Vec2f(-24, 16);
			newshape[5] = startpoint + Vec2f(-32, 8);
			shape.setFriction(0);
			shapeName = manager.addShape(shape, newshape, "mechjetsled");
			CMechCore::onAttach(blob, part);
		}
	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{
		if(blob !is null && blob.getHealth() > 0 && !blob.hasTag("omaewamou"))//think onDetach triggers on blob death as well so might need to do this
		{
			CShapeManager@ manager;
			blob.get("shapemanager", @manager);
			if(manager !is null)
			{
				CShape@ shape = blob.getShape();
				if(shape !is null)
				{
					shape.setFriction(0.5);
					manager.removeShape(shape, shapeName);
					shapeName = "";
				}
			}
		}
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "LOCO")
			return true;
		return false;
	}
}


void onInit(CBlob@ this)
{
	CMechJetSled part();
	setMechPart(this, @part);
}

void onTick(CBlob@ this)
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
