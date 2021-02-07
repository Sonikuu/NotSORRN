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
			if(isServer && caller !is null)
			{
				CInventory@ inv = caller.getInventory();
				for(int i = 0; i < 5; i++)
				{
					CGunRequirements@ tr = @(gunreqs[i][this.get_u8("selpart" + i)]);
					for(int j = 0; j < tr.materials.size(); j++)
					{
						inv.server_RemoveItems(tr.materials[j], tr.amt[j]);
					}
				}
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

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CGridMenu@ activemenu = getGridMenuByName("Part");
	CBlob@ caller = getLocalPlayerBlob();

	if(activemenu !is null)
	{
		//------------Building Req list-----------
		CInventory@ inv = caller.getInventory();
		array<array<bool>> reqcache;

		array<string> totalreqs;
		array<int> totalamt;
		for(int i = 0; i < gunreqs.size(); i++)
		{
			reqcache.push_back(array<bool>());
			for(int j = 0; j < gunreqs[i].size(); j++)
			{
				CGunRequirements@ tr = @(gunreqs[i][j]);
				bool canmake = true;
				
				for(int e = 0; e < tr.materials.size(); e++)
				{
					if(blob.get_u8("selpart" + i) == j)
					{
						int findpos = totalreqs.find(tr.materials[e]);
						if(findpos >= 0)
						{	
							totalamt[findpos] += tr.amt[e];
						}
						else
						{
							totalreqs.push_back(tr.materials[e]);
							totalamt.push_back(tr.amt[e]);
						}
					}

					if(inv.getCount(tr.materials[e]) < tr.amt[e])
					{
						canmake = false;
						break;
					}
				}
				reqcache[i].push_back(canmake);
			}
		}
		//-------------------------------------------------------------
		const int padding = 32;
		GUI::DrawPane(Vec2f(getScreenWidth() - 312 + padding, getScreenHeight() / 4 - (totalreqs.size()) * padding * 0.5 - 12 + padding),
		 Vec2f(getScreenWidth() - 36, getScreenHeight() / 4 + (totalreqs.size()) * padding * 0.5 + 12 + padding));
		for(int i = 0; i < totalreqs.size(); i++)
		{
			GUI::SetFont("menu");
			bool hasmats = inv.getCount(totalreqs[i]) >= totalamt[i];
			Vec2f pos = Vec2f(getScreenWidth() - 300, (getScreenHeight() / 4 - totalreqs.size() * padding * 0.5) + padding * (i + 1));
			GUI::DrawIconByName("$" + totalreqs[i] + "$", pos + Vec2f(padding, 0));
			GUI::DrawText((hasmats ? "" : "$RED$") + totalamt[i] + " " + totalreqs[i] + (hasmats ? "" : "$RED$"), 
			pos + Vec2f(padding * 2, 0), 
			Vec2f(getScreenWidth() - 50, pos.y),
			SColor(255, 255, 255, 255),
			true, true, false);
		}
		//Title and stats rendering
		{
			u8 coreindex = blob.get_u8("selpart0");
			u8 barrelindex = blob.get_u8("selpart1");
			u8 stockindex = blob.get_u8("selpart2");
			u8 gripindex = blob.get_u8("selpart3");
			u8 magindex = blob.get_u8("selpart4");
			
			//FIRST INDEX IS TYPE, SECOND IS PART
			if(coreindex >= gunparts[0].length || barrelindex >= gunparts[1].length || stockindex >= gunparts[2].length || gripindex >= gunparts[3].length || magindex >= gunparts[4].length)
			{
				//this.server_Die();
				print("INVALID CUSTOM GUN PARTS Gunbench.as onRender()");
				return;
			}
			CGunPart@ corepart = @(gunparts[0][coreindex]);
			CGunPart@ barrelpart = @(gunparts[1][barrelindex]);
			CGunPart@ stockpart = @(gunparts[2][stockindex]);
			CGunPart@ grippart = @(gunparts[3][gripindex]);
			CGunPart@ magpart = @(gunparts[4][magindex]);

			CGunEquipment@ gun = calculateGunStats(corepart, barrelpart, stockpart, grippart, magpart);
	
			string rendertext = getGunTitle(corepart, barrelpart, stockpart, grippart, magpart) + "\n" + getGunDescription(corepart, gun);
			Vec2f txtdim;
			GUI::GetTextDimensions(rendertext, txtdim);
			GUI::DrawText(rendertext, 
			Vec2f(getScreenWidth() - 50 - txtdim.x, (getScreenHeight() / 4) * 3 - txtdim.y / 2), 
			Vec2f(getScreenWidth() - 50, (getScreenHeight() / 4) * 3 + txtdim.y / 2),
			SColor(255, 255, 255, 255),
			true, true, true);
		}
	
	}
}

void makeGunMenu(CBlob@ this, CBlob@ caller)
{
	caller.ClearMenus();
	int buttons = gunparts.length;
	int startoffsx = ((buttons - 1) * -96) - 100;
	Vec2f screencenter(getScreenWidth() / 2, getScreenHeight() / 2);

	//Ahhh fun, adding requirements is always my favorite thing to do ever
	CInventory@ inv = caller.getInventory();
	array<array<bool>> reqcache;

	array<string> totalreqs;
	array<int> totalamt;
	bool canmakegunoverride = true;
	for(int i = 0; i < gunreqs.size(); i++)
	{
		reqcache.push_back(array<bool>());
		for(int j = 0; j < gunreqs[i].size(); j++)
		{
			CGunRequirements@ tr = @(gunreqs[i][j]);
			bool canmake = true;
			
			for(int e = 0; e < tr.materials.size(); e++)
			{
				if(this.get_u8("selpart" + i) == j)
				{
					int findpos = totalreqs.find(tr.materials[e]);
					if(findpos >= 0)
					{	
						totalamt[findpos] += tr.amt[e];
					}
					else
					{
						totalreqs.push_back(tr.materials[e]);
						totalamt.push_back(tr.amt[e]);
					}
				}

				if(inv.getCount(tr.materials[e]) < tr.amt[e])
				{
					canmake = false;
					if(this.get_u8("selpart" + i) == j)
						canmakegunoverride = false;
					break;
				}
			}
			reqcache[i].push_back(canmake);
		}
	}
	
	for(int i = 0; i < gunparts.length; i++)
	{
		int shortening = 0;
		for(int x = 0; x < gunreqs[i].size(); x++)
		{
			if(gunreqs[i][x].hidden && !reqcache[i][x])
				shortening++;
		}
		CGridMenu@ menu = CreateGridMenu(screencenter + Vec2f(startoffsx + i * 96, 0), this, Vec2f(2, gunparts[i].length - shortening), "Part");
		menu.SetCaptionEnabled(false);
		for(int j = 0; j < gunparts[i].length; j++)
		{
			if(gunreqs[i][j].hidden && !reqcache[i][j])
				continue;
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(i);
			params.write_u8(j);
			CGridButton@ butt = menu.AddButton("$gun_part" + i + "" + j + "$", "Select " + gunparts[i][j].name, this.getCommandID("selectpart"), params);
			if(this.get_u8("selpart" + i) == j)
				butt.SetSelected(1);
			if(!reqcache[i][j])
				butt.SetEnabled(false);
			butt.SetHoverText(gunparts[i][j].name);
		}
	}
	
	if(canmakegunoverride)
	{
		for(int i = 0; i < totalreqs.size(); i++)
		{
			if(inv.getCount(totalreqs[i]) < totalamt[i])
			{
				canmakegunoverride = false;
				break;
			}
		}
	}
	CGridMenu@ menu = CreateGridMenu(screencenter + Vec2f(startoffsx + 6 * 96, 0), this, Vec2f(2, 2), "Finish");
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	params.write_u8(6);
	params.write_u8(0);
	CGridButton@ butt = menu.AddButton("$finish_gun$", "Finish Building", this.getCommandID("selectpart"), params);
	if(!canmakegunoverride)
		butt.SetEnabled(false);
	
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
