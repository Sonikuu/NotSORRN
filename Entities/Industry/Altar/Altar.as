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
	this.set_s32("gold building amount", 50);

	AddIconToken("$claim_team$", "ManagementIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$manage_team$", "ManagementIcons.png", Vec2f(16, 16), 3);
	this.addCommandID("test");
	this.addCommandID("attach");

	CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(0, 0));
	tank.unmixedstorage = true;
	tank.singleelement = true;
	tank.maxelements = 5000;
	for(int i = 0; i < altarRecipes.size(); i++)
	{
		altarRecipes[i].generateRecipe();
	}
}

void onTick(CBlob@ this)
{
	if(getControls().isKeyJustPressed(KEY_KEY_K))
	{
		//altarRecipes[1].generateRecipe();
		for(int j = 0; j < altarRecipes.size(); j++)
		{
			print("Recipe: " + j);
			for(int i = 0; i < altarRecipes[j].recipecache.size(); i++)
			{ 
				print(altarRecipes[j].recipecache[i]);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//if(caller.getTeamNum() > 7 && this.isOverlapping(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$rotate_butt$", Vec2f(0, 0), this, this.getCommandID("test"), "Test Ritual", params);
	}
	for(int i = 0; i < this.getAttachmentPointCount(); i++)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(i);
		caller.CreateGenericButton("$rotate_butt$", this.getAttachmentPoint(i).offset / 2.0, this, this.getCommandID("attach"), "Attach/Detach Item", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("test"))
	{
		SColor fo(255, 255, 50, 155);
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && caller is getLocalPlayerBlob())
		{
			CAlchemyTank@ tank = getTank(this, 0);
			if(tank !is null)
			{
				int elemid = firstId(tank);
				if(elemid < 0)
				{
					client_AddToChat("The altar needs an essence to narrow down possible rituals", fo);
					return;
				}
				int validrecipe = -1;
				bool foundessmatch = false;
				array<CBlob@>@ storeditems;
				@storeditems = @getPillarItems(this);
				if(storeditems is null)
					return;
				for(int i = 0; i < altarRecipes.size(); i++)
				{
					if(altarRecipes[i].element == elemid)
					{
						foundessmatch = true;
						bool skipthis = false;
						array<int> skipnums;
						for(int j = 0; j < storeditems.size(); j++)
						{
							bool nomatch = true;
							for(int k = 0; k < altarRecipes[i].recipecache.size(); k++)
							{
								if(skipnums.find(k) >= 0)
									continue;
								if(storeditems[j].getConfig() == altarRecipes[i].recipecache[k])
								{
									nomatch = false;
									skipnums.push_back(k);
									break;
								}
							}
							if(nomatch)
							{
								skipthis = true;
								break;
							}
						}
						if(skipthis)
							continue;
						if(validrecipe >= 0)
						{
							client_AddToChat("The altar has multiple rituals for this element, add items to narrow down possible rituals", fo);
							return;
						}
						validrecipe = i;
					}
				}
				if(foundessmatch && validrecipe == -1)
				{
					client_AddToChat("The altar has no valid ritual for these items, try removing some", fo);
					return;
				}
				else if(validrecipe >= 0 && storeditems.size() < 4)
				{
					client_AddToChat("The altar recipe is valid thus far, try more items", fo);
					return;
				}
				else if(!foundessmatch && validrecipe == -1)
				{
					client_AddToChat("The current essence has no valid recipes", fo);
					return;
				}
				else
				{
					client_AddToChat("The altar is recipe valid and finished, toss the focus item or creature into the center", fo);
				}
			}
		}
		
	}
	else if(cmd == this.getCommandID("attach"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		u8 id = params.read_u8();
		AttachmentPoint@ att = this.getAttachmentPoint(id);
		if(att !is null)
		{
			CBlob@ b = att.getOccupied();
			if(b !is null)
			{
				this.server_DetachFrom(b);
			}
			else
			{

				if(caller !is null && caller.getCarriedBlob() !is null)
				{
					CBlob@ c = caller.getCarriedBlob();
					caller.server_DetachFrom(c);
					this.server_AttachTo(c, att);
				}
			}
		}
	}
}

array<CBlob@>@ getPillarItems(CBlob@ this)
{
	array<CBlob@> output;
	for(int i = 0; i < this.getAttachmentPointCount(); i++)
	{
		AttachmentPoint@ att = this.getAttachmentPoint(i);
		if(att !is null)
		{
			CBlob@ b = att.getOccupied();
			if(b !is null)
			{
				output.push_back(@b);
			}
		}
	}
	return @output;
}