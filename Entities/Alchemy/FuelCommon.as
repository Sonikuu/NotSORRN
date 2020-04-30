
class CFurnaceFuel
{
	string name;
	float value;
	
	CFurnaceFuel(string name, float value)
	{
		this.name = name;
		this.value = value;
	}
}

array<CFurnaceFuel> fuellist = 
{
	CFurnaceFuel(
	"mat_wood",
	1.0),
	
	CFurnaceFuel(
	"log",
	50.0),
	
	CFurnaceFuel(
	"mat_charcoal",
	3.0),
	
	CFurnaceFuel(
	"lifelog",
	50.0),
	
	CFurnaceFuel(
	"mat_lifewood",
	1.0),
	
	CFurnaceFuel(
	"blazecore",
	1000.0)
};

/*bool isFuel(string name)
{
	for (uint i = 0; i < fuellist.length; i++)
	{
		if(fuellist[i].name == name)
			return true;
	}
	return false;
}*/

float getFuelValue(CBlob@ blob)
{
	string name = blob.getConfig();
	for (uint i = 0; i < fuellist.length; i++)
	{
		if(fuellist[i].name == name)
		{
			return fuellist[i].value * blob.getQuantity();
		}
	}
	return 0.0;
}





