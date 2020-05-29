#include "MechCommon.as";
#include "MechGunCommon.as";


void onInit(CBlob@ this)
{
	CMechGun part(2.0, 10, 1, 10.0, 8.0);
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
