#include "NodeCommon.as";
#include "MakeSeed.as";
#include "RenderParticleCommon.as";

class CAlchemyInfuse
{
	string element;
	int elementquant;
	string item;
	int itemquant;
	string output;
	int outputquant;
	int proctime;
	CAlchemyInfuse(string element, string item, string output, int elementquant, int itemquant, int outputquant, int proctime)
	{
		this.element = element;
		this.item = item;
		this.output = output;
		
		this.elementquant = elementquant;
		this.itemquant = itemquant;
		this.outputquant = outputquant;
		
		this.proctime = proctime;
	}
}

array<CAlchemyInfuse@> infuserecipes =
{
	@CAlchemyInfuse(
	"life",//input element
	"seed",//input item
	"tree_life",//output item
	100,//element amount
	1,//item amount
	1,//output amount
	900//processing time
	),
	@CAlchemyInfuse(
	"aer",//input element
	"lantern",//input item
	"lum",//output item
	100,//element amount
	1,//item amount
	1,//output amount
	45//processing time
	),
	
	@CAlchemyInfuse(
	"purity",//input element
	"mat_stone",//input item
	"mat_marble",//output item
	25,//element amount
	25,//item amount
	25,//output amount
	25//processing time
	),

	@CAlchemyInfuse(
	"purity",//input element
	"mat_gold",//input item
	"mat_purifiedgold",//output item
	400,//element amount
	250,//item amount
	1,//output amount
	1800//processing time
	),
	
	@CAlchemyInfuse(
	"corruption",//input element
	"mat_stone",//input item
	"mat_basalt",//output item
	25,//element amount
	25,//item amount
	25,//output amount
	25//processing time
	),

	@CAlchemyInfuse(
	"aer",//input element
	"mat_purifiedgold",//input item
	"skyanchor",//output item
	50,//element amount
	1,//item amount
	1,//output amount
	150//processing time
	),

	@CAlchemyInfuse(
	"life",//input element
	"builder",//input item
	"builder",//output item
	250,//element amount
	1,//item amount
	1,//output amount
	300//processing time
	),
	
	//Can duplicate items sometimes...?
	//Might have to have it merge with a stack if possible instead?
	@CAlchemyInfuse(
	"any",//input element
	"mat_stone",//input item
	"mat_metal",//output item
	25,//element amount
	25,//item amount
	1,//output amount
	50//processing time
	),
	
	@CAlchemyInfuse(
	"ecto",//input element
	"mat_gold",//input item
	"souldust",//output item
	100,//element amount
	25,//item amount
	1,//output amount
	900//processing time
	),
	
	@CAlchemyInfuse(
	"ignis",//input element
	"mat_charcoal",//input item
	"blazecore",//output item
	250,//element amount
	100,//item amount
	1,//output amount
	600//processing time
	),
	
	@CAlchemyInfuse(
	"holy",//input element
	"mat_ammo",//input item
	"mat_holyammo",//output item
	25,//element amount
	10,//item amount
	10,//output amount
	90//processing time
	),

	@CAlchemyInfuse(
	"life",//input element
	"log",//input item
	"tree_pine",//output item
	25,//element amount
	1,//item amount
	1,//output amount
	30//processing time
	),

	@CAlchemyInfuse(
	"life",//input element
	"heart",//input item
	"chicken",//output item
	25,//element amount
	1,//item amount
	1,//output amount
	30//processing time
	),
	
	@CAlchemyInfuse(
	"yeet",//input element
	"mat_ammo",//input item
	"mat_yeetammo",//output item
	25,//element amount
	10,//item amount
	10,//output amount
	90//processing time
	),

	@CAlchemyInfuse(
	"yeet",//input element
	"ammopack",//input item
	"yeetammopack",//output item
	50,//element amount
	1,//item amount
	1,//output amount
	150//processing time
	),

	@CAlchemyInfuse(
	"holy",//input element
	"ammopack",//input item
	"holyammopack",//output item
	50,//element amount
	1,//item amount
	1,//output amount
	150//processing time
	),

	@CAlchemyInfuse(
	"force",//input element
	"mat_metal",//input item
	"mat_accelplate",//output item
	100,//element amount
	1,//item amount
	1,//output amount
	300//processing time
	),

	@CAlchemyInfuse(
	"force",//input element
	"inertcrystal",//input item
	"powercrystal",//output item
	100,//element amount
	1,//item amount
	1,//output amount
	300//processing time
	)
};

void onInit(CBlob@ this)
{	
	//Setup tanks
	CAlchemyTank@ input = addTank(this, "Input", true, Vec2f(0, -8));
	input.singleelement = true;
	input.maxelements = 1000;

	CItemIO@ iinput = @addItemIO(this, "Input", true, Vec2f(0, 0));
	CItemIO@ output = @addItemIO(this, "Output", false, Vec2f(0, 0));
	output.onlymovetagged = true;

	CLogicPlug@ disable = @addLogicPlug(this, "Disable", true, Vec2f(12, -12));
	//addTank(this, "inputr", true, Vec2f(4, -4));
	//addTank(this, "output", false, Vec2f(0, 4));
	this.set_u16("processtime", 0);
	
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ layer = this.addSpriteLayer("runes");
	CSpriteLayer@ woodlayer = this.addSpriteLayer("bgwood");
	CSpriteLayer@ itemlayer = this.addSpriteLayer("item");
	layer.SetRelativeZ(1);
	layer.SetFrame(1);
	woodlayer.SetRelativeZ(-10);
	woodlayer.SetFrame(2);
	//layer.setRenderStyle(RenderStyle::light);
	layer.SetLighting(false);
	itemlayer.SetVisible(false);
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ layer = this.getSpriteLayer("runes");
	CBlob@ blob = this.getBlob();
	CAlchemyTank@ tank = getTank(blob, 0);
	SColor color(255, 0, 0, 0);
	int id = -1;
	if(tank !is null)
		id = firstId(tank);
	if(id != -1)
		color = elementlist[id].color;
	
	layer.SetColor(color);
		
	if(blob.hasTag("active"))
	{
		Random rando(XORRandom(0x7FFFFFFF));
		if(rando.NextRanged(10) == 0)
		{
			CRenderParticleString newpart(1, false, false, 30, 0.25, color, true, 0, 5);
			newpart.velocity = Vec2f((rando.NextFloat() - 0.5) * 2, -rando.NextFloat() + -2.5);
			newpart.position = blob.getPosition()/* + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4)*/;
			addParticleToList(newpart);
		}
		if(rando.NextRanged(3) == 0)
		{
			this.PlaySound("lightup.ogg", rando.NextFloat() * 0.75 + 0.5, rando.NextFloat() * 0.75 + 0.5);
			ParticlePixel(blob.getPosition(), Vec2f((rando.NextFloat() - 0.5) * 4, (rando.NextFloat() - 1) * 4), color, true, 50);
		}
	}
	
	CSpriteLayer@ itemlayer = this.getSpriteLayer("item");
	if(itemlayer !is null)
	{
		CBlob@ item = blob.getInventory().getItem(0);
		string lastitem = blob.get_string("lastitem");
		if(item !is null)
		{
			itemlayer.SetVisible(true);
			CSprite@ itemsprite = item.getSprite();
			if(lastitem != item.getConfig())
			{
				itemlayer.ReloadSprite(itemsprite.getFilename(), itemsprite.getFrameWidth(), itemsprite.getFrameHeight());
				blob.set_string("lastitem", item.getConfig());
			}
			itemlayer.SetFrame(itemsprite.getFrame());
		}
		else
		{
			itemlayer.SetVisible(false);
		}
	}
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, 0);
	//CAlchemyTank@ inputr = getTank(this, "inputr");
	//CAlchemyTank@ output = getTank(this, "output");
	
	//Lots of loops in here, might need to optimize
	//CBlob@ item = this.getInventory().getItem(0);
	CInventory@ inv = this.getInventory();
	
	CSprite@ sprite = this.getSprite();
	if(input !is null && inv !is null && !getDisabled(this))
	{
		for(int i = 0; i < input.storage.elements.length; i++)
		{
			if(input.storage.elements[i] > 0)
			{
				for(int j = 0; j < infuserecipes.length; j++)
				{
					for(int k = 0; k < inv.getItemsCount(); k++)
					{
						CBlob@ invitem = inv.getItem(k);
						if(invitem.getConfig() == infuserecipes[j].item && inv.getCount(invitem.getConfig()) >= infuserecipes[j].itemquant)
						{
							if((elementlist[i].name == infuserecipes[j].element || infuserecipes[j].element == "any") &&
							input.storage.elements[i] >= infuserecipes[j].elementquant)
							{
								this.Tag("active");
								this.add_u16("processtime", 1);
								//Doing the thing
								if(this.get_u16("processtime") >= infuserecipes[j].proctime)
								{
									this.set_u16("processtime", 0);
									input.storage.elements[i] -= infuserecipes[j].elementquant;
										if(sprite !is null)
									sprite.PlaySound("ProduceSound.ogg", 1, 1);
									if(isServer())
									{
										int reqc = infuserecipes[j].itemquant;
										int index = 0;
										while(reqc > 0)
										{
											CBlob@ item = inv.getItem(index);
											if(item !is null && item.getName() == invitem.getConfig())
											{
												if(item.getQuantity() < reqc)
												{
													reqc -= item.getQuantity();
													item.server_Die();
												}
												else
												{
													item.server_SetQuantity(item.getQuantity() - reqc);
													reqc = 0;
												}
											}
											index++;
											if(index > inv.getItemsCount())
											{
												print("This shouldnt ever print - AlchemicalInfuser.as");
												break;
											}
										}

										CBlob@ output = null;
										if(infuserecipes[j].output.find("tree") >= 0)
										{
											@output = server_MakeSeed(this.getPosition(), infuserecipes[j].output);
										}
										else if(infuserecipes[j].output.find("mat_") >= 0)
										{
											@output = server_CreateBlobNoInit(infuserecipes[j].output);
											output.Tag("custom quantity");
											output.setPosition(this.getPosition());
											output.server_SetQuantity(infuserecipes[j].outputquant);
											output.Init();
										}
										else
										{
											@output = server_CreateBlob(infuserecipes[j].output, this.getTeamNum(), this.getPosition());
											output.server_SetQuantity(infuserecipes[j].outputquant);
										}
										CItemIO@ outputio = getItemIO(this, "Output");
										if(outputio !is null && outputio.connection !is null)
										{
											this.server_PutInInventory(output);
											output.Tag("outputblob");
										}
									}
								}
								return;
							}
						}
					}
				}
			}
		}
	}
	this.Untag("active");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}

