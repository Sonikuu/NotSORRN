

void onInit(CSprite@ this)
{
	
}

void onTick(CSprite@ this)
{
	
}

//blob

void onInit(CBlob@ this)
{
	this.Tag("bison");
	this.getShape().SetOffset(Vec2f(0, 7.5));
}


void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(this.getTickSinceCreated() > 30 * 60 * 5 && isServer())
	{
		if(XORRandom(2) == 0)
			server_CreateBlob("bison", this.getTeamNum(), this.getPosition());
		else 
			server_CreateBlob("cow", this.getTeamNum(), this.getPosition());
		this.server_Die();
	}
}

