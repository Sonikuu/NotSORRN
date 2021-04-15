#include "EquipmentCore.as";
#include "EquipmentGunBladeCommon.as";




void onInit(CBlob@ this)
{
	//					Damage, Range, ChargeTime, Knockback, Jab only, Jab cooldown, Slash cooldown, Lunge speed
	CGunBladeEquipment part(1.0, 	44, 	25, 		2, 		false, 	10, 				6, 				4);
	//Should be able to do everything you wany by just modifying the values above
	
	part.spriteoffset = Vec2f(8, 6);
	part.gun.spriteoffset = Vec2f(8, 6);
	part.spritescale = 0.5;
	part.gun.spritescale = 0.5;
	
	part.gun.tracerwidth = 2;
	part.gun.tracercolor = SColor(255, 150, 255, 255);
	part.gun.kick = 15;
	
	setEquipment(this, @part);
	this.addCommandID("partcmd");
	this.set_bool("equipped", false);
	
	
}

void onInit(CSprite@ this)
{
	this.ScaleBy(Vec2f(0.5, 0.5));
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
