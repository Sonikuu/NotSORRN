
#include "EquipmentCore.as";
#include "Explosion.as";
#include "Hitters.as";
#include "CHealth.as";

class CEquipmentSlot
{
	string name;
	int type;
	CEquipmentSlot(string name, int type)
	{
		this.name = name;
		this.type = type;
	}
}

array<CEquipmentSlot@> equipslots = 
{
	CEquipmentSlot("primaryequip", 0),
	CEquipmentSlot("secondaryequip", 0),
	CEquipmentSlot("torsoequip", 1)
};

void onInit(CBlob@ this)
{
	this.addCommandID("equipitem");
	//this.addCommandID("vehicle getout");
	//this.addCommandID("partcommand");
	
	//CShapeManager manager();
	//this.set("shapemanager", @manager);
	
	//Render::addBlobScript(Render::layer_prehud, this, "Mech.as", "testFunc");
	for(int i = 0; i < equipslots.size(); i++)
	{
		this.set_u16(equipslots[i].name, 0xFFFF);
	}
	
	AddIconToken("$equip_button$", "AbilityIcons.png", Vec2f(16, 16), 3);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	for(int i = 0; i < equipslots.size(); i++)
	{
		CBlob@ equipped = null;
		if(blob.get_u16(equipslots[i].name) != 0xFFFF)
			@equipped = getBlobByNetworkID(blob.get_u16(equipslots[i].name));
		
		if(equipped is null)
			return;
		
		IEquipment@ equip = @getEquipment(equipped);
		if(equip !is null)
		{
			equip.onRender(equipped, blob);
		}
	}
}

void onTick(CBlob@ this)
{
	for(int i = 0; i < equipslots.size(); i++)
	{
		CBlob@ equipped = null;
		if(this.get_u16(equipslots[i].name) != 0xFFFF)
			@equipped = getBlobByNetworkID(this.get_u16(equipslots[i].name));
		
		if(equipped is null)
		{
			return;
		}
		
		IEquipment@ equip = @getEquipment(equipped);
		if(equip !is null)
		{
			equip.onTick(equipped, this);
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	for(int i = 0; i < equipslots.size(); i++)
	{
		CBlob@ equipped = null;
		if(blob.get_u16(equipslots[i].name) != 0xFFFF)
			@equipped = getBlobByNetworkID(blob.get_u16(equipslots[i].name));
		
		if(equipped is null)
			return;
		CSprite@ sprite = equipped.getSprite();
		IEquipment@ equip = @getEquipment(equipped);
		if(equip !is null)
		{
			equip.onTick(sprite, blob);
		}
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("equipitem"))
	{
		u8 slot = params.read_u8();
		u16 blobid = params.read_u16();
		CBlob@ carried = (blobid == 0xFFFF ? null : getBlobByNetworkID(blobid));
		
		CBlob@ blob = null;
		
		//equip.canBeEquipped()
		if(this.get_u16(equipslots[slot].name) != 0xFFFF)
			@blob = getBlobByNetworkID(this.get_u16(equipslots[slot].name));
			
		if(blob !is null)
		{
			unequipBlob(this, blob, slot);
		}
		
		if(carried !is null)
		{
			IEquipment@ equip = @getEquipment(carried);
			if(equip !is null)
			{
				equipBlob(this, carried, slot);
			}
		}
	}
}

void onDie(CBlob@ this)
{
	for(int i = 0; i < equipslots.size(); i++)
	{
		CBlob@ blob = null;
		if(this.get_u16(equipslots[i].name) != 0xFFFF)
			@blob = getBlobByNetworkID(this.get_u16(equipslots[i].name));
		if(blob !is null)
		{
			unequipBlob(this, blob, i);
		}
	}
}

void equipBlob(CBlob@ this, CBlob@ blob, u8 slot)
{
	this.set_u16(equipslots[slot].name, blob.getNetworkID());
	blob.set_u16("equipper", this.getNetworkID());
	//blob.server_DetachAll();
	blob.server_DetachFromAll();
	blob.setPosition(Vec2f(-999, -999));
	
	blob.set_bool("equipped", true);
	
	CShape@ shape = blob.getShape();
	shape.SetStatic(true);
	
	IEquipment@ equip = @getEquipment(blob);
	if(equip !is null)
	{
		equip.onEquip(blob, this);
	}

	recalculateHealth(this);
}

void unequipBlob(CBlob@ this, CBlob@ blob, u8 slot)
{ 
	blob.setPosition(this.getPosition());
	this.set_u16(equipslots[slot].name, 0xFFFF);
	
	blob.set_bool("equipped", false);
	
	CShape@ shape = blob.getShape();
	shape.SetStatic(false);
	
	IEquipment@ equip = @getEquipment(blob);
	if(equip !is null)
	{
		equip.onUnequip(blob, this);
	}

	recalculateHealth(this);
}

void recalculateHealth(CBlob@ this)
{
	float maxhealth = this.getInitialHealth();
	for(int i = 0; i < equipslots.size(); i++)
	{
		CBlob@ blob = null;
		if(this.get_u16(equipslots[i].name) != 0xFFFF)
			@blob = getBlobByNetworkID(this.get_u16(equipslots[i].name));
		if(blob !is null)
		{
			IEquipment@ equip = @getEquipment(blob);
			if(equip !is null)
			{
				maxhealth = equip.modifyHealth(blob, this, maxhealth);
			}
		}
	}
	this.set_f32("chealth", maxhealth);
}


void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	Vec2f ul = gridmenu.getUpperLeftPosition();
    Vec2f lr = gridmenu.getLowerRightPosition();

    Vec2f pos = Vec2f(lr.x, (ul.y + lr.y) / 2) + Vec2f(48, 0);
    CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(1, 2), "Equip");
    
    if (menu !is null)
    {
        menu.deleteAfterClick = true;
		menu.SetCaptionEnabled(true);
        {
			CBitStream params;
			params.write_u8(0);
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$equip_button$", "Equip Held item (Hand)", this.getCommandID("equipitem"), params);
        }
		{
			CBitStream params;
			params.write_u8(1);
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$equip_button$", "Equip Held item (Chest)", this.getCommandID("equipitem"), params);
        }
        
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	
}
