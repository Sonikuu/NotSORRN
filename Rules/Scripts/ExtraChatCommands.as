#include "CommandChatCommon.as"
#include "ElementalCore.as"
#include "AlchemyCommon.as"

class AdminPixie : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "admin".getHash();
            names[1] = "adminpixie".getHash();
        }
        blob_must_exist = false;

    }

    bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {   
        if(blob !is null && blob.getConfig() == "pixie")
        {
            blob.server_Die();
            return true;
        }

        CBlob@ pixie = server_CreateBlob("pixie");
        if(blob is null)
        {
            pixie.setPosition(Vec2f(getMap().tilemapwidth*4,0));
        }
        else
        {
            pixie.setPosition(blob.getPosition());
            blob.server_Die();
        }
        pixie.server_SetPlayer(player);
		if(getSecurity().getPlayerSeclev(player).getName() != "Super Admin")
        {
			pixie.SendCommand(pixie.getCommandID("removegod"));
		}

        return true;
    }

    bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob) override
    {
        string name = getSecurity().getPlayerSeclev(player).getName();
        return (name == "Admin" || name == "Super Admin");
    }
}

class Vial :CommandBase
{
	void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
			names[0] = "vial".getHash();
		}
		minimum_parameter_count = 2;
	}

	bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
		int id = -1;
		id = elementIdFromName(tokens[1]);

		if(id <= -1)
		{
			id = parseInt(tokens[1]);
		}
		if(id > -1 && id < elementlist.size())
		{
			CBlob@ vial = server_CreateBlob("vial",blob.getTeamNum(), pos);
			CAlchemyTank@ tank = getTank(vial,0);
			tank.storage.setElement(id,100);
		}

		return true;
	}

	bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob)
	{
		string name = getSecurity().getPlayerSeclev(player).getName();
		return (name == "Super Admin");
	}


}

void onInit(CRules@ this)
{
    if(isServer())
    {
        array<ICommand@>@ commands;
        this.get("ChatCommands",@commands);
        if(commands is null){error("COMMANDS WAS NULL ADMINPIXIE COMMAND NOT ADDED!!! Try adjusting mod order"); return;}
        commands.push_back(AdminPixie());
		commands.push_back(Vial());
    }
}