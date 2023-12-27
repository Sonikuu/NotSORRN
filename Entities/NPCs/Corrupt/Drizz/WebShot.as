
#include "CHitters.as";
#include "FxHookCommon.as";

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.4);
	this.Tag("spawn_protect");
}


void onTick(CBlob@ this)
{
	if(this.getTickSinceCreated() > 300)
		this.server_Die();
		
	if(this.getVelocity().Length() > 0.1)
		this.setAngleDegrees(this.getVelocity().getAngle() * -1);
}

void onDie(CBlob@ this)
{
	//Spurt blood or something lel
	ParticleAnimated("SpitSplat.png", this.getPosition(), getRandomVelocity(0, 0.5, 360.0f), 0, 1, 1, 0, false);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool output = false;
	if((blob.hasTag("flesh") && blob.getTeamNum() != this.getTeamNum()) || blob.hasTag("solid"))
		output = true;
	return output;
}

/*bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}*/

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(solid)
	{
		
		if(blob !is null)
		{
			this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 0.25, CHitters::corrupt, false);
			applyFx(blob, 90, 25, "fxwebbed");
		}
		this.server_Die();
	}
	/*if(blob !is null && solid)
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
	}*/
}

//f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
//{
	//if(customData == CHitters::pure)
	//	damage *= 4;
//	return damage;
//}





