#include "NodeCommon.as";
#include "FuelCommon.as";

void onRender(CSprite@ this)
{
	//Change to look gud when possible
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
	addTank(this, "Output", false, Vec2f(0, -12));
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
			//if(sprite !is null)
			//	sprite.SetFrame(1);
			this.set_bool("active", true);
			
			CAlchemyTank@ tank = getTank(this, 0);
			if(tank !is null && tank.storage.getElement("ignis") < tank.maxelements)
			{
				addToTank(tank, "ignis", 1);
				this.add_f32("fuel", -1);
			}
		
			return;
		}
		this.set_bool("active", false);
		//if(sprite !is null)
		//	sprite.SetFrame(0);
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
