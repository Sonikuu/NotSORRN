#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CLogicPlug@ input = addLogicPlug(this, "Input", true, Vec2f(0, 0));
	CLogicPlug@ output = addLogicPlug(this, "Output1", false, Vec2f(-8, 0));
	CLogicPlug@ output2 = addLogicPlug(this, "Output2", false, Vec2f(8, 0));
	
}

void onTick(CBlob@ this)
{
	CLogicPlug@ i = getLogicPlug(this, 0);
	CLogicPlug@ o1 = getLogicPlug(this, 1);
	CLogicPlug@ o2 = getLogicPlug(this, 2);
	//if(i !is null && o1 !is null && o2 !is null)
	{
		o1.setState(i.getState());
		o2.setState(i.getState());
	}
}

void onTick(CSprite@ this)
{

	CLogicPlug@ i = getLogicPlug(this.getBlob(), 0);
	if(i.getState() && this.getFrame() == 0)
		this.SetFrame(1);
	else if(!i.getState() && this.getFrame() == 1)
		this.SetFrame(0);
}



