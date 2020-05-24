#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	addTank(this, "output", false, Vec2f(0, 12));
	
	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(getGameTime() % int(30 / Maths::Max((1.0 - this.getPosition().y / (map.tilemapheight * map.tilesize)) * 2, 1.0)) == 0)
	{
		//Using numbers to get tanks is probs faster than strings
		CAlchemyTank@ tank = getTank(this, 0);
		if(tank.storage.getElement("aer") < tank.maxelements)
			addToTank(tank, "aer", 1);
	}
}