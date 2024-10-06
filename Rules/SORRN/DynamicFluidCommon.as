


//The class below is currently unused so, this is the only current purpose for this script
//NVM things changed lol
const bool IS_WATER_ACTIVE = true;



/*
const u8 B_BIT = 0b1;		//Tile has any water
const u8 F_BIT = 0b01;		//Tile is full
const u8 M_BIT = 0b001;		//Tile moved this tick
const u8 A_BIT = 0b0001;	//Tile is active
			I'm so dumb lol
*/

const u8 B_BIT = 0b1;		//Tile has any water
const u8 F_BIT = 0b10;		//Tile is full
const u8 M_BIT = 0b100;		//Tile moved this tick
const u8 A_BIT = 0b1000;	//Tile is active

const u8 F_BIT_CMD = 0b10000000;
const u8 E_BIT_CMD = 0b01000000;

//Lets assign the R portion as the D value (amount of water)
//And the G portion as the U value (amount unusable)

bool getWaterB(u8 c)
{
	return (c & B_BIT) > 0;
}
bool getWaterF(u8 c)
{
	return (c & F_BIT) > 0;
}
bool getWaterM(u8 c)
{
	return (c & M_BIT) > 0;
}
bool getWaterA(u8 c)
{
	return (c & A_BIT) > 0;
}




//Handles not supported for SColor reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
SColor setWaterB(bool s, SColor c)
{
	if(s)
		c.setBlue(c.getBlue() | B_BIT);
	else
		c.setBlue(c.getBlue() & ~B_BIT);
	return c;
}
SColor setWaterF(bool s, SColor c)
{
	if(s)
		c.setBlue(c.getBlue() | F_BIT);
	else
		c.setBlue(c.getBlue() & ~F_BIT);
	return c;
}
SColor setWaterM(bool s, SColor c)
{
	if(s)
		c.setBlue(c.getBlue() | M_BIT);
	else
		c.setBlue(c.getBlue() & ~M_BIT);
	return c;
}
SColor setWaterA(bool s, SColor c)
{
	if(s)
		c.setBlue(c.getBlue() | A_BIT);
	else
		c.setBlue(c.getBlue() & ~A_BIT);
	return c;
}






//As long as we're setting the inwater part of ShapeVars we don't need to replace the vanilla functions for isInWater
//Still have to for the map.isInWater() tho
bool dynamicIsInWater(Vec2f pos)
{
	CMap@ map = getMap();
	pos /= map.tilesize;
	array<array<SColor>>@ waterdata;

	map.get("waterdata", @waterdata);
	if(waterdata is null || waterdata.size() == 0)//This can happen sometimes on nextmap
		return false;	

	if(waterdata !is null && pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
	{
		if(waterdata[pos.y][pos.x].getRed() > 0)
			return true;
	}
	return false;
}

void removeWater(Vec2f pos, int amt)
{
	CMap@ map = getMap();
	pos /= map.tilesize;
	array<array<SColor>>@ waterdata;

	map.get("waterdata", @waterdata);
	if(waterdata !is null && pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
	{
		waterdata[pos.y][pos.x].setRed(Maths::Max(int(waterdata[pos.y][pos.x].getRed()) - amt, 0));
		if(waterdata[pos.y][pos.x].getRed() < 15)
			waterdata[pos.y][pos.x] = setWaterF(false, waterdata[pos.y][pos.x]);
		setActive(pos);
	}
}

void addWater(Vec2f pos, int amt)
{
	CMap@ map = getMap();
	pos /= map.tilesize;
	array<array<SColor>>@ waterdata;

	map.get("waterdata", @waterdata);
	if(waterdata !is null && pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
	{
		waterdata[pos.y][pos.x].setRed(Maths::Min(int(waterdata[pos.y][pos.x].getRed()) + amt, 15));
		if(waterdata[pos.y][pos.x].getRed() >= 15)
			waterdata[pos.y][pos.x] = setWaterF(true, waterdata[pos.y][pos.x]);
		waterdata[pos.y][pos.x] = setWaterB(true, waterdata[pos.y][pos.x]);
		setActive(pos);
	}
}

u8 getWaterLevel(Vec2f pos)
{
	CMap@ map = getMap();
	pos /= map.tilesize;
	array<array<SColor>>@ waterdata;
	map.get("waterdata", @waterdata);
	if(waterdata !is null && pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
	{
		return waterdata[pos.y][pos.x].getRed();
	}
	return 0;
}

void setActive(Vec2f pos)
{
	CMap@ map = getMap();
	array<array<SColor>>@ waterdata;
	array<bool>@ activelayers;
	array<bool>@ activecolumns;

	map.get("waterdata", @waterdata);
	map.get("activelayers", @activelayers);
	map.get("activecolumns", @activecolumns);

	if(waterdata is null || activelayers is null || activecolumns is null)
		return;

		waterdata[pos.y][pos.x] = setWaterA(true, waterdata[pos.y][pos.x]);
	if(pos.x < map.tilemapwidth - 1)
		waterdata[pos.y][pos.x + 1] = setWaterA(true, waterdata[pos.y][pos.x + 1]);
	if(pos.x > 0)
		waterdata[pos.y][pos.x - 1] = setWaterA(true, waterdata[pos.y][pos.x - 1]);
	if(pos.y < map.tilemapheight - 1)
		waterdata[pos.y + 1][pos.x] = setWaterA(true, waterdata[pos.y + 1][pos.x]);
	if(pos.y > 0)
		waterdata[pos.y - 1][pos.x] = setWaterA(true, waterdata[pos.y - 1][pos.x]);

	activelayers[pos.y] = true;
	activecolumns[pos.x] = true;
	if(pos.y > 0)
		activelayers[pos.y - 1] = true;
	if(pos.y < map.tilemapheight)
		activelayers[pos.y + 1] = true;
	if(pos.x > 0)
		activecolumns[pos.x - 1] = true;
	if(pos.x < map.tilemapwidth)
		activecolumns[pos.x + 1] = true;
}


class CWaterTile
{
	bool b;		//If water
	bool f;		//If water full
	bool moved;	//If water already moved this tick, probs depreciate lel
	u8 d;		//Amount of water
	u8 u;		//Unusable amount of water, should make moved unnecessary
	bool a;		//Uh oh more bools, this one is a sort of active flag i guess

	CWaterTile()
	{
		b = false;
		moved = false;
		d = 0;
		u = 0;
		f = false;
		a = false;
	}
}

//array<array<CWaterTile>>@ waterdata;
//array<bool>@ activelayers;


