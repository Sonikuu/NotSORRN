#include "EquipmentCore.as";
#include "EquipmentGunCommon.as";


void onInit(CBlob@ this)
{
	CGunEquipment part(0.30, 4, 1, 8.0);
	
	part.spriteoffset = Vec2f(0, 1.25);
	part.tracercolor = SColor(255, 150, 255, 255);
	part.tiledamagechance = 0.5;
	
	setEquipment(this, @part);
	this.addCommandID("partcmd");
	this.set_bool("equipped", false);
}

void onTick(CBlob@ this)
{
	if(this.get_bool("equipped"))
	{
		this.server_DetachFromAll();
		this.setPosition(Vec2f(-999, -999));
	}
}

void onTick(CSprite@ this)
{
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("partcmd"))
	{
		IEquipment@ equip = getEquipment(this);
		u32 bits = params.read_u32();
		CBlob@ holder = getBlobByNetworkID(this.get_u16("equipper"));
		if(equip !is null)
			bits = equip.onCommand(this, holder, bits, params);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("flesh"))
		return false;
	return true;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	if(this.get_bool("equipped"))
		return false;
	return true;
}
