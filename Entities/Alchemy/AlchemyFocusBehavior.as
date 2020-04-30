#include "AlchemyCommon.as";
#include "Hitters.as";
#include "FxLowGrav.as";
#include "FxDamageReduce.as";
#include "FxGhostlike.as";
#include "FxCorrupt.as";
#include "FxPure.as";
#include "FxRegen.as";
#include "FxLightFall.as";
#include "FxHoly.as";
#include "FxUnholy.as";
#include "TreeCommon.as";
#include "RenderParticleCommon.as";
#include "TileInteractions.as";
#include "LoaderColors.as";

//Ehm, this might get weird, trying something new here
//Callbacks?
funcdef void padProto(CBlob@, int, CBlob@);
funcdef void wardProto(float, int, CBlob@);
funcdef void bindProto(CBlob@, int, CBlob@);
//The three floats should be aimdir, spread, and range
funcdef void sprayProto(int, float, float, float, CBlob@, CBlob@);
//uhhh and then...
/*array<padProto@> padFuncs = 
{

}*/
//uhhhhhhh
//yeah dunno what im really doing but maybe itll work?
//Think ill have the padfuncs be part of element junk actually


//PAD FOCUS BEHAVIOR

void padBlank(CBlob@ blob, int power, CBlob@ pad){}

void padAer(CBlob@ blob, int power, CBlob@ pad)
{
	bool blobmovingleft = pad.isFacingLeft();
	
	blob.setVelocity(Vec2f(blobmovingleft ? 3 : -3, -3) * power + blob.getVelocity());
	
	applyFxLightFall(blob, power * 30, power);
	
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 30, 1, elementlist[4].color, true, 0, 5);
			newpart.velocity = Vec2f((float(XORRandom(1000) - 500) / 1000.0) + (pad.isFacingLeft() ? 2 : -2), (XORRandom(1000) / 1000.0) * -2 + -3) * 5;
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padLife(CBlob@ blob, int power, CBlob@ pad)
{
	blob.server_SetHealth(Maths::Min(blob.getHealth() + float(power) * 0.2, blob.getInitialHealth() * 2));
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0, elementlist[1].color, true, 0, 5);
			float temprot = XORRandom(1000) / 500.0 * Maths::Pi;
			newpart.velocity = Vec2f(Maths::Cos(temprot + Maths::Pi), Maths::Sin(temprot + Maths::Pi)) * 3;
			newpart.position = blob.getPosition() + Vec2f(Maths::Cos(temprot), Maths::Sin(temprot)) * 30;
			addParticleToList(newpart);
		}
	}
}

void padEcto(CBlob@ blob, int power, CBlob@ pad)
{
	//900 = 30 seconds, should be a good amount?
	applyFxLowGrav(blob, power * 180, Maths::Ceil(float(power) / 5.0));
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0.25, elementlist[0].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -2 + -3);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padForce(CBlob@ blob, int power, CBlob@ pad)
{
	bool blobmovingleft = pad.isFacingLeft();
	
	blob.setVelocity(Vec2f(blobmovingleft ? 5 : -5, 0) * power + blob.getVelocity());
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 30, 0.1, elementlist[3].color, true, 0, 5);
			newpart.velocity = Vec2f((float(XORRandom(1000) - 500) / 1000.0) + (pad.isFacingLeft() ? 2 : -2), (XORRandom(1000) / 1000.0) * -0.2 + -0.3) * 7;
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padIgnis(CBlob@ blob, int power, CBlob@ pad)
{
	pad.server_Hit(blob, blob.getPosition(), Vec2f_zero, power * 0.1, Hitters::fire);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0, elementlist[5].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -2 + -3);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padTerra(CBlob@ blob, int power, CBlob@ pad)
{
	applyFxDamageReduce(blob, power * 180, Maths::Ceil(float(power) / 5.0));
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0, elementlist[6].color, true, 0, 5);
			float temprot = XORRandom(1000) / 500.0 * Maths::Pi;
			newpart.velocity = Vec2f(Maths::Cos(temprot + Maths::Pi), Maths::Sin(temprot + Maths::Pi)) * 3;
			newpart.position = blob.getPosition() + Vec2f(Maths::Cos(temprot), Maths::Sin(temprot)) * 30;
			addParticleToList(newpart);
		}
	}
}

void padNatura(CBlob@ blob, int power, CBlob@ pad)//Nature gives regen? 100% not a ros ripoff
{
	applyFxRegen(blob, power * 180, Maths::Ceil(float(power) / 5.0));
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0, elementlist[2].color, true, 0, 5);
			float temprot = XORRandom(1000) / 500.0 * Maths::Pi;
			newpart.velocity = Vec2f(Maths::Cos(temprot + Maths::Pi), Maths::Sin(temprot + Maths::Pi)) * 3;
			newpart.position = blob.getPosition() + Vec2f(Maths::Cos(temprot), Maths::Sin(temprot)) * 30;
			addParticleToList(newpart);
		}
	}
}

void padEntropy(CBlob@ blob, int power, CBlob@ pad)
{
	pad.server_Hit(blob, blob.getPosition(), Vec2f_zero, power * 0.4, Hitters::spikes);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0, elementlist[8].color, true, 0, 5);
			float temprot = XORRandom(1000) / 500.0 * Maths::Pi;
			newpart.velocity = Vec2f(Maths::Cos(temprot + Maths::Pi), Maths::Sin(temprot + Maths::Pi)) * 3;
			newpart.position = blob.getPosition() + Vec2f(Maths::Cos(temprot), Maths::Sin(temprot)) * 30;
			addParticleToList(newpart);
		}
	}
}

void padOrder(CBlob@ blob, int power, CBlob@ pad)
{
	blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFxLowGrav(blob, power * 30, 100);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 100, 0, elementlist[7].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -0.3 + -2.5);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}


void padAqua(CBlob@ blob, int power, CBlob@ pad)
{
	pad.server_Hit(blob, blob.getPosition(), Vec2f_zero, 0, Hitters::water_stun_force);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0.5, elementlist[9].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -2 + -3);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padCorruption(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFxCorrupt(blob, 180 * power, power * 0.4);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0.5, elementlist[10].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -0.3 + -2.5);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padPurity(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFxPure(blob, 180 * power, power * 0.4);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0.5, elementlist[11].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -0.3 + -2.5);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padHoly(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFxHoly(blob, 180 * power, power);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0.5, elementlist[13].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -0.3 + -2.5);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

void padUnholy(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFxUnholy(blob, 180 * power, power);
	if(getNet().isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			CRenderParticleString newpart(1, false, false, 10, 0.5, elementlist[12].color, true, 0, 5);
			newpart.velocity = Vec2f(float(XORRandom(1000) - 500) / 1000.0, (XORRandom(1000) / 1000.0) * -0.3 + -2.5);
			newpart.position = pad.getPosition() + Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 32, float(XORRandom(1000) / 1000.0 - 0.5) * 4);
			addParticleToList(newpart);
		}
	}
}

//WARD FOCUS BEHAVIOR HERE




void wardBlank(float radius, int power, CBlob@ ward){}

void wardForce(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			float rot = (blobs[i].getPosition() - ward.getPosition()).Angle() * -1;
			float distance = (blobs[i].getPosition() - ward.getPosition()).Length();
			Vec2f direction(1, 0);
			direction.RotateBy(rot);
			blobs[i].setVelocity(blobs[i].getVelocity() + direction * power * (Maths::Max(radius - distance, 0.0) / 100.0));
		}
	}
}


void wardNatura(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs) && getGameTime() % (450 / power) == 0)
	{
		for (int i = 0; i < blobs.length; i++)
		{
			TreeVars@ vars;
			blobs[i].get("TreeVars", @vars);
			
			growthTick@ growthtick;
			blobs[i].get("growthtick", @growthtick);
			
			if(vars !is null)
			{
				if(!blobs[i].hasTag("naturabuff"))
				{
					vars.max_height += 0.4 * power;
					blobs[i].Tag("naturabuff");
				}
			}
			if(growthtick !is null)
			{
				growthtick(blobs[i]);
			}
		}
	}
}

void wardLife(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs) && getGameTime() % 30 == 0)
	{
		for (int i = 0; i < blobs.length; i++)
		{
			if(blobs[i].getHealth() < blobs[i].getInitialHealth())
				blobs[i].server_Heal(0.04 * power);
		}
	}
}


void wardAer(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			float rot = (ward.getPosition() - blobs[i].getPosition()).Angle() * -1;
			float distance = (blobs[i].getPosition() - ward.getPosition()).Length();
			Vec2f direction(1, 0);
			direction.RotateBy(rot);
			blobs[i].setVelocity(blobs[i].getVelocity() + direction * power * (Maths::Max(radius - distance, 0.0) / 200.0));
		}
	}
}

void wardEcto(float radius, int power, CBlob@ ward)
{
	if(getGameTime() % 3 != 0)
		return;
	CBlob@[] blobs;
	CMap@ map = getMap();
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			applyFxGhostlike(blobs[i], 2 * power, 1);
			applyFxLowGrav(blobs[i], 2 * power, 100);
		}
	}
}


void wardIgnis(float radius, int power, CBlob@ ward)
{
	CMap@ map = getMap();
	if(getGameTime() % 30 == 0)
	{
		CBlob@[] blobs;
		
		
		if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				if(blobs[i] !is ward)
					ward.server_Hit(blobs[i], blobs[i].getPosition(), Vec2f_zero, 0.02 * power, Hitters::fire);
			}
		}
		
		
	}
	Random rando(XORRandom(0x7FFFFFFF));
	float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
	float length = rando.NextFloat() * radius;
	Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();
	Tile tile = map.getTile(pos);
	if(Tile::FLAMMABLE & tile.flags > 0)
		map.server_setFireWorldspace(pos, true);
}

//Slowly regenerates stone and dirt
void wardTerra(float radius, int power, CBlob@ ward) 
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	
	CMap@ map = getMap();
	for(int i = 0; i < power / 2; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();
		Tile tile = map.getTile(pos);
		
		//DIRT
		if(tile.type <= 31 && tile.type >= 29)
		{
			if(tile.type == 29)
				map.server_SetTile(pos, 16);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//STONE
		else if(tile.type <= 104 && tile.type >= 96)
		{
			if(tile.type <= 100 && tile.type >= 96)
				map.server_SetTile(pos, 218);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//THICC STONE
		else if(tile.type <= 218 && tile.type >= 214)
		{
			if(tile.type == 214)
				map.server_SetTile(pos, 208);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
	}
}

void wardOrder(float radius, int power, CBlob@ ward)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();
		Tile tile = map.getTile(pos);
		
		//STONE
		if(tile.type <= 63 && tile.type >= 58)
		{
			if(tile.type == 58)
				map.server_SetTile(pos, 48);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//WOOD
		else if(tile.type <= 203 && tile.type >= 200)
		{
			if(tile.type == 200)
				map.server_SetTile(pos, 196);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//STONE BG
		else if(tile.type <= 79 && tile.type >= 76)
		{
			if(tile.type == 76)
				map.server_SetTile(pos, 64);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//WOOD BG
		else if(tile.type == 207)
		{
			map.server_SetTile(pos, 205);
		}
	}
}

void wardEntropy(float radius, int power, CBlob@ ward) //probobly broken code :D 
//also feel free to change idea mainly just wanted to see what it would look like
//Just fixed it up a bit, dun worri, is gud ward
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();
		Tile tile = map.getTile(pos);
		
		//STONE
		if((tile.type <= 62 && tile.type >= 58) || tile.type == 48)
		{
			if(tile.type == 48)
				map.server_SetTile(pos, 58);
			else
				map.server_SetTile(pos, tile.type + 1);
		}
		//WOOD
		else if((tile.type <= 202 && tile.type >= 200) || tile.type == 196)
		{
			if(tile.type == 196)
				map.server_SetTile(pos, 200);
			else
				map.server_SetTile(pos, tile.type + 1);
		}
		//STONE BG
		else if((tile.type <= 78 && tile.type >= 76) || tile.type == 64)
		{
			if(tile.type == 64)
				map.server_SetTile(pos, 76);
			else
				map.server_SetTile(pos, tile.type + 1);
		}
		//WOOD BG
		else if(tile.type == 205)
		{
			map.server_SetTile(pos, 207);
		}
	}
}

void wardAqua(float radius, int power, CBlob@ ward)
{
	CMap@ map = getMap();
	if(getGameTime() % 30 == 0)
	{
		CBlob@[] blobs;
		if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				if(blobs[i].getConfig() == "bomb")
				{
					if(getNet().isServer())
					{
						server_CreateBlob("mat_bombs", blobs[i].getTeamNum(), blobs[i].getPosition());
					}
					//blobs[i].setPosition(Vec2f(-9999 ,-9999));
					blobs[i].RemoveScript("Bomb.as");
					blobs[i].RemoveScript("BombPhysics.as");
					blobs[i].RemoveScript("BombTimer.as");
					
					if(getNet().isServer())
					{
						blobs[i].server_Die();
					}
				}
				else if(blobs[i].getConfig() == "bucket")
				{
					u8 filled = blobs[i].get_u8("filled");
					if (filled < 3)
					{
						blobs[i].set_u8("filled", 3);
						blobs[i].getSprite().SetAnimation("full");
					}
					
				}
				else if(blobs[i].getConfig() == "keg")
				{
					if(blobs[i].hasTag("activated"))
						blobs[i].SendCommand(blobs[i].getCommandID("deactivate"));
				}
			}
		}
	}
}

void wardCorruption(float radius, int power, CBlob@ ward) 
{
	if(getGameTime() % (150 / power) != 0)
		return;
	Random rando(XORRandom(0x7FFFFFFF));
	CMap@ map = getMap();
	
	float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
	float length = rando.NextFloat() * radius;
	Vec2f pos = (Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition()) / 8;
	corruptTile(pos, map);
}

void wardPurity(float radius, int power, CBlob@ ward) 
{
	Random rando(XORRandom(0x7FFFFFFF));
	CMap@ map = getMap();
	
	for(int i = 0; i < power / 5; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = (Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition()) / 8;
		purifyTile(pos, map);
	}
}




//BINDER BEHVAIOR BEYOND HERE


void bindBlank(CBlob@ blob, int power, CBlob@ bind){}
/*
void bindAer(CBlob@ blob, int power, CBlob@ bind)
{
	bool blobmovingleft = bind.isFacingLeft();
	
	blob.setVelocity(Vec2f(blobmovingleft ? 3 : -3, -3) * power + blob.getVelocity());
}
*/
void bindLife(CBlob@ blob, int power, CBlob@ bind)
{
	if(getGameTime() % 30 == 0)
		blob.server_SetHealth(Maths::Min(blob.getHealth() + float(power) * 0.05, blob.getInitialHealth() * 2));
}

void bindEcto(CBlob@ blob, int power, CBlob@ bind)
{
	//900 = 30 seconds, should be a good amount?
	if(getGameTime() % 30 == 0)
		applyFxLowGrav(blob, power * 10, Maths::Ceil(float(power) / 5.0));
}
/*
void bindForce(CBlob@ blob, int power, CBlob@ bind)
{
	bool blobmovingleft = bind.isFacingLeft();
	
	blob.setVelocity(Vec2f(blobmovingleft ? 5 : -5, 0) * power + blob.getVelocity());
}
*/
void bindIgnis(CBlob@ blob, int power, CBlob@ bind)
{
	if(getGameTime() % 30 == 0)
		bind.server_Hit(blob, blob.getPosition(), Vec2f_zero, power * 0.1, Hitters::fire);
}

void bindTerra(CBlob@ blob, int power, CBlob@ bind)
{
	if(getGameTime() % 30 == 0)
		applyFxDamageReduce(blob, power * 10, Maths::Ceil(float(power) / 5.0));
}
/*
void bindEntropy(CBlob@ blob, int power, CBlob@ bind)
{
	bind.server_Hit(blob, blob.getPosition(), Vec2f_zero, power * 0.4, Hitters::spikes);
}
*/
void bindOrder(CBlob@ blob, int power, CBlob@ bind)
{
	blob.setVelocity(Vec2f(0, -0.02) * power + blob.getVelocity());
	if(getGameTime() % 30 == 0)
		applyFxLowGrav(blob, power * 10, 100);
}

/*
void bindAqua(CBlob@ blob, int power, CBlob@ bind)
{
	bind.server_Hit(blob, blob.getPosition(), Vec2f_zero, 0, Hitters::water_stun_force);
}*/




//SPRAY BEHAVIOR HERE

//Spray Particle Scale
const float sprayPSC = 1.5;

void sprayBlank(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user){}

void sprayForce(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	HitInfo@[] list;
	CMap@ map = getMap();
	if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list))
	{
		for (int i = 0; i < list.length; i++)
		{
			if(list[i].blob !is null)
			{
				float rot = aimdir;
				float distance = (list[i].blob.getPosition() - user.getPosition()).Length();
				Vec2f direction(1, 0);
				direction.RotateBy(rot);
				list[i].blob.setVelocity(list[i].blob.getVelocity() + direction * power * (Maths::Max(range - distance, 0.0) / 100.0));
			}
		}
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[3].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayEcto(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{//This one is pretty lame but eh, good eneough
	HitInfo@[] list;
	CMap@ map = getMap();
	if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list))
	{
		float rot = aimdir;
		Vec2f direction(1, 0);
		direction.RotateBy(rot);
		Vec2f targpos = user.getPosition() + direction * range * 0.8;
		for (int i = 0; i < list.length; i++)
		{
			if(list[i].blob !is null)
			{
				
				Vec2f diff = targpos - list[i].blob.getPosition();
				float distance = diff.Length();
				//Vec2f diffdir(1, 0);
				//diffdir.RotateBy(diffdir.Angle());
				
				list[i].blob.setVelocity(list[i].blob.getVelocity() + (diff * power / 50.0));
			}
		}
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[0].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayAer(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[4].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 6)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
	CAttachment@ att = user.getAttachments();
	if(att !is null)
	{
		AttachmentPoint@ attp = att.getAttachmentPoint("PICKUP", true, true);
		if(attp !is null)
			@user = @attp.getBlob();
	}
	user.setVelocity(user.getVelocity() + Vec2f(1, 0).RotateBy(aimdir + 180) * power * 0.1);
}

void sprayOrder(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		Tile tile = map.getTile(pos);
		
		//STONE
		if(tile.type <= 63 && tile.type >= 58)
		{
			if(tile.type == 58)
				map.server_SetTile(pos, 48);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//WOOD
		else if(tile.type <= 203 && tile.type >= 200)
		{
			if(tile.type == 200)
				map.server_SetTile(pos, 196);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//STONE BG
		else if(tile.type <= 79 && tile.type >= 76)
		{
			if(tile.type == 76)
				map.server_SetTile(pos, 64);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//WOOD BG
		else if(tile.type == 207)
		{
			map.server_SetTile(pos, 205);
		}
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[7].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayEntropy(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		Tile tile = map.getTile(pos);
		
		//STONE
		if((tile.type <= 62 && tile.type >= 58) || tile.type == 48)
		{
			if(tile.type == 48)
				map.server_SetTile(pos, 58);
			else
				map.server_SetTile(pos, tile.type + 1);
		}
		//WOOD
		else if((tile.type <= 202 && tile.type >= 200) || tile.type == 196)
		{
			if(tile.type == 196)
				map.server_SetTile(pos, 200);
			else
				map.server_SetTile(pos, tile.type + 1);
		}
		//STONE BG
		else if((tile.type <= 78 && tile.type >= 76) || tile.type == 64)
		{
			if(tile.type == 64)
				map.server_SetTile(pos, 76);
			else
				map.server_SetTile(pos, tile.type + 1);
		}
		//WOOD BG
		else if(tile.type == 205)
		{
			map.server_SetTile(pos, 207);
		}
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[8].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayLife(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	HitInfo@[] list;
	CMap@ map = getMap();
	if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list) && getGameTime() % 10 == 0)
	{
		for (int i = 0; i < list.length; i++)
		{
			if(list[i].blob !is null)
			{
				if(list[i].blob.getHealth() < list[i].blob.getInitialHealth())
					list[i].blob.server_Heal(0.1 * power);
			}
		}
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[1].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayNatura(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	HitInfo@[] list;
	CMap@ map = getMap();
	if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list) && getGameTime() % 10 == 0)
	{
		for (int i = 0; i < list.length; i++)
		{
			if(list[i].blob !is null)
			{
				CBlob@ targblob = @list[i].blob;
				TreeVars@ vars;
				targblob.get("TreeVars", @vars);
				
				growthTick@ growthtick;
				targblob.get("growthtick", @growthtick);
				
				if(vars !is null)
				{
					if(!targblob.hasTag("naturabuff"))
					{
						vars.max_height += 0.8 * power;
						targblob.Tag("naturabuff");
					}
				}
				if(growthtick !is null)
				{
					growthtick(targblob);
				}
			}
		}
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[2].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayPurity(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	//range *= 2;
	
	CMap@ map = getMap();
	for(int i = 0; i < power * 2; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		Tile tile = map.getTile(pos);
		
		purifyTile(pos / 8, map);
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[11].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayCorruption(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	//range *= 2;
	
	CMap@ map = getMap();
	
	if(getGameTime() % 300 / power == 0)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		Tile tile = map.getTile(pos);
		
		corruptTile(pos / 8, map);
	}
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[10].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayIgnis(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	CMap@ map = getMap();
	if(getGameTime() % (100 / power) == 0)
	{
		HitInfo@[] list;
		CMap@ map = getMap();
		if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list))
		{
			for (int i = 0; i < list.length; i++)
			{
				if(list[i].blob !is null && list[i].blob !is user)
					user.server_Hit(list[i].blob, list[i].blob.getPosition(), Vec2f_zero, 0.2, Hitters::fire);
			}
		}
	}
	//Random rando(XORRandom(0x7FFFFFFF));
	Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
	Tile tile = map.getTile(pos);
	if(Tile::FLAMMABLE & tile.flags > 0)
		map.server_setFireWorldspace(pos, true);
	
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[5].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}

void sprayAqua(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	CMap@ map = getMap();
	if(true)
	{
		HitInfo@[] list;
		CMap@ map = getMap();
		if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list))
		{
			for (int i = 0; i < list.length; i++)
			{
				if(list[i].blob !is null && list[i].blob !is user && list[i].blob.exists("air_count"))
				{
					list[i].blob.set_bool("forcedrown", true);
					list[i].blob.set_u8("air_count", Maths::Max(list[i].blob.get_u8("air_count") - 2, 0));
				}
			}
		}
	}
	
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[9].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition() /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
}



void sprayTerra(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	CMap@ map = getMap();
	
	
	string currmap = map.getMapName();
	//if(!Texture::exists(currmap + "zzz"))
		//Texture::createFromFile(currmap + "zzz", currmap);
	CFileImage@ mapdata = @CFileImage(currmap);
	
	//Random rando(XORRandom(0x7FFFFFFF));
	
	if(mapdata !is null)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * ((XORRandom(800) / 1000.0) + 0.2) + user.getPosition();
		Vec2f mappos = pos / map.tilesize;
		mappos.x = int(mappos.x);
		mappos.y = int(mappos.y);
		mapdata.setPixelPosition(mappos);
		SColor tilecol = mapdata.readPixel();
		//printVec2f("Pos: ", mapdata.getPixelPosition());
		//print("Col: R:" + tilecol.getRed() + " G:" + tilecol.getGreen() + " B:" + tilecol.getBlue());
		if(tilecol == map_colors::tile_ground)
			map.server_SetTile(pos, CMap::tile_ground);
		else if(tilecol == map_colors::tile_stone && getGameTime() % (10 / power) == 0)
			map.server_SetTile(pos, CMap::tile_stone);
		else if(tilecol == map_colors::tile_thickstone && getGameTime() % (15 / power) == 0)
			map.server_SetTile(pos, CMap::tile_thickstone);
		else if(tilecol == map_colors::tile_gold && getGameTime() % (30 / power) == 0)
			map.server_SetTile(pos, CMap::tile_gold);
	}
	
	if(getNet().isClient())
	{
		for (int i = 0; i < 8; i++)
		{
			CRenderParticleArrow newpart(sprayPSC, false, false, 4, 0, elementlist[6].color, true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 2000.0 + 0.5) / 8;
			newpart.position = user.getPosition();
			addParticleToList(newpart);
		}
	}
}



