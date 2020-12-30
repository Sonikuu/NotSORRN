#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CItemIO@ input = addItemIO(this, "Input", true, Vec2f(0, 0));
	CItemIO@ output = addItemIO(this, "Output", false, Vec2f(0, 0));
	@input.insertfunc = @routingInsertion;
	
	
}

void onTick(CBlob@ this)
{
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}


