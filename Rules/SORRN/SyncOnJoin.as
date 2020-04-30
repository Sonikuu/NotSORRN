//Instead of each blob having it's own sync stuff this will handle it all

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if(getNet().isServer())
	{
		CBlob@[] blobs;
		getBlobs(@blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			if(!blobs[i].hasTag("hassynccmd"))
				continue;
			CBitStream params;
			params.write_u16(player.getNetworkID());
			blobs[i].SendCommandOnlyServer(blobs[i].getCommandID("sync"), params);
		}
	}
}

