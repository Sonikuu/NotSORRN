
#include "EquipmentCore.as";
#include "Explosion.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.addCommandID("equipitem");
	//this.addCommandID("vehicle getout");
	//this.addCommandID("partcommand");
	
	//CShapeManager manager();
	//this.set("shapemanager", @manager);
	
	//Render::addBlobScript(Render::layer_prehud, this, "Mech.as", "testFunc");
	this.set_u16("primaryequip", 0xFFFF);
	
	AddIconToken("$equip_button$", "AbilityIcons.png", Vec2f(16, 16), 3);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	CBlob@ equipped = null;
	if(blob.get_u16("primaryequip") != 0xFFFF)
		@equipped = getBlobByNetworkID(blob.get_u16("primaryequip"));
	
	if(equipped is null)
		return;
	
	IEquipment@ equip = @getEquipment(equipped);
	if(equip !is null)
	{
		equip.onRender(equipped, blob);
	}
}

void onTick(CBlob@ this)
{
	CBlob@ equipped = null;
	if(this.get_u16("primaryequip") != 0xFFFF)
		@equipped = getBlobByNetworkID(this.get_u16("primaryequip"));
	
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

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	CBlob@ equipped = null;
	if(blob.get_u16("primaryequip") != 0xFFFF)
		@equipped = getBlobByNetworkID(blob.get_u16("primaryequip"));
	
	if(equipped is null)
		return;
	CSprite@ sprite = equipped.getSprite();
	IEquipment@ equip = @getEquipment(equipped);
	if(equip !is null)
	{
		equip.onTick(sprite, blob);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("equipitem"))
	{
		u16 blobid = params.read_u16();
		CBlob@ carried = (blobid == 0xFFFF ? null : getBlobByNetworkID(blobid));
		
		CBlob@ blob = null;
		if(this.get_u16("primaryequip") != 0xFFFF)
			@blob = getBlobByNetworkID(this.get_u16("primaryequip"));
		if(blob !is null)
		{
			unequipBlob(this, blob);
		}
		
		if(carried !is null)
		{
			equipBlob(this, carried);
		}
	}
}

void onDie(CBlob@ this)
{
	CBlob@ blob = null;
	if(this.get_u16("primaryequip") != 0xFFFF)
		@blob = getBlobByNetworkID(this.get_u16("primaryequip"));
	if(blob !is null)
	{
		unequipBlob(this, blob);
	}
}

void equipBlob(CBlob@ this, CBlob@ blob)
{
	this.set_u16("primaryequip", blob.getNetworkID());
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
}

void unequipBlob(CBlob@ this, CBlob@ blob)
{ 
	
	
	blob.setPosition(this.getPosition());
	this.set_u16("primaryequip", 0xFFFF);
	
	blob.set_bool("equipped", false);
	
	CShape@ shape = blob.getShape();
	shape.SetStatic(false);
	
	IEquipment@ equip = @getEquipment(blob);
	if(equip !is null)
	{
		equip.onUnequip(blob, this);
	}
}


void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	Vec2f ul = gridmenu.getUpperLeftPosition();
    Vec2f lr = gridmenu.getLowerRightPosition();

    Vec2f pos = Vec2f(lr.x, (ul.y + lr.y) / 2) + Vec2f(48, 0);
    CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(1, 1), "Equip");
    
    if (menu !is null)
    {
        menu.deleteAfterClick = true;
		menu.SetCaptionEnabled(true);
        {
			CBitStream params;
			params.write_u16(this.getCarriedBlob() is null ? 0xFFFF : this.getCarriedBlob().getNetworkID());
            CGridButton@ button = menu.AddButton("$equip_button$", "Equip Held item", this.getCommandID("equipitem"), params);
        }
        
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	
}
