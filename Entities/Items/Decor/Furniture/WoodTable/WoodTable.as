
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.isOnGround() || blob.isKeyPressed(key_down))
		return false;
	return true;
}

