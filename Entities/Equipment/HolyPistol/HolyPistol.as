#include "EquipmentCore.as";
#include "EquipmentGunCommon.as";

class CHolyPistolMod : CDamageModCore
{
	CHolyPistolMod(string name)
	{
		this.name = name;
	}
	f32 damageMod(CBlob@ this, CBlob@ blob, f32 damage, u8 customdata)
	{
		if(blob.hasTag("corrupt"))
			damage *= 4;
		return damage;
	}
}

class CHolyPistolEquipment : CGunEquipment
{
	CHolyPistolEquipment(float damage = 2.0, int firerate = 10, int shotcount = 1, float spread = 10.0)
	{
		super(damage, firerate, shotcount, spread);
	}

	void onEquip(CBlob@ blob, CBlob@ user)
	{
		addDamageMod(user, @holypistolmod);
		CGunEquipment::onEquip(blob, user);
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{	
		removeDamageMod(user, @holypistolmod);
		CGunEquipment::onUnequip(blob, user);
	}
}


CHolyPistolMod holypistolmod("holypistolmod");


void onInit(CBlob@ this)
{
	CHolyPistolEquipment part(0.5, 10, 1, 4.0);
	
	part.spriteoffset = Vec2f(0, 1.25);
	part.tracercolor = SColor(255, 255, 255, 200);
	part.hittype = CHitters::pure;
	
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
