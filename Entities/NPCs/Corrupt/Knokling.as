
#include "CHitters.as";

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	this.Tag("corrupt");
	this.addCommandID("hitram");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	CShape@ shape = blob.getShape();
	
	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	
	Vec2f vel = blob.getVelocity();
	
	const bool isonground = blob.isOnGround();
	
	if(up && isonground)
	{
		vel.y += -2;
	}
	if(left)
	{
		if(isonground)
			vel.x += -0.20;
		else
			vel.x += -0.14;
	}
	if(right)
	{
		if(isonground)
			vel.x += 0.20;
		else
			vel.x += 0.14;
	}
	blob.setVelocity(vel);
}

void onTick(CBlob@ this)
{
	if(this.isKeyPressed(key_left))
		this.SetFacingLeft(true);
	else if(this.isKeyPressed(key_right))
		this.SetFacingLeft(false);
	
	if(this.isKeyJustPressed(key_action2) && !this.hasTag("attacking"))
	{
		this.setVelocity(this.getVelocity() + Vec2f(this.isFacingLeft() ? -5 : 5, -3));
		this.Tag("attacking");
		this.Tag("unprimed");
	}
	
	if(this.hasTag("attacking"))
	{
		if(this.isOnGround())
		{
			if(!this.hasTag("unprimed"))
			{
				this.Untag("attacking");
				this.setVelocity(this.getVelocity() / 2);
			}
		}
		else if(this.hasTag("unprimed"))
			this.Untag("unprimed");
	}
}

void onDie(CBlob@ this)
{
	//Spurt blood or something lel
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool output = true;
	if(blob.hasTag("flesh") && blob.getTeamNum() == this.getTeamNum())
		output = false;
	return output;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("hitram"))
	{
		//Hit the boi
		Vec2f hitvel = params.read_Vec2f();
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		
		if(blob !is null)
		{
			this.server_Hit(blob, blob.getPosition(), hitvel, 0.25, CHitters::corrupt, false);
			blob.setVelocity(blob.getVelocity() + hitvel * 2.5);
			this.setVelocity(hitvel * -4);
			this.Untag("attacking");
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null && solid)
	{
		if(this.hasTag("attacking") && !this.hasTag("unprimed"))
		{
			Vec2f hitvel = blob.getPosition() - this.getPosition();
			hitvel.Normalize();
			//CBitStream params;
			//params.write_Vec2f(hitvel);
			//params.write_u16(blob.getNetworkID());
			//this.SendCommand(this.getCommandID("hitram"), params);
			
			this.server_Hit(blob, blob.getPosition(), hitvel, 0.25, CHitters::corrupt, false);
			blob.setVelocity(blob.getVelocity() + hitvel * 2.5);
			this.setVelocity(hitvel * -4);
			this.Untag("attacking");
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == CHitters::pure)
		damage *= 4;
	return damage;
}





