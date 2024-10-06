#include "NodeCommon.as";
#include "FuelCommon.as";

void onRender(CSprite@ this)
{
	FuelOnRender(this);
}

void onInit(CBlob@ this)
{	
	addTank(this, "Output", false, Vec2f(0, -12));
	CItemIO@ fuelin = @addItemIO(this, "Fuel Input", true, Vec2f(0, 12));
	@fuelin.insertfunc = @fuelInsertionFunc;
	fuelInit(this);

	CLogicPlug@ disable = @addLogicPlug(this, "Disable", true, Vec2f(4, -12));
	
	//this.addCommandID("meltitem");
	
	
	this.set_u16("burnprogress", 0);
	
	
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
		if(this.get_f32("fuel") > 0 && !getDisabled(this))
		{
			//if(sprite !is null)
			//	sprite.SetFrame(1);
			this.set_bool("active", true);
			
			CAlchemyTank@ tank = getTank(this, 0);
			if(tank !is null && tank.storage.getElement("ignis") < tank.maxelements)
			{
				addToTank(tank, "ignis", 1);
				addToFuelVallue(this,-1,true);
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
	generateFuelButtons(this,caller);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	handleFuelCommands(this,cmd,params);
}
