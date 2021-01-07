

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

bool fuelInsertionFunc(CBlob@ toblob, CBlob@ fuel)
{
	float fuelval = getFuelValue(fuel);
	if(fuelval > 0.0)
	{
		toblob.add_f32("fuel", fuelval);
		toblob.Sync("fuel", true);
		fuel.server_Die();
		return true;
	}
	return false;
}

void fuelInit(CBlob@ this){
	this.addCommandID("addfuel");
	this.set_f32("fuel", 0);
	AddIconToken("$add_fuel$", "FireFlash.png", Vec2f(32, 32), 0);
}

void addToFuelVallue(CBlob@ this, int ammount, bool sync){
	this.add_f32("fuel",ammount);
	if(sync){
		this.Sync("fuel",true);
	}
}


void handleFuelCommands(CBlob@ this, u8 cmd, CBitStream@ params){
	if(this.getCommandID("addfuel") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			//Checking if fuel again just in case
			CBlob@ helditem = caller.getCarriedBlob();
			if(helditem !is null)
			{
				float value = getFuelValue(helditem);
				if(value > 0.0)
				{
					this.add_f32("fuel", value);
					helditem.server_Die();
				}
			}
		}
	}
}

void generateFuelButtons(CBlob@ this, CBlob@ caller){
	CBlob@ helditem = caller.getCarriedBlob();
	if(helditem !is null)
	{
		float value = getFuelValue(helditem);
		if(value > 0.0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$add_fuel$", Vec2f(0, 6), this, this.getCommandID("addfuel"), "Add Fuel: " + formatFloat(value, ""), params);
		}
	}
}


void FuelOnRender(CSprite@ this){
	//Change to look gud when possible
	CBlob@ blob = this.getBlob();
	CControls@ controls = getControls();
	CCamera@ camera = getCamera();
	if(controls is null || blob is null)
		return;
	GUI::SetFont("snes");
	
	Vec2f fuelpos = (Vec2f(0, 12) * camera.targetDistance * 2 + blob.getScreenPos());
	if((fuelpos - controls.getMouseScreenPos()).Length() < 24)
	{
		GUI::DrawText("Fuel", Vec2f(0, 0) + fuelpos, SColor(255, 125, 125, 125));
		GUI::DrawText(formatInt(blob.get_f32("fuel"), ""), Vec2f(0, 20) + fuelpos, SColor(255, 255, 255, 255));
	}
}