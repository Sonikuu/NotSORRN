#include "VehicleCommon.as"
#include "GenericButtonCommon.as"

// Mounted Bow logic

const Vec2f arm_offset = Vec2f(-6, 0);

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.31f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	
	
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
		sprite.SetZ(-10);
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused)
{
	
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return true;
}

