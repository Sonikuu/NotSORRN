
void onInit(CBlob@ this)
{
	this.addCommandID("syncmenustate");
	this.set_bool("menustate", false);
}


void onTick(CBlob@ this)
{
	if(isClient() && this is getLocalPlayerBlob())
	{
		CHUD@ con = getHUD();
		bool isgui = con.hasMenus() || this.isKeyPressed(key_use); //|| this.get_bool("menuOpen");
		if(isgui != this.get_bool("menustate"))
		{
			this.set_bool("menustate", isgui);
			CBitStream params;
			params.write_bool(isgui);
			this.SendCommand(this.getCommandID("syncmenustate"), params);
		}
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("syncmenustate"))
	{
		if(this !is getLocalPlayerBlob())
		{
			this.set_bool("menustate", params.read_bool());
		}
	}
}

