

const int default_respawn = 150; //in ticks, 5 seconds
const string default_spawn_blob = "builder";


class CRespawnData
{
	string playername;
	int respawntime;//actual game time to spawn after passed
	//Note: Using player name here because player IDs might be confuzzled with players leaving and joining
	CRespawnData(int respawntime, string playername)
	{
		this.respawntime = respawntime;
		this.playername = playername;
	}
}

void onInit(CRules@ this)
{
	array<CRespawnData@> spawnqueue(0);
	this.set("spawnqueue", @spawnqueue);
	
	this.SetCurrentState(GAME);
	//this.server_setShowHoverNames(false);
}

void onTick(CRules@ this)
{
	if(!getNet().isServer())
		return;
	if(getNet().isServer())
	{
		array<CRespawnData@>@ spawnqueue;
		this.get("spawnqueue", @spawnqueue);
		if(spawnqueue !is null)
		{
			for (int i = 0; i < spawnqueue.length; i++)
			{
				//We live again!
				if(spawnqueue[i].respawntime <= getGameTime())
				{	
					CPlayer@ player = getPlayerByUsername(spawnqueue[i].playername);
					if(player !is null && player.getBlob() is null)
						spawnPlayer(this, player);
					spawnqueue.removeAt(i);
					i--;
					continue;
				}
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if(!getNet().isServer())
		return;

	CBlob@[] blobs;
	getBlobsByTag(player.getUsername() + "'s soulless",@blobs);
	if(blobs.size() > 0)
	{
		if(!blobs[0].hasTag("dead"))
		{
			blobs[0].server_SetPlayer(player);
			player.server_setTeamNum(blobs[0].getTeamNum());
		}
		else
		{
			player.server_setTeamNum(50);
			spawnPlayer(this, player);
		}
		blobs[0].set_bool("soulless",false);
		blobs[0].Untag(player.getUsername() + "'s soulless");
		blobs[0].Sync("soulless", true);
		blobs[0].SendCommand(blobs[0].getCommandID("Server_Menu_Sync"));
	}
	else
	{
		player.server_setTeamNum(50);
		spawnPlayer(this, player);
	}
}

//If we dont do this nobody spawns on nextmap lel
void onRestart(CRules@ this)
{
	if(!getNet().isServer())
		return;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ targPlayer = getPlayer(i);
		if(targPlayer !is null)
		{
			spawnPlayer(this, targPlayer);
		}
	}
	
	this.SetCurrentState(GAME);
}


//Way this works means nonplayers cant turn into ghosts... good or bad?
//Nobody knows
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if(!getNet().isServer())
		return;
	//print("playerDie");
	addRespawnQueue(this, victim);
	//Note: this means still living blobs can be put in the respawn queue... there were some issues with not
	//respawning, so we're gonna play it safe
	if(getNet().isServer())
	{
		CBlob@ blob = victim.getBlob();
		if(blob !is null)
		{
			string blobname = getRespawnBlob(blob);
			if(blobname != "")
			{
				CBlob@ newblob = server_CreateBlob(blobname, blob.getTeamNum(), blob.getPosition());

				//blob_swap(blob, newblob);
				//addElement(newblob, "ecto", getElement(newblob,"life"));
				//setElement(newblob,"life",0);
				
				/*CBitStream params;
				params.write_u16(victim.getNetworkID());
				newblob.SendCommand(newblob.getCommandID("sync"), params);*/
				
				newblob.set_u32("syncat", getGameTime() + 1);
				newblob.set_u16("syncid", victim.getNetworkID());
				
				//newblob.server_SetPlayer(victim);
			}
			//else
				//addRespawnQueue(this, victim);
		}
		//else
			//addRespawnQueue(this, victim);
	}
}

//This is going to be used to cause dead players to turn into ghosts and junk
//Maybe have this be handled by the blob's scripts instead?
string getRespawnBlob(CBlob@ deadblob)
{
	//if(deadblob.getConfig() == "knight" || deadblob.getConfig() == "builder" || deadblob.getConfig() == "crate")
		//return "ghost";
	return "";
}

void spawnPlayer(CRules@ this, CPlayer@ player)
{
	if(!getNet().isServer())
		return;
	CBlob@[] spawns;
	//Change bush to spawncave once implemented
	//Actually we can have this function take a bloblist instead and have each player have their own spawn places
	getBlobsByName("spawncave", @spawns);
	//This can go wrong with no spawnpoints, but if thats the case things have already gone wrong
	if(spawns.length > 0)
	{
		CBlob@ spawnpoint = @spawns[XORRandom(spawns.length)];
		if(player.getTeamNum() >= 8)
		{
			int num = 8 + XORRandom(244);
			if(num >= 200)//200 = Spectator team
				num++;
			player.server_setTeamNum(num);
		}
		else
		{
			array<CBlob@> blobs;
			array<CBlob@> valid;
			getBlobsByName("coopkey", @blobs);
			print("" + blobs.length);
			for (uint i = 0; i < blobs.length; i++)
			{
				if(player.getTeamNum() == blobs[i].getTeamNum())
				{
					valid.push_back(@(blobs[i]));
				}
			}
			if(valid.length > 0)
				@spawnpoint = @valid[XORRandom(valid.length)];
			else
			{
				//Copy pastad cause too lazy
				int num = 8 + XORRandom(244);
				if(num >= 200)//200 = Spectator team
					num++;
				player.server_setTeamNum(num);
			}
		}
		
		CBlob@ newblob = server_CreateBlob(default_spawn_blob, player.getTeamNum(), spawnpoint.getPosition());
		newblob.server_SetPlayer(player);
	}
	else
	{
		CBlob@ newblob = server_CreateBlob(default_spawn_blob, player.getTeamNum(), Vec2f_zero);
		newblob.server_SetPlayer(player);
	}
}

void addRespawnQueue(CRules@ this, CPlayer@ player)
{
	if(!getNet().isServer())
		return;
	array<CRespawnData@>@ spawnqueue;
	this.get("spawnqueue", @spawnqueue);
	if(spawnqueue !is null && player !is null)
	{
		//Maybe could add different respawn times if we want
		spawnqueue.push_back(@CRespawnData(getGameTime() + default_respawn, player.getUsername()));
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	CBlob@ blob = player.getBlob();
	if(blob !is null)
	{
		blob.Tag(player.getUsername() + "'s soulless");
		blob.set_bool("soulless",true);
		blob.server_SetPlayer(null);
	}
}