#include "EquipmentCore.as";
#include "EquipmentSprayerCommon.as";


void onInit(CBlob@ this)
{
	CSprayerEquipment part(10, 0.0, 60, 128);
	
	part.spriteoffset = Vec2f(0, 1.25);
	
	CAlchemyTank@ tank = addTank(this, "input", true, Vec2f(0, 0));
	tank.maxelements = 100;
	tank.singleelement = true;
	tank.dynamictank = true;
	
	setEquipment(this, @part);
	this.addCommandID("partcmd");
	this.set_bool("equipped", false);
	
	this.getShape().getConsts().mapCollisions = true;
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
