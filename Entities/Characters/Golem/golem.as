#include "golemparticles.as"


void onInit(CBlob@ this){
	this.set_f32("jumpPower", 0);
		this.getSprite().SetEmitSound("GolemCharge.ogg");
	doParticleInit(this);
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
		this.setVelocity(Vec2f(this.getVelocity().x, (inWater ? -20 : -10) * (this.get_f32("jumpPower")/chargeTime) ));
		this.getSprite().SetEmitSoundPaused(true);
	}

	if(!this.isKeyPressed(key_up)){
		this.set_f32("jumpPower",0);
		this.getSprite().RewindEmitSound();
	}
}

void onTick(CSprite@ this){
	CBlob@ b = this.getBlob();

	if(b.get_f32("jumpPower") >= chargeTime){
		this.SetAnimation("charged");
	} else {
		this.SetAnimation("default");
	}
}