#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	addTank(this, "Input", true, Vec2f(0, 4));
	//getTank(this, 0).dynamictank = true;
	
	//this.addCommandID("activate");
	
	this.addCommandID("toggle");
	
	//this.addCommandID("flip");
	
	this.set_bool("active", true);
	
	AddIconToken("$toggle_pad$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	//AddIconToken("$flip_pad$", "InteractionIcons.png", Vec2f(32, 32), 8);
	
	this.set_TileType("background tile", 0);
}


void onTick(CBlob@ this)
{
	if(this.get_bool("active"))
	{
		array<CElementSetup> @elementlist = @getElementList();
		CBlob@ shard = this.getInventory().getItem(0);

		if(shard is null) {return;}
		if(shard.getConfig() != "soul_chunk") {return;}

		CPlayer@ player = getPlayerByUsername(shard.get_string("player_username"));
		if(player is null) {return;}
		CBlob@ pblob = player.getBlob();
		if(pblob is null) {return;}


		CAlchemyTank@ tank = getTank(this, 0);
		//int active_elements = 0;
		for (int i = 0; i < elementlist.length; i++)
		{
			if(tank.storage.elements[i] >= 1)
			{
				//active_elements++;
				elementlist[i].bindbehavior(pblob, 5, this);
				
				//break;
			}
			if(getGameTime() % 5 == 0)
				tank.storage.elements[i] -= 1;
		}
	}


}



void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	caller.CreateGenericButton("$toggle_pad$", Vec2f(0, -12), this, this.getCommandID("toggle"), this.get_bool("active") ? "Deactivate Binder" : "Reactivate Binder");
	
	//caller.CreateGenericButton("$flip_pad$", Vec2f(0, 0), this, this.getCommandID("flip"), "Flip Pad");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("toggle") == cmd)
	{
		this.set_bool("active", this.get_bool("active") ? false : true);
		if(this.getSprite() !is null)
			this.getSprite().SetFrame(this.get_bool("active") ? 0 : 1);
	}
}