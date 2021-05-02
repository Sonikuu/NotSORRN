
#include "EquipmentCore.as";
#include "Explosion.as";
#include "Hitters.as";
#include "CHealth.as";

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
	
	AddIconToken("$hand_equip_button$", "AbilityIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$chest_equip_button$", "AbilityIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$boots_equip_button$", "AbilityIcons.png", Vec2f(16, 16), 2);
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
			continue;
		
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
			continue;
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
				if(equip.canBeEquipped(slot))
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
	IEquipment@ equip = @getEquipment(blob);
	if(equip !is null && slot == 1 && equip.isTwoHand())
	{
		slot = 0;
		if(this.get_u16(equipslots[slot].name) != 0xFFFF)//Quick fix
		{
			CBlob@ tempblob = getBlobByNetworkID(this.get_u16(equipslots[slot].name));
			if(tempblob !is null)
				unequipBlob(this, tempblob, slot);
		}
	}

	this.set_u16(equipslots[slot].name, blob.getNetworkID());
	blob.set_u16("equipper", this.getNetworkID());
	//blob.server_DetachAll();
	blob.server_DetachFromAll();
	blob.setPosition(Vec2f(-999, -999));
	
	blob.set_bool("equipped", true);
	
	CShape@ shape = blob.getShape();
	shape.SetStatic(true);
	
	
	if(equip !is null)
	{
		//Dual handed special cases
		if(slot == 0 && equip.isTwoHand())
		{
			CBlob@ secondhand = null;
			if(this.get_u16(equipslots[1].name) != 0xFFFF)
				@secondhand = getBlobByNetworkID(this.get_u16(equipslots[1].name));
			if(secondhand !is null)
			{
				unequipBlob(this, secondhand, 1);
			}
		}
		else if(slot == 1)
		{
			CBlob@ firsthand = null;
			if(this.get_u16(equipslots[0].name) != 0xFFFF)
				@firsthand = getBlobByNetworkID(this.get_u16(equipslots[0].name));
			if(firsthand !is null && getEquipment(firsthand) !is null && getEquipment(firsthand).isTwoHand())
			{
				unequipBlob(this, firsthand, 0);
			}
		}
		equip.onEquip(blob, this);
		equip.setAttachPoint(slot);
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
    CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(1, 4), "Equip");

	CBlob@ carried = this.getCarriedBlob();
	IEquipment@ equip = carried is null ? null : @getEquipment(carried);
    
    if (menu !is null)
    {
        menu.deleteAfterClick = true;
		menu.SetCaptionEnabled(true);
        {
			CBitStream params;
			params.write_u8(0);
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$hand_equip_button$", "Equip Held item (Hand)", this.getCommandID("equipitem"), params);

			if(equip !is null)
			{
				if(!equip.canBeEquipped(0))
					button.SetEnabled(false);
			}
        }
		{
			CBitStream params;
			params.write_u8(1);
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$hand_equip_button$", "Equip Held item (Hand)", this.getCommandID("equipitem"), params);

			if(equip !is null)
			{
				if(!equip.canBeEquipped(1))
					button.SetEnabled(false);
			}
        }
		{
			CBitStream params;
			params.write_u8(2);
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$chest_equip_button$", "Equip Held item (Chest)", this.getCommandID("equipitem"), params);

			if(equip !is null)
			{
				if(!equip.canBeEquipped(2))
					button.SetEnabled(false);
			}
        }
		{
			CBitStream params;
			params.write_u8(3);
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$boots_equip_button$", "Equip Held item (Boots)", this.getCommandID("equipitem"), params);

			if(equip !is null)
			{
				if(!equip.canBeEquipped(3))
					button.SetEnabled(false);
			}
        }
        
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	
}
