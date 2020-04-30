#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	addTank(this, "input", true, Vec2f(0, -4));
	addTank(this, "outputl", false, Vec2f(-4, 4));
	addTank(this, "outputr", false, Vec2f(4, 4));
	
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, "input");
	CAlchemyTank@ outputl = getTank(this, "outputl");
	CAlchemyTank@ outputr = getTank(this, "outputr");
	
	if(input !is null && outputl !is null && outputr !is null && getTotal(@input.storage.elements) >= 2)
	{
		transferSimple(input, outputl, 1);
		transferSimple(input, outputr, 1);
	}
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}

