
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("flesh"))
		return false;
	return true;
}