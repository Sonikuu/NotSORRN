#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	CItemIO@ output = addItemIO(this, "Output", false, Vec2f(0, 0));	
}

void onTick(CBlob@ this)
{
	//This should be automatically connected to by the unloader, all this blob does is pick up items
	if(this.get_bool("riding"))
		this.getShape().getConsts().mapCollisions = false;
	else
		this.getShape().getConsts().mapCollisions = true;
	
	CItemIO@ output = getItemIO(this, "Output");
	if(output !is null && output.connection !is null)
	{
		CInventory@ inv = this.getInventory();
		if(inv.getItemsCount() > 0)
		{
			this.set_f32("railmult", 0);
		}
		else
		{
			this.set_f32("railmult", 1);
			if(isServer())
			{
				CBitStream params;
				params.write_u8(output.nodeid);
				this.SendCommand(this.getCommandID("disconnect"), params);
			}
		}
	}
	else
	{
		if((getGameTime() + this.getNetworkID()) % 30 == 0 && this.get_bool("riding"))
		{
			CMap@ map = getMap();
			CBlob@[] blobs;
			if(map.getBlobsInRadius(this.getPosition(), 24, @blobs))
			{
				for(int i = 0; i < blobs.size(); i++)
				{
					if(blobs[i].getConfig().find("mat_") >= 0 && !blobs[i].isAttached())
					{
						Vec2f oldpos = blobs[i].getPosition();
						if(!this.server_PutInInventory(blobs[i]))
							blobs[i].setPosition(oldpos);
					}
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}


