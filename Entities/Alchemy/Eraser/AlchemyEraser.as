
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//bonk
	if(!blob.hasTag("flesh") || !this.isOnGround())
		return true;
	return false;
}


