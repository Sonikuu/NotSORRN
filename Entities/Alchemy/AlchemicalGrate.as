#include "NodeCommon.as";
#include "DynamicFluidCommon.as";



void onInit(CBlob@ this)
{	
	//Setup tanks
	CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(0, -1.5));
	tank.onlyele = 9;//5 Is ignis
	tank.maxelements = 250;
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, 0);
	
	if(input !is null)
	{
		//for(int i = 0; i < input.storage.elements.length; i++)
		{
			if(input.storage.elements[9] > 0)
			{
				if(getWaterLevel(this.getPosition()) < 15)
				{
					addWater(this.getPosition(), 1);
					input.storage.elements[9]--;
				}
			}
		}
	}
}