// Bush logic

void onInit(CBlob@ this)
{
	this.set_bool("grown", true);
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.Tag("builder always hit");
	this.Tag("corrupt");
	this.Tag("flesh");//So we can shoot it
	//this.Tag("nature");
}

//void onDie( CBlob@ this )
//{
//	//TODO: make random item
//}

void onTick(CBlob@ this)
{
	if(getGameTime() % 30 == 0)
	{
		this.add_u16("spawncountdown", 1);

		if(this.get_u16("spawncountdown") >= 240)
		{
			server_CreateBlob("drizz", this.getTeamNum(), this.getPosition());
			this.server_Die();
		}
	}
}

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
	//this.animation.frame = (netID % this.animation.getFramesCount());
	this.SetFacingLeft(((netID % 13) % 2) == 0);
	//this.getCurrentScript().runFlags |= Script::remove_after_this;	// wont be sent on network
	this.SetZ(10.0f);
}

void onTick(CSprite@ this)
{
	int frame = this.getBlob().get_u16("spawncountdown") / 60;
	if(this.getFrame() != frame)
		this.SetFrame(frame);
}

