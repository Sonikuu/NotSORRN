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
		o.setState(!i.getState());
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





