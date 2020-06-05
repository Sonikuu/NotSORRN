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
	CIngredientData(string ingredient, int flavor, int effect, float healing, int basepower, int baseduration, float powermod, float durationmod)
	{
		this.ingredient = ingredient;
		this.flavor = flavor;
		this.effect = effect;
		this.healing = healing;
		this.basepower = basepower;
		this.baseduration = baseduration;
		this.powermod = powermod;
		this.durationmod = durationmod;
	}
}

array<CIngredientData@> ingredientdata =
{
	@CIngredientData("lettuce", 2, 0, 0.25, 1, 1, 1, 1)
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
	//this.addCommandID("meltitem");
	
	this.set_f32("fuel", 0);
	this.set_u16("burnprogress", 0);
	
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
}