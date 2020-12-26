
void onInit(CBlob@ this){
	this.set_f32("jumpPower", 0);
}

const f32 speed = 0.5;
const f32 chargeTime = 15;

void onTick(CBlob@ this){

	int airTime = this.getAirTime();

	if(airTime < 7 || this.isInWater()){
		bool h = false;
		if(this.isKeyPressed(key_left)){
			this.setVelocity(this.getVelocity() + Vec2f(-speed,0));
			h = true;
		}
		if(this.isKeyPressed(key_right)){
			this.setVelocity(this.getVelocity() + Vec2f(speed,0));
			h = true;
		}

		if(h && this.isOnWall() && (airTime < 3)){
			this.setVelocity(this.getVelocity() + Vec2f(0,-1));
		}

		if(this.isKeyPressed(key_up) || this.isKeyPressed(key_down)){
			this.set_f32("jumpPower",Maths::Clamp(this.get_f32("jumpPower") + 1,0, chargeTime));
		}

		if(this.isKeyJustReleased(key_up) && (airTime < 3)){
			this.setVelocity(this.getVelocity() + Vec2f(0,-10 * (this.get_f32("jumpPower")/chargeTime)));
		}

		if(!this.isKeyPressed(key_up)){
			this.set_f32("jumpPower",0);
		}
	}
}