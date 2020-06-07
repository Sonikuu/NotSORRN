
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("railmult", 3);
}

void onTick(CBlob@ this)
{
	if(this.get_bool("riding"))
	{
		this.getShape().getConsts().mapCollisions = false;
		Vec2f diff = this.getPosition() - this.get_Vec2f("lastvec");
		for(int i = 0; i < this.getTouchingCount(); i++)
		{
			CBlob@ blob = this.getTouchingByIndex(i);
			/*if(blob !is null && !blob.isKeyPressed(key_up) && this.doesCollideWithBlob(blob) && (blob.get_u32("lastplatmove") < getGameTime() - 3 || blob.get_u16("lastplatid") == this.getNetworkID()))
			{
				blob.set_u32("lastplatmove", getGameTime());
				blob.set_u16("lastplatid", this.getNetworkID());
				blob.setPosition(blob.getPosition() + diff);
			}*/
			if(blob !is null && !blob.isKeyPressed(key_up) && this.doesCollideWithBlob(blob))
			{
				blob.setVelocity(blob.getVelocity() + Vec2f(0, 2));
			}
		}
	}
	else
		this.getShape().getConsts().mapCollisions = true;
	//this.set_Vec2f("lastvec", this.getPosition());
}

/*void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(solid && blob !is null)
	{
		this.setVelocity(this.getVelocity() + blob.getVelocity());
	}
}*/

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//if(blob.get_bool("riding") && this.get_bool("riding") || (blob.get_u32("lastplatmove") < getGameTime() - 3 && blob.get_u16("lastplatid") == this.getNetworkID()))
		//return false;
	return true;
}