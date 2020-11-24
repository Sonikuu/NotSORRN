// monster sprite stuff and things

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if(blob !is null)
	{
		if(blob.hasTag("attacking"))
		{
			this.SetAnimation("ramming");
		}
		else if(!blob.isOnGround())
		{
			if(blob.getVelocity().y > 0)
			{
				this.SetAnimation("falling");
			}
			else
			{
				this.SetAnimation("jumping");
			}
		}
		else if(blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right))
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("default");
		}
	}
}

