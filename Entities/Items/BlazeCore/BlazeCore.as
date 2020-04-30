
void onInit(CBlob@ this)
{
	//Make this emit particles eventually
	this.getShape().SetRotationsAllowed(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.hasTag("flesh") || !this.isOnGround())
		return true;
	return false;
}


