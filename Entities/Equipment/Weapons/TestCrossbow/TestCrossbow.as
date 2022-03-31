#include "EquipmentCore.as";
#include "EquipmentGunCommon.as";


void onInit(CBlob@ this)
{
	CGunEquipment part(2.0, 5, 1, 2.0);
	part.projname = "crossbolt";
	part.projectile = true;
	part.maxammo = 1;
	part.ammotype = "mat_arrows";
	part.reloadtime = 20;
	part.semi = true;
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
