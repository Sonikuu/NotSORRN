
#include "MakeCrate.as";


void onInit( CRules@ this )
{
	this.addCommandID("discord");
	this.addCommandID("discordlink");
	
	ConfigFile file;
	if(!file.loadFile("../Cache/DiscordIntegration.cfg"))
	{
		file.saveFile("DiscordIntegration.cfg");
		print("Created discord integration save file");
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("discord"))
	{	
		
		string input = params.read_string();
		string[]@ tokens = input.split(" ");
		
		if(tokens.length > 3 && tokens[2] == "!link")
		{
			CPlayer@ player = getPlayerByUsername(tokens[3]);
			if(player !is null)
			{
				if(player is getLocalPlayer())
					client_AddToChat("Link with discord account " + tokens[0] + " started! To finish type !link", SColor(255, 200, 0, 0));
				this.set_string("linkstart" + tokens[3], tokens[1]);
			}
			else
			{
				tcpr("discordchat SYSTEM SYSTEM Invalid username! User needs to be online");
			}
		}
		else if(tokens.length > 2 && tokens[2] == "!killme")
		{
			ConfigFile file;
			if(file.loadFile("../Cache/DiscordIntegration.cfg"))
			{
				CPlayer@ player = getPlayerByUsername(file.read_string(tokens[1], ""));
				if(player !is null && player.getBlob() !is null)
				{
					player.getBlob().server_Die();
					tcpr("discordchat SYSTEM SYSTEM Murdered self successfully!");
				}
			}
		}
		else if(tokens.length > 2 && tokens[2] == "!players")
		{
			sendPlayerList();
		}
		// else if(tokens.length > 2 && tokens[2] == "!cache")
		// {
		// 	tcpr("discordchat SYSTEM SYSTEM A cache has appeared!");
		// 	client_AddToChat("A cache has appeared!", SColor(255, 200, 0, 0));
		// 	if(isServer())
		// 	{
		// 		CMap@ map = getMap();
		// 		CBlob@ crate = server_MakeCrateOnParachute("", "", 5, -1, Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0));
		// 		if (crate !is null)
		// 		{
		// 			// make unpack button
		// 			crate.Tag("unpackall");
		// 			//crate.Tag("destroy on touch");
		// 			for (uint i = 0; i < 2; i++)
		// 			{
		// 				CBlob@ mat = server_CreateBlob("mat_wood");
		// 				if (mat !is null)
		// 				{
		// 					crate.server_PutInInventory(mat);
		// 				}
		// 			}
		// 			for (uint i = 0; i < 2; i++)
		// 			{
		// 				CBlob@ mat = server_CreateBlob("mat_stone");
		// 				if (mat !is null)
		// 				{
		// 					crate.server_PutInInventory(mat);
		// 				}
		// 			}
		// 			{
		// 				CBlob@ mat = server_CreateBlob("mat_metal");
		// 				if (mat !is null)
		// 				{
		// 					crate.server_PutInInventory(mat);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
		// else if(tokens.length > 2 && tokens[2] == "!corrupt")
		// {
		// 	tcpr("discordchat SYSTEM SYSTEM A corrupted squad has appeared!");
		// 	client_AddToChat("A corrupted squad has appeared!", SColor(255, 200, 0, 0));
		// 	if(isServer())
		// 	{
		// 		CMap@ map = getMap();
		// 		Vec2f startpos = Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0);
		// 		for (uint i = 0; i < 8; i++)
		// 		{
		// 			CBlob@ knok = server_CreateBlob("knokling", -1, startpos + (Vec2f(XORRandom(200) - 100, 0)));
		// 		}
		// 	}
		// }
		else if(tokens.length > 2)
		{
			input = tokens[0];
			for(int i = 2; i < tokens.length; i++)
				input += " " + tokens[i];
			client_AddToChat(input, SColor(255, 200, 0, 200));
		}
	}
	if(cmd == this.getCommandID("discordlink"))
	{
		string input = params.read_string();
		string[]@ tokens = input.split(" ");
		if(tokens.length > 1)
		{
			CPlayer@ player = getPlayerByUsername(tokens[1]);
			if(player !is null)
			{
				if(player is getLocalPlayer())
					client_AddToChat("Link with discord account " + tokens[0] + " started! To finish type !link", SColor(255, 200, 0, 0));
				this.set_string("linkstart" + tokens[1], tokens[0]);
			}
			else
			{
				tcpr("discordchat SYSTEM SYSTEM Invalid username! User needs to be online"); 
			}
		}
	}
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	if(textIn[0] != "!"[0] || textIn == "!discord")
	{
		tcpr("discordchat " + player.getCharacterName().replace(" ", "_") + " " + player.getUsername() + " " + textIn);
	}
	else if(textIn == "!link")
	{
		if(this.exists("linkstart" + player.getUsername()))
		{
			ConfigFile file;
			if(file.loadFile("../Cache/DiscordIntegration.cfg"))
			{
				file.add_string(this.get_string("linkstart" + player.getUsername()), player.getUsername());
				file.saveFile("DiscordIntegration.cfg");
				tcpr("discordchat SYSTEM SYSTEM Link Success!");
			}
		}
		else
		{
			if(player is getLocalPlayer())
				client_AddToChat("Link not started!", SColor(255, 200, 0, 0));
		}
	}
	return true;
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if(attacker !is null)
	{
		tcpr("discordchat SYSTEM SYSTEM " + victim.getCharacterName() + " was murdered by " + attacker.getCharacterName() + "!");
	}
	else
	{
		tcpr("discordchat SYSTEM SYSTEM " + victim.getCharacterName() + " died!");
	}
}
void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	tcpr("discordchat SYSTEM SYSTEM " + player.getCharacterName() + " joined the server!");
	sendPlayerList();
}
void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	tcpr("discordchat SYSTEM SYSTEM " + player.getCharacterName() + " left the server.");
	sendPlayerList();
}
void sendPlayerList()
{
	string s = "";
	for(int  i = 0; i < getPlayersCount(); i++)
	{
		s += getPlayer(i).getCharacterName() + (i == getPlayersCount() -1 ? "" : ", ");
	}
	if(s == "")
	{
		tcpr("discordchat SYSTEM SYSTEM no players :(");
	}
	else
	{
		tcpr("discordchat SYSTEM SYSTEM " + s);
	}
}
/*void discordChat(string input)
{
	CRules@ this = getRules();
	CBitStream params;
	params.write_string(input);
	this.SendCommand(this.getCommandID("discord"), params);
}*/

//CRules@ this = getRules; CBitStream params; params.write_string(input); this.SendCommand(this.getCommandID("discord"), params);