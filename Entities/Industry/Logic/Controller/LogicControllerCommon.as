#include "NodeCommon.as";

void updateNeighbors(Vec2f pos, bool state)
{
	CMap@ map = getMap();
	array<CBlob@> blobs;
	map.getBlobsAtPosition(pos + Vec2f(0, 8), @blobs);
	map.getBlobsAtPosition(pos + Vec2f(0, -8), @blobs);
	map.getBlobsAtPosition(pos + Vec2f(8, 0), @blobs);
	map.getBlobsAtPosition(pos + Vec2f(-8, 0), @blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		if(blobs[i].hasTag("logiccont") && blobs[i].get_bool("active") != state)
		{
			blobs[i].set_bool("active", state);
			updateNeighbors(blobs[i].getPosition(), state);
		}
	}
}



