// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";


/*void onInit(CRules@ this)
{
	//Texture::createBySize("shadertex", getScreenWidth(), getScreenHeight());
	CFileImage img(getScreenWidth(), getScreenHeight(), true);
	img.setFilename("shadertex.png", IMAGE_FILENAME_BASE_MAPS);
	img.Save();
}

void onTick(CRules@ this)
{
	if(getGameTime() % 30 != 0)
		return;
	//ImageData@ data = Texture::data("shadertex");
	//data.put(XORRandom(data.width()), XORRandom(data.height()), SColor(255, 255, 255, 255));
	//Texture::update("shadertex", data);
	
	CFileImage img("shadertex");
	img.setFilename("shadertex.png", IMAGE_FILENAME_BASE_MAPS);
	for(int i = 0; i < 100; i++)
		img.setPixelAtPosition(XORRandom(img.getWidth()), XORRandom(img.getHeight()), SColor(255, 255, 255, 255), false);
	img.Save();
	getDriver().SetShaderExtraTexture("noise", "Maps/shadertex.png");
	
	
}*/

//bool colortextsonic = true;
//bool colortextzable = true;


bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	onBothProcessChat(this, text_in, text_out, player);
	if (player is null)
		return true;


	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		if(text_in == "!fixme")
		{
			CBlob@ targetblob = server_CreateBlob("builder", 0, Vec2f(0, 0));
			if(targetblob !is null)
			{
				targetblob.server_SetPlayer(player);
			}
		}
		return true;
	}

	//commands that don't rely on sv_test

	if (text_in == "!killme")
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 100.0f, 0);
	}
	else if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
	{
		CPlayer@ bot = AddBot("Henry");
		return true;
	}
	else if (text_in == "!debug" && player.isMod())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
		}
	}
	/*
	else if (text_in == "no u" || text_in == "nou" && player.getUsername() != "magestic_12")
	{
		if(player.getUsername() == "sonic7089")
		{
			player.getBlob().server_Die();
		}
		
		client_AddToChat("<" + player.getCharacterName() + ">" + text_in);
		client_AddToChat("no u", SColor(255,255,0,0));
		text_out = "";
		return false;
		
	}


	else if(player.getUsername() == "sonic7089" && text_in == "!color")
	{
		colortextsonic = !colortextsonic;
		return false;
	}


	else if(player.getUsername() == "magestic_12" && text_in == "!color")
	{
		colortextzable = !colortextzable;
		return false;
	}
	
	 else if(colortextzable && player.getUsername() == "magestic_12")
	{
	
		client_AddToChat("<" + player.getCharacterName() + "> " + text_in,SColor(255,0,0,255));
		return false;
	}  
	else if(colortextsonic && player.getUsername() == "sonic7089")
	{
	
		client_AddToChat("<sonic7089> " + text_in,SColor(255,255,103,13));
		text_out = "";
		return false;
	}
	else if(player.getUsername() == "carlospaul")
	{
		if(XORRandom(10) == 1) 
		{
		 client_AddToChat("I am retarded and you should kill me");
		}
		else
		{
			client_AddToChat("<Dumb Ass> " + text_in);
		}
		return false;
	} 

	*/

	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if (canUseCommand(player.getUsername()))
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();

		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		/*else if (text_in == "!killsonic" && player.getUsername() != "magestic_12" && player.getUsername() == "sonic7089")
		{
			CPlayer@ sonic = getPlayerByUsername("sonic7089");
			CBlob@ sonicb = sonic.getBlob();
			
			CPlayer@ hurr = getPlayerByUsername("magestic_12");
			CBlob@ durr = hurr.getBlob();
			if(hurr !is null && durr !is null)
			{
				durr.server_Die();
			}
		}*/
		else if (text_in == "!btree")
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!kit")
        {
            server_CreateBlob('mat_stone',-1,pos);
            server_CreateBlob('mat_stone',-1,pos);
            server_CreateBlob('mat_wood',-1,pos);
            server_CreateBlob('mat_wood',-1,pos);
        }
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!tree")
		{

		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!pteam")
				{
					int team = parseInt(tokens[1]);
					player.server_setTeamNum(team);
				}
				/*else if(tokens[0] == "!cfgspam")
				{
					this.set_string("spam_target", tokens[1]);
					this.set_u32("spam_size",parseInt(tokens[2]) );
					return false;
				}*/
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
						s += " " + tokens[i];
					server_MakePredefinedScroll(pos, s);
				}
				else if (tokens[0] == "!morph")
				{
					string blobname = tokens[1];
					
					CBlob@ targetblob = server_CreateBlob(blobname, team, pos);
					if(targetblob !is null)
					{
						targetblob.server_SetPlayer(player);
						blob.server_Die();
					}
				}
				else if (tokens[0] == "!cgun")
				{
					if(tokens.length > 5)
					{
						CBlob@ targetblob = server_CreateBlobNoInit("customgun");
						targetblob.setPosition(pos);
						targetblob.server_setTeamNum(team);
						targetblob.set_u8("coreindex", parseInt(tokens[1]));
						targetblob.set_u8("barrelindex", parseInt(tokens[2]));
						targetblob.set_u8("stockindex", parseInt(tokens[3]));
						targetblob.set_u8("gripindex", parseInt(tokens[4]));
						targetblob.set_u8("magindex", parseInt(tokens[5]));
						targetblob.Init();
					}
				}
				
			}
			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob(name, team, pos) is null)
			{
				client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
			}
		}
	}

	//print(text_in);

	///if( (player.getUsername() == "sonic7089" || player.getUsername() == "magestic_12") && text_in[0] == "!"[0])
	///{
		///return false;
	///}
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	onBothProcessChat(this, text_in, text_out, player);
	if (player is null)
		return true;
	CBlob@ pblob = player.getBlob();
	/*bool outputText = true;

	if( (player.getUsername() == "sonic7089" || player.getUsername() == "magestic_12") && text_in[0] == "!"[0])
	{
		outputText = false;
	}

	if ((text_in == "no u" || text_in == "nou") && player.getUsername() != "magestic_12")
	{
		if(player.getUsername() == "sonic7089")
		{
			player.getBlob().server_Die();
		}
		
		client_AddToChat("<" + player.getCharacterName() + "> " + text_in);
		if(pblob !is null)
			pblob.Chat(text_in);
		client_AddToChat("no u", SColor(255,255,0,0));
		text_out = "";
		outputText = false;
		
	}*/



	bool ismyplayer =  player is getLocalPlayer();
	if (!getNet().isServer() || true)
	{
		if(text_in == "!debug")
		{
			// print all blobs
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

				if (blob.getShape() !is null)
				{
					CBlob@[] overlapping;
					if (blob.getOverlapping(@overlapping))
					{
						for (uint i = 0; i < overlapping.length; i++)
						{
							CBlob@ overlap = overlapping[i];
							print("       " + overlap.getName() + " " + overlap.isLadder());
						}
					}
				}
			}
		}
		
		
		else if (text_in == "!disin")
		{
			if(pblob !is null)
			{
				CSprite@ sprite = pblob.getSprite();
				if(sprite !is null)
				{
					sprite.AddScript("Disintegrate");
				}
			}
		}

		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			
			
		}
	}
	
	return true;
}

bool onBothProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;
		
	text_out = text_in;
		
	bool ismyplayer = player is getLocalPlayer();
	
	CBlob@ blob = player.getBlob();
	if(blob is null)
		return true;
		
	if (canUseCommand(player.getUsername()))
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();


		if (text_in == "!bloodsky")
		{
			CMap@ map = getMap();
			map.AddScript("BloodSky");
		}
		/*else if(text_in == "!shadertest")
		{
			getDriver().ForceStartShaders();
			getDriver().AddShader("noise", 2.0);
			getDriver().SetShader("noise", true);
			print("" + getDriver().AreShadersAllowed());
			Texture::createFromFile("world.png", "world.png");
			CFileMatcher matchy("NotSORRN/Maps/shadertex.png");
			print(matchy.getFirst());
			print(matchy.getRandom());
			getDriver().SetShaderTextureFilter("noise", true);
			getDriver().SetShaderExtraTexture("noise", matchy.getFirst());
			
			
		}
		else if(text_in == "!son")
		{
			getDriver().SetShader("noise", true);
		}*/
		else if (text_in == "!tag")
		{
			if(ismyplayer)
				client_AddToChat("Usage: !tag TYPE TAGNAME VALUE PLAYERNAME[optional]", SColor(255, 255, 0, 0));
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!timespeed")
				{
					int speed = parseInt(tokens[1]);
					this.daycycle_speed = speed;
				}
				else if (tokens[0] == "!timeset")
				{
					getMap().SetDayTime(parseFloat(tokens[1]));
				}
				else if (tokens[0] == "!tickmult")
				{
					this.set_f32("tickmult", parseFloat(tokens[1]));
				}
				else if (tokens[0] == "!raincount")
				{
					this.set_u16("raincount", parseInt(tokens[1]));
				}
				else if(tokens[0] == "!tp" || tokens[0] == "!teleport")
                {
					if(tokens.length > 1)
					{
						CPlayer@ tp = getPlayerByUsername(tokens[1]);
						if(tp !is null)
						{
							CBlob@ tb = tp.getBlob();
							if(tb !is null)
							{
								blob.setPosition(tb.getPosition());
							}
						}
					}
                }
				else if (tokens[0] == "!tag")
				{
					if (tokens.length > 3)
					{
						string typein = tokens[1];
						string namein = tokens[2];
						string input = tokens[3];
						string targetname;
						if(tokens.length > 4)
						{
							if(getPlayerByUsername(tokens[4]) !is null)
							{
								targetname = tokens[4];
							}
							else
							{
								targetname = player.getUsername();
							}
						}
						else
						{
							targetname = player.getUsername();
						}
						CPlayer@ target = getPlayerByUsername(targetname);
						CBlob@ targetblob = target.getBlob();
						if(targetblob !is null)
						{
							if(typein == "u8")
							{
								u8 innum = parseInt(input);
								targetblob.set_u8(namein, innum);
							}
							else if(typein == "s8")
							{
								s8 innum = parseInt(input);
								targetblob.set_s8(namein, innum);
							}
							else if(typein == "u16")
							{
								u16 innum = parseInt(input);
								targetblob.set_u16(namein, innum);
							}
							else if(typein == "s16")
							{
								s16 innum = parseInt(input);
								targetblob.set_s16(namein, innum);
							}
							else if(typein == "u32")
							{
								u32 innum = parseInt(input);
								targetblob.set_u32(namein, innum);
							}
							else if(typein == "s32")
							{
								s32 innum = parseInt(input);
								targetblob.set_s32(namein, innum);
							}
							else if(typein == "f32")
							{
								float innum = parseFloat(input);
								targetblob.set_f32(namein, innum);
							}
							else if(typein == "bool")
							{
								
								if (input == "true")
								{
									targetblob.set_bool(namein, true);
								}
								else if (input == "false")
								{
									targetblob.set_bool(namein, false);
								}
								else
								{
									if(ismyplayer)
										client_AddToChat("true or false, its not that hard", SColor(255, 255, 0, 0));
								}
							}
							else if(typein == "string")
							{
								targetblob.set_string(namein, input);
							}
							else
							{
								if(ismyplayer)
									client_AddToChat("Types: u8, s8, u16, s16, u32, s32, f32, bool, string", SColor(255, 255, 0, 0));
							}
							//targetblob.Sync(namein, false);
						}
						
					}
					else
					{
						if(ismyplayer)
							client_AddToChat("Usage: !tag TYPE TAGNAME VALUE PLAYERNAME[optional]", SColor(255, 255, 0, 0));
					}
				}
				return true;
			}
		}
	}
		
	return true;
}

bool canUseCommand(string name)
{
	if (sv_test || name == "sonic7089" || name == "magestic_12" /* Just for testing purposes i swer*/)
	{
		return true;
	}
	return false;
}

/*void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("morph"))
	{
		if(true)
		{
			CBlob@ blob = getBlobByNetworkID(params.read_u16());
			CPlayer@ player = getPlayerByNetworkId(params.read_u16());
			if(blob !is null && player !is null)
			{
				blob.server_SetPlayer(player);
			}
		}
	}
}*/
