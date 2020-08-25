
//Alright, ideas time
//I want food to have status effects, how to do?
//1. Food will consist of several different ingredients, one of which will determine main effects
//2. All other ingredients will modify stats on effect, ex. power, duration, possible auxilliary effects
//3. I want any ingredient to be able to determine main effect and base stats

//Lets give each ingredient some basic stats:
//Duration and power for if main ingredient
//Duration and power multipliers otherwise
//Option for secondary ingredient effect?

//One way to determine which ingredient is the main is assigning a "flavor" value
//Whichever one has the highest will determine effect
//Maybe, if two ingredients match, the food will get both effects, at the cost of missing out on a multiplier
//Or they could get a minor duration reduction or something
//Duration between all effects applied should be the same tho

//More ideas:
//Way to increase or decrease the flavor on an ingredient
//So you could force it to match flavor of another, at a certain cost?
//Maybe this can be implemented through condiments: salt, pepper, ketchup, ranch, mustard, honey, or even boiling an ingredient
//Mmm boiled asparagus lel

//Note: just base data, modifiers probs

//Oh right, need stuff like healing power, since it is food, and also ingredient category (Grain, veg, fruit, meat)

//Ooh, here's idea
//Different recipe types have different status affinities?
//Ex burger good for strength buff
//Salad good for speed boost
//Something like that
//Or just modifiers on power and duration
namespace Categories
{
	enum Types
	{
		Grain = 	0b00000001,
		Meat = 		0b00000010,
		Vegetable = 0b00000100,
		Fruit = 	0b00001000,
		Cheese = 	0b00010000,
		Fish =	 	0b00100000
	}
}

int ingidcounter = 0;
class CIngredientData
{
	int id;
	string ingredient;
	string friendlyname;
	int flavor;
	int effect;
	float healing;
	int basepower;
	int baseduration;
	float powermod;
	float durationmod;
	SColor color;
	u8 typedata;
	CIngredientData(string ingredient, string friendlyname, int flavor, int effect, float healing, int basepower, int baseduration, float powermod, float durationmod, SColor color, u8 typedata)
	{
		id = ingidcounter;
		ingidcounter++;

		this.ingredient = ingredient;
		this.friendlyname = friendlyname;
		this.flavor = flavor;
		this.effect = effect;
		this.healing = healing;
		this.basepower = basepower;
		this.baseduration = baseduration;
		this.powermod = powermod;
		this.durationmod = durationmod;
		this.color = color;
		this.typedata = typedata;
	}
}

array<CIngredientData@> ingredientdata =
{
	@CIngredientData("lettuce", 	"Lettuce",		2, 6, 0.25, 4, 900, 1, 1, 	SColor(255, 100, 155, 13),	Categories::Vegetable),
	@CIngredientData("grain", 		"Wheat",		4, 9, 0.5, 	4, 900, 1.2, 1.2,	SColor(255, 196, 135, 58),	Categories::Grain),		//technially some generic grain, we'll treat it like wheat tho lel
	@CIngredientData("tomato", 		"Tomato",		3, 6, 0.25, 2, 1800, 1, 1, 	SColor(255, 213, 84, 63),	Categories::Vegetable | Categories::Fruit), //its not both, of course, but eh
	@CIngredientData("cucumber", 	"Cucumber",		4, 0, 0.25, 4, 900, 1.1, 1.1, SColor(255, 150, 200, 65),	Categories::Vegetable),	//we need stuff with more flavor lel
	@CIngredientData("steak",	 	"Beef",			8, 0, 0.5, 	7, 450, 1.3, 1.3, SColor(255, 213, 84, 63),	Categories::Meat),
	@CIngredientData("fishy",	 	"Fish",			5, 0, 0.5, 	4, 900, 1, 1.5, 	SColor(255, 44, 175, 222),	Categories::Meat | Categories::Fish),		//Change to a cooked fish or whatever eventually, maybe
	@CIngredientData("carrot",	 	"Carrot",		6, 10, 0.25, 4, 900, 1.4, 1, 	SColor(255, 230, 110, 0),	Categories::Vegetable),
	@CIngredientData("lantern",	 	"Lantern?",		0, 0, 0, 	4, 900, 1, 1, 	SColor(255, 240, 230, 30),	Categories::Cheese),	//Temporary cheese substitute
	@CIngredientData("rosarybead", 	"Rosary Bead",	10, 11, -0.5, 15, 300, 1, 1, 	SColor(255, 150, 64, 43),	Categories::Vegetable),
	@CIngredientData("pineapple", 	"Pineapple",	7, 9, 0.5, 10, 300, 1.5, 1.3, 	SColor(255, 213, 204, 74),	Categories::Fruit | Categories::Vegetable)
};

CIngredientData@ getIngredientData(string input)
{
	for (int i = 0; i < ingredientdata.length; i++)
	{
		if(input == ingredientdata[i].ingredient)
		
			return @ingredientdata[i];
	}
	return null;
}

class CRecipeData
{
	string recipename;
	array<u8> ingredientlist;
	array<string> ingredientspecific;
	array<u8> optionals;
	CRecipeData(string recipename)
	{
		this.recipename = recipename;
	}

	CRecipeData@ addIngredient(u8 ingredient)
	{
		ingredientlist.push_back(ingredient);
		return @this;
	}

	CRecipeData@ addSpecific(string ingredient)
	{
		ingredientspecific.push_back(ingredient);
		return @this;
	}

	CRecipeData@ addOptional(u8 ingredient)
	{
		optionals.push_back(ingredient);
		return @this;
	}
}

array<CRecipeData@> recipelist = 
{
	@CRecipeData("Burger").addIngredient(Categories::Grain).addIngredient(Categories::Meat).addIngredient(Categories::Vegetable).addOptional(Categories::Cheese),
	@CRecipeData("Salad").addIngredient(Categories::Vegetable).addIngredient(Categories::Vegetable).addIngredient(Categories::Vegetable).addOptional(Categories::Fruit | Categories::Meat),
	@CRecipeData("Pizza").addIngredient(Categories::Grain).addIngredient(Categories::Cheese).addSpecific("tomato").addOptional(Categories::Fruit | Categories::Meat),
	@CRecipeData("Pancakes").addIngredient(Categories::Grain).addIngredient(Categories::Grain).addIngredient(Categories::Grain).addOptional(Categories::Fruit)
};

void makeFoodData(CBlob@ this)
{
	//First, we get the recipe used to make this food
	u8 recipe = this.get_u8("recipe");
	array<CIngredientData@> ingredients;

	CRecipeData@ recdata;
	if(recipe >= recipelist.size())
		return;
	@recdata = @recipelist[recipe];

	//Then, all the ingredients from that recipe
	string texname = "customfood";
	for(int i = 0; i < recdata.ingredientlist.size(); i++)
	{
		ingredients.push_back(@getIngredientData(this.get_string("ingredient" + i)));
		texname += getIngredientData(this.get_string("ingredient" + i)).id;
	}

	//Optionals yeet
	for(int i = 0; i < recdata.optionals.size(); i++)
	{
		string ing = this.get_string("ingredient" + (i + recdata.ingredientlist.size()));
		if(ing != "")
		{
			ingredients.push_back(@getIngredientData(ing));
			texname += getIngredientData(ing).id;
		}
		else
		{
			ingredients.push_back(null);//uhhhhhhhhhhhh tomnato
			texname += "x";
		}
	}

	//This part makes the custom sprite we use
	if(isClient())
	{	
		CSprite@ sprite = this.getSprite();
		Vec2f spritesize(16, 16);
		//Texname is the unique name for each type of food
		//If it exists, we can just set it
		if(Texture::exists(texname))
		{
			sprite.SetTexture(texname, 16, 16);
			sprite.SetFrame(0);
		}
		else
		{
			//Otherwise, make the sprite

			//This part makes sure the ImageData for the base custom food sprite exists, so we can copy what we need from it	
			if(!Texture::exists("CustomFood"))
			{
				if(!Texture::createFromFile("CustomFood", "CustomFood.png"))
					print("oh this is a problem");
			}
			//Getting base image data
			ImageData@ baseimage = Texture::data("CustomFood");
			//if(!Texture::createBySize(texname, 32, 16))
				//print("ohno");
			//New image data
			ImageData@ newimage = @ImageData(16, 16);
			
			//First, clear image
			for(int x = 0; x < 16; x++)
			{
				for(int y = 0; y < 16; y++)
				{
					newimage.put(x, y, SColor(0, 0, 0, 0));
				}
			}
			
			//Now, for each ingredient we add the pixels from the base image, properly tinted to match the ingredient
			Vec2f startpos = Vec2f(0, 16 * recipe);
			//First thing we copy is not tinted, usually outline and such
			mergeOnto(newimage, baseimage, Vec2f_zero, startpos, startpos + spritesize);
			for(int i = 0; i < ingredients.size(); i++)
			{
				if(ingredients[i] !is null)
					mergeOntoColored(newimage, baseimage, Vec2f_zero, startpos + Vec2f((i + 1) * spritesize.x, 0), startpos + Vec2f((i + 1) * spritesize.x, 0) + spritesize, ingredients[i].color);
			}

			//Now, we actually create the texture from the new image data
			Texture::createFromData(texname, newimage);
			//And just set all the stuff we need to
			sprite.SetTexture(texname, 16, 16);
			sprite.SetFrame(0);
			
			//Code partially stolen from custom gun stuff woo
		}
		this.SetInventoryIcon("RecipeIcons.png", recipe, Vec2f(16, 16));
		string name = "";
		for(int i = 0; i < recdata.ingredientlist.size(); i++)
		{
			if(i == recdata.ingredientlist.size() - 1)
			{
				if(i == 0)
					name += getIngredientData(this.get_string("ingredient" + i)).friendlyname + " ";
				else
					name += "and " + getIngredientData(this.get_string("ingredient" + i)).friendlyname + " ";
			}
			else
			{
				if(recdata.ingredientlist.size() > 2)
					name += getIngredientData(this.get_string("ingredient" + i)).friendlyname + ", ";
				else
					name += getIngredientData(this.get_string("ingredient" + i)).friendlyname + " ";
			}
		}
		name += recdata.recipename;
		
		if(this.get_string("ingredient" + (recdata.ingredientlist.size())) != "")
		{
			name += " with " + getIngredientData(this.get_string("ingredient" + (recdata.ingredientlist.size()))).friendlyname;
		}

		this.setInventoryName(name);
	}

	//Now, we do the stats of the food
	//Add specifics to the ingredients array 
	for(int i = 0; i < recdata.ingredientspecific.size(); i++)
	{
		ingredients.push_back(@getIngredientData(recdata.ingredientspecific[i]));
	}
	//First, get the highest flavor, this will determine the basic stats
	int flavorid = -1;
	int highestflavor = -1;

	for(int i = 0; i < ingredients.size(); i++)
	{
		if(ingredients[i] !is null && ingredients[i].flavor > highestflavor)
		{
			flavorid = i;
			highestflavor = ingredients[i].flavor;
		}
	}
	//Now, extract base stats and multiply the rest into it
	float foodpower = ingredients[flavorid].basepower;
	float foodduration = ingredients[flavorid].baseduration;
	for(int i = 0; i < ingredients.size(); i++)
	{
		if(i != flavorid && ingredients[i] !is null)
		{
			foodpower *= ingredients[i].powermod;
			foodduration *= ingredients[i].durationmod;
		}
	}
	//Lit, now we just set the vars, and applying it will be handled in the food eating code, woo
	this.set_u8("fxid", ingredients[flavorid].effect);
	this.set_u16("fxpower", foodpower);
	this.set_u32("fxduration", foodduration);
}

void mergeOntoColored(ImageData@ onto, ImageData@ fromimage, Vec2f offset, Vec2f startpos, Vec2f endpos, SColor color)
{
	//Resaturation?
	//Dunno lel
	float invratio = Maths::Max(Maths::Max(color.getRed(), color.getGreen()), color.getBlue());
	invratio /= 255.0;
	invratio = 1.0 - invratio;
	invratio += 1.0;
	color.set(255, color.getRed() * invratio,  color.getGreen() * invratio,  color.getBlue() * invratio);
	for(int x = startpos.x; x < endpos.x; x++)
	{
		for(int y = startpos.y; y < endpos.y; y++)
		{
			SColor pixcol = fromimage.get(x, y);
			float colratio = pixcol.getRed() / 255.0;
			//colratio = Maths::Min(1.0, colratio * 2.0);
			pixcol.set(pixcol.getAlpha(), color.getRed() * colratio, color.getGreen() * colratio, color.getBlue() * colratio);
			Vec2f thispos = (Vec2f(x, y) - startpos) + offset;
			if(pixcol.getAlpha() > 0)
				onto.put(thispos.x, thispos.y, pixcol);
		}
	}
}

void mergeOnto(ImageData@ onto, ImageData@ fromimage, Vec2f offset, Vec2f startpos, Vec2f endpos)
{
	for(int x = startpos.x; x < endpos.x; x++)
	{
		for(int y = startpos.y; y < endpos.y; y++)
		{
			SColor pixcol = fromimage.get(x, y);
			Vec2f thispos = (Vec2f(x, y) - startpos) + offset;
			if(pixcol.getAlpha() > 0)
				onto.put(thispos.x, thispos.y, pixcol);
		}
	}
}
