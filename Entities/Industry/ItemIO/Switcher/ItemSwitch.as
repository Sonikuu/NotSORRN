#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CItemIO@ input = addItemIO(this, "Input", true, Vec2f(0, 0));
	CItemIO@ outputl = addItemIO(this, "Left Output", false, Vec2f(-8, 0));
	CItemIO@ outputr = addItemIO(this, "Right Output", false, Vec2f(8, 0));
	@input.insertfunc = @switchInsertion;
	//this.addCommandID("setfilter");
	//AddIconToken("$config_sorter$", "TechnologyIcons.png", Vec2f(16, 16), 12);
}

void onTick(CBlob@ this)
{
	
}

/*void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() !is null)
	{
		CBitStream params;
		params.write_u16(caller.getCarriedBlob().getNetworkID());
		caller.CreateGenericButton("$config_sorter$", Vec2f(0, 0), this, this.getCommandID("setfilter"), "Set filter to held item", params);
	}
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("setfilter") == cmd)
	{
		CBlob@ item = getBlobByNetworkID(params.read_u16());
		if(item !is null)
		{
			this.set_string("filter", item.getConfig());
		}
	}
}*/