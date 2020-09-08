void onInit(CRules@ this)
{
	this.set_bool("is_test", false);
	ConfigFile file;
	file.loadFile("../Cache/test.cfg");
	if(file.exists("is_test"))
	{
		this.set_bool("is_test", file.read_bool("is_test"));
	}

	print("test mode = " + this.get_bool("is_test"));
}