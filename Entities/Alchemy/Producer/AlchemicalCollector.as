#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	addTank(this, "output", false, Vec2f(0, 12));
	
	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onTick(CBlob@ this)
{
	if(getGameTime() % 30 == 0)
	{
		//Using numbers to get tanks is probs faster than strings
		CAlchemyTank@ tank = getTank(this, 0);
		if(tank.storage.getElement("aer") < tank.maxelements)
			addToTank(tank, "aer", 1);
	}
}