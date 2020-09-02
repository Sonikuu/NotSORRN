

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.addCommandID("toggle");

	this.SetLightRadius(8);
	this.SetLightColor(SColor(255,100,0,0));
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.getAttachments().getAttachmentPoint("PICKUP").getOccupied() !is null) {return;}
	bool active = this.get_bool("active");
	CButton@ button = caller.CreateGenericButton(0, Vec2f_zero, this,this.getCommandID("toggle"), "Toggle switch " + (active ? "off" : "on") );
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	
	if(cmd == this.getCommandID("toggle"))
	{
		this.set_bool("active", !this.get_bool("active"));
	}
}


void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	bool active = blob.get_bool("active");

	if(active)
	{
		this.SetFrame(1);
		blob.SetLight(true);
	}
	else
	{
		this.SetFrame(0);
		blob.SetLight(false);
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}