#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CLogicPlug@ output = addLogicPlug(this, "Output", false, Vec2f(0, 0));
	this.addCommandID("flip");
}

void onTick(CBlob@ this)
{
	CLogicPlug@ p = getLogicPlug(this, 0);
	if(p !is null)
	{
		p.setState(this.get_bool("leverstate"));
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u8(this.get_bool("leverstate") ? 1 : 0);
	caller.CreateGenericButton(2, Vec2f_zero, this, this.getCommandID("flip"), "Attach Part", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("flip"))
	{
		u8 s = params.read_u8();
		if(s == 1)
			this.set_bool("leverstate", false);
		else
			this.set_bool("leverstate", true);
	}
}


