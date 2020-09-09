
#define SERVER_ONLY

void onInit(CBlob@ this)
{
  this.set_u16('decay time', 300);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("activate"))
	{
		CBlob@ holder = this.getAttachments().getAttachmentPoint("PICKUP").getOccupied();
		/*if(holder is null && this.isInInventory())
		{
			print("e");
			@holder = @this.getTouchingByIndex(0);
		}*/
		CBlob@ newbomb = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
		if(holder !is null)
		{
			holder.server_Pickup(newbomb);
		}
		this.server_Die();
	}
}
