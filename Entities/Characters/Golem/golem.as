#include "golemparticles.as"


void onInit(CBlob@ this){
	this.set_f32("jumpPower", 0);
		this.getSprite().SetEmitSound("GolemCharge.ogg");
}

const f32 speed = 0.5;
const f32 chargeTime = 30;

void onTick(CBlob@ this){

	int airTime = this.getAirTime();
	bool onGround = this.isOnGround();
	bool inWater = this.isInWater();

	f32 eSpeed = onGround ? speed : speed/2;

	bool h = false;
	if(this.isKeyPressed(key_left)){
		this.setVelocity(this.getVelocity() + Vec2f(-eSpeed,0));
		h = true;
	}
	if(this.isKeyPressed(key_right)){
		this.setVelocity(this.getVelocity() + Vec2f(eSpeed,0));
		h = true;
	}

	if(h && this.isOnWall() && (airTime < 3)){
		this.setVelocity(this.getVelocity() + Vec2f(0,-1));
	}

	if(this.isKeyPressed(key_up) && (airTime < 7 || inWater)){
		this.getSprite().SetEmitSoundPaused(this.get_f32("jumpPower") >= chargeTime);
		doParticlesPassive(this);
		this.set_f32("jumpPower",Maths::Clamp(this.get_f32("jumpPower") + 1,0, chargeTime));
	}

	if(this.isKeyJustReleased(key_up)){
		this.setVelocity(Vec2f(this.getVelocity().x, this.get_f32("jumpPower") < 5 ? this.getVelocity().y : 0 +  (inWater ? -20 : -10) * (this.get_f32("jumpPower")/chargeTime) ));
		this.getSprite().SetEmitSoundPaused(true);
		doParticlesJump(this);
	}

	if(!this.isKeyPressed(key_up)){
		this.set_f32("jumpPower",0);
		this.getSprite().RewindEmitSound();
	}
}

void onTick(CSprite@ this){
	CBlob@ b = this.getBlob();

	if(b.getPlayer() is null){
		this.SetAnimation("soulless");
	}
	else if(b.get_f32("jumpPower") >= chargeTime){
		this.SetAnimation("charged");
	} else {
		this.SetAnimation("default");
	}


	if(!b.get_bool("onGroundLastTick") && b.isOnGround() && b.get_Vec2f("lastVelocity").y > 4){
		f32 shakeValue = Maths::Clamp(150.0f * (b.get_Vec2f("lastVelocity").y/16.0f),0,300);
		ShakeScreen(shakeValue, 30, b.getPosition());
		this.PlaySound("StoneFall1.ogg",2);
		MakeDustParticle(b.getPosition(),"dust" + (XORRandom(2) == 1 ? "2" : "") + ".png");
	}

	b.set_Vec2f("lastVelocity",b.getVelocity());
	b.set_bool("onGroundLastTick",b.isOnGround());	
}

void MakeDustParticle(Vec2f pos, string file)
{
	CParticle@ temp = ParticleAnimated(file, pos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

	if (temp !is null)
	{
		temp.width = 8;
		temp.height = 8;
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){
	return this.getPlayer() is null &&
	((this.getTeamNum() > 7 && byBlob.getTeamNum() > 7) || this.getTeamNum() == byBlob.getTeamNum());
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){
	this.getSprite().PlaySound("rock_hit.ogg");

	return damage;
}
void onDie(CBlob@ this){
	this.getSprite().Gib();
}

void doParticlesPassive(CBlob@ this){
	if(getGameTime() %2 != 0){
		return;
	}

	Vec2f particlePos = this.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4) * 2;
	Vec2f thisPos = this.getPosition();
	Vec2f norm = (particlePos - thisPos);
	norm.Normalize();


	CParticle@ p = ParticleAnimated("lum.png",particlePos, Vec2f(XORRandom(10) - 5 * norm.x, XORRandom(10) - 10 *norm.y) / 60.0, 0, 1.0 / 16.0, 0, 0, Vec2f(64, 64), 1, -0.002, true);

	if(p !is null)
	{
		p.damping = 0.98;
		p.animated = 40;
		p.growth = -0.0005;
		p.colour = SColor(255,255,255,255);

		p.setRenderStyle(RenderStyle::light);

	}
}

void doParticlesJump(CBlob@ this){
	f32 jumpPower = this.get_f32("jumpPower");
	f32 pCharged = jumpPower/chargeTime;

	for(int i = 0; i < (pCharged * 10); i++ ){
		Vec2f particlePos = this.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4) * 2;

		CParticle@ p = ParticleAnimated("lum.png",particlePos, Vec2f(0,XORRandom(3) + 3), 0, 1.0 / 16.0, 0, 0, Vec2f(64, 64), 1, -0.002, true);

		if(p !is null)
		{
			p.fastcollision = true;
			p.diesoncollide = true;
			p.damping = 0.98;
			p.animated = 40;
			p.growth = -0.0005;
			p.colour = SColor(255,255,255,255);

			p.setRenderStyle(RenderStyle::light);

		}
	}
}