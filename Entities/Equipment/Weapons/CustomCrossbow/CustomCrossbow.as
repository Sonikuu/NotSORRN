#include "EquipmentCore.as";
#include "EquipmentGunCommon.as";
#include "CustomCrossbowCommon.as";

void onInit(CBlob@ this)
{
	//Setting stats for CGun will be simple, create gun with noInit, set netvars, then init
	//Calc stats based on parts, maybe in a certain order?
	//But how will unique sprite for each gun be done?
	//How many different parts?
	//AAAAA
	//There needs to be a core part, determines base stats and maybe firing style/ammo?
	//from there maybe a barrel, stock, grip?
	//and then some optional parts?
	//might also be able to have diffent loading styles, like pumpaction, belt fed, magazine, or maybe energy based?
	//load style maybe should be based on core
	//want to be able to have fire style and ammo separate...
	//CGunEquipment part(0.30, 4, 1, 8.0);
	buildGun(this);
	this.set_u16("ammo", 0);
	//part.spriteoffset = Vec2f(0, 1.25);
	//part.tracercolor = SColor(255, 150, 255, 255);
	//part.tiledamagechance = 0.5;
	
	//setEquipment(this, @part);
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
