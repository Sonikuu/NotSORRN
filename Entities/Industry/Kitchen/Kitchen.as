#include "FuelCommon.as";


//Alright, ideas time
//I want food to have status effects, how to do?
//1. Food will consist of several different ingredients, one of which will determine main effects
//2. All other ingredients will modify stats on effect, ex. power, duration, possible auxilliary effects
//3. I want any ingredient to be able to determine main effect and base stats

//Lets give each ingredient some basic stats:
//Duration and power for if main ingredient
//Duration and power multipliers otherwise
//Option for secondary ingredient effect?

//One way to determine which ingredient is the main is assigning a "flavor" value
//Whichever one has the highest will determine effect
//Maybe, if two ingredients match, the food will get both effects, at the cost of missing out on a multiplier
//Or they could get a minor duration reduction or something
//Duration between all effects applied should be the same tho

//More ideas:
//Way to increase or decrease the flavor on an ingredient
//So you could force it to match flavor of another, at a certain cost?
//Maybe this can be implemented through condiments: salt, pepper, ketchup, ranch, mustard, honey, or even boiling an ingredient
//Mmm boiled asparagus lel

//Note: just base data, modifiers probs

//Oh right, need stuff like healing power, since it is food, and also ingredient category (Grain, veg, fruit, meat)
namespace Categories
{
	enum Types
	{
		Grain = 	0b00000001,
		Meat = 		0b00000010,
		Vegetable = 0b00000100,
		Fruit = 	0b00001000,
		Cheese = 	0b00010000,
		Fish =	 	0b00100000
	}
}

class CIngredientData
{
	string ingredient;
	int flavor;
	int effect;
	float healing;
	int basepower;
	int baseduration;
	float powermod;
	float durationmod;
	u8 typedata;
	CIngredientData(string ingredient, int flavor, int effect, float healing, int basepower, int baseduration, float powermod, float durationmod, u8 typedata)
	{
		this.ingredient = ingredient;
		this.flavor = flavor;
		this.effect = effect;
		this.healing = healing;
		this.basepower = basepower;
		this.baseduration = baseduration;
		this.powermod = powermod;
		this.durationmod = durationmod;
		this.typedata = typedata;
	}
}

array<CIngredientData@> ingredientdata =
{
	@CIngredientData("lettuce", 	2, 0, 0.25, 1, 1, 1, 1, 	Categories::Vegetable),
	@CIngredientData("grain", 		3, 0, 0.5, 	1, 1, 1.2, 1.2, Categories::Grain),		//technially some generic grain, we'll treat it like wheat tho lel
	@CIngredientData("tomato", 		2, 0, 0.25, 1, 1, 1, 1, 	Categories::Vegetable | Categories::Fruit), //its not both, of course, but eh
	@CIngredientData("cucumber", 	3, 0, 0.25, 1, 1, 1.1, 1.1, Categories::Vegetable),	//we need stuff with more flavor lel
	@CIngredientData("steak",	 	4, 0, 0.5, 	1, 1, 1.3, 1.3, Categories::Meat),
	@CIngredientData("fishy",	 	2, 0, 0.5, 	1, 1, 1, 1.5, Categories::Meat | Categories::Fish)		//Change to a cooked fish or whatever eventually, maybe
};

CIngredientData@ getIngredientData(string input)
{
	for (int i = 0; i < ingredientdata.length; i++)
	{
		if(input == ingredientdata[i].ingredient)
		
			return @ingredientdata[i];
	}
	return null;
}

class CRecipeData
{
	string recipename;
	array<u8> ingredientlist;
	array<string> ingredientspecific;
	CRecipeData(string recipename)
	{
		this.recipename = recipename;
	}

	CRecipeData@ addIngredient(u8 ingredient)
	{
		ingredientlist.push_back(ingredient);
		return @this;
	}

	CRecipeData@ addSpecific(string ingredient)
	{
		ingredientspecific.push_back(ingredient);
		return @this;
	}
}

array<CRecipeData@> recipelist = 
{
	@CRecipeData("Burger").addIngredient(Categories::Grain).addIngredient(Categories::Meat).addIngredient(Categories::Vegetable),
	@CRecipeData("Salad").addIngredient(Categories::Vegetable).addIngredient(Categories::Vegetable).addIngredient(Categories::Vegetable),
	@CRecipeData("Pizza").addIngredient(Categories::Grain).addIngredient(Categories::Cheese).addSpecific("tomato")
};

void onRender(CSprite@ this)
{
	//Change to look gud when possible
	//oh no, ive gone and reused this code without making it look good
	//big rip
	CBlob@ blob = this.getBlob();
	CControls@ controls = getControls();
	CCamera@ camera = getCamera();
	if(controls is null || blob is null)
		return;
	GUI::SetFont("snes");
	
	Vec2f fuelpos = (Vec2f(0, 12) * camera.targetDistance * 2 + blob.getScreenPos());
	if((fuelpos - controls.getMouseScreenPos()).Length() < 24)
	{
		GUI::DrawText("Fuel", Vec2f(0, 0) + fuelpos, SColor(255, 125, 125, 125));
		GUI::DrawText(formatInt(blob.get_f32("fuel"), ""), Vec2f(0, 20) + fuelpos, SColor(255, 255, 255, 255));
	}
}

void onInit(CBlob@ this)
{	
	this.addCommandID("addfuel");
	this.addCommandID("recipemenu");
	this.addCommandID("selrecipe");
	this.addCommandID("selingredient");
	
	this.set_f32("fuel", 0);
	this.set_u16("burnprogress", 0);

	this.set_u8("currrecipe", 255);
	
	AddIconToken("$add_fuel$", "FireFlash.png", Vec2f(32, 32), 0);
	
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");
}

void onInit(CSprite@ this)
{	
	this.SetEmitSound("Inferno.ogg");
	this.SetEmitSoundVolume(0.5);
	this.SetEmitSoundPaused(true);
}


void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(!blob.get_bool("active") && !this.getEmitSoundPaused())
	{
		this.SetEmitSoundPaused(true);
		this.SetFrame(0);
	}
	else if(blob.get_bool("active") && this.getEmitSoundPaused())
	{
		this.SetEmitSoundPaused(false);
		this.RewindEmitSound();
		this.SetFrame(1);
	}
}

void onTick(CBlob@ this)
{
	//The hard part :tm:
	//oh boi
	/*CSprite@ sprite = this.getSprite();
	if(getGameTime() % 2 == 0)
	{
		if(this.get_f32("fuel") > 0)
		{
			CInventory@ inv = this.getInventory();
			CBlob@ invitem = inv.getItem(0);
			if(invitem !is null)
			{
				CBurnableItem@ burnable = getBurnable(invitem.getConfig());
				if(burnable !is null && invitem.getQuantity() >= burnable.inputquant)
				{
					this.add_u16("burnprogress", 1);
					this.add_f32("fuel", -1);		
					this.set_bool("active", true);
					if(this.get_u16("burnprogress") >= burnable.burntime && getNet().isServer())
					{
						invitem.server_SetQuantity(invitem.getQuantity() - burnable.inputquant);
						if(invitem.getQuantity() <= 0)
							invitem.server_Die();
						CBlob@ newblob = server_CreateBlob(burnable.output, this.getTeamNum(), this.getPosition());
						newblob.server_SetQuantity(burnable.outputquant);
						this.add_u16("burnprogress", -burnable.burntime);
					}
					
					return;
				}
			}
		}
		this.set_bool("active", false);
	}*/
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ helditem = caller.getCarriedBlob();
	if(helditem !is null)
	{
		float value = getFuelValue(helditem);
		if(value > 0.0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$add_fuel$", Vec2f(0, 6), this, this.getCommandID("addfuel"), "Add Fuel: " + formatFloat(value, ""), params);
		}
	}
	else
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$open_menu$", Vec2f(0, 6), this, this.getCommandID("recipemenu"), "Open Recipe Menu", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("addfuel") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			//Checking if fuel again just in case
			CBlob@ helditem = caller.getCarriedBlob();
			if(helditem !is null)
			{
				float value = getFuelValue(helditem);
				if(value > 0.0)
				{
					this.add_f32("fuel", value);
					helditem.server_Die();
				}
			}
		}
	}
	else if(this.getCommandID("recipemenu") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && caller is getLocalPlayerBlob())
			openRecipeMenu(this, caller);
	}
	else if(this.getCommandID("selrecipe") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		u8 recipe = params.read_u8();
		this.set_u8("currrecipe", recipe);
		if(caller !is null && caller is getLocalPlayerBlob())
			openRecipeMenu(this, caller);
	}
	else if(this.getCommandID("selingredient") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		u8 slot = params.read_u8();
		string ingredient = params.read_string();
		this.set_string("selingredient" + slot, ingredient);
		if(caller !is null && caller is getLocalPlayerBlob())
			openRecipeMenu(this, caller);
	}
}

void openRecipeMenu(CBlob@ this, CBlob@ caller)
{
	//This is gonna suckkkkkkkkkk
	//ASDHGASDHGASHDGASDHY
	//okay
	//les go
	Vec2f screenmid(getScreenWidth() / 2, getScreenHeight() / 2);
	u8 currentrecipe = this.get_u8("currrecipe");
	//First, we make a list of all available recipes
	CGridMenu@ selrec = CreateGridMenu(screenmid - Vec2f(256, 0), this, Vec2f(1, recipelist.size()), "Recipes");
	for(int i = 0; i < recipelist.size(); i++)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(i);
		CGridButton@ butt = selrec.AddButton("RecipeIcons.png", i, Vec2f(16, 16), recipelist[i].recipename, this.getCommandID("selrecipe"), Vec2f(1, 1), params);
		if(currentrecipe == i)
		{
			butt.SetSelected(1);
		}
	} 

	//Next, we make our ingredient selection menu
	//Gotta get recipe first ofc
	if(currentrecipe < recipelist.size())
	{
		CRecipeData@ recipedata = @recipelist[currentrecipe];
		CInventory@ inv = this.getInventory();
		//Now, lets get all valid recipe items from storage
		//And cache names in the array
		array<string> storedingredients;
		for(int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			if(item !is null && getIngredientData(item.getName()) !is null && storedingredients.find(item.getName()) < 0)
			{
				storedingredients.push_back(item.getName());
				print(item.getName());	//Havent tested yet, i have a feeling ill need this
			}
		}

		//Okay, now that thats done
		//Lets make the gui for each ingredient selector
		//ugh

		for(int i = 0; i < recipedata.ingredientlist.size(); i++)
		{
			//First, we get the valid ingredients for this ingredient space in particular
			//So we can size the grid menu correctly
			array<string> valids;
			for(int j = 0; j < storedingredients.size(); j++)
			{
				if(recipedata.ingredientlist[i] & getIngredientData(storedingredients[j]).typedata != 0)
					valids.push_back(storedingredients[j]);
			}

			//Now we make menu
			//And then add each ingredient to list
			CGridMenu@ seling = CreateGridMenu(screenmid + Vec2f(0, (i + 0.5 - float(recipedata.ingredientlist.size()) / 2.0) * 80), this, Vec2f(valids.size(), 1), "Select Ingredient");
			for(int j = 0; j < valids.size(); j++)
			{
				CBlob@ datblob = inv.getItem(valids[j]);
				if(datblob !is null)
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(i);	//Ing slot
					params.write_string(valids[j]); //The ingredient to select
					CGridButton@ butt = seling.AddButton(datblob.inventoryIconName, datblob.inventoryIconFrame, datblob.inventoryFrameDimension, datblob.getInventoryName(), this.getCommandID("selingredient"), Vec2f(1, 1), params);
					if(this.get_string("selingredient" + i) == valids[j])
					{
						butt.SetSelected(1);
					}
				}
			}
		} 
	}
}