#include "NodeCommon.as";
#include "FuelCommon.as";

class CMeltableItem
{
	string name;
	array<int>@ values;
	CMeltableItem(string name, array<int>@ values)
	{
		this.name = name;
		@this.values = @values;
	}
}

//Have to do this because of angelscript limitations
//(Probably)
//Might just be dumb tho

//These values are in the same order as element master list
//Doesnt have to be as long as master list, but has to be shorter

//Current order:
//									ecto, 	life, 	natura, 	force, 	aer, 	ignis, 	terra, 	order, 	entropy, 	aqua, 	corruption, 	purity, 	unholy, 	holy								
array<int> mat_wood_val = 			{0, 	0, 		1};
array<int> log_val = 				{0, 	0, 		50};
array<int> mat_stone_val = 			{0, 	0, 		0, 			0, 		0, 		0, 		2};
array<int> mat_charcoal_val = 		{0, 	0, 		0, 			1, 		0, 		1};
array<int> soul_chunk_val = 		{50};
array<int> mat_sand_val = 			{0, 	0, 		0, 			0, 		1, 		0, 		1};
array<int> mat_gold_val = 			{0, 	0, 		0, 			0, 		0, 		0, 		1, 		1};
array<int> mat_gunpowder_val = 		{0, 	0, 		0, 			1, 		0, 		1, 		0, 		0, 		2};
array<int> mat_glass_val = 			{0, 	0, 		0, 			0, 		0, 		0, 		0, 		1};
array<int> bucket_val = 			{0, 	0, 		10, 		0, 		0, 		0, 		0, 		0, 		0, 			0};
array<int> lantern_val = 			{0, 	0, 		10, 		0, 		0, 		25};
array<int> egg_val = 				{0, 	25};
array<int> lifelog_val = 			{0, 	50, 	50};
array<int> mat_lifewood_val = 		{0, 	1, 		1};
array<int> lifefruit_val = 			{0, 	100};
array<int> mat_puredust_val = 		{0, 	0,		0,			0,		0,		0,		0,		0,		0,			0,		0,				1};
array<int> mat_corrpulp_val = 		{0, 	0,		0,			0,		0,		0,		0,		0,		0,			0,		1};
array<int> blazecore_val = 			{0, 	0, 		0, 			0, 		0, 		500};
array<int> mat_marble_val = 		{0, 	0, 		0, 			0, 		0, 		0,		1,		1,		0,			0,		0,				1};
array<int> mat_basalt_val = 		{0, 	0, 		0, 			0, 		0, 		0,		1,		0,		1,			0,		1};
array<int> mat_metal_val = 			{0, 	0, 		0, 			0, 		0, 		0,		25,		25};
array<int> builder_val = 			{50, 	50, 	0, 			0, 		0, 		0,		0,		0,		0,			0,		0,				0,			10};//Corpse, essentially
array<int> fish_val = 				{0, 	25, 	0, 			0, 		0, 		0,		0,		0,		0,			50,		0,				0,			5};
array<int> heart_val = 				{0, 	25, 	0, 			0, 		0, 		0,		0,		0,		0,			0,		0,				0,			10};
array<int> chicken_val = 			{0, 	25, 	10, 		0, 		25, 	0,		0,		0,		0,			0,		0,				0,			5};
array<int> grain_val = 				{0, 	25, 	25, 		0, 		10};
//array<int> grain_val = 				{0, 	25, 	25, 		0, 		10};

array<CMeltableItem> meltlist = 
{
	CMeltableItem(
	"mat_wood",
	@mat_wood_val
	),
	
	CMeltableItem(
	"log",
	@log_val
	),
	
	CMeltableItem(
	"mat_stone",
	@mat_stone_val
	),
	
	CMeltableItem(
	"mat_charcoal",
	@mat_charcoal_val
	),
	
	CMeltableItem(
	"soul_chunk",
	@soul_chunk_val
	),
	
	CMeltableItem(
	"mat_sand",
	@mat_sand_val
	),
	
	CMeltableItem(
	"mat_gold",
	@mat_gold_val
	),
	
	CMeltableItem(
	"mat_gunpowder",
	@mat_gunpowder_val
	),
	
	CMeltableItem(
	"mat_glass",
	@mat_glass_val
	),
	
	CMeltableItem(
	"bucket",
	@bucket_val
	),
	
	CMeltableItem(
	"lantern",
	@lantern_val
	),
	
	CMeltableItem(
	"egg",
	@egg_val
	),
	
	CMeltableItem(
	"lifelog",
	@lifelog_val
	),
	
	CMeltableItem(
	"mat_lifewood",
	@mat_lifewood_val
	),
	
	CMeltableItem(
	"lifefruit",
	@lifefruit_val
	),
	
	CMeltableItem(
	"mat_puredust",
	@mat_puredust_val
	),
	
	CMeltableItem(
	"mat_corrpulp",
	@mat_corrpulp_val
	),
	
	CMeltableItem(
	"blazecore",
	@blazecore_val
	),
	
	CMeltableItem(
	"mat_marble",
	@mat_marble_val
	),
	
	CMeltableItem(
	"mat_basalt",
	@mat_basalt_val
	),
	
	CMeltableItem(
	"mat_metal",
	@mat_metal_val
	),
	
	CMeltableItem(
	"builder",
	@builder_val
	),

	CMeltableItem(
	"fishy",
	@fish_val
	),

	CMeltableItem(
	"heart",
	@heart_val
	),

	CMeltableItem(
	"chicken",
	@chicken_val
	),

	CMeltableItem(
	"grain",
	@grain_val
	)
};

void onInit(CBlob@ this)
{	
	this.addCommandID("addfuel");
	this.addCommandID("meltitem");
	
	this.set_f32("fuel", 0);
	this.set_u16("burncooldown", 0);
	
	//Setup tanks
	addTank(this, "Output", false, Vec2f(0, -12));
	addItemIO(this, "Input", true, Vec2f(0, 0));

	CItemIO@ fuelin = @addItemIO(this, "Fuel Input", true, Vec2f(0, 12));
	@fuelin.insertfunc = @fuelInsertionFunc;
	
	AddIconToken("$add_fuel$", "FireFlash.png", Vec2f(32, 32), 0);
	
}

void onRender(CSprite@ this)
{
	//Change to look gud when possible
	CBlob@ blob = this.getBlob();
	CControls@ controls = getControls();
	CCamera@ camera = getCamera();
	if(controls is null || blob is null)
		return;
	GUI::SetFont("snes");
	CNodeController@ controller = getNodeController(blob);
	for (uint i = 0; i < controller.tanks.length; i++)
	{
		Vec2f fuelpos = (Vec2f(0, 12) * camera.targetDistance * 2 + blob.getScreenPos());
		if((fuelpos - controls.getMouseScreenPos()).Length() < 24)
		{
			GUI::DrawText("Fuel", Vec2f(0, 0) + fuelpos, SColor(255, 125, 125, 125));
			GUI::DrawText(formatInt(blob.get_f32("fuel"), ""), Vec2f(0, 20) + fuelpos, SColor(255, 255, 255, 255));
		}
	}
	
}

void onTick(CSprite@ this)
{
	CBlob@ b = this.getBlob();
	if(b.hasTag("active"))
		this.SetFrame(1);
	else
		this.SetFrame(0);
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(getGameTime() % 2 == 0)
	{
		if(this.get_u16("burncooldown") == 0 && this.get_f32("fuel") > 0)
		{
			CInventory@ inv = this.getInventory();
			CBlob@ invitem = inv.getItem(0);
			if(invitem !is null)
			{
				
				int id = -1;
				array<int>@ values = getElementalValue(invitem.getConfig(), id);
				CAlchemyTank@ tank = getTank(this, 0);
				if(values !is null)
				{
					if(getNet().isServer())
					{
						CBitStream params;
						params.write_u16(invitem.getNetworkID());
						if(invitem.getQuantity() >= 10)
						{
							params.write_u8(10);
						}
						else
						{
							params.write_u8(invitem.getQuantity());
						}
						this.SendCommand(this.getCommandID("meltitem"), params);
					}
					else
					{
						this.Tag("active");
					}
					/*
					this.add_u16("burncooldown", getTotal(@values));
					addToTank(tank, values);
					invitem.server_SetQuantity(invitem.getQuantity() - 1);
					if(invitem.getQuantity() <= 0)
					{
						invitem.server_Die();
					}*/
				}
			}
			else
				this.Untag("active");
		}
		else
		{
			if(this.get_f32("fuel") > 0 && this.get_u16("burncooldown") != 0)
			{
				this.Tag("active");
				//if(sprite !is null)
				//	sprite.SetFrame(1);
				this.add_f32("fuel", -1);
				this.add_u16("burncooldown", -1);
			}
			else
			{
				//if(sprite !is null)
				//	sprite.SetFrame(0);
				this.Untag("active");
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
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

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
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
	else if(this.getCommandID("meltitem") == cmd)
	{
		CBlob@ melted = getBlobByNetworkID(params.read_u16());
		u8 count = params.read_u8();
		if(melted !is null)
		{
			int id = -1;
			array<int>@ values = getElementalValue(melted.getConfig(), id);
			CAlchemyTank@ tank = getTank(this, 0);
			if(values !is null && tank !is null)
			{
				array<int> valcopy;
				for (uint i = 0; i < values.length; i++)
				{
					valcopy.push_back(values[i] * count * 2);
				}
				this.add_u16("burncooldown", getTotal(@valcopy));
				addToTank(tank, valcopy);
				melted.server_SetQuantity(melted.getQuantity() - count);
				if(melted.getQuantity() <= 0)
				{
					melted.server_Die();
				}
			}
		}
		
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	//Everybody can access! yey
	return true;
}

array<int>@ getElementalValue(string name, int &out id)
{
	for (uint i = 0; i < meltlist.length; i++)
	{
		if(meltlist[i].name == name)
		{
			id = i;
			return @meltlist[i].values;
		}
	}
	return null;
}