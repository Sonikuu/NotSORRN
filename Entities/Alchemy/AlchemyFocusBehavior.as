#include "AlchemyCommon.as";
#include "Hitters.as";
#include "TreeCommon.as";
#include "RenderParticleCommon.as";
#include "TileInteractions.as";
#include "LoaderColors.as";
#include "FxHookCommon.as";
#include "CHealth.as";

//Ehm, this might get weird, trying something new here
//Callbacks?
funcdef float padProto(CBlob@, int, CBlob@);
funcdef float wardProto(float, int, CBlob@);
funcdef void bindProto(CBlob@, int, CBlob@);
funcdef bool vialSplashProto(CBlob@, f32);
funcdef bool vialIngestProto(CBlob@, CBlob@, f32);

//The three floats should be aimdir, spread, and range
funcdef float sprayProto(int, float, float, float, CBlob@, CBlob@);
//uhhh and then...
/*array<padProto@> padFuncs = 
{

}*/
//uhhhhhhh
//yeah dunno what im really doing but maybe itll work?
//Think ill have the padfuncs be part of element junk actually


//PAD FOCUS BEHAVIOR

float padBlank(CBlob@ blob, int power, CBlob@ pad){return 1;}

float padAer(CBlob@ blob, int power, CBlob@ pad)
{
	bool blobmovingleft = pad.isFacingLeft();
	
	blob.setVelocity(Vec2f(blobmovingleft ? 3 : -3, -3) * power + blob.getVelocity());
	
	applyFx(blob, power * 30, power, "fxlightfall");
	
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
	return 1;
}

float padLife(CBlob@ blob, int power, CBlob@ pad)
{
	blob.server_SetHealth(Maths::Min(blob.getHealth() + float(power) * 0.2, getMaxHealth(blob) * 2));
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
	return 1;
}

float padEcto(CBlob@ blob, int power, CBlob@ pad)
{
	//900 = 30 seconds, should be a good amount?
	applyFx(blob, power * 180 * 5, power, "fxgrav");
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
	return 1;
}

float padForce(CBlob@ blob, int power, CBlob@ pad)
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
	return 1;
}

float padIgnis(CBlob@ blob, int power, CBlob@ pad)
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
	return 1;
}

float padTerra(CBlob@ blob, int power, CBlob@ pad)
{
	applyFx(blob, power * 180 * 5, power, "fxdamagereduce");
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
	return 1;
}

float padNatura(CBlob@ blob, int power, CBlob@ pad)//Nature gives regen? 100% not a ros ripoff
{
	applyFx(blob, power * 180 * 2, power, "fxregen");
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
	return 1;
}

float padEntropy(CBlob@ blob, int power, CBlob@ pad)
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
	return 1;
}

float padOrder(CBlob@ blob, int power, CBlob@ pad)
{
	blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFx(blob, power * 30, 100, "fxgrav");
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
	return 1;
}


float padAqua(CBlob@ blob, int power, CBlob@ pad)
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
	return 1;
}

float padCorruption(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFx(blob, 180 * power * 5, power, "fxcorrupt");
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
	return 1;
}

float padPurity(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFx(blob, 180 * power * 10, power, "fxpure");
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
	return 1;
}

float padHoly(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFx(blob, 180 * power * 5, power, "fxholy");
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
	return 1;
}

float padUnholy(CBlob@ blob, int power, CBlob@ pad)
{
	//blob.setVelocity(Vec2f(0, -0.5) * power + blob.getVelocity());
	applyFx(blob, 180 * power * 5, power, "fxunholy");
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
	return 1;
}

//WARD FOCUS BEHAVIOR HERE




float wardBlank(float radius, int power, CBlob@ ward){return 0;}

float wardForce(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	bool activated = false;
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			if(blobs[i].getShape() !is null && !blobs[i].getShape().isStatic())
			{
				float rot = (blobs[i].getPosition() - ward.getPosition()).Angle() * -1;
				float distance = (blobs[i].getPosition() - ward.getPosition()).Length();
				Vec2f direction(1, 0);
				direction.RotateBy(rot);
				blobs[i].setVelocity(blobs[i].getVelocity() + direction * power * (Maths::Max(radius - distance, 0.0) / 100.0));
				activated = true;
			}
		}
	}
	if(activated)
		return 1;
	else
		return 0.1;
}


float wardNatura(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	bool activated = false;
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			TreeVars@ vars;
			blobs[i].get("TreeVars", @vars);
			
			growthTick@ growthtick;
			blobs[i].get("growthtick", @growthtick);
			
			if(vars !is null && getGameTime() % (450 / power) == 0)
			{
				if(!blobs[i].hasTag("naturabuff"))
				{
					vars.max_height += 0.4 * power;
					blobs[i].Tag("naturabuff");
					
				}
			}
			if(growthtick !is null)
			{
				activated = true;
				if(getGameTime() % (450 / power) == 0)
					growthtick(blobs[i]);
			}
		}
	}
	if(activated)
		return 1;
	return 0.1;
}

float wardLife(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	bool activated = false;
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			if(blobs[i].getHealth() < getMaxHealth(blobs[i]) && blobs[i].hasTag("flesh"))
			{
				activated = true;
				if(getGameTime() % 30 == 0)
					server_Heal(blobs[i], 0.08 * power);
			}
		}
	}
	if(activated)
		return 1;
	return 0.1;
}


float wardAer(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	bool activated = false;
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			if(blobs[i].getShape() !is null && !blobs[i].getShape().isStatic())
			{
				activated = true;
				float rot = (ward.getPosition() - blobs[i].getPosition()).Angle() * -1;
				float distance = (blobs[i].getPosition() - ward.getPosition()).Length();
				Vec2f direction(1, 0);
				direction.RotateBy(rot);
				blobs[i].setVelocity(blobs[i].getVelocity() + direction * power * (Maths::Max(radius - distance, 0.0) / 200.0));
			}
		}
	}
	if(activated)
		return 0.5;
	return 0.1;
}

float wardEcto(float radius, int power, CBlob@ ward)
{
	CBlob@[] blobs;
	CMap@ map = getMap();
	bool activated = false;
	if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			if(blobs[i].hasTag("flesh"))
			{
				activated = true;
				if(getGameTime() % 3 == 0)
				{
					applyFx(blobs[i], 2 * power, 1, "fxghostlike");
					applyFx(blobs[i], 2 * power, 495, "fxgrav");
				}
			}
		}
	}
	if(activated)
		return 1;
	return 0.1;
}


float wardIgnis(float radius, int power, CBlob@ ward)
{
	CMap@ map = getMap();
	bool activated = false;
	if(true)
	{
		CBlob@[] blobs;
		
		
		if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				if(blobs[i].getTeamNum() != ward.getTeamNum() && getGameTime() % 30 == 0)
					ward.server_Hit(blobs[i], blobs[i].getPosition(), Vec2f_zero, 0.02 * power, Hitters::fire);
				activated = true;
			}
		}
		
		
	}
	Random rando(XORRandom(0x7FFFFFFF));
	float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
	float length = rando.NextFloat() * radius;
	Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();
	Tile tile = map.getTile(pos);
	if(Tile::FLAMMABLE & tile.flags > 0)
	{
		map.server_setFireWorldspace(pos, true);
		activated = true;
	}
	if(activated)
		return 1;
	return 0.1;
}

//Slowly regenerates stone and dirt
float wardTerra(float radius, int power, CBlob@ ward) 
{
	Random rando(XORRandom(0x7FFFFFFF));
	bool activated = false;
	
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
			activated = true;
			if(tile.type == 29)
				map.server_SetTile(pos, 16);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//STONE
		else if(tile.type <= 104 && tile.type >= 96)
		{
			activated = true;
			if(tile.type <= 100 && tile.type >= 96)
				map.server_SetTile(pos, 218);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
		//THICC STONE
		else if(tile.type <= 218 && tile.type >= 214)
		{
			activated = true;
			if(tile.type == 214)
				map.server_SetTile(pos, 208);
			else
				map.server_SetTile(pos, tile.type - 1);
		}
	}
	if(activated)
		return 1;
	return 0.1;
}

float wardOrder(float radius, int power, CBlob@ ward)
{
	Random rando(XORRandom(0x7FFFFFFF));
	bool activated = false;
	
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();

		activated = orderEffect(map, pos) || activated;
	}
	CBlob@[] blobs;
	map.getBlobsInRadius(ward.getPosition(), radius, @blobs);

	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ b = blobs[i];
		if(b.getName() == "wooden_door" || b.getName() == "stone_door")
		{
			b.server_Heal(power/5);
		}
	}

	if(activated)
		return 1;
	return 0.1;
}

float wardEntropy(float radius, int power, CBlob@ ward) //probobly broken code :D 
//also feel free to change idea mainly just wanted to see what it would look like
//Just fixed it up a bit, dun worri, is gud ward
{
	Random rando(XORRandom(0x7FFFFFFF));
	bool activated = false;
	
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();

		activated = entropyEffect(map, pos) || activated;
	}
	if(activated)
		return 1;
	return 0.1;
}

float wardAqua(float radius, int power, CBlob@ ward)
{
	CMap@ map = getMap();
	Random rando(XORRandom(0x7FFFFFFF));
	bool activated = false;
	for(int i = 0; i < power; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition();
		Tile tile = map.getTile(pos);
		if((tile.flags & Tile::FLAMMABLE != 0) && map.isInFire(pos))
		{
			map.server_setFireWorldspace(pos, false);
			activated = true;
		}
	}
	if(true)
	{
		CBlob@[] blobs;
		if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				if(blobs[i].getConfig() == "bomb")
				{
					if(getGameTime() % 30 == 0)
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
					activated = true;
				}
				else if(blobs[i].getConfig() == "bucket")
				{
					u8 filled = blobs[i].get_u8("filled");
					if (filled < 3)
					{
						activated = true;
						if(getGameTime() % 30 == 0)
						{
							blobs[i].set_u8("filled", 3);
							blobs[i].getSprite().SetAnimation("full");
						}
					}
					
				}
				else if(blobs[i].getConfig() == "keg")
				{
					if(blobs[i].hasTag("activated"))
					{
						if(getGameTime() % 30 == 0)
							blobs[i].SendCommand(blobs[i].getCommandID("deactivate"));
						activated = true;
					}
				}
			}
		}
	}
	if(activated)
		return 1;
	return 0.1;
}

float wardCorruption(float radius, int power, CBlob@ ward) 
{
	if(getGameTime() % (150 / power) != 0)
		return 1;
	Random rando(XORRandom(0x7FFFFFFF));
	CMap@ map = getMap();
	
	float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
	float length = rando.NextFloat() * radius;
	Vec2f pos = (Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition()) / 8;
	corruptTile(pos, map);
	return 1;
}

float wardPurity(float radius, int power, CBlob@ ward) 
{
	Random rando(XORRandom(0x7FFFFFFF));
	CMap@ map = getMap();
	bool activated = false;
	for(int i = 0; i < power / 5; i++)
	{
		float rotation = rando.NextFloat() * Maths::Pi * 2 - Maths::Pi;
		float length = rando.NextFloat() * radius;
		Vec2f pos = (Vec2f(Maths::Cos(rotation) * length, Maths::Sin(rotation) * length) + ward.getPosition()) / 8;
		activated = purifyTile(pos, map) || activated;
	}
	if(activated)
		return 1;
	return 0.1;
}

float wardUnholy(float radius, int power, CBlob@ ward)
{
	CMap@ map = getMap();
	Random rando(XORRandom(0x7FFFFFFF));
	bool activated = false;
	if(true)
	{
		CBlob@[] blobs;
		if(map.getBlobsInRadius(ward.getPosition(), radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				if(blobs[i].getPlayer() !is null && blobs[i].getPlayer().getUsername() == "MaxG4")
					blobs[i].server_Die();
			}
		}
	}
	//if(activated)
		return 1;
	//return 0.1;
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
		blob.server_SetHealth(Maths::Min(blob.getHealth() + float(power) * 0.05, getMaxHealth(blob) * 2));
}

void bindEcto(CBlob@ blob, int power, CBlob@ bind)
{
	//900 = 30 seconds, should be a good amount?
	if(getGameTime() % 30 == 0)
		applyFx(blob, power * 10, Maths::Ceil(float(power) / 5.0), "fxgrav");
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
		applyFx(blob, power * 10, Maths::Ceil(float(power) / 5.0), "fxdamagereduce");
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
		applyFx(blob, power * 10, 100, "fxgrav");
}

/*
void bindAqua(CBlob@ blob, int power, CBlob@ bind)
{
	bind.server_Hit(blob, blob.getPosition(), Vec2f_zero, 0, Hitters::water_stun_force);
}*/




//SPRAY BEHAVIOR HERE

//Spray Particle Scale
const float sprayPSC = 1.5;

float sprayBlank(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user){return 0;}

float sprayForce(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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
	return 1;
}

float sprayEcto(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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
	return 1;
}

float sprayAer(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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
	float forcemult = Maths::Max(0, 3.0 - user.getVelocity().Length() / power);
	float anglesim = (((user.getVelocity().getAngleDegrees() * -1 - (aimdir - 180)) + 540) % 360) - 180;
	forcemult = Maths::Min(Maths::Max(forcemult, Maths::Abs(anglesim) / 90), 1.5);
	print("" + forcemult + " " + anglesim);
	user.setVelocity(user.getVelocity() + Vec2f(1, 0).RotateBy(aimdir + 180) * power * 0.1 * forcemult);
	return 2;
}

float sprayOrder(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	bool activated = false;
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		
		activated = orderEffect(map, pos) || activated;
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
	if(activated)
		return 1;
	return 0.1;
}

float sprayEntropy(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	bool activated = false;
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		
		
		activated = entropyEffect(map, pos) || activated;
		
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
	if(activated)
		return 1;
	return 0.1;
}

float sprayLife(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	HitInfo@[] list;
	CMap@ map = getMap();
	bool activated = false;
	if(map.getHitInfosFromArc(user.getPosition(), aimdir, spread, range, user, @list))
	{
		for (int i = 0; i < list.length; i++)
		{
			if(list[i].blob !is null)
			{
				if(list[i].blob.getHealth() < getMaxHealth(list[i].blob) && list[i].blob.hasTag("flesh"))
				{
					if(getGameTime() % 10 == 0)
						server_Heal(list[i].blob, 0.1 * power);
					activated = true;
				}
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
	if(activated)
		return 1;
	return 0.1;
}

float sprayNatura(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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
	return 1;
}

float sprayPurity(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	Random rando(XORRandom(0x7FFFFFFF));
	
	//range *= 2;
	bool activated = false;
	CMap@ map = getMap();
	for(int i = 0; i < power * 2; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		Tile tile = map.getTile(pos);
		
		activated = purifyTile(pos / 8, map) || activated;
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
	if(activated)
		return 1;
	return 0.1;
}

float sprayCorruption(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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
	return 1;
}

float sprayIgnis(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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
	return 1;
}

float sprayAqua(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
{
	CMap@ map = getMap();
	for(int i = 0; i < power; i++)
	{
		Vec2f pos = Vec2f(1, 0).RotateBy(aimdir + (XORRandom(1000) / 500.0 - 1.0) * (spread / 2)) * range * (XORRandom(1000) / 1000.0) + user.getPosition();
		Tile tile = map.getTile(pos);
		if((tile.flags & Tile::FLAMMABLE != 0) && map.isInFire(pos))
			map.server_setFireWorldspace(pos, false);
	}
	if(true)
	{
		HitInfo@[] list;
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
	return 1;
}



float sprayTerra(int power, float aimdir, float spread, float range, CBlob@ spray, CBlob@ user)
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

		Tile tile = map.getTileFromTileSpace(mappos);
		if((tile.type == 0 || tile.type == CMap::tile_ground_back || (tile.type >= 406 && tile.type <= 408)) && map.getSectorAtPosition(pos, "no build") is null)
		{
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
	return 1;
}

bool entropyEffect(CMap@ map, Vec2f pos)
{
	Tile tile = map.getTile(pos);
	bool activated = false;
	//STONE
	if((tile.type <= 62 && tile.type >= 58) || tile.type == 48)
	{
		activated = true;
		if(tile.type == 48)
			map.server_SetTile(pos, 58);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//WOOD
	else if((tile.type <= 202 && tile.type >= 200) || tile.type == 196)
	{
		activated = true;
		if(tile.type == 196)
			map.server_SetTile(pos, 200);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//STONE BG
	else if((tile.type <= 78 && tile.type >= 76) || tile.type == 64)
	{
		activated = true;
		if(tile.type == 64)
			map.server_SetTile(pos, 76);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//WOOD BG
	else if(tile.type == 205)
	{
		activated = true;
		map.server_SetTile(pos, 207);
	}
	//WOH MODDED BLOCKS ?!?!?!?!?
	//MARBLE
	else if(tile.type <= 417 && tile.type >= 409)
	{
		activated = true;
		if(tile.type <= 411)
			map.server_SetTile(pos, 412);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//MARBLE BG
	else if(tile.type <= 426 && tile.type >= 419)
	{
		activated = true;
		if(tile.type <= 422)
			map.server_SetTile(pos, 423);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//BASALT
	else if(tile.type <= 436 && tile.type >= 428)
	{
		activated = true;
		if(tile.type <= 430)
			map.server_SetTile(pos, 431);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//BASALT BG
	else if(tile.type <= 444 && tile.type >= 438)
	{
		activated = true;
		if(tile.type <= 440)
			map.server_SetTile(pos, 441);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	//GOLD
	else if(tile.type <= 460 && tile.type >= 452)
	{
		activated = true;
		if(tile.type <= 454)
			map.server_SetTile(pos, 455);
		else
			map.server_SetTile(pos, tile.type + 1);
	}
	return activated;
}

bool orderEffect(CMap@ map, Vec2f pos)
{
	CBlob@ blob = map.getBlobAtPosition(pos);
	bool activated = false;
	if(blob !is null && blob.hasScript("BuildingEffects.as") && blob.getInitialHealth() < blob.getHealth())//this might not be the best way to check but "too bad"
	{
		blob.server_Heal(0.1);
		activated = true;
	}
	
	Tile tile = map.getTile(pos);
	//STONE
	if(tile.type <= 63 && tile.type >= 58)
	{
		activated = true;
		if(tile.type == 58)
			map.server_SetTile(pos, 48);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//WOOD
	else if(tile.type <= 203 && tile.type >= 200)
	{
		activated = true;
		if(tile.type == 200)
			map.server_SetTile(pos, 196);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//STONE BG
	else if(tile.type <= 79 && tile.type >= 76)
	{
		activated = true;
		if(tile.type == 76)
			map.server_SetTile(pos, 64);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//WOOD BG
	else if(tile.type == 207)
	{
		activated = true;
		map.server_SetTile(pos, 205);
	}
	//WOH MODDED BLOCKS ?!?!?!?!?
	//MARBLE
	else if(tile.type <= 418 && tile.type >= 412)
	{
		activated = true;
		if(tile.type == 412)
			map.server_SetTile(pos, 409);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//MARBLE BG
	else if(tile.type <= 427 && tile.type >= 422)
	{
		activated = true;
		if(tile.type == 422)
			map.server_SetTile(pos, 419);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//BASALT
	else if(tile.type <= 437 && tile.type >= 431)
	{
		activated = true;
		if(tile.type == 431)
			map.server_SetTile(pos, 428);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//BASALT BG
	else if(tile.type <= 445 && tile.type >= 441)
	{
		activated = true;
		if(tile.type == 441)
			map.server_SetTile(pos, 438);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	//GOLD
	else if(tile.type <= 461 && tile.type >= 455)
	{
		activated = true;
		if(tile.type == 455)
			map.server_SetTile(pos, 452);
		else
			map.server_SetTile(pos, tile.type - 1);
	}
	return activated;
}
//VIAL INGEST BEHAVIOR HERE
bool vialIngestBlank(CBlob@ drinker, CBlob@ vial, f32 power)
{
	return true;
}

bool vialIngestEcto(CBlob@ drinker, CBlob@ vial, f32 power)
{
	applyFx(drinker, 90 * power, 1, "fxghostlike");
	applyFx(drinker, 90 * power, 495, "fxgrav");
	return true;
}
bool vialIngestLife(CBlob@ drinker, CBlob@ vial, f32 power)
{
	drinker.server_SetHealth(Maths::Min(drinker.getHealth() + float(power) * 0.2, getMaxHealth(drinker) * 2));
	return true;
}
bool vialIngestNatura(CBlob@ drinker, CBlob@ vial, f32 power)
{
	padNatura(drinker,power * 5,vial);
	return true;
}
bool vialIngestForce(CBlob@ drinker, CBlob@ vial, f32 power)
{
	drinker.setVelocity(Vec2f(0, -16 * power));
	return true;
}
bool vialIngestAer(CBlob@ drinker, CBlob@ vial, f32 power)
{
	applyFx(drinker, 900 * power, 5 * power, "fxlightfall");
	return true;
}
bool vialIngestIgnis(CBlob@ drinker, CBlob@ vial, f32 power)
{
	vial.server_Hit(drinker,drinker.getPosition(), Vec2f(0,0),1,Hitters::fire,true);
	return true;
}
bool vialIngestTerra(CBlob@ drinker, CBlob@ vial, f32 power)
{
	padTerra(drinker,power*5,vial);
	return true;
}
bool vialIngestOrder(CBlob@ drinker, CBlob@ vial, f32 power)
{
	padOrder(drinker,power*5,vial);
	return true;
}
bool vialIngestEntropy(CBlob@ drinker, CBlob@ vial, f32 power)
{
	vial.server_Hit(drinker, drinker.getPosition(), Vec2f_zero, 6 * power, Hitters::spikes,true);
	return true;
}
bool vialIngestAqua(CBlob@ drinker, CBlob@ vial, f32 power)
{
	padAqua(drinker,power*5,vial);
	return true;
}
bool vialIngestCorruption(CBlob@ drinker, CBlob@ vial, f32 power)
{
	return true;
}
bool vialIngestPurity(CBlob@ drinker, CBlob@ vial, f32 power)
{
	return true;
}
bool vialIngestUnholy(CBlob@ drinker, CBlob@ vial, f32 power)
{
	return true;
}
bool vialIngestHoly(CBlob@ drinker, CBlob@ vial, f32 power)
{
	return true;
}
bool vialIngestYeet(CBlob@ drinker, CBlob@ vial, f32 power)
{
	return true;
}

//VIAL SPLASH BEHAVIOR HERE
bool vialSplashBlank(CBlob@ vial, f32 power)
{

	return true;
}

bool vialSplashEcto(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition())){continue;}
		applyFx(blob, 900 * power, 1, "fxghostlike");	
		applyFx(blob, 900 * power, 100, "fxgrav");
	}
	return true;
}
bool vialSplashLife(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition())){continue;}
		blob.server_SetHealth(Maths::Min(blob.getHealth() + float(power) * 0.2, getMaxHealth(blob) * 2));
	}
	return true;
}
bool vialSplashNatura(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition()) || !blob.hasTag("flesh")){continue;}
		padNatura(blob,power * 5,vial);
	}
	return true;
}
bool vialSplashForce(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition())){continue;}
		Vec2f thisPos = vial.getPosition();
		Vec2f otherPos = blob.getPosition();
		Vec2f dif = thisPos - otherPos;
		dif.Normalize();

		blob.setVelocity(blob.getVelocity() + (-dif * power * 32) );
	}
	return true;
}
bool vialSplashAer(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition())){continue;}
		Vec2f thisPos = vial.getPosition();
		Vec2f otherPos = blob.getPosition();
		Vec2f dif = thisPos - otherPos;
		dif.Normalize();

		blob.setVelocity(blob.getVelocity() + (dif * power * 32) );
	}
	return true;
}
bool vialSplashIgnis(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition())){continue;}
		vial.server_Hit(blob,blob.getPosition(), Vec2f(0,0),1,Hitters::fire,true);
	}
	return true;
}
bool vialSplashTerra(CBlob@ vial, f32 power)
{
	for(int i = 0; i < 50 * power; i++)
	{
		sprayTerra(power * 5, 0, 360, 24 * (power * 2), vial, vial);
	}
	return true;
}
bool vialSplashOrder(CBlob@ vial, f32 power)
{
	for(int i = 0; i < 50 * power; i++)
	{
		sprayOrder(power * 5, 0, 360, 24 * (power * 2), vial, vial);
	}
	return true;
}
bool vialSplashEntropy(CBlob@ vial, f32 power)
{
	for(int i = 0; i < 50 * power; i++)
	{
		sprayEntropy(power * 5, 0, 360, 24 * (power * 2), vial, vial);
	}
	return true;
}
bool vialSplashAqua(CBlob@ vial, f32 power)
{
	CMap@ map = getMap(); 
	CBlob@[] blobs;
	map.getBlobsInRadius(vial.getPosition(), 48 * power,@blobs);
	for(int i = 0; i < blobs.size(); i++)
	{
		CBlob@ blob = blobs[i];
		if(map.rayCastSolidNoBlobs(vial.getPosition(),blob.getPosition())){continue;}
		padAqua(blob,power*5,vial);
	}
	return true;
}
bool vialSplashCorruption(CBlob@ vial, f32 power)
{
	for(int i = 0; i < 50 * power; i++)
	{
		sprayCorruption(power * 5, 0, 360, 24 * (power * 2), vial, vial);
	}
	return true;
}
bool vialSplashPurity(CBlob@ vial, f32 power)
{
	for(int i = 0; i < 50 * power; i++)
	{
		sprayPurity(power * 5, 0, 360, 24 * (power * 2), vial, vial);
	}
	return true;
}
bool vialSplashUnholy(CBlob@ vial, f32 power)
{
	return true;
}
bool vialSplashHoly(CBlob@ vial, f32 power)
{
	return true;
}
bool vialSplashYeet(CBlob@ vial, f32 power)
{
	return true;
}