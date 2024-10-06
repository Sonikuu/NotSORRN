#include "FuelCommon.as";
#include "NodeCommon.as";

class CBurnableItem
{
	string input;
	string output;
	int inputquant;
	int outputquant;
	int burntime;
	CBurnableItem(string input, string output, int inputquant, int outputquant, int burntime)
	{
		this.input = input;
		this.output = output;
		this.inputquant = inputquant;
		this.outputquant = outputquant;
		this.burntime = burntime;
	}
}

array<CBurnableItem@> burnlist =
{
	@CBurnableItem(
	"mat_wood",
	"mat_charcoal",
	10,
	10,
	10),
	
	@CBurnableItem(
	"log",
	"mat_charcoal",
	1,
	50,
	25),
	
	@CBurnableItem(
	"mat_sand",	
	"mat_glass",
	25,
	10,
	25),
	
	@CBurnableItem(
	"mat_lifewood",
	"mat_charcoal",
	10,
	10,
	10),
	
	
	@CBurnableItem(
	"lifelog",
	"mat_charcoal",
	1,
	50,
	25),
	
	@CBurnableItem(
	"mat_corrpulp",
	"mat_puredust",
	25,
	25,
	25),
	
	@CBurnableItem(
	"blazecore",
	"unstablecore",
	1,
	1,
	100),

	@CBurnableItem(
	"mat_glass",
	"inertcrystal",
	100,
	1,
	100)
};

CBurnableItem@ getBurnable(string input)
{
	for (int i = 0; i < burnlist.length; i++)
	{
		if(input == burnlist[i].input)
		
			return @burnlist[i];
	}
	return null;
}

void onRender(CSprite@ this)
{
	FuelOnRender(this);
}

void onInit(CBlob@ this)
{	
	fuelInit(this);
	//this.addCommandID("meltitem");
	CItemIO@ input = @addItemIO(this, "Input", true, Vec2f(0, 0));
	CItemIO@ output = @addItemIO(this, "Output", false, Vec2f(0, 0));

	CLogicPlug@ disable = @addLogicPlug(this, "Disable", true, Vec2f(4, -8));
	output.onlymovetagged = true;

	CItemIO@ fuelin = @addItemIO(this, "Fuel Input", true, Vec2f(0, 8));
	@fuelin.insertfunc = @fuelInsertionFunc;
	
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
	CSprite@ sprite = this.getSprite();
	if(getGameTime() % 2 == 0)
	{
		if(this.get_f32("fuel") > 0 && !getDisabled(this))
		{
			CInventory@ inv = this.getInventory();
			for(int i = 0; i < this.getInventory().getItemsCount(); i++)
			{
				CBlob@ invitem = inv.getItem(i);
				if(invitem !is null)
				{
					CBurnableItem@ burnable = getBurnable(invitem.getConfig());
					if(burnable !is null && invitem.getQuantity() >= burnable.inputquant)
					{
						this.add_u16("burnprogress", 1);
						addToFuelVallue(this,-1,true);		
						this.set_bool("active", true);
						if(this.get_u16("burnprogress") >= burnable.burntime && getNet().isServer())
						{
							invitem.server_SetQuantity(invitem.getQuantity() - burnable.inputquant);
							if(invitem.getQuantity() <= 0)
								invitem.server_Die();
							CBlob@ newblob = server_CreateBlob(burnable.output, this.getTeamNum(), this.getPosition());
							newblob.server_SetQuantity(burnable.outputquant);
							newblob.Tag("outputblob");
							this.add_u16("burnprogress", -burnable.burntime);
							CItemIO@ output = getItemIO(this, "Output");
							if(output !is null && output.connection !is null)
							{
								this.server_PutInInventory(newblob);
							}
						}
						
						return;
					}
				}
			}
			
		}
		this.set_bool("active", false);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	generateFuelButtons(this,caller);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	handleFuelCommands(this,cmd,params);
}