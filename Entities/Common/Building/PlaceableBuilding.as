bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onInit(CBlob@ this)
{
    this.Tag("place norotate");
}

void onTick(CSprite@ this)
{
    if(!this.getBlob().isAttached())
    {
        this.SetZ(-50);
        this.getCurrentScript().tickFrequency = 0;
    }
}
