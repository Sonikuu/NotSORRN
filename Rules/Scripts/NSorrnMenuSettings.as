
void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	initalizeConfig();
	CPlayer@ p = getLocalPlayer();

    CBitStream params;
    Menu::addContextItemWithParams(Menu::addContextMenu(menu, "NSORRN Settings"),"Toggal new pickup " + (this.get_bool(p.getUsername() + "_NewPickupOn") ? "{ON}" : "OFF"),"NSorrnMenuSettings.as", "onToggalNewPickup",params);
}

void onInit(CRules@ this)
{
	this.addCommandID("UpdateNewPickupOn");
}

void initalizeConfig()
{
	CRules@ rules = getRules();

	if(rules.get_bool("NSORRNSettingsInitalized"))
	{
		return; //don't need to reinitalize
	}

	ConfigFile file;

	CPlayer@ p = getLocalPlayer();
	if(p is null)
	{
		return;
	}//should be client only after this because the server doesn't have a player
	if(file.loadFile("../Cache/NSORRNSettings_" + p.getUsername() + ".cfg") == false)
	{
		print("initalizing config");
		file.add_bool("NewPickupOn",true);
		file.saveFile("NSORRNSettings_" + p.getUsername() + ".cfg");
	}

	client_UpdateWithServer(p,file.read_bool("NewPickupOn"));
	rules.set_bool("NSORRNSettingsInitalized",true);
}

void onToggalNewPickup(CBitStream@ params)
{
	CPlayer@ p = getLocalPlayer();
	if(p is null){return;}
    CRules@ rules = getRules();
	if(!rules.get_bool("NSORRNSettingsInitalized"))
	{
		initalizeConfig();
	}

    ConfigFile file;

    if(file.loadFile("../Cache/NSORRNSettings_" + p.getUsername() + ".cfg") == false)
	{
		print("CFG not initalized or some other error happened when button pressed NSorrnMenuSettings.as");
		return;
	}

	file.add_bool("NewPickupOn",!file.read_bool("NewPickupOn"));
	file.saveFile("NSORRNSettings_" + p.getUsername() + ".cfg");

	client_UpdateWithServer(p,file.read_bool("NewPickupOn"));
}

void client_UpdateWithServer(CPlayer@ p, bool NewPickupOn)
{
	CRules@ rules = getRules();
	CBitStream params;
	params.write_string(p.getUsername());
	params.write_bool(NewPickupOn);
	rules.SendCommand(rules.getCommandID("UpdateNewPickupOn"), params);
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("UpdateNewPickupOn"))
	{
		CPlayer@ p = getPlayerByUsername(params.read_string());
		if(p !is null)
		{
			bool on = params.read_bool();
			this.set_bool(p.getUsername() + "_NewPickupOn",on);

			print(p.getUsername() + "NewPickupOn: " + on);
		}
	}
}