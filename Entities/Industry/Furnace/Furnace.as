#include "FuelCommon.as";

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