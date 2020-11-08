void onInit( CRules@ this )
{
	ConfigFile file;
	file.loadFile("../Cache/servername.cfg");
	if(file.exists("name"))
	{
		sv_name = file.read_string("name") + " Now with mysterious cheese!";
	}
}