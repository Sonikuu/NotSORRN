#include "NodeCommon.as";
#include "DynamicFluidCommon.as";

void onInit(CBlob@ this)
{	
	addTank(this, "Output", false, Vec2f(0, -12));
	CLogicPlug@ disable = @addLogicPlug(this, "Disable", true, Vec2f(12, -12));
	
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
	if(getGameTime() % 10 == 0 && !getDisabled(this))
	{
		CMap@ map = getMap();
		if(IS_WATER_ACTIVE)
		{
			CAlchemyTank@ tank = getTank(this, 0);
			if(tank.storage.getElement("aqua") < tank.maxelements)
			{
				if(dynamicIsInWater(this.getPosition() + Vec2f(-4, 28)) ||dynamicIsInWater(this.getPosition() + Vec2f(4, 28)))
				{
					if(dynamicIsInWater(this.getPosition() + Vec2f(-4, 28)))//I'm lazy
						removeWater(this.getPosition() + Vec2f(-4, 28), 1);
					else
						removeWater(this.getPosition() + Vec2f(-4, 28), 1);
					addToTank(getTank(this, 0), "aqua", 1);
				}
			}
		}
		else
		{
			if(map.isInWater(this.getPosition() + Vec2f(-4, 28)) || map.isInWater(this.getPosition() + Vec2f(4, 28)))
			{
				//Using numbers to get tanks is probs faster than strings
				CAlchemyTank@ tank = getTank(this, 0);
				if(tank.storage.getElement("aqua") < tank.maxelements)
					addToTank(getTank(this, 0), "aqua", 1);
			}
		}
	}
}