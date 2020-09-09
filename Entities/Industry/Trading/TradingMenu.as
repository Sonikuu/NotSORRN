// Trading Post

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("can settle"); //for DieOnCollapse to prevent 2 second life :)

	InitTrader(this);
}


void InitTrader(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(3, 4));
	this.set_string("shop description", "Trading Post");
	this.set_u8("shop icon", 25);

	/*{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::lantern_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::sponge_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::trampoline_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::crate_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", WARCosts::drill_stone);
		//AddRequirement(s.requirements, "tech", "drill", "Drill Technology");
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::saw_wood);
		//AddRequirement(s.requirements, "tech", "saw", "Saw Technology");
	}
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", Descriptions::dinghy, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::dinghy_wood);
		//AddRequirement(s.requirements, "tech", "dinghy", "Dinghy Technology");
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", WARCosts::boulder_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Gunpowder", "$mat_gunpowder$", "mat_gunpowder-50", "Explosive gunpowder... for explosives", false);
		AddRequirement(s.requirements, "blob", "mat_sand", "Sand", 25);
		AddRequirement(s.requirements, "blob", "mat_charcoal", "Charcoal", 25);
		
		AddIconToken("$mat_gunpowder$", "MaterialGunpowder.png", Vec2f(16, 16), 3);
		AddIconToken("$mat_sand$", "MaterialSand.png", Vec2f(16, 16), 3);
		AddIconToken("$mat_charcoal$", "MaterialCharcoal.png", Vec2f(16, 16), 3);
	}*/
	{
		ShopItem@ s = addShopItem(this, "Diffuser Recipe", "$recipe$", "recipe-0", "Basic recipe for diffuser", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Furnace Recipe", "$recipe$", "recipe-1", "Instructions on constructing a furnace", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Mixer Recipe", "$recipe$", "recipe-2", "Random mixer recipe", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Furnace Recipe", "$recipe$", "recipe-3", "Random furnace recipe", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Common Seed", "$seed$", "seed", "Random common crop seed", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Cheddar Cheese", "$cheddar$", "cheddar", "Cheddar Cheese", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Swiss Cheese", "$swiss$", "swiss", "Swiss Cheese", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 20);
	}
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
			this.getSprite().PlaySound("/ChaChing.ogg");
		}
	}
}