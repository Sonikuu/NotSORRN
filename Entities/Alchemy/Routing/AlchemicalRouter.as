#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	addTank(this, "input", true, Vec2f(0, -4));
	addTank(this, "output", false, Vec2f(0, 4));
	
}

void onTick(CBlob@ this)
{
	//Move fluid from input to output
	//Should it have a preference for move order based on registry order?
	//Means less code and probs better for performance
	//Nevermind all that, its all handled by a common function now wheeeeee
	CAlchemyTank@ input = getTank(this, "input");
	CAlchemyTank@ output = getTank(this, "output");
	if(input !is null && output !is null)
		transferSimple(input, output, 2);
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}


