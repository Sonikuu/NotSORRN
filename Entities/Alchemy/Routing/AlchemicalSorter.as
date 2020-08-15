#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	//Setup tanks
	CAlchemyTank@ input = addTank(this, "Input", true, Vec2f(0, -4));
	addTank(this, "Left Output", false, Vec2f(-10, 4));
	addTank(this, "Middle Output", false, Vec2f(0, 4));
	addTank(this, "Right Output", false, Vec2f(10, 4));
	
	this.set_string("filter1", "none");
	this.set_string("filter2", "none");
	this.set_string("filter3", "none");
	
	AddIconToken("$config_sorter$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	
	this.addCommandID("configmenu");
	this.addCommandID("config");
	
	input.unmixedstorage = true;
}

void onTick(CBlob@ this)
{
	
	CAlchemyTank@ input = getTank(this, "Input");
	
	CAlchemyTank@ output1 = getTank(this, "Left Output");
	CAlchemyTank@ output2 = getTank(this, "Middle Output");
	CAlchemyTank@ output3 = getTank(this, "Right Output");
	
	array<string> blacklist1 = {this.get_string("filter2"), this.get_string("filter3")};
	array<string> blacklist2 = {this.get_string("filter1"), this.get_string("filter3")};
	array<string> blacklist3 = {this.get_string("filter1"), this.get_string("filter2")};
	
	if(input !is null && output1 !is null)
		transferOnlyBlacklist(input, output1, 1, this.get_string("filter1"), @blacklist1);
	
	if(input !is null && output2 !is null)
		transferOnlyBlacklist(input, output2, 1, this.get_string("filter2"), @blacklist2);
	
	if(input !is null && output3 !is null)
		transferOnlyBlacklist(input, output3, 1, this.get_string("filter3"), @blacklist3);
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton("$config_sorter$", Vec2f(8, -4), this, this.getCommandID("configmenu"), "Configure Sorter", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("configmenu") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller is getLocalPlayerBlob() && caller !is null)
		{
			makeSorterMenu(this, caller);
		}
	}
	else if(this.getCommandID("config") == cmd)
	{
		u16 callerid = params.read_u16();
		u8 tankid = params.read_u8();
		u8 filter = params.read_u8();
		string tanknum = formatInt(tankid, "");
		print(tanknum);
		
		//Probs not gonna have 254 elements, so this is pretty safe
		string filtername = filter == 255 ? "none" :
							filter == 254 ? "any" :
							elementlist[filter].name;
		
		this.set_string("filter" + tanknum, filtername);
		CBlob@ caller = getBlobByNetworkID(callerid);
		if(caller is getLocalPlayerBlob() && caller !is null)
		{
			makeSorterMenu(this, caller);
		}
	}
}

void makeSorterMenu(CBlob@ this, CBlob@ caller)
{
	caller.ClearMenus();
	int buttons = elementlist.length + 2 - HIDDEN_ELEMENTS;
	Vec2f screencenter(getScreenWidth() / 2, getScreenHeight() / 2);
	
	CGridMenu@ menu1 = CreateGridMenu(screencenter - Vec2f(0, 80), this, Vec2f(buttons, 1), "Left Output");
	int tankid1 = 1;
	
	CGridMenu@ menu2 = CreateGridMenu(screencenter - Vec2f(0 , 0), this, Vec2f(buttons, 1), "Middle Output");
	int tankid2 = 2;
	
	CGridMenu@ menu3 = CreateGridMenu(screencenter - Vec2f(0, -80), this, Vec2f(buttons, 1), "Right Output");
	int tankid3 = 3;
	
	menu1.deleteAfterClick = true;
	menu2.deleteAfterClick = true;
	menu3.deleteAfterClick = true;
	
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(tankid1);
		params.write_u8(255);
		CGridButton@ butt = menu1.AddButton("$config_sorter$", "Allow None", this.getCommandID("config"), params);
		if(this.get_string("filter1") == "none")
			butt.SetSelected(1);
	}
	
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(tankid2);
		params.write_u8(255);
		CGridButton@ butt = menu2.AddButton("$config_sorter$", "Allow None", this.getCommandID("config"), params);
		if(this.get_string("filter2") == "none")
			butt.SetSelected(1);
	}
	
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(tankid3);
		params.write_u8(255);
		CGridButton@ butt = menu3.AddButton("$config_sorter$", "Allow None", this.getCommandID("config"), params);
		if(this.get_string("filter3") == "none")
			butt.SetSelected(1);
	}
	
	for (int i = 0; i < elementlist.length; i++)
	{
		if(elementlist[i].hidden)
			continue;
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(tankid1);
			params.write_u8(i);
			CGridButton@ butt = menu1.AddButton("$element_" + elementlist[i].name + "$", "Allow " + elementlist[i].visiblename, this.getCommandID("config"), params);
			if(this.get_string("filter1") == elementlist[i].name)
				butt.SetSelected(1);
		}
		
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(tankid2);
			params.write_u8(i);
			CGridButton@ butt = menu2.AddButton("$element_" + elementlist[i].name + "$", "Allow " + elementlist[i].visiblename, this.getCommandID("config"), params);
			if(this.get_string("filter2") == elementlist[i].name)
				butt.SetSelected(1);
		}
		
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(tankid3);
			params.write_u8(i);
			CGridButton@ butt = menu3.AddButton("$element_" + elementlist[i].name + "$", "Allow " + elementlist[i].visiblename, this.getCommandID("config"), params);
			if(this.get_string("filter3") == elementlist[i].name)
				butt.SetSelected(1);
		}
	}
	
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(tankid1);
		params.write_u8(254);
		CGridButton@ butt = menu1.AddButton("$config_sorter$", "Allow Any", this.getCommandID("config"), params);
		if(this.get_string("filter1") == "any")
			butt.SetSelected(1);
	}
	
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(tankid2);
		params.write_u8(254);
		CGridButton@ butt = menu2.AddButton("$config_sorter$", "Allow Any", this.getCommandID("config"), params);
		if(this.get_string("filter2") == "any")
			butt.SetSelected(1);
	}
	
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(tankid3);
		params.write_u8(254);
		CGridButton@ butt = menu3.AddButton("$config_sorter$", "Allow Any", this.getCommandID("config"), params);
		if(this.get_string("filter3") == "any")
			butt.SetSelected(1);
	}
}

