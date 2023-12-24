// monster sprite stuff and things

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if(blob !is null)
	{
		if(blob.getVelocity().y > 0)
		{
			this.SetAnimation("default");
		}
		else
		{
			this.SetAnimation("rising");
		}
	}
}

void onRender(CSprite@ this)
{
	
}

