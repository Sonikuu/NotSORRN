#include "MechCommon.as";

shared class CMechHover : CMechCore
{
	u16 shapeid;
	CMechHover()
	{
		//lel
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		const int maxdistance = 256;
		CMap@ map = getMap();
		Vec2f distance;
		
		if(driver !is null)
		{
			if(!driver.isKeyPressed(key_down) && map.rayCastSolid(blob.getPosition(), blob.getPosition() + Vec2f(0, maxdistance), distance))//checking distance between mech and ground
			{
				distance -= blob.getPosition();
				//																									//inverse % height for mech to hover at of max distance
				blob.setVelocity(blob.getVelocity() + Vec2f(0, (distance.y - maxdistance) / (maxdistance * (driver.isKeyPressed(key_up) ? 1.0 : 2.0))));
				
				if(driver.isKeyPressed(key_up))
				{
					addHeat(blob, 0.5); //overdrive has a mild heat cost, even MI can dissipate it but will make using tools
										//in overdrive harder
				}
				
				float anglerad = 0;
				
				float handrot = blob.getAngleDegrees();
				
				float handmult = Maths::Min(1, handrot / 180.0);
				if (handrot > 180)
				{
					handmult = Maths::Min(1, (360 - handrot) / 180.0);
				}
				float rotspeed = 0;
				if(handrot < anglerad) 
				{
					if(handrot < 180)
					   rotspeed += 0.8 * handmult;
					else rotspeed -= 0.8 * handmult;
				}
				else 
				{
					if(handrot < 180)
					   rotspeed -= 0.8 * handmult;
					else rotspeed += 0.8 * handmult;
				}
				blob.setAngularVelocity(blob.getAngularVelocity() + rotspeed);
			}
			if(driver.isKeyPressed(key_left))
			{
				blob.setVelocity(blob.getVelocity() + Vec2f(-0.1, 0));
				if(blob.getVelocity().x < -1)
					blob.SetFacingLeft(true);
			}
			if(driver.isKeyPressed(key_right))
			{
				blob.setVelocity(blob.getVelocity() + Vec2f(0.1, 0));
				if(blob.getVelocity().x > 1)
					blob.SetFacingLeft(false);
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
				if(driver !is null && !driver.isKeyPressed(key_down))
					partsp.SetAnimation("active");
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

	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{
		
	}
}


void onInit(CBlob@ this)
{
	CMechHover part();
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
