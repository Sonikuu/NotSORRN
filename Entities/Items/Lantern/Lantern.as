// Lantern script
#include "FuelCommon.as"


void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 252, 86, 10));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$lantern on$", "Lantern.png", Vec2f(8, 8), 0);
	AddIconToken("$lantern off$", "Lantern.png", Vec2f(8, 8), 3);

	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("ignore_arrow");
	this.Tag("place norotate");

	//this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;

	fuelInit(this);
}

void onTick(CBlob@ this)
{
	if (this.isLight())
	{
		if((this.isInWater() || this.get_f32("fuel") < 1))
		{
			Light(this, false);
		}
		this.add_f32("fuel",-1);
	}
	this.setInventoryName((this.get_f32("fuel") > 0 ? "" : "Empty ") + "Lantern");
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		if(this.get_f32("fuel") > 0)
		{
			Light(this, !this.isLight());
		} else {
			this.getSprite().PlaySound("NoAmmo.ogg",0.5);
		}
	}

	handleFuelCommands(this,cmd,params);

}

void GetButtonsFor(CBlob@ this, CBlob@ caller){
	generateFuelButtons(this, caller);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.getShape().isStatic();
}


void onRender(CSprite@ this){
	FuelOnRender(this);
}