#include "CommandChatCommon.as"
#include "ElementalCore.as"
#include "NodeCommon.as"

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
		blob_must_exist = true;
	}

	bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
		if(blob is null)
			return true;
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

class Kit : CommandBase
{
	void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
			names[0] = "kit".getHash();
		}
		blob_must_exist = true;
	}

	bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
		// yteet
		{CBlob@ mats = server_CreateBlob("mat_stone", blob.getTeamNum(), pos);}
        {CBlob@ mats = server_CreateBlob("mat_stone", blob.getTeamNum(), pos);}
        {CBlob@ mats = server_CreateBlob("mat_wood", blob.getTeamNum(), pos);}
        {CBlob@ mats = server_CreateBlob("mat_wood", blob.getTeamNum(), pos);}
		return true;
	}

	bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob)
	{
		string name = getSecurity().getPlayerSeclev(player).getName();
		return (name == "Super Admin");
	}


}

class SkinTest : CommandBase
{
	void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
			names[0] = "skin".getHash();
		}
		minimum_parameter_count = 2;
	}

	bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
		if(blob !is null)
		{
			CSprite@ spr = blob.getSprite();
			if(spr !is null)
			{
				int id = -1;
				id = parseInt(tokens[1]);
				string texname = spr.getTextureName() + "skin_" + id;
				print(texname);
				print(spr.getFilename());
				ImageData@ data = Texture::data(texname);
				if(data is null)
				{
					Texture::createFromFile(spr.getTextureName() + "skin_" + id, "BuilderMale.png");
					texname = spr.getTextureName() + "skin_" + id;
					@data = Texture::data(texname);
					
					//Still null? might as well die
					if(data is null)
					{
						print("ANGERY in SkinTest command");
						return true;
					}
					
					
					
					//---REMAPPING--
					
					if(!Texture::exists("SkinColors"))
					{
						if(!Texture::createFromFile("SkinColors", "SkinTones.png"))
							print("oh this is a problem");
					}
		
					ImageData@ colors = Texture::data("SkinColors");
					//if(!Texture::createBySize(texname, 32, 16))
						//print("ohno");
					//ImageData@ newimage = @data;
					
					const int colornum = 4;
					array<SColor> fromcol;
					array<SColor> tocol;
					
					for(int i = 0; i < colornum; i++)
					{
						fromcol.push_back(colors.get(0, i));
						tocol.push_back(colors.get(id, i));
					}
					
					data.remap(fromcol, tocol);
					
				}
				
				//Texture::createFromCopy(texname + "d", texname);
				print(texname);
				Texture::createFromData(texname, data);
				spr.SetTexture(texname/*, this.getFrameWidth(), this.getFrameHeight()*/);
				//array<array<int>> imagesize(data.width())(data.height());
				//blob.set("disintegration", @imagesize);
			}
		}
		return true;
	}

	bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob)
	{
		string name = getSecurity().getPlayerSeclev(player).getName();
		return true;
	}
}

class Discord : CommandBase{
	void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
			names[0] = "discord".getHash();
		}
		minimum_parameter_count = 0;
	}

	bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override{
		OpenWebsite("discord.gg/MqkH8ss");
		return true;
	}

	bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob){
		return true;
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
        commands.push_back(Kit());
		commands.push_back(SkinTest());
		commands.push_back(Discord());
    }
}