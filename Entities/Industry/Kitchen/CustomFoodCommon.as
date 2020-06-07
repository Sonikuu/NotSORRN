
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
	int flavor;
	int effect;
	float healing;
	int basepower;
	int baseduration;
	float powermod;
	float durationmod;
	SColor color;
	u8 typedata;
	CIngredientData(string ingredient, int flavor, int effect, float healing, int basepower, int baseduration, float powermod, float durationmod, SColor color, u8 typedata)
	{
		id = ingidcounter;
		ingidcounter++;

		this.ingredient = ingredient;
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
	@CIngredientData("lettuce", 	2, 0, 0.25, 1, 1, 1, 1, 	SColor(255, 100, 155, 13),	Categories::Vegetable),
	@CIngredientData("grain", 		3, 0, 0.5, 	1, 1, 1.2, 1.2,	SColor(255, 196, 135, 58),	Categories::Grain),		//technially some generic grain, we'll treat it like wheat tho lel
	@CIngredientData("tomato", 		2, 0, 0.25, 1, 1, 1, 1, 	SColor(255, 213, 84, 63),	Categories::Vegetable | Categories::Fruit), //its not both, of course, but eh
	@CIngredientData("cucumber", 	3, 0, 0.25, 1, 1, 1.1, 1.1, SColor(255, 150, 200, 65),	Categories::Vegetable),	//we need stuff with more flavor lel
	@CIngredientData("steak",	 	4, 0, 0.5, 	1, 1, 1.3, 1.3, SColor(255, 213, 84, 63),	Categories::Meat),
	@CIngredientData("fishy",	 	2, 0, 0.5, 	1, 1, 1, 1.5, 	SColor(255, 44, 175, 222),	Categories::Meat | Categories::Fish),		//Change to a cooked fish or whatever eventually, maybe
	@CIngredientData("carrot",	 	3, 0, 0.25, 1, 1, 1.4, 1, 	SColor(255, 230, 110, 0),	Categories::Vegetable),
	@CIngredientData("lantern",	 	0, 0, 0, 	1, 1, 1, 1, 	SColor(255, 240, 230, 30),	Categories::Cheese)	//Temporary cheese substitute
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
}

array<CRecipeData@> recipelist = 
{
	@CRecipeData("Burger").addIngredient(Categories::Grain).addIngredient(Categories::Meat).addIngredient(Categories::Vegetable),
	@CRecipeData("Salad").addIngredient(Categories::Vegetable).addIngredient(Categories::Vegetable).addIngredient(Categories::Vegetable),
	@CRecipeData("Pizza").addIngredient(Categories::Grain).addIngredient(Categories::Cheese).addSpecific("tomato")
};

void makeFoodImage(CBlob@ this)
{

	
	if(isClient())
	{
		//First, we get the recipe used to make this food
		u8 recipe = this.get_u8("recipe");
		array<CIngredientData@> ingredients;

		CRecipeData@ recdata;
		if(recipe >= recipelist.size())
			return;
		@recdata = @recipelist[recipe];

		//Then, all the ingredients from that recipe
		CSprite@ sprite = this.getSprite();
		string texname = "customfood";
		for(int i = 0; i < recdata.ingredientlist.size(); i++)
		{
			ingredients.push_back(@getIngredientData(this.get_string("ingredient" + i)));
			texname += getIngredientData(this.get_string("ingredient" + i)).id;
		}

		Vec2f spritesize(16, 16);
		if(Texture::exists(texname))
		{
			sprite.SetTexture(texname, 16, 16);
			sprite.SetFrame(0);
		}
		else
		{
			
			if(!Texture::exists("CustomFood"))
			{
				if(!Texture::createFromFile("CustomFood", "CustomFood.png"))
					print("oh this is a problem");
			}
			ImageData@ baseimage = Texture::data("CustomFood");
			//if(!Texture::createBySize(texname, 32, 16))
				//print("ohno");
			ImageData@ newimage = @ImageData(16, 16);
			
			
			for(int x = 0; x < 16; x++)
			{
				for(int y = 0; y < 16; y++)
				{
					newimage.put(x, y, SColor(0, 0, 0, 0));
				}
			}
			
			
			Vec2f startpos = Vec2f(0, 16 * recipe);
			mergeOnto(newimage, baseimage, Vec2f_zero, startpos, startpos + spritesize);
			for(int i = 0; i < ingredients.size(); i++)
			{
				mergeOntoColored(newimage, baseimage, Vec2f_zero, startpos + Vec2f((i + 1) * spritesize.x, 0), startpos + Vec2f((i + 1) * spritesize.x, 0) + spritesize, ingredients[i].color);
			}
			/*startpos = Vec2f(32, 16 * barrelindex);
			mergeOnto(newimage, baseimage, barrelpos, startpos, startpos + spritesize);
			startpos = Vec2f(64, 16 * stockindex);
			mergeOnto(newimage, baseimage, stockpos, startpos, startpos + spritesize);
			startpos = Vec2f(96, 16 * gripindex);
			mergeOnto(newimage, baseimage, grippos, startpos, startpos + spritesize);
			startpos = Vec2f(128, 16 * magindex);
			mergeOnto(newimage, baseimage, magpos, startpos, startpos + spritesize);*/
			
			//sprite.ReloadSprite(texname);
			Texture::createFromData(texname, newimage);
			sprite.SetTexture(texname, 16, 16);
			sprite.SetFrame(0);
			//FML everytime i use imagedata i want to die
			//ill get used to it eventually
		}
	}
}

void mergeOntoColored(ImageData@ onto, ImageData@ fromimage, Vec2f offset, Vec2f startpos, Vec2f endpos, SColor color)
{
	for(int x = startpos.x; x < endpos.x; x++)
	{
		for(int y = startpos.y; y < endpos.y; y++)
		{
			SColor pixcol = fromimage.get(x, y);
			float colratio = pixcol.getRed() / 255.0;
			colratio = Maths::Min(1.0, colratio * 2.0);
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
