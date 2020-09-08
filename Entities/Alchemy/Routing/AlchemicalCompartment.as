#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CAlchemyTank@ input = addTank(this, "Input", true, Vec2f(0, -13));
	CAlchemyTank@ output = addTank(this, "Output", false, Vec2f(0, 13));
	
	input.maxelements = 10;
	input.unmixedstorage = true;
	
	output.maxelements = 2000;
	output.unmixedstorage = true;
	
}

void onTick(CBlob@ this)
{
	//Move fluid from input to output
	//Should it have a preference for move order based on registry order?
	//Means less code and probs better for performance
	//Nevermind all that, its all handled by a common function now wheeeeee
	CAlchemyTank@ input = getTank(this, "Input");
	CAlchemyTank@ output = getTank(this, "Output");
	if(input !is null && output !is null)
		transferSimple(input, output, 2);
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}


