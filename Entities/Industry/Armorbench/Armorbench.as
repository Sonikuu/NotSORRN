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
		ShopItem@ s = addShopItem(this,  "Wooden Sword", "$woodsword$", "woodsword", "Basic Wooden Sword\nMust be equipped", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements,"blob","log","Log",1);
		
		AddIconToken("$woodsword$", "WoodSword.png", Vec2f(24, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Dagger", "$dagger$", "dagger", "Dagger, for stabbing\nCan be dual-wielded\nMust be equipped", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
		
		AddIconToken("$dagger$", "Dagger.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Spear", "$spear$", "spear", "Poke people with murderous intent\nMust be equipped", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
		
		AddIconToken("$spear$", "PokingStick.png", Vec2f(32, 16), 0);
	}
	//---------------Log crafting end--------------
	{
		ShopItem@ s = addShopItem(this,  "Bolts", "$mat_bolts$", "mat_bolts-30", "Bolts for your crossbow", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		
		AddIconToken("$mat_bolts$", "MaterialBolts.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Cleaver", "$cleaver$", "cleaver", "Heavy melee weapon, sacrifices speed for damage\nMust be equipped", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 4);
		
		AddIconToken("$cleaver$", "Cleaver.png", Vec2f(32, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Metal Sword", "$metalsword$", "metalsword", "Lighter metallic sword, balanced speed and damage\nMust be equipped", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 3);
		
		AddIconToken("$metalsword$", "MetalSword.png", Vec2f(24, 16), 0);
	}
	/*{
		ShopItem@ s = addShopItem(this, "Soul Dust", "$souldust$", "souldust-3", "Smash a soul shard into dust", false);
		AddRequirement(s.requirements, "blob", "soul_chunk", "Soul Chunk", 1);
		
		AddIconToken("$soul_chunk$", "GhostShard.png", Vec2f(8, 8), 0);
		AddIconToken("$souldust$", "Souldust.png", Vec2f(16, 16), 0);
	}*/
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
	//ARMOR ---- MOVE TO DIFFERENT CRAFTING STATION MAYBE
	{
		ShopItem@ s = addShopItem(this,  "Metal Helmet", "$metal_helmet$", "metal_helmet", "Metallic head armor", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 4);

		AddIconToken("$metal_helmet$", "MetalHelmet.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Metal Chestplate", "$metal_chestplate$", "metal_chestplate", "Metallic chest armor", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 8);

		AddIconToken("$metal_chestplate$", "MetalChestplate.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Metal Boots", "$metal_boots$", "metal_boots", "Metallic foot armor", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Alchemical Metal Sheets", 4);

		AddIconToken("$metal_boots$", "MetalBoots.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Gold Helmet", "$gold_helmet$", "gold_helmet", "Golden head armor", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);

		AddIconToken("$gold_helmet$", "GoldHelmet.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Gold Chestplate", "$gold_chestplate$", "gold_chestplate", "Golden chest armor", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);

		AddIconToken("$gold_chestplate$", "GoldChestplate.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Gold Boots", "$gold_boots$", "gold_boots", "Golden foot armor", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);

		AddIconToken("$gold_boots$", "GoldBoots.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Corrupted Helmet", "$chitin_helmet$", "chitin_helmet", "Corrupted head armor", false);
		AddRequirement(s.requirements, "blob", "mat_chitin", "Chitin", 1);

		AddIconToken("$chitin_helmet$", "ChitinHelmet.png", Vec2f(16, 16), 0);
		AddIconToken("$mat_chitin$", "MaterialChitin.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Corrupted Chestplate", "$chitin_chestplate$", "chitin_chestplate", "Corrupted chest armor", false);
		AddRequirement(s.requirements, "blob", "mat_chitin", "Chitin", 2);

		AddIconToken("$chitin_chestplate$", "ChitinChestplate.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Corrupted Boots", "$chitin_boots$", "chitin_boots", "Corrupted foor armor", false);
		AddRequirement(s.requirements, "blob", "mat_chitin", "Chitin", 1);

		AddIconToken("$chitin_boots$", "ChitinBoots.png", Vec2f(16, 16), 0);
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
		planks.SetOffset(Vec2f(3.0f, -5.0f));
		planks.SetRelativeZ(-100);
	}
}
