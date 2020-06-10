#include "Hitters.as"
#include "ExplosionCommon.as"

void onInit(CBlob@ this)
{
	//Make this emit particles eventually
	this.getShape().SetRotationsAllowed(true);
	this.SetLightColor(SColor(255, 252, 86, 10));
	this.SetLightRadius(24.0f);
	this.SetLight(true);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(getGameTime() % 1 == 0)
	{
		CParticle@ p = ParticlePixel(blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), Vec2f(XORRandom(16) - 8, XORRandom(16) - 8) / 16.0, SColor(255, 200 + XORRandom(50), 100 + XORRandom(50), 50 + XORRandom(25)), true, 60);
		if(p !is null)
			p.gravity = Vec2f_zero;
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.hasTag("flesh") || !this.isOnGround())
		return true;
	return false;
}

//radius 48, damage 3, sound Bomb.ogg, map radius 24, map ratio 0.4
				//Explode(user, endpos, range * 0.1, damage, "Bomb.ogg", range * 0.05, damage * 0.4, true, Hitters::explosion, true);

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(solid && (this.getVelocity().Length() > 1.0 || (blob !is null && blob.getVelocity().Length() > 1.0)))
	{
		this.server_Hit(this, this.getPosition(), Vec2f_zero, 1.0, Hitters::fall, true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData != Hitters::explosion)
	{
		Explode(this, this.getPosition(), 24, 2.5, "Bomb.ogg", 16, 1.0, true, Hitters::explosion, true);
		Random rand(this.getNetworkID() + this.getHealth());
		this.setVelocity(Vec2f((rand.NextFloat() - 0.5) * (Maths::Abs(this.getOldVelocity().y) + 4) * 4, (rand.NextFloat() - 0.5) * 4) + Vec2f(0, (this.getOldVelocity().y + 4.0) * -1) * 1.5);
	}
	else
	{
		this.setVelocity(this.getVelocity() + velocity * 0.5);
	}
	return damage;
}
