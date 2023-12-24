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
	if(getGameTime() % 30 == 0 && this.get_u16("sporecooldown") > 0)
		this.sub_u16("sporecooldown", 1);
	if(this.get_u16("sporecooldown") == 0)
	{
		array<CBlob@> blobs;
		if(getBlobsByTag("building", @blobs))
		{
			float closest = 2048;
			int closeid = -1;
			for(int i = 0; i < blobs.size(); i++)
			{
				if((blobs[i].getPosition() - this.getPosition()).Length() < closest)
				{
					closest = (blobs[i].getPosition() - this.getPosition()).Length();
					closeid = i;
				}
			}

			if(closeid != -1)
			{
				CBlob@ new = server_CreateBlob("spritzbomb", this.getTeamNum(), this.getPosition());
				new.set_Vec2f("target", blobs[closeid].getPosition());
				this.set_u16("sporecooldown", 20 + XORRandom(10));
			}
			else 
			{
				this.set_u16("sporecooldown", 10);
			}
		}
		else
		{
			//Get player to shoot at I guess lol
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

