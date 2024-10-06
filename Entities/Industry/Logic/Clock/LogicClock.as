#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CLogicPlug@ output = addLogicPlug(this, "Output", false, Vec2f(0, 0));
	this.addCommandID("config");
	this.addCommandID("seton");
	this.addCommandID("setoff");
	this.set_u16("ontime", 10);
	this.set_u16("offtime", 10);
	AddIconToken("$min_100$", "LogicClockIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$min_10$", "LogicClockIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$min_1$", "LogicClockIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$plus_100$", "LogicClockIcons.png", Vec2f(16, 16), 3);
	AddIconToken("$plus_10$", "LogicClockIcons.png", Vec2f(16, 16), 4);
	AddIconToken("$plus_1$", "LogicClockIcons.png", Vec2f(16, 16), 5);
	AddIconToken("$config_sorter$", "TechnologyIcons.png", Vec2f(16, 16), 12);
}

void onTick(CBlob@ this)
{
	CLogicPlug@ p = getLogicPlug(this, 0);
	if(p !is null)
	{
		if(p.getState())
		{
			this.add_u16("timer", 1);
			if(this.get_u16("timer") >= this.get_u16("ontime"))
			{
				p.setState(false);
				this.set_u16("timer", 0);
			}
		}
		else
		{
			this.add_u16("timer", 1);
			if(this.get_u16("timer") >= this.get_u16("offtime"))
			{
				p.setState(true);// true!
				this.set_u16("timer", 0);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton("$config_sorter$", Vec2f_zero, this, this.getCommandID("config"), "Configure Clock", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("config"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && caller is getLocalPlayerBlob())
		{	
			createConfigMenu(this, caller);
		}
	}
	else if(cmd == this.getCommandID("seton"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		this.set_u16("ontime", params.read_u16());
		if(caller !is null && caller is getLocalPlayerBlob())
		{
			createConfigMenu(this, caller);
		}
	}
	else if(cmd == this.getCommandID("setoff"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		this.set_u16("offtime", params.read_u16());
		if(caller !is null && caller is getLocalPlayerBlob())
		{
			createConfigMenu(this, caller);
		}
	}
}

void createConfigMenu(CBlob@ this, CBlob@ caller)
{
	caller.ClearMenus();
	Vec2f screencenter(getScreenWidth() / 2, getScreenHeight() / 2);
	
	CGridMenu@ menu1 = CreateGridMenu(screencenter - Vec2f(0, 40), this, Vec2f(6, 1), "On time: " + this.get_u16("ontime") + " | 30 ticks = 1 second");
	
	CGridMenu@ menu2 = CreateGridMenu(screencenter - Vec2f(0 , -40), this, Vec2f(6, 1), "Off time: " + this.get_u16("offtime") + " | 30 ticks = 1 second");
	
	
	menu1.deleteAfterClick = true;
	menu2.deleteAfterClick = true;
	//gud code
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Max(int(this.get_u16("ontime")) - 100, 1));
		CGridButton@ butt = menu1.AddButton("$min_100$", "Reduce on time by 100", this.getCommandID("seton"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Max(int(this.get_u16("ontime")) - 10, 1));
		CGridButton@ butt = menu1.AddButton("$min_10$", "Reduce on time by 10", this.getCommandID("seton"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Max(int(this.get_u16("ontime")) - 1, 1));
		CGridButton@ butt = menu1.AddButton("$min_1$", "Reduce on time by 1", this.getCommandID("seton"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Min(int(this.get_u16("ontime")) + 1, 60000));
		CGridButton@ butt = menu1.AddButton("$plus_1$", "Increase on time by 1", this.getCommandID("seton"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Min(int(this.get_u16("ontime")) + 10, 60000));
		CGridButton@ butt = menu1.AddButton("$plus_10$", "Increase on time by 10", this.getCommandID("seton"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Min(int(this.get_u16("ontime")) + 100, 60000));
		CGridButton@ butt = menu1.AddButton("$plus_100$", "Increase on time by 100", this.getCommandID("seton"), params);
	}


	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Max(int(this.get_u16("offtime")) - 100, 1));
		CGridButton@ butt = menu2.AddButton("$min_100$", "Reduce off time by 100", this.getCommandID("setoff"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Max(int(this.get_u16("offtime")) - 10, 1));
		CGridButton@ butt = menu2.AddButton("$min_10$", "Reduce off time by 10", this.getCommandID("setoff"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Max(int(this.get_u16("offtime")) - 1, 1));
		CGridButton@ butt = menu2.AddButton("$min_1$", "Reduce off time by 1", this.getCommandID("setoff"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Min(int(this.get_u16("offtime")) + 1, 60000));
		CGridButton@ butt = menu2.AddButton("$plus_1$", "Increase off time by 1", this.getCommandID("setoff"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Min(int(this.get_u16("offtime")) + 10, 60000));
		CGridButton@ butt = menu2.AddButton("$plus_10$", "Increase off time by 10", this.getCommandID("setoff"), params);
	}
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(Maths::Min(int(this.get_u16("offtime")) + 100, 60000));
		CGridButton@ butt = menu2.AddButton("$plus_100$", "Increase off time by 100", this.getCommandID("setoff"), params);
	}
	
}

void onTick(CSprite@ this)
{
	CLogicPlug@ o = getLogicPlug(this.getBlob(), 0);
	if(o.getState() && this.getFrame() == 0)
		this.SetFrame(1);
	else if(!o.getState() && this.getFrame() == 1)
		this.SetFrame(0);
}



