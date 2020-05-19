// Bush logic

#include "../Scripts/canGrow.as";

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
	if(isServer() && (getGameTime() + this.getNetworkID() * 10) % 900 == 0)
	{
		CMap@ map = getMap();
		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(), 256, @blobs);
		int zerrcount = 0;
		bool dospawn = true;
		for(int i = 0; i < blobs.length(); i++)
		{
			if(blobs[i].getConfig() == "zerr")
			{
				zerrcount++;
				if(zerrcount >= 12)
				{
					dospawn = false;
					break;
				}
			}
		}
		if(dospawn)
			server_CreateBlob("zerr", this.getTeamNum(), this.getPosition());
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

