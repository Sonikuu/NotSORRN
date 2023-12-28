#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CLogicPlug@ output = addLogicPlug(this, "Output", false, Vec2f(0, 0));
	CLogicPlug@ input = addLogicPlug(this, "Input", true, Vec2f(0, 0));
}

void onTick(CBlob@ this)
{
	CLogicPlug@ o = getLogicPlug(this, 0);
	CLogicPlug@ i = getLogicPlug(this, 1);
	if(i !is null && o !is null)
	{
		if(o.getState() != i.getState())
			print("poop");
		o.setState(i.getState());
	}
}



