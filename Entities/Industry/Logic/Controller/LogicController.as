#include "NodeCommon.as";
#include "LogicControllerCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CLogicPlug@ input = addLogicPlug(this, "Input", true, Vec2f(0, 0));
}

void onTick(CBlob@ this)
{

	CLogicPlug@ i = getLogicPlug(this, 0);
	if(i !is null)
	{
		updateNeighbors(this.getPosition(), i.getState());
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







