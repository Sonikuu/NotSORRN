#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	addTank(this, "Input", true, Vec2f(0, -4));
	addTank(this, "Left Output", false, Vec2f(-4, 4));
	addTank(this, "Right Output", false, Vec2f(4, 4));
	
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, "Input");
	CAlchemyTank@ outputl = getTank(this, "Left Output");
	CAlchemyTank@ outputr = getTank(this, "Right Output");
	
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

