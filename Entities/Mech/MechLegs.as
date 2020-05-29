#include "MechCommon.as";

shared class CMechLegs : CMechCore
{
	int jumptime;
	CMechLegs()
	{
		jumptime = 0;
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		jumptime--;
		if(driver !is null)
		{
			//No heat cost for this boi, cause he's pretty lame
			if(driver.isKeyPressed(key_left))
			{
				blob.setVelocity(blob.getVelocity() + Vec2f(blob.isOnGround() ? -0.4 : Maths::Min(-0.1, -0.06 * jumptime), 0));
				if(blob.getVelocity().x < -1)
					blob.SetFacingLeft(true);
			}
			if(driver.isKeyPressed(key_right))
			{
				blob.setVelocity(blob.getVelocity() + Vec2f(blob.isOnGround() ? 0.4 : Maths::Max(0.1, 0.06 * jumptime), 0));
				if(blob.getVelocity().x > 1)
					blob.SetFacingLeft(false);
			}
			if(driver.isKeyPressed(key_up) && blob.isOnGround() && jumptime < 0)
			{
				jumptime = 9;
				blob.setVelocity(blob.getVelocity() + Vec2f(0, -3));
			}
			else if(driver.isKeyPressed(key_up) && jumptime >= 0)
			{
				if(jumptime < 3)
				{
					blob.setVelocity(blob.getVelocity() + Vec2f(0, -0.4));
				}
				else if(jumptime < 6)
				{
					blob.setVelocity(blob.getVelocity() + Vec2f(0, -0.8));
				}
				else if(jumptime < 9)
				{
					blob.setVelocity(blob.getVelocity() + Vec2f(0, -1.2));
				}
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
				if(!blob.isOnGround())
					partsp.SetAnimation("midair");
				else if(driver !is null && (driver.isKeyPressed(key_left) || driver.isKeyPressed(key_right)))
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
		CShapeManager@ manager;
		blob.get("shapemanager", @manager);
		if(manager !is null)
		{
			CShape@ shape = blob.getShape();
			shape.SetRotationsAllowed(false);
			blob.setAngleDegrees(0);

			Vec2f[] newshape(4);
			newshape[0] = Vec2f(4, 32);
			newshape[1] = Vec2f(28, 32);
			newshape[2] = Vec2f(28, 48);
			newshape[3] = Vec2f(4, 48);
			shapeName = manager.addShape(shape, newshape, "mechlegs");
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
					shape.SetRotationsAllowed(true);
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
	CMechLegs part();
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
