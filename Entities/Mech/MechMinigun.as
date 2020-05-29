#include "MechCommon.as";
#include "MechGunCommon.as";


void onInit(CBlob@ this)
{
	CMechSpoolGun part(1, 30, 1, 10.0, 5.0, 29, 3);
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


