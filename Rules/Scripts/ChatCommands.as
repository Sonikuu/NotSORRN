//See the !test command if you want to make your own command. Search for !test.


/*
--
---
----
-----
------
-------

**************************************************
|| THANKS SADNUMAN FOR THE CHAT COMMANDS SCRIPT ||
**************************************************

-------
------
-----
----
---
--
*/

//TODO
// mute player command
//Turn all commands into methods to allow other commands to use each other and the ability to take out commands for use in other mods.
//Have an onTick method that runs commands by the amount of delay they requested. i.e a single tick of delay for spawning bots to allow them to be spawned with a blob.
//Clean up AddBot


//!tagplayer TYPE TAGNAME VALUE PLAYERNAME
//!tagblob TYPE TAGNAME VALUE BLOBNETID
//!heldblobid                  returns NETID of blob the player's controlled blob is holding. specify both client and server side NETID's.
//!timespeed SPEED

//!permissionlist             for checking security permissions

//!getplayerroles (PLAYERNAME)

//!announce command

//!tagplayer - tag the CPlayer


#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

bool ExtraCommands = true;//Make this false if you want all the new commands to be disabled. But why would you?

enum CommandEnum
{
    //CommandEnum 0 is nothing/blank/null, whatever you want to call it.

	//Default
	AllMats = 1,
	WoodStone,
	StoneWood,
	Wood,
	Stones,
	Gold,
	Tree,
	BTree,
	AllArrows,
	Arrows,
	AllBombs,
	Bombs,
	SpawnWater,
	Seed,
	Crate,
	Scroll,
	Coins,
	CoinOverload,
	FishySchool,
	ChickenFlock,
	//ExtraCommands below here
    HideCommands,
	Help,
	PlayerCount,
	//NextMap,
	SpinEverything,
	ToggleFeatures,
    Test,
	GiveCoin,
    PrivateMessage,
	SetTime,
	Ban,
    Unban,
	Kick,
	Freeze,
	Teleport,
	Coin,
	SetHp,
	Damage,
	Kill,
	Team,
	PlayerTeam,
	ChangeName,
	Actor,
    AddRobot,
	ForceRespawn,
	Give,
    TagBlob,
    TagPlayerBlob,
    HeldBlobNetID,
    PlayerBlobNetID,
    PlayerNetID,
    Announce,
    Nothing,//End
}

enum PermissionLevel
{
    Moderator = 1,
    Admin,
    SuperAdmin,
}

void onInit(CRules@ this)
{
	this.addCommandID("clientmessage");	
	this.addCommandID("teleport");
    this.addCommandID("clientshowhelp");
	this.addCommandID("allclientshidehelp");
    this.addCommandID("announcement");
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	//--------MAKING CUSTOM COMMANDS-------//
	// Inspect commented out !nextmap command
    // It will show you the basics

	if (player is null)
		return true;

	CBlob@ blob = player.getBlob(); // now, when the code references "blob," it means the player who called the command

	//if (blob is null && !player.isMod())
	//{
	//	return true;
	//}
	Vec2f pos;
	int team;
	if (blob !is null)
	{
		pos = blob.getPosition(); // grab player position (x, y)
		team = blob.getTeamNum(); // grab player team number (for i.e. making all flags you spawn be your team's flags)
	}

	uint8 permlevel = 0;//what level of adminship you need to use this command
	if (text_in == "!debug" && player.isMod())
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

	if(text_in.substr(0, 1) == "!")
	{
        bool no_sv_test = false;//All commands besides those specified with no_sv_test = true;(and those that have their personal security checks like the ban command) can be used when sv_test is 1.
        bool blob_must_exist = false;//If this is true, the player's blob must exist to use the command.

        u8 minimum_parameter_count = 0;

		string[]@ tokens = text_in.split(" ");

		//Params
		uint16 commandenum = 0;
		uint8 target_player_slot = 0;
		bool target_player_blob_param = false;




        //Find the sent command, set the required permissions for the commands, and setup anything else needed before running the command code. 


        //Legacy commands, do not edit.
		if (tokens[0] == "!allmats")//What you have to type in chat to use this command
		{
			commandenum = AllMats;//What command it activates
            permlevel = Moderator;
        }
		else if (tokens[0] == "!woodstone")
		{
			commandenum = WoodStone;
            permlevel = Moderator;
        }
		else if (tokens[0] == "!stonewood")
		{
			commandenum = StoneWood;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!wood")
		{
			commandenum = Wood;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!stones" || tokens[0] == "!stone")
		{
			commandenum = Stones;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!gold")
		{
			commandenum = Gold;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!tree")
		{
			commandenum = Tree;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!btree")
		{
			commandenum = BTree;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!allarrows")
		{
			commandenum = AllArrows;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!arrows")
		{
			commandenum = Arrows;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!allbombs")
		{
			commandenum = AllBombs;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!bombs")
		{
			commandenum = Bombs;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!spawnwater")
		{
			commandenum = SpawnWater;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!seed")
		{
			commandenum = Seed;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!crate")
		{
			commandenum = Crate;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!scroll")
		{
			commandenum = Scroll;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!fishyschool")
		{
			commandenum = FishySchool;
            permlevel = Moderator;
		}
		else if (tokens[0] == "!chickenflock")
		{
			commandenum = ChickenFlock;
            permlevel = Moderator;
		}//Legacy commands end

		//Extra
		else if (tokens[0] == "!togglefeatures")// Disables/Enables the extra modded commands
		{
            permlevel = SuperAdmin;
			no_sv_test = true;
            commandenum = ToggleFeatures;
		}
		else if (ExtraCommands == false)//Stops checking the rest if ExtraCommands is off
		{
            if (tokens[0] == "!team")//check team though. It exists without ExtraCommands
		    {
                permlevel = Admin;
			    commandenum = Team;

                minimum_parameter_count = 1;
            }
		}
        
        else if(tokens[0] == "!test")//!test (number) (username)
        {
            commandenum = Test;//The most important part. This tells the code below which command was specified. When you add a command, add the name to it up in the CommandEnum enum just like how the Test command did it.

            permlevel = Admin;//Assigns the permission level to be admin. You must be an admin to use this command.
			
            if(tokens.length > 2)//This is an optional part. If there are more then 2 tokens, do the code inside. For example "!test 99 the1sad1numanator".  This has 3 tokens, 1: !test 2: 99 3: the1sad1numanator
			{//This is most useful when having a command that by default specifies the player that used it, but can specify another player optionally. 
 
                permlevel = SuperAdmin;//Reassign the perm level to be SuperAdmin. You must now be a SuperAdmin to use this command.
				
                target_player_slot = 2;//Specifies which token the playerusername is on. In this case it is the third token, but since things start from 0 in programming we assign it to 2. 
				//Specifying this tells some code below to figure out what player has the specified username and put it into the "target_player" variable for later use in the script. 
                //If the player does not exist, it will not run the actual command code and the client that ran this command will be informed.

                target_player_blob_param = true;//After getting the target_player, making this variable true will get the blob from the target_player and put it into the variable "target_blob".
                //Like the target_player, if the target_blob does not exist, the actual command code will not run and the client will be informed that the target_player had no blob.
                //These target_ variables will be further discussed later in the code that makes up the command.

                //Simply put, using target_player and target_blob you do not need to do null checks. It handles it itself. 
            }

            no_sv_test = true;//All commands besides those specified with no_sv_test = true;(and those that have their personal security checks like the ban command) can be used when sv_test is 1.
        
            blob_must_exist = true;//If this is true, when the player's blob does not exist the command code will not run and the player will be informed that their blob is null.

            minimum_parameter_count = 0;//Specifies at minimum how many parameters a command must have. If the number of parameters is less than the minimum, some code prevents the command from running and tells the user.

            //Open your search (usually ctrl + f) and type !test. Find the other part of the test command.
        }
		
        else if (tokens[0] == "!commands" || tokens[0] == "!showcommands")
		{
			commandenum = Help;
		}
        else if(tokens[0] == "!heldblobnetid" || tokens[0] == "!heldblobid" || tokens[0] == "!heldid")//!heldblobid - returns netid of held blob
        {
            commandenum = HeldBlobNetID;

            blob_must_exist = true;
        }
        else if(tokens[0] == "!playerid" || tokens[0] ==  "!playernetid")//!playerid (username) - returns netid of the player
        {
            commandenum = PlayerNetID;
            if(tokens.length > 1)
            {
                target_player_slot = 1;
            }
        }            
        else if(tokens[0] == "!heldblobnetid" || tokens[0] == "!heldblobid" || tokens[0] == "!heldid")//!heldblobid - returns netid of held blob
        {
            commandenum = HeldBlobNetID;

            blob_must_exist = true;
        }
        else if(tokens[0] == "!playerblobnetid" || tokens[0] == "!playerblobid")//!playerblobid (username) - returns netid of players blob
        {
            commandenum = PlayerBlobNetID;
            if(tokens.length > 1)
            {
                target_player_slot = 1;
                target_player_blob_param = true;
            }
            else
            {
                blob_must_exist = true;
            }

        }
		else if (tokens[0] == "!playercount")//!playercount - prints the playercount for just you
		{
			commandenum = PlayerCount;
		}
        else if (tokens[0] == "!announce")
        {
            commandenum = Announce;
            permlevel = Admin;
        }
        else if (tokens[0] == "!tagplayerblob")//!tagplayerblob "type" "tagname" "value" (PLAYERNAME) - defaults to yourself, type can equal "u8, s8, u16, s16, u32, s32, f32, bool, string, tag"
		{
			commandenum = TagPlayerBlob;

            if(tokens.length > 4)
            {
                target_player_slot = 4;
                target_player_blob_param = true;
            }
            else
            {
                blob_must_exist = true;
            }

            permlevel = Admin;
            minimum_parameter_count = 3;
        }
        else if (tokens[0] == "!tagblob")//!tagblob "type" "tagname" "value" "blobnetid" - type can equal "u8, s8, u16, s16, u32, s32, f32, bool, string, tag"
		{
			commandenum = TagBlob;
            permlevel = Admin;
            minimum_parameter_count = 4;
        }
		else if (tokens[0] == "!hidecommands")//!hidecommands - after using this command you will no longer print your !command messages to chat, use again to disable this
		{
            permlevel = SuperAdmin;
            no_sv_test = true;
			commandenum = HideCommands;
		}
		else if (tokens[0] == "!spineverything")//Spins everything
		{
            permlevel = SuperAdmin;
			commandenum = SpinEverything;
		}
		else if (tokens[0] == "!settime")//sets the time, input between 0.0 - 1.0
		{
            permlevel = SuperAdmin;
			commandenum = SetTime;
            minimum_parameter_count = 1;
		}
		else if (tokens[0] == "!givecoin")//!givecoin "amount" "player" gives coin to player, deducts from your coins
		{
			commandenum = GiveCoin;
			target_player_slot = 2;//This command requires a player on the second argument (for this it would be !givecoin 10 xXGamerXx)
            
            minimum_parameter_count = 2;
        }
        else if(tokens[0] == "!pm")//!pm "player" "message"
        {
            commandenum = PrivateMessage;
            target_player_slot = 1;

            minimum_parameter_count = 2;
        }
		else if (tokens[0] == "!ban")//!ban "player" "minutes"
		{
            if(!getSecurity().checkAccess_Command(player, "ban")){
                sendClientMessage(this, player, "You do not sufficient permissions to ban a player.");
                return true;
            }

			commandenum = Ban;
			target_player_slot = 1;

            minimum_parameter_count = 1;
		}
        else if (tokens[0] == "!unban")//!unban "player"
		{
            if(!getSecurity().checkAccess_Command(player, "unban")){
                sendClientMessage(this, player, "You do not sufficient permissions to unban a player.");
                return true;
            }

			commandenum = Unban;

            minimum_parameter_count = 1;
		}
		else if (tokens[0] == "!kickp")//!kickp "player"
		{
            if(!getSecurity().checkAccess_Command(player, "kick")){
                sendClientMessage(this, player, "You do not sufficient permissions to kick a player.");
                return true;
            }

			commandenum = Kick;
			target_player_slot = 1;

            minimum_parameter_count = 1;
		}
        else if (tokens[0] == "!kick")
        {
            sendClientMessage(this, player, "You might be looking for the command, \"!kickp\" - CommandChat");
            return false;
        }
		else if (tokens[0] == "!freeze")//!freeze "player"
		{
            if(!getSecurity().checkAccess_Command(player, "freezeid") || !getSecurity().checkAccess_Command(player, "unfreezeid")){
                sendClientMessage(this, player, "You do not sufficient permissions to freeze and unfreeze a player.");
                return true;
            }
            
			commandenum = Freeze;
			target_player_slot = 1;

            minimum_parameter_count = 1;
		}
		/*else if (tokens[0] == "!nextmap")
		{
            permlevel = Admin;
			commandenum = NextMap;
		}*/
		else if (tokens[0] == "!team")//!team "team" (player)
		{
            permlevel = Admin;
			commandenum = Team;
			if(tokens.length > 2)
			{
                permlevel = Admin;
				target_player_slot = 2;
				target_player_blob_param = true;
			}
            else
            {
                blob_must_exist = true;
            }
		}
		else if (tokens[0] == "!playerteam")//!playerteam "team" (player) - this changes the playerteam (team on scoreboard and respawn), it does not change your blob
		{
            permlevel = Admin;
			commandenum = PlayerTeam;
			if(tokens.length > 2)
			{
                permlevel = Admin;
				target_player_slot = 2;
			}
		}
		else if (tokens[0] == "!changename")//!changename "username" (player)
		{
			commandenum = ChangeName;
			if(tokens.length > 2)
			{
                permlevel = Admin;
				target_player_slot = 2;
			}
            
            minimum_parameter_count = 1;
		}
		else if (tokens[0] == "!teleport" || tokens[0] == "!tp")//!teleport "player" - teleports to player || !teleport "player1" "player2" - teleports player1 to player2
		{
            permlevel = Admin;
			commandenum = Teleport;
			target_player_slot = 1;
			target_player_blob_param = true;//This command requires the targets blob
		
            minimum_parameter_count = 1;
        }
		else if (tokens[0] == "!coin")//!coin "amount" (player)
		{
            permlevel = Admin;
			commandenum = Coin;
			if(tokens.length > 2)//This command is optional
			{
				target_player_slot = 2;
			}
		
            minimum_parameter_count = 1;
        }
		else if (tokens[0] == "!damage")//!damage "amount" (player)
		{
            permlevel = Admin;
			commandenum = Damage;
			if(tokens.length > 2)
			{
				target_player_slot = 2;
				target_player_blob_param = true;
			}
		
            minimum_parameter_count = 1;
        }
		else if (tokens[0] == "!kill")//!kill "player"
		{
            permlevel = Admin;
			commandenum = Kill;
			target_player_slot = 1;
			target_player_blob_param = true;
		
            minimum_parameter_count = 1;
        }
		else if (tokens[0] == "!actor" || tokens[0] == "!playerblob" || tokens[0] == "!morph")//!actor "blob" (player)
		{
            permlevel = Admin;
			commandenum = Actor;
			if(tokens.length > 2)
			{
				target_player_slot = 2;
				target_player_blob_param = true;
			}
		
            minimum_parameter_count = 1;
        }
        else if (tokens[0] == "!bot" || tokens[0] == "!addbot" || tokens[0] == "!createbot")////!addbot (on_player) (blob) (team) (name) (difficulty 1-15)
        {
            permlevel = Admin;
			commandenum = AddRobot;
        }
		else if (tokens[0] == "!forcerespawn")//!forcerespawn (player)
		{
            permlevel = Admin;
			target_player_slot = 1;
			commandenum = ForceRespawn;
		}
		else if (tokens[0] == "!give")//!give "blob" (amount) (player)
		{
            permlevel = Admin;
			commandenum = Give;
			if(tokens.length > 3)
			{
				target_player_slot = 3;
				target_player_blob_param = true;
			}

            minimum_parameter_count = 1;
		}
        else if (tokens[0] == "!sethp")//!sethp "amount" (player) //() <- optional
		{
            permlevel = Admin;
			
			commandenum = SetHp;
			if(tokens.length > 2)
			{
				target_player_slot = 2;
				target_player_blob_param = true;
			}

            minimum_parameter_count = 1;
		}
		
        //Command param and security list end

        if(blob_must_exist)
        {
            if(blob == null)
            {
                sendClientMessage(this, player, "Your blob appears to be null, this command will not work unless your blob actually exists.");
                return !this.get_bool(player.getUsername() + "_hidecom");
            }
        }

        if(no_sv_test)
        {
            sv_test = false;
        }   



        if(permlevel == Moderator && !player.isMod() && !sv_test)
        {
            sendClientMessage(this, player, "You must be a moderator or higher to use this command.");
            return true;
        }
        if(permlevel == Admin && !getSecurity().checkAccess_Command(player, "admin_color") && !sv_test)
        {
            sendClientMessage(this, player, "You must be a admin or higher to use this command.");
            return true;
        }
        if(permlevel == SuperAdmin && !getSecurity().checkAccess_Command(player, "ALL") && !sv_test)
        {
            sendClientMessage(this, player, "You must be a superadmin to use this command.");
            return true;
        }


        if(tokens.length < minimum_parameter_count + 1)
        {
            sendClientMessage(this, player, "This command requires at least " + minimum_parameter_count + " parameters.");
            return !this.get_bool(player.getUsername() + "_hidecom");
        }


		if(commandenum == 0 && (sv_test || getSecurity().checkAccess_Command(player, "admin_color")))//If this isn't a command
		{
			string name = text_in.substr(1, text_in.size());
			if(blob != null)
			{
				server_CreateBlob(name, team, pos);
			}
			return !this.get_bool(player.getUsername() + "_hidecom");
		}

		//Assign needed values

		CPlayer@ target_player;
		CBlob@ target_blob;

		if(target_player_slot != 0)
		{
			if(tokens.length <= target_player_slot)
			{
				sendClientMessage(this, player, "You must specify the player on param " + target_player_slot);
				return false;
			}

			array<CPlayer@> target_players = getPlayersByShortUsername(tokens[target_player_slot]);//Get a list of players that have this as the start of their name
            if(target_players.length() > 1)//If there is more than 1 player in the list
            {
                string playernames = "";
                for(int i = 0; i < target_players.length(); i++)//for every player in that list
                {
                    playernames += " : " + target_players[i].getUsername();// put their name in a string
                }
                sendClientMessage(this, player, "There is more than one possible player" + playernames);//tell the client that these players in the string were found
                return false;//don't send the message to chat, don't do anything else
            }
            else if(target_players == null || target_players.length == 0)
            {
                sendClientMessage(this, player, "No players were found from " + tokens[target_player_slot]);
                return false;
            }

            
			@target_player = target_players[0];

            if (target_player != null)
			{
				if(target_player_blob_param == true)
				{
					@target_blob = @target_player.getBlob();
					if(target_blob == null)
					{
						sendClientMessage(this, player, "This player does not yet have a blob.");
						return false;
					}
				}
			}
			else
			{
				sendClientMessage(this, player, "player " + tokens[target_player_slot] + " not found");
				return false;
			}
		}


        //Legacy code:

		//If the gamemode is sandbox
		if (this.gamemode_name == "Sandbox")
		{
			switch(commandenum)
			{
				case AllMats: // 500 wood, 500 stone, 100 gold
				{
					//wood
					CBlob@ wood = server_CreateBlob('mat_wood', -1, pos);
					wood.server_SetQuantity(500); // so I don't have to repeat the server_CreateBlob line again
					//stone
					CBlob@ stone = server_CreateBlob('mat_stone', -1, pos);
					stone.server_SetQuantity(500);
					//gold
					CBlob@ gold = server_CreateBlob('mat_gold', -1, pos);
					gold.server_SetQuantity(100);
					break;
				}
				case WoodStone: // 250 wood, 500 stone
				{
					CBlob@ b = server_CreateBlob('mat_wood', -1, pos);

					for (int i = 0; i < 2; i++)
					{
						CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
					}
					break;
				}
				case StoneWood: // 500 wood, 250 stone
				{
					CBlob@ b = server_CreateBlob('mat_stone', -1, pos);

					for (int i = 0; i < 2; i++)
					{
						CBlob@ b = server_CreateBlob('mat_wood', -1, pos);
					}
					break;
				}
				case Wood: // 250 wood
				{
					CBlob@ b = server_CreateBlob('mat_wood', -1, pos);
					break;
				}
				case Stones: // 250 stone
				{
					CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
					break;
				}

				case Gold:// 200 gold
				{
					for (int i = 0; i < 4; i++)
					{
						CBlob@ b = server_CreateBlob('mat_gold', -1, pos);
					}
					break;
				}
			}
		}

        switch(commandenum)
        {
            case Tree:
                server_MakeSeed(pos, "tree_pine", 600, 1, 16);
                break;
            case BTree:
                server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
                break;
            case AllArrows:
            {
                CBlob@ normal = server_CreateBlob('mat_arrows', -1, pos);
                CBlob@ water = server_CreateBlob('mat_waterarrows', -1, pos);
                CBlob@ fire = server_CreateBlob('mat_firearrows', -1, pos);
                CBlob@ bomb = server_CreateBlob('mat_bombarrows', -1, pos);
                break;
            }
            case Arrows:
            {
                for (int i = 0; i < 3; i++)
                {
                    CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);
                }
                break;
            }
            case AllBombs:
            {
                for (int i = 0; i < 2; i++)
                {
                    CBlob@ bomb = server_CreateBlob('mat_bombs', -1, pos);
                }
                CBlob@ water = server_CreateBlob('mat_waterbombs', -1, pos);
                break;
            }
            case Bombs:
                for (int i = 0; i < 3; i++)
                {
                    CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
                }
            break;
            case SpawnWater:
                getMap().server_setFloodWaterWorldspace(pos, true);
            break;
            case Seed:
                // crash prevention?
            break;
            case Crate:
                sendClientMessage(this, player, "usage: !crate BLOBNAME [DESCRIPTION]"); //e.g., !crate shark Your Little Darling
                server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
                return this.get_bool(player.getUsername() + "_hidecom");//To prevent overlap
            break;
            case Coins:
                player.server_setCoins(player.getCoins() + 100);
            break;
            case CoinOverload:
                player.server_setCoins(player.getCoins() + 10000);
            break;
            case FishySchool:
                for (int i = 0; i < 12; i++)
                {
                    CBlob@ b = server_CreateBlob('fishy', -1, pos);
                }
            break;
            case ChickenFlock:
                for (int i = 0; i < 12; i++)
                {
                    CBlob@ b = server_CreateBlob('chicken', -1, pos);
                }
            break;
        }
        //Legacy code end



        
        if (commandenum == ToggleFeatures)
        {
            if(ExtraCommands)
            {
                CBitStream params;
                this.SendCommand(this.getCommandID("allclientshidehelp"), params);
                ExtraCommands = false;
                sendClientMessage(this, player, "Extra commands are disabled");
            }
            else
            {
                ExtraCommands = true;
                sendClientMessage(this, player, "Extra commands are enabled");
            }
            return false;
        }

        //Single argument extra commands
        if (ExtraCommands == true)
        {
            switch(commandenum)
            {
                case Help://!commands - Help, I'm being held hostage by my own brain
                {
                    CBitStream params;
                    this.SendCommand(this.getCommandID("clientshowhelp"), params, player);
                    return false;
            
                    //break;
                }
                case HideCommands://!hidecommands - after using this command you will no longer print your !command messages to chat, use again to disable this
                {
                    //I'd like feedback on this, should people be able to hide their own commands? - Numan
                    bool hidecom = false;
                    if(this.get_bool(player.getUsername() + "_hidecom") == false)
                    {
                        hidecom = true;
                    }
                    
                    this.set_bool(player.getUsername() + "_hidecom", hidecom);
                    return false;
                    //break; //Not needed because of  "return false;"
                }
                case PlayerCount://!playercount - prints the playercount for you
                {
                    uint16 playercount = getPlayerCount();
                    if(playercount > 1) {
                        sendClientMessage(this, player, "There are " + getPlayerCount() + " Players here.");
                    }
                    else {
                        sendClientMessage(this, player, "It's just you.");
                    }
                    break;
                }
                case Announce://!announce - shows text on screen to everyone
                {
                    CBitStream params;
					params.write_string(text_in.substr(tokens[0].length()));
					this.SendCommand(this.getCommandID("announcement"), params);

                    break;
                }
                /*case NextMap:
                {
                    LoadNextMap();
                }*/
                case SpinEverything://!spineverything - spins everything
                {
                    uint32 rotationvelocity = 100;
                    if(tokens.length > 1)
                    {
                        rotationvelocity = parseInt(tokens[1]);
                    }
                    CBlob@[] blobs;
                    getBlobs(@blobs); 
                    for(int i = 0; i < blobs.length; i++)
                    {
                        CShape@ s = blobs[i].getShape();
                        if(s != null)
                        {
                            s.server_SetActive(true); s.SetRotationsAllowed(true); s.SetStatic(false); s.SetAngularVelocity(XORRandom(rotationvelocity));
                        }
                    }	
                    break;
                }



                case Test://!test (number) (playerusername) - You found it. Read the stuff below to be informed on how to make commands.
                {
                    sendClientMessage(this, player, "You just used the test command.");//This method sends a message to the specified player. the "player" variable is the player that used the !test command.

                    if(tokens.length > 1)//If there are more than a single token. The first token is command itself, and the second token is the number in this case.
                    {
                        string string_number = tokens[1];//Here we get the very first parameter, the number, and put it in the string.

                        u8 number = parseInt(string_number);//We take the very first parameter and turn it into an int variable with the name "number".
                        
                        sendClientMessage(this, player, "There is a parameter specified. The first parameter is: " + number);//Message the player that sent this command this.

                        if (tokens.length > 2)//If there are more than two tokens. The first token is the command itself, the second is the number, the third is the specified player.
                        {
                            sendClientMessage(this, player, "There are two parameters specified, the second parameter is: " + tokens[2], SColor(255, 0, 0, 153));//This time we specify a color.
                        
                            //Tip, you do not need to check if the target_player or target_blob exist, that is already handled by something else.

                            target_blob.server_setTeamNum(number);//As we specified the target_player_blob_param = true; we have the blob of the target_player right here.

                            sendClientMessage(this, target_player, "Your team has been changed to " + number + " by " + player.getUsername() + " who is on team " + team);//This sends a message to the target_player
                        }

                        //If there is only 1 parameter (2 tokens) do this.
                        else if(blob != null)//Remember to check if the blob of the player that sent this command is null
                        {
                            blob.server_setTeamNum(number);//Set the player's blob that sent this command to the specified team.
                        }
                    }


                    break;//Remember to leave this at the end of commands as to not pass into the next command (unless that is what you want to do.)
                }

                case HeldBlobNetID://!heldblobid - returns netid of held blob
                {

                    CBlob@ held_blob = blob.getCarriedBlob();
                    if(held_blob != null)
                    {
                        sendClientMessage(this, player, "NetID: " + held_blob.getNetworkID());
                    }
                    else
                    {
                        sendClientMessage(this, player, "Held blob not found.");
                    }

                    break;
                }
                
                case PlayerBlobNetID://!playerblobid (username) - returns netid of players blob
                {
                    if(tokens.length > 1)
                    {
                        sendClientMessage(this, player, "NetID: " + target_blob.getNetworkID());
                    }
                    else
                    {
                        sendClientMessage(this, player, "NetID: " + blob.getNetworkID());
                    }
                    break;
                }

                case PlayerNetID://!playerid (username) - returns netid of the player
                {
                    if(tokens.length > 1)
                    {
                        sendClientMessage(this, player, "NetID: " + target_player.getNetworkID());
                    }
                    else
                    {
                        sendClientMessage(this, player, "NetID: " + player.getNetworkID());
                    }
                    break;
                }

                case TagPlayerBlob://!tagplayerblob "type" "tagname" "value" (PLAYERNAME) - defaults to yourself, type can equal "u8, s8, u16, s16, u32, s32, f32, bool, string, tag"
                { 
                    string message = "";
                    if(tokens.length > 4)
                    {
                        message = TagSpecificBlob(target_blob, tokens[1], tokens[2], tokens[3]);
                    }
                    else
                    {
                        message = TagSpecificBlob(blob, tokens[1], tokens[2], tokens[3]);
                        @target_player = @player;
                    }

                    if(message == "")
                    {
                        if(tokens[1] == "tag")
                        {
                            string tag_or_untag = "tagged";
                            if (tokens[3] == "false" || tokens[3] == "0")
                            {
                                tag_or_untag = "untagged";
                            }

                            message = "player " + target_player.getUsername() + " has had their blob " + tag_or_untag + " with " + tokens[2];
                        }
                        else
                        {
                            message = "player " + target_player.getUsername() + " has their blob's " + tokens[1] + " value with the key " + tokens[2] + " set to " + tokens[3];
                        }
                    }

                    if(message != "")
                    {
                        sendClientMessage(this, player, message);
                    }

                    break;
                }

                case TagBlob://!tagblob "type" "tagname" "value" "blobnetid" - type can equal "u8, s8, u16, s16, u32, s32, f32, bool, string, tag"
                {
                    u16 netid = parseInt(tokens[4]);

                    CBlob@ netidblob = getBlobByNetworkID(netid);

                    string message = "";
                    if(netidblob != null)
                    {
                        message = TagSpecificBlob(netidblob, tokens[1], tokens[2], tokens[3]);
                    }
                    else
                    {
                        message = "The blob with the specified NetID " + tokens[4] + " was null/not found.";
                    }

                    if(message == "")
                    {
                        if(tokens[1] == "tag")
                        {
                            string tag_or_untag = "tag";
                            if (tokens[3] == "false" || tokens[3] == "0")
                            {
                                tag_or_untag = "untag";
                            }

                            message = "The blob with the NetID " + tokens[4] + " has been " + tag_or_untag + " with " + tokens[2];
                        }
                        else
                        {
                            message = "The blob with the NetID " + tokens[4] + " has had their " + tokens[1] + " value with the key " + tokens[2] + " set to " + tokens[3];
                        }
                    }

                    if(message != "")
                    {
                        sendClientMessage(this, player, message);
                    }

                    break;
                }

                case GiveCoin://!givecoin "amount" "player" - Gives a amount of coin to a specified player, will deduct coin from your coins
                {
                    uint32 coins = parseInt(tokens[1]);

                        if(player.getCoins() >= coins)
                        {
                            player.server_setCoins(player.getCoins() - coins);
                            target_player.server_setCoins(target_player.getCoins() + coins);
                            sendClientMessage(this, player, "You gave " + coins + " Coins To " + target_player.getCharacterName());
                        }
                        else
                        {
                            sendClientMessage(this, player, "You don't have enough coins");
                            return false;
                        }
                    break;
                }
                case PrivateMessage://!pm "player" "message" - Sends the specified message to only one player, other players can not read into this and figure out what was sent
                {
                    if(tokens.length > 2)
                    {
                        string messagefrom = "pm from " + player.getUsername() + ": ";
                        string message = "";
                        for(int i = 2; i < tokens.length; i++)
                        {
                            message += tokens[i] + " ";
                        }
                        if(message != "")
                        {
                            sendClientMessage(this, target_player, messagefrom + message, SColor(255, 0, 0, 153));
                            sendClientMessage(this, player, "Your message \" " + message + "\"has been sent");
                            return false;
                        }
                    }
                    else
                    {
                        sendClientMessage(this, player, "A message is required");
                        return false;
                    }
                    break;
                }
                case SetTime://!settime "time" - sets time to this, value between 0 and 1 
                {
                    float time = parseFloat(tokens[1]);
                    getMap().SetDayTime(time);
                    break;
                }
                case Ban://!ban "player" (minutes) - bans the player for 60 minutes by default, unless specified. 
                {
                    CSecurity@ security = getSecurity();
                    if(security.checkAccess_Feature(target_player, "ban_immunity"))
                    {
                        sendClientMessage(this, player, "This player has ban immunity");//Check for kick immunity    
                        return false;
                    }
                    uint32 ban_length = 60;
                    if (tokens.length > 2)
                    {
                        ban_length = parseInt(tokens[2]);
                    }
                    security.ban(target_player, ban_length);
                    sendClientMessage(this, player, "Player " + target_player.getUsername() + " has been banned for " + ban_length + " minutes");//Check for ban immunity
                    break;
                }
                case Unban://!unban "player" - unbans specified player with the specified username, as the player is not in the server autocomplete will not work. 
                {
                    CSecurity@ security = getSecurity();
                    /*if(security.isPlayerBanned(tokens[1]))
                    {*/
                        security.unBan(tokens[1]);
                        sendClientMessage(this, player, "Player " + tokens[1] + " has been unbanned");
                    /*}
                    else
                    {
                        sendClientMessage(this, player, "Specified banned player not found, i.e nobody with this username is banned");
                    }*///Fix me later numan
                    break;
                }
                case Kick://!kick "player" - kicks the player
                {
                    if(getSecurity().checkAccess_Feature(target_player, "kick_immunity"))
                    {
                        sendClientMessage(this, player, "This player has kick immunity");//Check for kick immunity    
                        return false;
                    }
                    KickPlayer(target_player);
                    sendClientMessage(this, player, "Player " + tokens[1] + " has been kicked");//Check for kick immunity
                    break;
                }
                case Freeze://!freeze "player" - will freeze a player if not frozen, if frozen it will unfreeze that player
                {
                    if(getSecurity().checkAccess_Feature(target_player, "freeze_immunity"))
                    {
                        sendClientMessage(this, player, "This player has freeze immunity");//Check for kick immunity    
                        return false;
                    }
                    target_player.freeze = !target_player.freeze;
                    break;
                }
                case Teleport://!teleport "player" - will teleport to that player || !teleport "player" "player2" - will teleport player to player2
                {
                    if(tokens.length > 2)
                    {
                        if(target_player.isBot())
                        {
                            sendClientMessage(this, player, "You can not teleport a bot.");
                            return false;
                        }
                        
                        array<CPlayer@> target_players = getPlayersByShortUsername(tokens[2]);//Get a list of players that have this as the start of their name
                        if(target_players.length() > 1)//If there is more than 1 player in the list
                        {
                            string playernames = "";
                            for(int i = 0; i < target_players.length(); i++)//for every player in that list
                            {
                                playernames += " : " + target_players[i].getUsername();// put their name in a string
                            }
                            sendClientMessage(this, player, "There is more than one possible player for the second player param" + playernames);//tell the client that these players in the string were found
                            return false;//don't send the message to chat, don't do anything else
                        }
                        else if(target_players == null || target_players.length == 0)
                        {
                            sendClientMessage(this, player, "No player was found for the second player param.");
                            return false;
                        }

                        CPlayer@ target_playertwo = target_players[0];
                        
                        if (target_playertwo !is null)
                        {
                            CBlob@ target_blobtwo = target_playertwo.getBlob();
                            
                            if(target_blobtwo != null && target_blob != null)
                            {
                                Vec2f target_postwo = target_blobtwo.getPosition();
                                target_postwo.y -= 5;

                                CBitStream params;//Assign the params

                                params.write_u16(target_player.getNetworkID());
                                params.write_Vec2f(target_postwo);
                                this.SendCommand(this.getCommandID("teleport"), params);
                            }
                        }
                        else
                        {
                            sendClientMessage(this, player, "The second specified player " + tokens[2] + " was not found");
                        }
                    }
                    else if (blob != null)
                    {
                        Vec2f target_pos = target_blob.getPosition();
                        target_pos.y -= 5;

                        CBitStream params;//Assign the params
                        
                        params.write_u16(player.getNetworkID());
                        params.write_Vec2f(target_pos);
                        this.SendCommand(this.getCommandID("teleport"), params);
                    }
                    
                    break;
                }
                case Coin://!coin "amount" (player) - gives coins you yourself unless a player was specified
                {
                    int coin = parseInt(tokens[1]);
                    if (tokens.length > 2) 
                    {
                        target_player.server_setCoins(target_player.getCoins() + coin);
                    }
                    else
                    {
                        player.server_setCoins(player.getCoins() + coin);
                    }	
                    break;
                }
                case SetHp://!sethp "amount" (player) - sets your own hp to the amount specified unless a player was specified.
                {
                    float health = parseFloat(tokens[1]);
                    if (tokens.length > 2) 
                    { 
                        target_blob.server_SetHealth(health);
                    }
                    else if (blob != null)
                    {
                        blob.server_SetHealth(health);
                    }
                    break;
                }
                case Damage://!damage "amount" (player)
                {
                    float damage = parseFloat(tokens[1]);
                    if(damage < 0.0)
                    {
                        sendClientMessage(this, player, "You can not apply negative damage");
                        return false;
                    }
                    if (tokens.length > 2)
                    { 
                        target_blob.server_Hit(target_blob, target_blob.getPosition(), Vec2f(0, 0), damage, 0);
                    }
                    else if (blob != null)
                    {
                        blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage, 0);
                    }
                    break;
                }
                case Kill://!kill "player" - Applys 99999 damage to a player
                {
                    target_blob.server_Hit(target_blob, target_blob.getPosition(), Vec2f(0, 0), 99999.0f, 0);
                    break;
                }
                case Team://!team "team" (player) - sets your own blobs to this, unless a player was specified
                {
                    if(tokens.length == 1)
                    {
                        sendClientMessage(this, player, "Your controlled blob's team is " + blob.getTeamNum());
                        break;
                    }

                    // Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
                    int team = parseInt(tokens[1]);
                    if (tokens.length > 2)
                    {
                        target_blob.server_setTeamNum(team);
                    }
                    else
                    {
                        blob.server_setTeamNum(team);
                    }
                    break;
                }
                case PlayerTeam://!playerteam "team" (player) - like !team but it sets the players team (in the scoreboard and on respawn generally), it does not change the blobs team
                {
                    if(tokens.length == 1)
                    {
                        sendClientMessage(this, player, "Your player team is " + player.getTeamNum());
                        break;
                    }

                    // Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
                    int team = parseInt(tokens[1]);
                    
                    if (tokens.length > 2)
                    { 	
                        target_player.server_setTeamNum(team);
                    }
                    else
                    {
                        player.server_setTeamNum(team);
                    }
                    break;
                }
                case ChangeName://!player "charactername" (player)
                {

                    if (tokens.length > 2)
                    {
                        target_player.server_setCharacterName(tokens[1]);
                    }
                    else
                    {
                        player.server_setCharacterName(tokens[1]);
                    }
                    break;
                }
                case Actor://!actor "blob" (player) - turns yourself into the specified blob, unless a player was specified, this is good for class changing
                {//Note, keep hp? - Numan
                    string actor = tokens[1];
                    
                    if (tokens.length > 2) 
                    {
                        if(target_blob == null)
                        {
                            sendClientMessage(this, player, "Can not respawn while dead, try !forcerespawn \"player\"");
                            return false;
                        }
                        CBlob@ newBlob = server_CreateBlob(actor, target_blob.getTeamNum(), target_blob.getPosition());
                    
                        if(newBlob != null && newBlob.getWidth() != 0.0f)
                        {						
                            if(target_blob != null) {
                                target_blob.server_Die();
                            }
                            newBlob.server_SetPlayer(target_player);
                            ParticleZombieLightning(target_blob.getPosition());
                        }
                        else
                        {
                            sendClientMessage(this, player, "Failed to spawn the \"" + actor + "\" blob");
                        }
                    }
                    else
                    {
                        if(blob == null)
                        {
                            sendClientMessage(this, player, "Can not respawn while dead, try !forcerespawn \"player\"");
                            return false;
                        }
                        CBlob@ newBlob = server_CreateBlob(actor, team, pos);
                        if(newBlob != null && newBlob.getWidth() != 0.0f)
                        {
                            if(blob != null)
                            { 
                                blob.server_Die();
                            }
                            newBlob.server_SetPlayer(player);
                            ParticleZombieLightning(pos); 
                        }
                        else
                        {
                            sendClientMessage(this, player, "Failed to spawn the \"" + actor + "\" blob");
                        }
                    }
                    break;
                }
                case AddRobot://!addbot (on_player) (blob) (team) (name) (difficulty 1-15)
                //- adds a bot as the specified blob, team, and name. Bot spawns on player pos. on_player = if true, spawns on player position. if false, respawns normally
                {
                    if(tokens.length == 1)
                    {
                        CPlayer@ bot = AddBot("Henry");
                    }
                    else
                    {
                        bool on_player = true;
                        string bot_actor = "";
                        string bot_name = "Henry";
                        u8 bot_team = 255;
                        u8 bot_difficulty = 15;

                        //There is at least 1 token.
                        string sop_string = tokens[1];
                        if(sop_string == "false" || sop_string == "0")
                        {
                            on_player = false;
                        }
                        //Are there two parameters?
                        if (tokens.length > 2)
                        {
                            bot_actor = tokens[2];
                        }
                        //Three parameters?
                        if(tokens.length > 3)
                        {
                            bot_team = parseInt(tokens[3]);
                        }
                        //Four parameters?
                        if(tokens.length > 4)
                        {
                            bot_name = tokens[4];
                        }
                        //Five parameters?
                        if(tokens.length > 5)
                        {
                            bot_difficulty = parseInt(tokens[5]);
                        }

                        if(on_player == true)
                        {
                            if(bot_actor == "")
                            {
                                bot_actor = "knight";
                            }
                            if(bot_team == 255)
                            {
                                bot_team = 0;
                            }

                            CBlob@ newBlob = server_CreateBlob(bot_actor, bot_team, pos);   
                            
                            if(newBlob != null)
                            {
                                newBlob.set_s32("difficulty", bot_difficulty);
                                newBlob.getBrain().server_SetActive(true);
                            }
                        }
                        else
                        {
                            CPlayer@ bot = AddBot(bot_name);
                        
                            //bot.server_setSexNum(XORRandom(2));
                            
                            if(bot_team != 255)
                            {
                                bot.server_setTeamNum(bot_team);
                            }
                            
                            if(bot_actor != "")
                            {
                                bot.lastBlobName = bot_actor;
                            }
                        }
                    }
                    break;
                }
                case ForceRespawn://!forcerespawn - respawns a player even if they already exist or are dead.
                {
                    if(tokens.length == 2)
                    {
                        @target_player = @player;
                        @target_blob = @blob;
                    }
                    Vec2f[] spawns;
                    Vec2f spawn;
                    if (target_player.getTeamNum() == 0)
                    {
                        if(getMap().getMarkers("blue spawn", spawns))
                        {
                            spawn = spawns[ XORRandom(spawns.length) ];
                        }
                        else if(getMap().getMarkers("blue main spawn", spawns))
                        {
                            spawn = spawns[ XORRandom(spawns.length) ];
                        }
                        else
                        {
                            spawn = Vec2f(0,0);
                        }
                    }
                    else if (target_player.getTeamNum() == 1)
                    {
                        if(getMap().getMarkers("red spawn", spawns))
                        {
                            spawn = spawns[ XORRandom(spawns.length) ];
                        }
                        else if(getMap().getMarkers("red main spawn", spawns))
                        {
                            spawn = spawns[ XORRandom(spawns.length) ];
                        }
                        else
                        {
                            spawn = Vec2f(0,0);
                        }
                    }
                    else
                    {
                        spawn = Vec2f(0,0);
                    }

                    string actor = "knight";
                    if(target_player.lastBlobName != "")
                        actor = target_player.lastBlobName;
                    CBlob@ newBlob = server_CreateBlob(actor, target_player.getTeamNum(), spawn);
                        
                    if(newBlob != null)
                    {
                        @target_blob = @target_player.getBlob();
                        if(target_blob != null) {
                            target_blob.server_Die();
                        }
                        newBlob.server_SetPlayer(target_player);
                    }
                    
                    break;
                }
                case Give://!give "blob" (amount) (player) - gives the specified blob to yourself or a specified player
                {
                    int quantity = 1;

                    if(tokens.length > 2)//If the quantity parameter is specified
                    {
                        quantity = parseInt(tokens[2]);
                    }

                    Vec2f _pos = pos;
                    int8 _team = team;
                    
                    if (tokens.length > 3)//If the player parameter is specified
                    {
                        _pos = target_blob.getPosition();
                        _team = target_blob.getTeamNum();
                    }
                    
                    CBlob@ giveblob = server_CreateBlobNoInit(tokens[1]);
                    
                    giveblob.server_setTeamNum(_team);
                    giveblob.setPosition(_pos);
                    giveblob.Init();


                    if(giveblob.getMaxQuantity() > 1)
                    {
                        giveblob.Tag('custom quantity');

                        giveblob.server_SetQuantity(quantity);
                    }
                    
                    
                    break;
                }
                //default:
                //{
                //    return true;
                //}
            }
        
        }
        else //No extra commands, revert to normal
        {
            // eg. !team 2
            if (commandenum == Team)
            {
                // Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
                int team = parseInt(tokens[1]);
                blob.server_setTeamNum(team);
                // We should consider if this should change the player team as well, or not.
            }
            else if(commandenum == AddRobot)
            {
                CPlayer@ bot = AddBot("Henry");
            }
        }
        if(blob != null)
        {
            //(see above for crate parsing example)
            if (commandenum == Crate)
            {
                int frame = tokens[1] == "catapult" ? 1 : 0;
                string description = tokens.length > 2 ? tokens[2] : tokens[1];
                server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
            }
            else if (commandenum == Scroll)
            {
                string s = tokens[1];
                for (uint i = 2; i < tokens.length; i++)
                {
                    s += " " + tokens[i];
                }
                server_MakePredefinedScroll(pos, s);
            }
        }

        //return !this.get_bool(player.getUsername() + "_hidecom"); //Not needed

		return !this.get_bool(player.getUsername() + "_hidecom");
	}

	return true;
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if(cmd == this.getCommandID("clientmessage") )//sends message to a specified client
    {
        
		string text = params.read_string();
        u8 alpha = params.read_u8();
        u8 red = params.read_u8();
        u8 green = params.read_u8();
        u8 blue = params.read_u8();


        client_AddToChat(text, SColor(alpha, red, green, blue));//Color of the text
    }
	else if(cmd == this.getCommandID("teleport") )//teleports player to other player
	{
		CPlayer@ target_player = getPlayerByNetworkId(params.read_u16());//Player 1
		
		if(target_player == null) //|| !target_player.isMyPlayer())//Not sure if this is needed
		{	return;	}
		

		CBlob@ target_blob = target_player.getBlob();
		if(target_blob != null)
		{
            Vec2f pos = params.read_Vec2f();
			target_blob.setPosition(pos);
            ParticleZombieLightning(pos);
        }
		
	}
    else if(cmd == this.getCommandID("clientshowhelp"))//toggles the gui help overlay
    {
		if(!isClient())
		{
			return;
		}
        CPlayer@ local_player = getLocalPlayer();
        if(local_player == null)
        {
            return;
        }

		if(this.get_bool(local_player.getNetworkID() + "_showHelp") == false)
		{
			this.set_bool(local_player.getNetworkID() + "_showHelp", true);
			client_AddToChat("Showing Commands, type !commands to hide", SColor(255, 255, 0, 0));
		}
		else
		{
			this.set_bool(local_player.getNetworkID() + "_showHelp", false);
			client_AddToChat("Hiding help", SColor(255, 255, 0, 0));
		}
	}
	else if(cmd == this.getCommandID("allclientshidehelp"))//hides all gui help overlays for all clients
	{
		if(!isClient())
		{
			return;
		}

		CPlayer@ target_player = getLocalPlayer();
		if (target_player != null)
		{
			if(this.get_bool(target_player.getNetworkID() + "_showHelp") == true)
			{
				this.set_bool(target_player.getNetworkID() + "_showHelp", false);
			}
		}
	}
    else if(cmd == this.getCommandID("announcement"))
	{
		this.set_string("announcement", params.read_string());
		this.set_u32("announcementtime",30 * 15 + getGameTime());//15 seconds
	}
}

void sendClientMessage(CRules@ this, CPlayer@ player, string message)
{
	CBitStream params;//Assign the params
	params.write_string(message);
    params.write_u8(255);
    params.write_u8(255);
    params.write_u8(0);
    params.write_u8(0);

	this.SendCommand(this.getCommandID("clientmessage"), params, player);
}
void sendClientMessage(CRules@ this, CPlayer@ player, string message, SColor color)//Now with color
{
	CBitStream params;//Assign the params
	params.write_string(message);
    params.write_u8(color.getAlpha());
    params.write_u8(color.getRed());
    params.write_u8(color.getGreen());
    params.write_u8(color.getBlue());

	this.SendCommand(this.getCommandID("clientmessage"), params, player);
}

string TagSpecificBlob(CBlob@ targetblob, string typein, string namein, string input)
{
    if(targetblob == null)
    {
        return "something weird happened when assigning tags";
    }

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
        
        if (input == "true" || input == "1")
        {
            targetblob.set_bool(namein, true);
        }
        else if (input == "false" || input == "0")
        {
            targetblob.set_bool(namein, false);
        }
        else
        {
            return "True or false, it isn't that hard";
        }
    }
    else if(typein == "string")
    {
        targetblob.set_string(namein, input);
    }
    else if(typein == "tag")
    {
        if(input == "true" || input == "1")
        {
            targetblob.Tag(namein);
        }
        else if (input == "false" || input == "0")
        {
            targetblob.Untag(namein);
        }
        else
        {
            return "Set the value to true, to tag. Set the value to false, to untag.";
        }
    }
    else
    {
        return "typein " + typein + " is not one of the types you can use.";
    }
    return "";
}

//Get an array of players that have "shortname" at the start of their username. If their username is exactly the same, it will return an array containing only that player.
array<CPlayer@> getPlayersByShortUsername(string shortname)
{
    array<CPlayer@> playersout;//The main array for storing all the players which contain shortname

    for(int i = 0; i < getPlayerCount(); i++)//For every player
    {
        CPlayer@ player = getPlayer(i);//Grab the player
        string playerusername = player.getUsername();//Get the player's username

        if(playerusername == shortname)//If the name is exactly the same
        {
            array<CPlayer@> playersoutone;//Make a quick array
            playersoutone.push_back(player);//Put the player in that array
            return playersoutone;//Return this array
        }

        if(playerusername.substr(0, shortname.length()) == shortname)//If the players username contains shortname
        {
            playersout.push_back(player);//Put the array.
        }
    }
    return playersout;//Return the array
}

//Uses the above getPlayersByShortUsername method.
CPlayer@ getPlayerByShortUsername(string shortname)
{
    array<CPlayer@> target_players = getPlayersByShortUsername(shortname);//Get a list of players that have this as the start of their username
    if(target_players.length() > 1)//If there is more than 1 player in the list
    {
        string playernames = "";
        for(int i = 0; i < target_players.length(); i++)//for every player in that list
        {
            playernames += " : " + target_players[i].getUsername();//put their name in a string
        }
        print("There is more than one possible player for the player param" + playernames);//tell the client that these players in the string were found
        return @null;//don't send the message to chat, don't do anything else
    }
    else if(target_players == null || target_players.length == 0)
    {
        print("No player was found for the player param.");
        return @null;
    }
    return target_players[0];
}


bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
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

	return true;
}

void onRender( CRules@ this )
{
    if(!isClient())
    {
        return;
    }
    CPlayer@ localplayer = getLocalPlayer();
    if(localplayer == null)
    {
        return;
    }

    if(this.get_u32("announcementtime") > getGameTime())
	{
		GUI::DrawTextCentered(this.get_string("announcement"), Vec2f(getScreenWidth()/2,getScreenHeight()/2), SColor(255,255,127,60));
	}


    if(this.get_bool(localplayer.getNetworkID() + "_showHelp") == false)
    {
        return;
    }
	u8 nextline = 16;
	
	GUI::SetFont("menu");
    Vec2f drawPos = Vec2f(getScreenWidth() - 350, 0);
    Vec2f drawPos_width = Vec2f(drawPos.x + 346, drawPos.y);
    GUI::DrawText("Commands parameters:\n" + 
	"{} <- Required\n" + 
    "[] <- Optional" +
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" + 
    "Type !commands to close this window"
    ,
    drawPos, drawPos_width, color_black, false, false, true);
        
    GUI::DrawText("                             :No Roles:\n" +
    "!playercount - Tells you the playercount\n" +
    "!givecoin {amount} {player}\n" +
    "-Deducts coin from you to give to another player\n" +
    "!pm {player} {message}\n" + 
    "- Privately spam player of choosing\n" +
    "!changename {charactername} [player]\n" +
    "- To change another's name, you require admin"
    ,
    Vec2f(drawPos.x, drawPos.y - 7 + nextline * 4), drawPos_width, SColor(255, 255, 125, 10), false, false, false);
    
    GUI::DrawText("                             :Moderators:\n" +
    "!ban {player} [minutes] - Defaults to 60 minutes\n" +
    "Warning, this command auto completes names\n" +
    "!unban {player} - Auto complete will not work\n" +
    "!kickp {player}\n" +
    "!freeze {player} - Use again to unfreeze\n" +
    "!team {team} [player] - Blob team\n" +
    "!playerteam {team} [player] - Player team"
    ,
    Vec2f(drawPos.x, drawPos.y + nextline * 11), drawPos_width, SColor(255, 45, 240, 45), false, false, false);
    
    GUI::DrawText("                             :Admins:\n" +
    "!teleport {player} - Teleports you to the player\n" +
    "!teleport {player1} {player2}\n" +
    "- Teleports player1 to player2\n" +
    "!coin {amount} [player] - Coins appear magically\n" +
    "!sethp {amount} [player] - give yourself 9999 life\n" +
    "!damage {amount} [player] - Hurt their feelings\n" + 
    "!kill {player} - Makes players ask, \"why'd i die?\"\n" +
    "!actor {blob} [player]\n" +
    "-This changes what blob the player is controlling\n" +
    "!forcerespawn {player}\n" +
    "- Drags the player back into the living world\n" +
    "!give {blob} [quantity] [player]\n" +
    "- Spawns a blob on a player\n" +
    "Quantity only relevant to quantity-based blobs\n" +
    "!announce {text}\n" +
    "!addbot [on_player] [blob] [team] [name] [exp]\n" +
    "- ex !addbot true archer 1\n" +
    "On you, archer, team 1\n"+
    "exp=difficulty. Choose a value between 0 and 15"
    ,
    Vec2f(drawPos.x, drawPos.y - 5 + nextline * 20), drawPos_width, SColor(255, 25, 25, 215), false, false, false);

    GUI::DrawText("                             :SuperAdmin:\n" +
    "!settime {time} input between 0.0 - 1.0\n" +
    "!spineverything - go ahead, try it\n" +
    "!hidecommands - hide your admin-abuse\n" +
    "!togglefeatures- turns off/on these commands"
    ,
    Vec2f(drawPos.x, drawPos.y - 3 + nextline * 40), drawPos_width, SColor(255, 235, 0, 0), false, false, false);
}