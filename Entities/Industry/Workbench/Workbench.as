// Workbench

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
	this.Tag("builder always hit");
	InitWorkshop(this);
}


void InitWorkshop(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(7, 8));

	//-----Temporarily readded because i dun wanna fix log crafting
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", "An empty lantern to light the night", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
	}
	//---------------Log crafting end--------------
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
	}
	{
		ShopItem@ s = addShopItem(this,  "Alchemical Drill", "$alchemydrill$", "alchemydrill", "Can be fed essence to improve some aspects\nAqua increases cooling speed\nTerra allows the drill to get additional materials from a tile\nForce increases drill speed", false);
		AddRequirement(s.requirements, "blob", "drill", "Drill", 1);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 8);
		
		AddIconToken("$alchemydrill$", "AlchemicDrill.png", Vec2f(32, 16), 0);
		AddIconToken("$mat_metal$", "MaterialMetal.png", Vec2f(16, 16), 3);
	}
	{
		ShopItem@ s = addShopItem(this,  "Alchemical Battery", "$alchemybattery$", "alchemybattery", "Portable essence storage\nStores 200 essence", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 3);
		
		AddIconToken("$alchemybattery$", "AlchemyBattery.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Alchemical Spray Gun", "$essencesprayer$", "essencesprayer", "Uses essence to manipulate a cone in front of the user\nNeeds to be equipped", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 10);
		
		AddIconToken("$essencesprayer$", "EssenceSprayer.png", Vec2f(32, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Alchemic Eraser", "$alchemyeraser$", "alchemyeraser", "Interact with tanks while holding this to empty them of their essence", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		
		AddIconToken("$alchemyeraser$", "AlchemyEraser.png", Vec2f(8, 8), 0);
	}
	/*{
		ShopItem@ s = addShopItem(this,  "Ammo x10", "$mat_ammo$", "mat_ammo-10", "Basic ammo for basic guns", false);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 10);
		AddRequirement(s.requirements, "blob", "mat_metal", "Metal", 1);
		
		AddIconToken("$mat_ammo$", "MaterialAmmo.png", Vec2f(16, 16), 3);
	}
	{
		ShopItem@ s = addShopItem(this,  "Piercing Ammo x10", "$mat_pierceammo$", "mat_pierceammo-10", "Piercing ammo for piercing magazines", false);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 10);
		AddRequirement(s.requirements, "blob", "mat_metal", "Metal", 1);
		AddRequirement(s.requirements, "blob", "mat_glass", "Glass", 10);
		
		AddIconToken("$mat_pierceammo$", "MaterialPierceAmmo.png", Vec2f(16, 16), 3);
		AddIconToken("$mat_glass$", "MaterialGlass.png", Vec2f(16, 16), 3);
	}
	{
		ShopItem@ s = addShopItem(this,  "Explosive Ammo x10", "$mat_explosiveammo$", "mat_explosiveammo-10", "Explosive ammo for explosive magazines", false);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 10);
		AddRequirement(s.requirements, "blob", "mat_metal", "Metal", 1);
		AddRequirement(s.requirements, "blob", "blazecore", "Blaze Core", 1);
		
		AddIconToken("$mat_explosiveammo$", "MaterialExplosiveAmmo.png", Vec2f(16, 16), 3);
		AddIconToken("$blazecore$", "BlazeCore.png", Vec2f(8, 8), 0);
	}*/
	/*{
		ShopItem@ s = addShopItem(this,  "Ammo Pack", "$ammopack$", "ammopack", "Basic ammo for basic guns", false);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 25);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 2);
		
		AddIconToken("$ammopack$", "AmmoPack.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Piercing Ammo Pack", "$piercingammopack$", "piercingammopack", "Piercing ammo for piercing guns", false);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 25);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 2);
		AddRequirement(s.requirements, "blob", "mat_glass", "Glass", 25);
		
		AddIconToken("$piercingammopack$", "PiercingAmmoPack.png", Vec2f(16, 16), 0);
		AddIconToken("$mat_glass$", "MaterialGlass.png", Vec2f(16, 16), 3);
	}
	{
		ShopItem@ s = addShopItem(this,  "Explosive Ammo Pack", "$explosiveammopack$", "explosiveammopack", "Explosive ammo for explosive guns", false);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 50);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 2);
		AddRequirement(s.requirements, "blob", "blazecore", "Blaze Core", 1);
		
		AddIconToken("$explosiveammopack$", "ExplosiveAmmoPack.png", Vec2f(16, 16), 0);
		AddIconToken("$blazecore$", "BlazeCore.png", Vec2f(8, 8), 0);
	}*/
	
	/*{
		ShopItem@ s = addShopItem(this, "Soul Dust", "$souldust$", "souldust-3", "Smash a soul shard into dust", false);
		AddRequirement(s.requirements, "blob", "soul_chunk", "Soul Chunk", 1);
		
		AddIconToken("$soul_chunk$", "GhostShard.png", Vec2f(8, 8), 0);
		AddIconToken("$souldust$", "Souldust.png", Vec2f(16, 16), 0);
	}*/
	{
		ShopItem@ s = addShopItem(this,  "Track Platform", "$railplatform$", "railplatform", "A platform that will move around on placed tracks", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 2);
		
		AddIconToken("$log$", "Log.png", Vec2f(16, 16), 0);
		AddIconToken("$railplatform$", "RailPlatform.png", Vec2f(32, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Track Drill", "$raildrill$", "raildrill", "A drill that will automatically activate and move around on a track", false);
		AddRequirement(s.requirements, "blob", "drill", "Drill", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		
		AddIconToken("$raildrill$", "RailDrill.png", Vec2f(32, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Item Sucker", "$itemsucker$", "itemsucker", "Will automatically pick up any materials nearby\nRides tracks", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_component", "Components", 4);
		
		AddIconToken("$itemsucker$", "ItemSucker.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Mechanical Components", "$mat_component$", "mat_component-1", "A crude component made from stone", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		
		AddIconToken("$mat_component$", "MaterialComponents.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Mechanical Components", "$mat_component1$", "mat_component-4", "Metallic components for machinery", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Metal", 1);
		
		AddIconToken("$mat_component1$", "MaterialComponents.png", Vec2f(16, 16), 1);
	}
	{
		ShopItem@ s = addShopItem(this,  "Element Vial", "$vial$", "vial", "An element holding vial, looks fragile but sturdy enough to drink from ", false);
		AddRequirement(s.requirements, "blob", "mat_glass", "Glass", 30);
		
		AddIconToken("$vial$", "vial.png", Vec2f(8, 8), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Golemite Dust", "$golemitedust$", "golemitedust", "A mysterious substance that wiggles when you touch it", false);
		AddRequirement(s.requirements, "blob", "mat_purifiedgold", "Purified Gold", 1);
		AddRequirement(s.requirements, "blob", "mat_sand", "Sand", 250);
		
		AddIconToken("$golemitedust$", "GolemiteDust.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Mine", "$mine$", "mine", "Trap explosive", false);
		AddRequirement(s.requirements, "blob", "mat_component", "Mechanical Components", 2);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 100);
		
		AddIconToken("$mine$", "Mine.png", Vec2f(16, 16), 1);
	}
	{
		ShopItem@ s = addShopItem(this,  "Keg", "$keg$", "keg", "Barrel full of gunpowder", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 250);
	}
	{
		ShopItem@ s = addShopItem(this,  "Bomb", "$mat_bombs$", "mat_bombs", "It's a bomb", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 25);
	}
	{
		ShopItem@ s = addShopItem(this,  "Golem", "$golem$", "golem", "A mechanical device that might be able to be controled", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
		AddRequirement(s.requirements, "blob", "mat_purifiedgold", "Purified Gold", 2);

		AddIconToken("$golem$", "golem.png", Vec2f(16, 16), 0);
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
			this.getSprite().PlaySound("/ConstructShort");
		}
	}
}

//sprite - planks layer

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(6);
		planks.SetOffset(Vec2f(3.0f, -7.0f));
		planks.SetRelativeZ(-100);
	}
}
