#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this){
	this.set_string("shop description","carve");
	InitWorkshop(this);
}


void InitWorkshop(CBlob@ this)
{	
	InitCosts();
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 3));

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", "An empty lantern to light the night", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
	}
	{
		ShopItem@ s = addShopItem(this,  "Wooden Sword", "$woodsword$", "woodsword", "Basic Wooden Sword", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements,"blob","log","Log",1);
		
		AddIconToken("$woodsword$", "WoodSword.png", Vec2f(24, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Dagger", "$dagger$", "dagger", "Dagger, for Stabbing", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
		
		AddIconToken("$dagger$", "Dagger.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Spear", "$spear$", "spear", "Poke people with murderous intent", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
		
		AddIconToken("$spear$", "PokingStick.png", Vec2f(32, 16), 0);
	}
}

void onTick(CBlob@ this){
	CBlob@ carrier = this.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();
	this.set_bool("shop disabled",carrier !is getLocalPlayerBlob());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop buy"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		bool spawnToInventory = params.read_bool();
		bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
		string blobName = params.read_string();
		u8 s_index = params.read_u8();

		// check spam
		//if (blobName != "factory" && isSpammed( blobName, this.getPosition(), 12 ))
		//{
		//}
		//else
		{
			this.getSprite().PlaySound("/ConstructShort");
		}
	}
}