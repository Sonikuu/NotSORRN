#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	addTank(this, "Output", false, Vec2f(0, -12));
	
	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ layer = this.addSpriteLayer("pipe", 32, 32);
	layer.SetFrame(1);
	layer.TranslateBy(Vec2f(0, 32));
}

void onTick(CBlob@ this)
{
	if(getGameTime() % 10 == 0)
	{
		CMap@ map = getMap();
		if(map.isInWater(this.getPosition() + Vec2f(-4, 28)) || map.isInWater(this.getPosition() + Vec2f(4, 28)))
		{
			//Using numbers to get tanks is probs faster than strings
			CAlchemyTank@ tank = getTank(this, 0);
			if(tank.storage.getElement("aqua") < tank.maxelements)
				addToTank(getTank(this, 0), "aqua", 1);
		}
	}
}