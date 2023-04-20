#include "FuelCommon.as";
#include "CustomFoodCommon.as";
#include "FxHookCommon.as";


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
	AddIconToken("$open_menu$", "RecipeIcons.png", Vec2f(16, 16), 0);
	
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");

	this.inventoryButtonPos = Vec2f(-12, 0);

	array<string> ingcache;
	this.set("ingcache", @ingcache);
}

void onInit(CSprite@ this)
{	
	this.SetEmitSound("Inferno.ogg");
	this.SetEmitSoundVolume(0.5);
	this.SetEmitSoundPaused(true);

	{
		CSpriteLayer@ itemlayer = this.addSpriteLayer("item0");
		itemlayer.SetRelativeZ(1);
		itemlayer.SetVisible(false);
		itemlayer.SetOffset(Vec2f(20, -12));
	}
	{
		CSpriteLayer@ itemlayer = this.addSpriteLayer("item1");
		itemlayer.SetRelativeZ(1);
		itemlayer.SetVisible(false);
		itemlayer.SetOffset(Vec2f(12, -12));
	}
	{
		CSpriteLayer@ itemlayer = this.addSpriteLayer("item2");
		itemlayer.SetRelativeZ(1);
		itemlayer.SetVisible(false);
		itemlayer.SetOffset(Vec2f(4, -12));
	}
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
	//Dont look
	string item0s = "";
	string item1s = "";
	int curritem = 0;
	CInventory@ inv = blob.getInventory();
	for (int i = 0; i < inv.getItemsCount() && curritem < 3; i++)
	{
		CBlob@ item = inv.getItem(i);
		string lastitem = blob.get_string("lastitem" + curritem);
		if(item !is null)
		{
			CSpriteLayer@ itemlayer = this.getSpriteLayer("item" + curritem);
			if(itemlayer !is null && item.getConfig() != item0s && item.getConfig() != item1s)
			{
				itemlayer.SetVisible(true);
				CSprite@ itemsprite = item.getSprite();
				if(lastitem != item.getConfig())
				{
					itemlayer.ReloadSprite(itemsprite.getFilename(), itemsprite.getFrameWidth(), itemsprite.getFrameHeight());
					blob.set_string("lastitem" + curritem, item.getConfig());
				}
				itemlayer.SetFrame(itemsprite.getFrame());
				if(curritem == 0)
					item0s = item.getConfig();
				else if(curritem == 1)
					item1s = item.getConfig();
				curritem++;
			}
		}
	}
	if(curritem < 3)
		{CSpriteLayer@ itemlayer = this.getSpriteLayer("item2"); if(itemlayer !is null) itemlayer.SetVisible(false);}
	if(curritem < 2)
		{CSpriteLayer@ itemlayer = this.getSpriteLayer("item1"); if(itemlayer !is null) itemlayer.SetVisible(false);}
	if(curritem < 1)
		{CSpriteLayer@ itemlayer = this.getSpriteLayer("item0"); if(itemlayer !is null) itemlayer.SetVisible(false);}

	
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

	//Alright, first ill just write the actual food making thingy, then ill make it work with fuel and stuff
	//All the usual checks, of course
	

	u8 currentrecipe = this.get_u8("currrecipe");
	if(currentrecipe < recipelist.size() && isServer())
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
			}
		}

		//So, lets get every required item and their count
		array<string> reqname;
		array<int> reqcount;
		bool canmake = true;
		for(int i = 0; i < recipedata.ingredientlist.size(); i++)
		{
			string thisreq = this.get_string("selingredient" + i);
			if(getIngredientData(thisreq) is null || getIngredientData(thisreq).typedata & recipedata.ingredientlist[i] == 0)
				canmake = false;
			int reqpos = reqname.find(thisreq);
			if(reqpos >= 0)
			{
				reqcount[reqpos]++;
			}
			else
			{
				reqname.push_back(thisreq);
				reqcount.push_back(1);
			}
		} 
		

		//For our hardcoded ingredients
		for(int i = 0; i < recipedata.ingredientspecific.size(); i++)
		{
			string thisreq = recipedata.ingredientspecific[i];
			int reqpos = reqname.find(thisreq);
			if(reqpos >= 0)
			{
				reqcount[reqpos]++;
			}
			else
			{
				reqname.push_back(thisreq);
				reqcount.push_back(1);
			}
		} 

		//And then the optional ingredients, if selected
		for(int i = 0; i < recipedata.optionals.size(); i++)
		{
			string thisreq = this.get_string("selingredient" + (i + recipedata.ingredientlist.size()));
			if(thisreq == "")
				continue;
			if(getIngredientData(thisreq) is null || getIngredientData(thisreq).typedata & recipedata.optionals[i] == 0)
				canmake = false;
			int reqpos = reqname.find(thisreq);
			if(reqpos >= 0)
			{
				reqcount[reqpos]++;
			}
			else
			{
				reqname.push_back(thisreq);
				reqcount.push_back(1);
			}
		} 
		//Now check we got everything we need

		for(int i = 0; i < reqname.size(); i++)
		{
			if(inv.getCount(reqname[i]) < reqcount[i])
				canmake = false;
		}

		if(canmake)
		{
			for(int i = 0; i < reqname.size(); i++)
			{
				int index = 0;
				while(reqcount[i] > 0)
				{
					CBlob@ invitem = inv.getItem(index);
					if(invitem !is null && invitem.getName() == reqname[i])
					{
						invitem.server_Die();
						reqcount[i]--;
					}
					index++;
					if(index > inv.getItemsCount())
						break;
				}
			}
			//print("THE PART WHERE WE MAKE FOOD");
			//Cool, now that custom food is now an item, we can make it
			CBlob@ food = server_CreateBlobNoInit("customfood");
			food.setPosition(this.getPosition());
			food.set_u8("recipe", currentrecipe);
			for(int i = 0; i < recipedata.ingredientlist.size(); i++)
			{
				food.set_string("ingredient" + i, this.get_string("selingredient" + i));
			}
			for(int i = 0; i < recipedata.optionals.size(); i++)
			{
				food.set_string("ingredient" + (i + recipedata.ingredientlist.size()), this.get_string("selingredient" + (i + recipedata.ingredientlist.size())));
			}
			food.Init();
		}
	}
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
			caller.CreateGenericButton("$add_fuel$", Vec2f(6, 0), this, this.getCommandID("addfuel"), "Add Fuel: " + formatFloat(value, ""), params);
		}
	}
	else
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$open_menu$", Vec2f(6, 0), this, this.getCommandID("recipemenu"), "Open Recipe Menu", params);
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	array<string>@ ingcache;
	this.get("ingcache", @ingcache);

	if(ingcache.find(blob.getConfig()) < 0)
		ingcache.push_back(blob.getConfig());
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
	caller.ClearGridMenus();
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
		const float rowsdist = 100; //80 default
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
				//print(item.getName());	//Havent tested yet, i have a feeling ill need this
			}
		}

		//Okay, now that thats done
		//Lets make the gui for each ingredient selector
		//ugh
		int totalsize = recipedata.ingredientlist.size() + recipedata.ingredientspecific.size() + recipedata.optionals.size();
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
			CGridMenu@ seling = CreateGridMenu(screenmid + Vec2f(0, (i + 0.5 - float(totalsize) / 2.0) * rowsdist), this, Vec2f(Maths::Max(valids.size(), 1), 1), "Select Ingredient");

			//Real quick, lets make a little text box for stats display :)
			CGridMenu@ textboi = CreateGridMenu(screenmid + Vec2f(getScreenWidth() / 2 - 128, (i + 0.5 - float(totalsize) / 2.0) * rowsdist), this, Vec2f(5, 2), "Stats");
			textboi.SetCaptionEnabled(false);
			CIngredientData@ ingdata = getIngredientData(this.get_string("selingredient" + i));
			if(ingdata !is null)
			{
				textboi.AddTextButton(makeStatText(ingdata), Vec2f(5, 2));
			}
			else
			{
				//hmm
			}
			//-------------------TXT
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

		for(int i = 0; i < recipedata.optionals.size(); i++)
		{
			//First, we get the valid ingredients for this ingredient space in particular
			//So we can size the grid menu correctly
			array<string> valids;
			for(int j = 0; j < storedingredients.size(); j++)
			{
				if(recipedata.optionals[i] & getIngredientData(storedingredients[j]).typedata != 0)
					valids.push_back(storedingredients[j]);
			}

			//Now we make menu
			//And then add each ingredient to list
			CGridMenu@ seling = CreateGridMenu(screenmid + Vec2f(0, (i + recipedata.ingredientlist.size() + 0.5 - float(totalsize) / 2.0) * rowsdist), this, Vec2f(Maths::Max(valids.size() + 1, 1), 1), "Select Ingredient");

			//Real quick, lets make a little text box for stats display :)
			CGridMenu@ textboi = CreateGridMenu(screenmid + Vec2f(getScreenWidth() / 2 - 128, ((i + recipedata.ingredientlist.size()) + 0.5 - float(totalsize) / 2.0) * rowsdist), this, Vec2f(5, 2), "Stats");
			textboi.SetCaptionEnabled(false);
			CIngredientData@ ingdata = getIngredientData(this.get_string("selingredient" + (i + recipedata.ingredientlist.size())));
			if(ingdata !is null)
			{
				textboi.AddTextButton(makeStatText(ingdata), Vec2f(5, 2));
			}
			else
			{
				//hmm
			}
			//-------------------TXT
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				params.write_u8(i + recipedata.ingredientlist.size());	//Ing slot
				params.write_string(""); //The ingredient to select
				CGridButton@ butt = seling.AddButton("WiringIcons.png", 0, Vec2f(16, 16), "Deselect", this.getCommandID("selingredient"), Vec2f(1, 1), params);
				if(this.get_string("selingredient" + (i + recipedata.ingredientlist.size())) == "")
					butt.SetSelected(1);
			}
			for(int j = 0; j < valids.size(); j++)
			{
				CBlob@ datblob = inv.getItem(valids[j]);
				if(datblob !is null)
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(i + recipedata.ingredientlist.size());	//Ing slot
					params.write_string(valids[j]); //The ingredient to select
					CGridButton@ butt = seling.AddButton(datblob.inventoryIconName, datblob.inventoryIconFrame, datblob.inventoryFrameDimension, datblob.getInventoryName(), this.getCommandID("selingredient"), Vec2f(1, 1), params);
					if(this.get_string("selingredient" + (i + recipedata.ingredientlist.size())) == valids[j])
					{
						butt.SetSelected(1);
					}
				}
			}
		} 

		for(int i = 0; i < recipedata.ingredientspecific.size(); i++)
		{
			CGridMenu@ seling = CreateGridMenu(screenmid + Vec2f(0, (i + recipedata.ingredientlist.size() + recipedata.optionals.size() + 0.5 - float(totalsize) / 2.0) * rowsdist), this, Vec2f(1, 1), "Required Ingredient");
			CIngredientData@ specdata = getIngredientData(recipedata.ingredientspecific[i]);
			CBitStream params;
			CGridButton@ butt = seling.AddButton(specdata.friendlyname + ".png", 0, Vec2f(8, 8), specdata.friendlyname, this.getCommandID("selingredient"), Vec2f(1, 1), params);
			//if(this.get_string("selingredient" + i) == valids[j])
			{
				butt.SetSelected(1);
				butt.clickable = false;
			}
		}


		//Making box for finished result
		//Real quick, lets make a little text box for stats display :)
		CGridMenu@ textboi = CreateGridMenu(screenmid + Vec2f(getScreenWidth() / 2 - 128, getScreenHeight() - 90), this, Vec2f(5, 2), "Finished Product");
		textboi.SetCaptionEnabled(false);
		array<CIngredientData@> inglist;
		bool invalid = false;
		for(int i = 0; i < recipedata.ingredientlist.size() + recipedata.optionals.size(); i++)
		{
			CIngredientData@ thising = getIngredientData(this.get_string("selingredient" + i));
			if(thising is null && i < recipedata.ingredientlist.size())
			{
				invalid = true;
				print("Breaking");
				break;
			}
			inglist.push_back(thising);
				
		}
		for(int i = 0; i < recipedata.ingredientspecific.size(); i++)
		{
			CIngredientData@ thising = getIngredientData(this.get_string("selingredient" + i));
			if(thising is null)
			{
				invalid = true;
				print("Breaking deez nuts");
				break;
			}
			inglist.push_back(thising);
		}
		
		if(!invalid)
		{
			textboi.AddTextButton(makeCompletedText(@inglist), Vec2f(5, 2));
		}
		else
		{
			//hmm
		}
	}
}

string makeStatText(CIngredientData@ ingdata)
{
	return ingdata.friendlyname + 
		"\nEffect: " + effectlist[ingdata.effect].getDisplayName() + 
		"\nHealing: " + ingdata.healing +
		"\nBase Power: " + ingdata.basepower + 
		" Base Duration: " + ingdata.baseduration / 30.0 + "s" + 
		"\nPower Mod: " + ingdata.powermod + "x" +
		" Duration Mod: " + ingdata.durationmod + "x" +
		"\nFlavor: " + ingdata.flavor;
}

string makeCompletedText(array<CIngredientData@>@ ingdata)
{
	if (ingdata.size() == 0)
	{
		print("asdsadas");
		return "Invalid Food";
	}
	//Now, we do the stats of the food
	
	//First, get the highest flavor, this will determine the basic stats
	int flavorid = -1;
	int highestflavor = -1;

	for(int i = 0; i < ingdata.size(); i++)
	{
		if(ingdata[i] !is null && ingdata[i].flavor > highestflavor)
		{
			flavorid = i;
			highestflavor = ingdata[i].flavor;
		}
	}
	//Now, extract base stats and multiply the rest into it
	float foodpower = ingdata[flavorid].basepower;
	float foodduration = ingdata[flavorid].baseduration;
	for(int i = 0; i < ingdata.size(); i++)
	{
		if(i != flavorid && ingdata[i] !is null)
		{
			foodpower *= ingdata[i].powermod;
			foodduration *= ingdata[i].durationmod;
		}
	}
	


	return "Finished Meal" + 
		"\nEffect: " + effectlist[ingdata[flavorid].effect].getDisplayName() + 
		"\nHealing: ???" +
		"\nPower: " + foodpower + 
		"\nDuration: " + foodduration / 30.0 + "s";
}