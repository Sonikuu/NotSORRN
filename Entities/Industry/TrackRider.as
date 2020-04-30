//Track Riding Core
#include "CustomBlocks.as";

namespace RiderDir
{
	u8 right = 	0b0001;
	u8 down = 	0b0010;
	u8 left = 	0b0100;
	u8 up = 	0b1000;
	u8 nope = 	0b0000;
	
	/*enum CurrDir
	{
		left = 0,
		down,
		right,
		up
	};*/
}

void onInit(CBlob@ this)
{
	this.set_f32("railmult", 1);
	if(!this.exists("riding"))
		this.set_bool("riding", false);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.get_bool("riding") && this.get_bool("riding"))
		return false;
	return true;
}

const float movespeed = 1;

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(!this.get_bool("riding"))
	{
		Tile tile = map.getTile(this.getPosition());
		if(tile.type >= CCTiles::tile_track && tile.type < CCTiles::tile_track + track_variation && !this.isAttached())
		{
			this.set_bool("riding", true);
			u8 nextdir = getNextDir(tile, RiderDir::nope);
			this.set_u8("nextdir", nextdir);
			Vec2f goodpos = blockCenterPos(this.getPosition(), map);
			this.setPosition(goodpos);
			this.setVelocity(Vec2f_zero);
			this.set_Vec2f("nextpos", goodpos + dirToVec(nextdir) * map.tilesize);
			this.Sync("nextpos", true);
			Sound::Play("thud.ogg", this.getPosition(), 1.0f);
		}
		this.getShape().getConsts().mapCollisions = true;
	}
	else
	{
		float railspeed = movespeed * this.get_f32("railmult");
		Tile tile = map.getTile(this.getPosition());
		if(!(tile.type >= CCTiles::tile_track && tile.type < CCTiles::tile_track + track_variation) || this.isAttached())
		{
			this.set_bool("riding", false);
		}
		else
		{
			if((this.getPosition() - this.get_Vec2f("nextpos")).Length() < railspeed * 1.5)//If close to center
			{
				u8 nextdir = getNextDir(tile, this.get_u8("nextdir"));
				this.set_u8("nextdir", nextdir);
				Vec2f goodpos = blockCenterPos(this.getPosition(), map);
				this.set_Vec2f("nextpos", goodpos + dirToVec(nextdir) * map.tilesize);
				this.Sync("nextpos", true);
			}
			Vec2f diff = this.get_Vec2f("nextpos") - this.getPosition();
			diff.Normalize();
			this.setVelocity(diff * railspeed);
			this.getShape().getConsts().mapCollisions = false;
		}
	}
	
	CShape@ shape = this.getShape();
	if(shape !is null)
	{
		if(!this.get_bool("riding"))
			shape.SetGravityScale(1);
		else
			shape.SetGravityScale(0);
	}
}

Vec2f blockCenterPos(Vec2f pos, CMap@ map)
{
	pos /= map.tilesize;
	pos.x = Maths::Floor(pos.x) + 0.5;
	pos.y = Maths::Floor(pos.y) + 0.5;
	return pos * map.tilesize;
}

Vec2f dirToVec(u8 dir)
{
	if(dir == RiderDir::left)
		return Vec2f(-1, 0);
	if(dir == RiderDir::down)
		return Vec2f(0, 1);
	if(dir == RiderDir::right)
		return Vec2f(1, 0);
	if(dir == RiderDir::up)
		return Vec2f(0, -1);
	return Vec2f_zero;
}

u8 getNextDir(Tile tile, u8 blackdirs)
{
	u8 available = 0;
	if(tile.type == CCTiles::tile_track)//NO CONNECTION
		return RiderDir::nope;
	else if(tile.type == CCTiles::tile_trackc)//CORNER
		available = RiderDir::left | RiderDir::down;
	else if(tile.type == CCTiles::tile_tracks)//STRAIGHT, UNLIKE WHOEVERS READING THIS
		available = RiderDir::left | RiderDir::right;
	else if(tile.type == CCTiles::tile_trackt)//T JUNC
		available = RiderDir::left | RiderDir::right | RiderDir::down;
	else if(tile.type == CCTiles::tile_tracke)//END
		available = RiderDir::down;
	else//4 WAY, AT LEAST IT SHOULD BE
		available = 0b1111;
	
	
	if(tile.flags & Tile::ROTATE > 0)//Rotate first, other two shouldnt matter
	{
		available = rotateDirs(available);
	}
	if(tile.flags & Tile::FLIP > 0)
	{
		available = flipDirs(available);
	}
	if(tile.flags & Tile::MIRROR > 0)
	{
		available = mirrorDirs(available);
	}
	blackdirs = flipDirs(mirrorDirs(blackdirs));
	if(available == blackdirs)//Ignore blacklist, go backwards
		return available;
	available &= ~blackdirs;
	u8 possdirs = XORRandom((available & 1) + ((available >> 1) & 1) + ((available >> 2) & 1) + ((available >> 3) & 1)) + 1;
	u8 currcheck = 1;
	while (true)
	{
		if(currcheck & available > 0)
		{
			possdirs--;
			if(possdirs == 0)
			{
				break;
			}
		}
		if(currcheck > 0b1000 || currcheck == 0)//Simple check, might remove later if this works fine
		{
			print("IM BAD");
			return 0;
		}
		currcheck *= 2;
	}
	return currcheck;
}

u8 rotateDirs(u8 dirs)
{
	return (dirs << 1) + ((dirs & 0b1000) >> 3);
}

u8 flipDirs(u8 dirs)//UP BECOMES DOWN
{
	return ((dirs & RiderDir::down) << 2) | ((dirs & RiderDir::up) >> 2) | (dirs & 0b0101);
}

u8 mirrorDirs(u8 dirs)//LEFT BECOMES RIGHT
{
	return ((dirs & RiderDir::right) << 2) | ((dirs & RiderDir::left) >> 2) | (dirs & 0b1010);
}




