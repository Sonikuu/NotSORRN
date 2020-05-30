#include "CommandChatCommon.as"

class AdminPixie : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "admin".getHash();
            names[1] = "adminpixie".getHash();
        }
        permlevel = Moderator;
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
        pixie.SendCommand(pixie.getCommandID("removegod"));

        return true;
    }

    bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob) override
    {
        string name = getSecurity().getPlayerSeclev(player).getName();
        return (name == "Admin" || name == "Super Admin");
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
    }
}