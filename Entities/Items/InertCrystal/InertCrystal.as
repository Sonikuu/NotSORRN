
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.hasTag("flesh") || !this.isOnGround())
		return true;
	return false;
}