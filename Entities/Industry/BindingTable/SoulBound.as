
void onTick(CBlob@ this)
{
	if(getGameTime() % 30 != 0 || this.isInInventory() || this.isAttached() || this.get_bool("equipped"))
		return;
	CPlayer@ player = getPlayerByUsername(this.get_string("boundtoplayer"));
	if(player !is null)
	{
		CBlob@ blob = player.getBlob();
		if(blob !is null)
		{
			CInventory@ inv = blob.getInventory();
			if(inv !is null)
			{
				//this.setPosition(blob.getPosition());
				blob.server_PutInInventory(this);
			}
		}
	}
}
























