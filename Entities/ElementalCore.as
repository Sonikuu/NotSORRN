//Main elemental handler
//Should be usuable for both alchemy system and blob element levels
//Thinking alchemy system will have one of these for each internal tank

//Used to store all the elemental vars like name/color/internal name
//Maybe we can program special behaviors in here?

#include "AlchemyFocusBehavior.as";

const int HIDDEN_ELEMENTS = 1;

class CElementSetup
{
	string name;
	SColor color;
	string visiblename;
	padProto@ padbehavior;
	wardProto@ wardbehavior;
	bindProto@ bindbehavior;
	sprayProto@ spraybehavior;
	vialIngestProto@ vialIngestbehavior;
	vialSplashProto@ vialSplashbehavior;

	bool hidden;
	CElementSetup(string name, SColor color, string visiblename, padProto@ padbehavior, wardProto@ wardbehavior, bindProto@ bindbehavior, sprayProto@ spraybehavior, vialIngestProto@ vialIngestbehavior, vialSplashProto@ vialSplashbehavior)
	{
		this.name = name;
		this.color = color;
		this.visiblename = visiblename;
		@this.padbehavior = padbehavior;
		@this.wardbehavior = wardbehavior;
		@this.bindbehavior = bindbehavior;
		@this.spraybehavior = spraybehavior;
		@this.vialIngestbehavior = vialIngestbehavior;
		@this.vialSplashbehavior = vialSplashbehavior;

		hidden = false;
	}
	CElementSetup setHidden(bool hidden)
	{
		this.hidden = hidden;
		return this;
	}
}


//Element list, all other parts should be able to work off of only this
//When getting data about elements, use the element list

enum EElement
{
	ecto = 0,
	life = 1,
	natura = 2,
	force = 3,
	aer = 4,
	ignis = 5,
	terra = 6,
	order = 7,
	entropy = 8,
	aqua = 9,
	corruption = 10,
	purity = 11,
	unholy = 12,
	holy = 13,
	yeet = 14
}

const array<CElementSetup> elementlist = 
{
	CElementSetup//0
	("ecto",//Internal name for getting / setting element levels
	SColor(255, 200, 200, 200),//Color: Intended to use for alchemy system
	"Soul",//External name, in case we ever need one
	@padEcto,
	@wardEcto,
	@bindBlank,
	@sprayEcto,
	@vialIngestEcto,
	@vialSplashEcto),	//Replace the blanks with special behavior when added
				//We can add icon names when we need to (or can, more like)
	
	CElementSetup//1
	("life",
	SColor(255, 100, 200, 255),
	"Life",
	@padLife,
	@wardLife,
	@bindLife,
	@sprayLife,
	@vialIngestLife,
	@vialSplashLife),
	
	CElementSetup//2
	("natura",
	SColor(255, 50, 255, 50),
	"Natura",
	@padNatura,
	@wardNatura,
	@bindBlank,
	@sprayNatura,
	@vialIngestNatura,
	@vialSplashNatura),
	
	CElementSetup//3
	("force",
	SColor(255, 255, 255, 50),
	"Force",
	@padForce,
	@wardForce,
	@bindBlank,
	@sprayForce,
	@vialIngestForce,
	@vialSplashForce),
	
	CElementSetup//4
	("aer",
	SColor(255, 200, 200, 100),
	"Aer",
	@padAer,
	@wardAer,
	@bindBlank,
	@sprayAer,
	@vialIngestAer,
	@vialSplashAer),
	
	CElementSetup//5
	("ignis",
	SColor(255, 255, 100, 100),
	"Ignis",
	@padIgnis,
	@wardIgnis,
	@bindBlank,
	@sprayIgnis,
	@vialIngestIgnis,
	@vialSplashIgnis),
	
	CElementSetup//6
	("terra",
	SColor(255, 100, 50, 0),
	"Terra",
	@padTerra,
	@wardTerra,
	@bindBlank,
	@sprayTerra,
	@vialIngestTerra,
	@vialSplashTerra),

	CElementSetup//7
	("order",
	SColor(255, 255, 255, 255),
	"Order",
	@padOrder,
	@wardOrder,
	@bindBlank,
	@sprayOrder,
	@vialIngestOrder,
	@vialSplashOrder),
	
	CElementSetup//8
	("entropy",
	SColor(255, 50, 50, 50),
	"Entropy",
	@padEntropy,
	@wardEntropy,
	@bindBlank,
	@sprayEntropy,
	@vialIngestEntropy,
	@vialSplashEntropy),
	
	CElementSetup//9
	("aqua",
	SColor(255, 100, 100, 255),
	"Aqua",
	@padAqua,
	@wardAqua,
	@bindBlank,
	@sprayAqua,
	@vialIngestAqua,
	@vialSplashEntropy),
	
	CElementSetup//10
	("corruption",
	SColor(255, 100, 0, 150),
	"Corruption",
	@padCorruption,
	@wardCorruption,
	@bindBlank,
	@sprayCorruption,
	@vialIngestCorruption,
	@vialSplashCorruption),
	
	CElementSetup//11
	("purity",
	SColor(255, 255, 255, 200),
	"Purity",
	@padPurity,
	@wardPurity,
	@bindBlank,
	@sprayPurity,
	@vialIngestPurity,
	@vialSplashPurity),
	
	CElementSetup//12
	("unholy",
	SColor(255, 150, 0, 100),
	"Unholy",
	@padUnholy,
	@wardBlank,
	@bindBlank,
	@sprayBlank,
	@vialIngestUnholy,
	@vialSplashUnholy),
	
	CElementSetup//13
	("holy",
	SColor(255, 255, 200, 100),
	"Holy",
	@padHoly,
	@wardBlank,
	@bindBlank,
	@sprayBlank,
	@vialIngestHoly,
	@vialSplashHoly),
	
	CElementSetup//14
	("yeet",
	SColor(255, 255, 200, 200),
	"YEET",
	@padAer,
	@wardForce,
	@bindBlank,
	@sprayForce,
	@vialIngestYeet,
	@vialSplashYeet).setHidden(true),
};

void renderElementsCentered(array<int>@ elements, Vec2f pos, bool excludeempty = true)
{
	const int iconsize = 32;
	const int spacing = 8;
	
	int iconcount = elementlist.length;
	
	if(excludeempty)
	{
		for (int i = 0; i < elementlist.length; i++)
		{
			if(elements[i] <= 0)
				iconcount--;
		}
	}
	const int iwidth = Maths::Max(Maths::Ceil(Maths::FastSqrt(float(iconcount))), 1);
	
	const int width = iwidth * iconsize + iwidth * (spacing - 1);
	const int center = width / 2;
	
	Vec2f startpos(pos.x - center, pos.y);
	
	int currpos = 0;
	
	for (int i = 0; i < elementlist.length; i++)
	{
		if(excludeempty)
		{
			if(elements[i] > 0)
			{
				drawElementIcon(startpos + Vec2f((iconsize + spacing) * (currpos % iwidth), (iconsize + spacing) * Maths::Floor(float(currpos) / iwidth)), i, elements[i]);
				currpos++;
			}
		}
		else
		{
			drawElementIcon(startpos + Vec2f((iconsize + spacing) * (currpos % iwidth), (iconsize + spacing) * Maths::Floor(float(currpos) / iwidth)), i, elements[i]);
			currpos++;
		}
	}
}

void renderElementsRight(array<int>@ elements, Vec2f pos, bool excludeempty = true)
{
	const int iconsize = 32;
	const int spacing = 8;
	
	int iconcount = elementlist.length;
	
	if(excludeempty)
	{
		for (int i = 0; i < elementlist.length; i++)
		{
			if(elements[i] <= 0)
				iconcount--;
		}
	}
	
	const int iwidth = Maths::Max(Maths::Ceil(Maths::FastSqrt(float(iconcount))), 1);
	
	const int width = iwidth * iconsize + iwidth * (spacing - 1);
	
	Vec2f startpos(pos.x - width, pos.y);
	
	int currpos = 0;
	
	for (int i = 0; i < elementlist.length; i++)
	{
		if(excludeempty)
		{
			if(elements[i] > 0)
			{
				drawElementIcon(startpos + Vec2f((iconsize + spacing) * (currpos % iwidth), (iconsize + spacing) * Maths::Floor(float(currpos) / iwidth)), i, elements[i]);
				currpos++;
			}
		}
		else
		{
			drawElementIcon(startpos + Vec2f((iconsize + spacing) * (currpos % iwidth), (iconsize + spacing) * Maths::Floor(float(currpos) / iwidth)), i, elements[i]);
			currpos++;
		}
	}
}

void drawElementIcon(Vec2f pos, int id, int amount)
{
	GUI::DrawIcon("ElementBG.png", 0, Vec2f(16, 16), pos);
	GUI::DrawIcon("ElementIcons.png", id, Vec2f(16, 16), pos);
	
	GUI::DrawTextCentered(elementlist[id].visiblename, pos + Vec2f(14, 0), SColor(255, 255, 255, 255));
	
	GUI::DrawTextCentered(formatInt(amount, ""), pos + Vec2f(14, 32), SColor(255, 255, 255, 255));
}

//Function for helping get the stuff and things
int elementIdFromName(string element)
{
	
	for (int i = 0; i < elementlist.length; i++)
	{
		if(element == elementlist[i].name)
		{
			
			return i;
		}
	}
	return -1;//If the string you give me isnt valid :V
}


class CElementalCore
{
	//Maybe can get away with only one array?
	array<int> elements;
	//Default init
	CElementalCore()
	{
		//What this should do is reserve however much space we need for this
		for (int i = 0; i < elementlist.length; i++)
		{
			elements.push_back(0);
		}
	}
	//Note: probably not gonna be using any of these functions and gonna instead use the global ones that take a blob
	
	//Now for the magic functions
	//getting element count from string
	int getElement(string element)
	{
		return getElement(elementIdFromName(element));
	}
	//Same thing but ID
	int getElement(int element)
	{
		if(element < elementlist.length && element >= 0)
			return elements[element];
		return -1;
	}
	void setElement(string element, int amount)
	{
		setElement(elementIdFromName(element), amount);
	}
	void setElement(int element, int amount)
	{
		if(element < elementlist.length && element >= 0)
			elements[element] = amount;
	}
	void addElement(string element, int amount)
	{
		addElement(elementIdFromName(element), amount);
	}
	void addElement(int element, int amount)
	{
		if(element < elementlist.length && element >= 0)
			elements[element] += amount;
	}
}

//Gets element
int getElement(CBlob@ blob, string element)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	if(core is null)
	{
		print("Null core! If this happens without command usage you suck");
		return 0;
	}
	return core.getElement(element);
}
int getElement(CBlob@ blob, int element)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	if(core is null)
	{
		print("Null core! If this happens without command usage you suck");
		return 0;
	}
	return (core.getElement(element));
}

//Sets element to amount
void setElement(CBlob@ blob, string element, int amount)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	if(core is null)
	{
		print("Null core! If this happens without command usage you suck");
		return;
	}
	core.setElement(element, amount);
}
void setElement(CBlob@ blob, int element, int amount)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	if(core is null)
	{
		print("Null core! If this happens without command usage you suck");
		return;
	}
	core.setElement(element, amount);
}

//Adds amount to the element
void addElement(CBlob@ blob, string element, int amount)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	if(core is null)
	{
		print("Null core! If this happens without command usage you suck");
		return;
	}
	core.addElement(element, amount);
}
void addElement(CBlob@ blob, int element, int amount)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	if(core is null)
	{
		print("Null core! If this happens without command usage you suck");
		return;
	}
	core.addElement(element, amount);
}

//Self explanitory: Swaps cores
void swapCore(CBlob@ blob, CBlob@ newblob)
{
	CElementalCore@ core;
	CElementalCore@ tempcore;
	newblob.get("elementcore", @tempcore);
	blob.get("elementcore", @core);
	newblob.set("elementcore", @core);
	blob.set("elementcore", @tempcore);
}

//Use to add core to blob oninit
void addCore(CBlob@ blob)
{
	CElementalCore core();
	blob.set("elementcore", @core);
}

CElementalCore@ getCore(CBlob@ blob)
{
	CElementalCore@ core;
	blob.get("elementcore", @core);
	return @core;
}

/*
Just some example code to help out, easy to use trust me

Swaps the core of both, essentially transferring all elements between
swapCore(builder, ghost);

Adds 10 ecto, easy enough
addElement(blob, "ecto", 10)


Prints the name of all elements and how much of it blob has
for (int i = 0; i < elementlist.length; i++)
{
	printInt(elementlist[i].visiblename, getElement(blob, i));
}











*/



















