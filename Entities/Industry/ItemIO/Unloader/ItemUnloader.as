#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	CItemIO@ input = addItemIO(this, "Input", true, Vec2f(0, 0));
	CItemIO@ output = addItemIO(this, "Output", false, Vec2f(0, 0));	
}

void onTick(CBlob@ this)
{
	//Will automatically connect to any nearby rail blobs with an output node
	if(getGameTime() % 15 == 0 && isServer())
	{
		CMap@ map = getMap();

		CBlob@[] blobs;
		if(map.getBlobsInRadius(this.getPosition(), 16, @blobs))
		{
			for(int i = 0; i < blobs.size(); i++)
			{
				CBlob@ thisblob = @blobs[i];
				if(thisblob.get_bool("riding"))
				{
					CItemIO@ bloboutput = getItemIO(thisblob, "Output");
					if(bloboutput !is null && bloboutput.connection is null)
					{
						CItemIO@ input = getItemIO(this, "Input");
						CBitStream params;
						params.write_u16(this.getNetworkID());
						params.write_u8(input.nodeid);
						params.write_u16(thisblob.getNetworkID());
						params.write_u8(bloboutput.nodeid);
						this.SendCommand(this.getCommandID("connect"), params);
					}
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
}


