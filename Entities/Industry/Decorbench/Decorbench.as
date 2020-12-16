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
	this.set_Vec2f("shop menu size", Vec2f(6, 8));

	{
		ShopItem@ s = addShopItem(this,  "Decor Heart", "$heart$", "decorheart", "Decorative placeable heart \n(Not edible!)", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
		
		AddIconToken("heart$", "Heart.png", Vec2f(16, 16), 0);
		//AddIconToken("$railplatform$", "RailPlatform.png", Vec2f(32, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Wooden Chair", "$wood_chair$", "wood_chair", "A chair for sitting", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		
		AddIconToken("$wood_chair$", "WoodChair.png", Vec2f(16, 16), 0);
	}
	{
		ShopItem@ s = addShopItem(this,  "Wooden Table", "$wood_table$", "wood_table", "A simple table", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		
		AddIconToken("$wood_table$", "WoodTable.png", Vec2f(24, 16), 0);
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
