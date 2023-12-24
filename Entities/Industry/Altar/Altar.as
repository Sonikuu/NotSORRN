#include "NodeCommon.as";

//Alright where to start

//Altar should be for making powerful items
//Or infusing the player with special abilities / starting progression paths
//Altar can take maybe 4 items and an essence for infusions, and a focus to infuse into
//Should item storage things be attachment points maybe? I think that works
//Dunno how to hide recipe here, I think having an ingame method of figuring out infusions would work well
//Ooooo what if recipes are randomly generated, or the items required at least, per map
//From a set of possible items IE seeds, and random vegetables 


//I might just hardcode the ritual effects based on recipe ID
//Or a funcdef, I guess

/*enum EElement //For reference
{
	ecto = 0,
	life = 1,
	natura = 2,
	force = 3,
	aer = 4,
	ignis = 5,
	terra = 6,
	order = 7,
	entropy = 8,
	aqua = 9,
	corruption = 10,
	purity = 11,
	unholy = 12,
	holy = 13,
	yeet = 14
}*/



class CAltarRecipe
{
	array<string>@ recipecache;
	array<string>@ itemposs;	//Format idea: number_of_items:item1:item2:item3	ex. 2:tomato:cucumber:lettuce
	int element;
	string focus;
	CAltarRecipe(int element, string focus)
	{
		this.element = element;
		this.focus = focus;
		@itemposs = @array<string>();
		@recipecache = @array<string>();
	}

	CAltarRecipe@ addPossString(string poss)
	{
		itemposs.push_back(poss);
		return this;
	}
	void generateRecipe()
	{
		print("rinning");
		recipecache.clear();
		for(int i = 0; i < itemposs.size(); i++)
		{
			array<string>@ items = itemposs[i].split(":");
			int amt = parseInt(items[0]);
			string item = items[XORRandom(items.size() - 1) + 1];
			for(int j = 0; j < amt; j ++)
				recipecache.push_back(item);
		}
	}
}

array<CAltarRecipe> altarRecipes = {
	CAltarRecipe(2, "builder").addPossString("2:seed").addPossString("2:tomato:cucumber:lettuce:pineapple:carrot"),
	CAltarRecipe(0, "builder").addPossString("2:souldust").addPossString("1:mat_metal:mat_component").addPossString("1:lum:mat_purifiedgold")
};

void onInit(CBlob@ this)
{	
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");
	this.set_s32("gold building amount", 80);

	AddIconToken("$claim_team$", "ManagementIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$manage_team$", "ManagementIcons.png", Vec2f(16, 16), 3);
}

void onTick(CBlob@ this)
{
	if(getControls().isKeyJustPressed(KEY_KEY_K))
	{
		altarRecipes[1].generateRecipe();
		for(int i = 0; i < altarRecipes[1].recipecache.size(); i++)
		{ 
			print(altarRecipes[1].recipecache[i]);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() > 7 && this.isOverlapping(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$rotate_butt$", Vec2f(0, 0), this, this.getCommandID("join"), "Join Team", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
}
