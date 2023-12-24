#include "Hitters.as"
#include "ExplosionCommon.as"

void onInit(CBlob@ this)
{
	//Make this emit particles eventually
	this.getShape().SetRotationsAllowed(true);
	this.getShape().SetGravityScale(0);
	this.SetLightColor(SColor(255, 128, 10, 128));
	this.SetLightRadius(36.0f);
	this.SetLight(true);
	this.Tag("corrupt");
	this.setVelocity(Vec2f(0, -4));
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(getGameTime() % 1 == 0)
	{
		CParticle@ p = ParticlePixel(blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), Vec2f(XORRandom(16) - 8, XORRandom(16) - 8) / 16.0, SColor(255, 128 + XORRandom(50), 50 + XORRandom(25), 128 + XORRandom(50)), true, 60);
		if(p !is null)
			p.gravity = Vec2f_zero;
	}

	
}

void onTick(CBlob@ this)
{
	float ang = (this.get_Vec2f("target") - this.getPosition()).Angle();
	this.setAngularVelocity(5);
	this.setVelocity(this.getVelocity() + Vec2f_lengthdir_deg(0.1, ang * -1));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

//radius 48, damage 3, sound Bomb.ogg, map radius 24, map ratio 0.4
				//Explode(user, endpos, range * 0.1, damage, "Bomb.ogg", range * 0.05, damage * 0.4, true, Hitters::explosion, true);

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	//if(solid && (this.getVelocity().Length() > 1.0 || (blob !is null && blob.getVelocity().Length() > 1.0)))
	if(this.getTickSinceCreated() > 30 && (solid || !blob.hasTag("corrupt")))
	{
		this.server_Die();
	}
}



void onDie(CBlob@ this)
{
	Explode(this, this.getPosition(), 48, 2.5, "Bomb.ogg", 48, 0.5, true, Hitters::explosion, true, false, true);
}
