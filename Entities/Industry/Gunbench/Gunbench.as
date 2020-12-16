// Workbench

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"
#include "CustomGunCommon.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("can settle"); //for DieOnCollapse to prevent 2 second life :)
	this.Tag("builder always hit");

	InitWorkshop(this);
	
	AddIconToken("$gun_menu$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	AddIconToken("$finish_gun$", "MenuItems.png", Vec2f(32, 32), 28);
	
	for(int i = 0; i < gunparts.length; i++)
	{
		for(int j = 0; j < gunparts[i].length; j++)
		{
			AddIconToken("$gun_part" + i + "" + j + "$", "CustomGun.png", Vec2f(32, 16), j * 6 + i);
		}
	}
	
	this.addCommandID("openmenu");
	this.addCommandID("selectpart");
}


void InitWorkshop(CBlob@ this)
{

	this.set_Vec2f("shop offset", Vec2f(-6, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 6));

	/*{
		ShopItem@ s = addShopItem(this, "Soul Dust", "$souldust$", "souldust-3", "Smash a soul shard into dust", false);
		AddRequirement(s.requirements, "blob", "soul_chunk", "Soul Chunk", 1);
		
		AddIconToken("$soul_chunk$", "GhostShard.png", Vec2f(8, 8), 0);
		AddIconToken("$souldust$", "Souldust.png", Vec2f(16, 16), 0);
	}*/
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton("$gun_menu$", Vec2f(6, 0), this, this.getCommandID("openmenu"), "Build Gun", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop buy"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		bool spawnToInventory = params.read_bool();
		bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
		string blobName = params.read_string();
		u8 s_index = params.read_u8();

		// check spam
		//if (blobName != "factory" && isSpammed( blobName, this.getPosition(), 12 ))
		//{
		//}
		//else
		{
			this.getSprite().PlaySound("/ConstructShort");
		}
	}
	else if(cmd == this.getCommandID("openmenu"))
	{
		u16 callerID;
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && caller is getLocalPlayerBlob())
			makeGunMenu(this, caller);
	}
	else if(cmd == this.getCommandID("selectpart"))
	{
		u16 callerID;
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		u8 cat = params.read_u8();
		u8 part = params.read_u8();
		if(cat == 6)
		{
			if(isServer)
			{
				CBlob@ targetblob = server_CreateBlobNoInit("customgun");
				targetblob.setPosition(this.getPosition());
				targetblob.server_setTeamNum(this.getTeamNum());
				targetblob.set_u8("coreindex", this.get_u8("selpart0"));
				targetblob.set_u8("barrelindex", this.get_u8("selpart1"));
				targetblob.set_u8("stockindex", this.get_u8("selpart2"));
				targetblob.set_u8("gripindex", this.get_u8("selpart3"));
				targetblob.set_u8("magindex", this.get_u8("selpart4"));
				targetblob.Init();
			}
		}
		else
		{
			this.set_u8("selpart" + cat, part);
			if(caller !is null && caller is getLocalPlayerBlob())
			{
				makeGunMenu(this, caller);
			}
		}
	}
}

void makeGunMenu(CBlob@ this, CBlob@ caller)
{
	caller.ClearMenus();
	int buttons = gunparts.length;
	int startoffsx = ((buttons - 1) * -96);
	Vec2f screencenter(getScreenWidth() / 2, getScreenHeight() / 2);
	
	for(int i = 0; i < gunparts.length; i++)
	{
		CGridMenu@ menu = CreateGridMenu(screencenter + Vec2f(startoffsx + i * 96, 0), this, Vec2f(2, gunparts[i].length), "Part");
		menu.SetCaptionEnabled(false);
		for(int j = 0; j < gunparts[i].length; j++)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(i);
			params.write_u8(j);
			CGridButton@ butt = menu.AddButton("$gun_part" + i + "" + j + "$", "Select " + gunparts[i][j].name, this.getCommandID("selectpart"), params);
			if(this.get_u8("selpart" + i) == j)
				butt.SetSelected(1);
			butt.SetHoverText(gunparts[i][j].name);
		}
	}
	
	CGridMenu@ menu = CreateGridMenu(screencenter + Vec2f(startoffsx + 6 * 96, 0), this, Vec2f(2, 2), "Finish");
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	params.write_u8(6);
	params.write_u8(0);
	CGridButton@ butt = menu.AddButton("$finish_gun$", "Finish Building", this.getCommandID("selectpart"), params);
	
}

//sprite - planks layer

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(6);
		planks.SetOffset(Vec2f(3.0f, -7.0f));
		planks.SetRelativeZ(-100);
	}
}
