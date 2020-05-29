#include "MechCommon.as";
#include "MechGunCommon.as";


void onInit(CBlob@ this)
{
	CMechSpoolGun part(0.2, 10, 10, 25.0, 15.0, 9, 0.5);
	setMechPart(this, @part);
}

void onTick(CBlob@ this)
{

}

void onTick(CSprite@ this)
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
