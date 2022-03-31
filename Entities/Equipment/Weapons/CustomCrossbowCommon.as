#include "EquipmentCore.as";
#include "EquipmentGunCommon.as";
#include "RenderParticleCommon.as";

//This is crossbow now
//Parts:
//Core: Mainly determines weight, accuracy, and recoil
//Bars/Limbs: Bolt speed, damage modifier (Maybe), small weight mod, reload speed
//String: reloadspeed modifier, special effects
//Barrel(Guess its called that for crossbows too lol): Bolt type, accuracy mod
class CCrossBowPart
{
	//How to determine if stat is additive or mult?
	//Maybe just have one bool for all stats?
	float damage;
	float firerate;
	float projspeed;
	float spread;
	float shotcount;
	float movespeed;
	float recoil;
	float maxammo;
	float reloadspeed;
	float tiledamagechance;
	float homingrange;
	bool multi;
	bool semi;
	Vec2f barrelpoint;
	Vec2f stockpoint;
	Vec2f limbpoint;
	Vec2f stringpoint;
	Vec2f ammoguisize;			   
	int hittype;
	int guntype;
	int blobpiercing;
	string name;
	string ammotype;
	string ammoguifile;				
	SColor tracercolor;
	gunHitBlob@ blobfx;
	gunHitTile@ tilefx;
	CCrossBowPart(bool multi, float damage, float firerate, float shotcount, float spread, float projspeed, float movespeed, float recoil, float maxammo, float reloadspeed, string name)
	{
		this.damage = damage;
		this.firerate = firerate;
		this.shotcount = shotcount;
		this.spread = spread;
		this.projspeed = projspeed;
		this.multi = multi;
		this.movespeed = movespeed;
		this.recoil = recoil;
		this.name = name;
		this.maxammo = maxammo;
		this.reloadspeed = reloadspeed;
		
		barrelpoint = Vec2f_zero;
		stockpoint = Vec2f_zero;
		limbpoint = Vec2f_zero;
		stringpoint = Vec2f_zero;
		ammoguisize = Vec2f(5, 8);					
		
		hittype = CHitters::bullet;
		guntype = 0;
		tiledamagechance = 1;
		/*if(multi)
		{
			homingrange = 1;
			blobpiercing = 1;
		}
		else*/
		{
			homingrange = 0;
			blobpiercing = 0;
		}
		
		tracercolor = SColor(255, 255, 255, 0);
		
		ammotype = "mat_bolts";
		ammoguifile = "AmmoGUIPistol.png";							
		
		semi = false;
		
		@blobfx = null;
		@tilefx = null;
	}
	CCrossBowPart setBarrel(Vec2f point)
	{
		this.barrelpoint = point;
		return this;
	}
	CCrossBowPart setStock(Vec2f point)
	{
		this.stockpoint = point;
		return this;
	}
	CCrossBowPart setLimbs(Vec2f point)
	{
		this.limbpoint = point;
		return this;
	}
	CCrossBowPart setString(Vec2f point)
	{
		this.stringpoint = point;
		return this;
	}
	CCrossBowPart setSemi(bool semi)
	{
		this.semi = semi;
		return this;
	}
	CCrossBowPart setHittype(int hittype)
	{
		this.hittype = hittype;
		return this;
	}
	CCrossBowPart setGuntype(int guntype)
	{
		this.guntype = guntype;
		return this;
	}
	CCrossBowPart setTileDamageChance(float tiledamagechance)
	{
		this.tiledamagechance = tiledamagechance;
		return this;
	}
	CCrossBowPart setTracerColor(SColor tracercolor)
	{
		this.tracercolor = tracercolor;
		return this;
	}
	CCrossBowPart setAmmotype(string ammotype)
	{
		this.ammotype = ammotype;
		return this;
	}
	CCrossBowPart setHomingrange(float homingrange)
	{
		this.homingrange = homingrange;
		return this;
	}
	CCrossBowPart setBlobPiercing(int blobpiercing)
	{
		this.blobpiercing = blobpiercing;
		return this;
	}
	CCrossBowPart setBlobFx(gunHitBlob@ blobfx)
	{
		@this.blobfx = @blobfx;
		return this;
	}
	CCrossBowPart setTileFx(gunHitTile@ tilefx)
	{
		@this.tilefx = @tilefx;
		return this;
	}
	CCrossBowPart setAmmoGUI(string ammoguifile, Vec2f ammoguisize)
	{
		this.ammoguifile = ammoguifile;
		this.ammoguisize = ammoguisize;
		return this;
	}
}

class CCrossbowRequirements
{
	array<string> materials;
	array<int> amt;
	bool hidden;
	CCrossbowRequirements()
	{
		hidden = false;
	}

	CCrossbowRequirements addRequirement(string material, int amount)
	{
		materials.push_back(material);
		amt.push_back(amount);
		return this;
	}
	CCrossbowRequirements setHidden(bool hidden)
	{
		this.hidden = hidden;
		return this;
	}
}

array<array<CCrossBowPart>> cbowparts = {
//CORES
{
	//DAMAGE, FIRERATE, BULLET COUNT, SPREAD, PROJSPEED, MOVE SPEED, RECOIL, MAXAMMO, RELOAD SPEED
	CCrossBowPart(false, 1, 6, 1, 2, 20, 1, 3, 1, 30, "Standard Crossbow").setBarrel(Vec2f(0, 0)),//STANDARD
	CCrossBowPart(false, 1, 4, 1, 3, 15, 1.2, 6, 1, 30, "Light Crossbow").setBarrel(Vec2f(0, 0))//LIGHT
},
//BARRELS
{
	CCrossBowPart(true, 1, 1, 1, 		1, 1, 0.9, 		1, 1, 1, "Standard-Barrel").setLimbs(Vec2f(6, 0)),//STANDARD
	CCrossBowPart(true, 1.25, 1, 1, 	1.25, 1.5, 0.9, 1.2, 1, 1.1, "Accelerated-Barrel").setLimbs(Vec2f(6, 0))//ACCEL
},
//LIMBS
{
	CCrossBowPart(true, 1, 1, 1, 1, 1, 1.1, 1, 1, 1, "Wooden Limbs").setString(Vec2f(-4, 0))//WOOD
},
//STRING
//Uh oh im gonna have to add string materials now
{
	CCrossBowPart(true, 1, 1, 1, 1.25, 1, 1, 1.25, 1, 0.8, "Normal String"),//NORMAL
	CCrossBowPart(true, 1, 1, 1, 1.5, 1.25, 0.9, 1.75, 1, 1.2, "Golden Thread")
}/*, Removed for now, might readd last part later
//MAG
{
	CCrossBowPart(true, 1, 1, 1, 1, 1, 1, 0.8, 		1, 1, "Basic"),//LOWCAL?
	CCrossBowPart(true, 1, 1, 1, 1, 1, 0.8, 1, 		1.5, 1, "High Capacity"),//HIGHCAL?
	CCrossBowPart(true, 1, 1, 1, 1, 1, 1, 1, 		1, 1, "Holy").setHittype(CHitters::pure).setTracerColor(SColor(255, 255, 255, 200)).setAmmotype("holyammopack"),//HOLY
	CCrossBowPart(true, 1, 1, 1, 1, 1, 0.7, 1, 		2.5, 2, "Drum Fed"),//DRUM
	CCrossBowPart(true, 0.1, 2, 1, 0.7, 1, 1.2, 0.7, 1, 1, "YEETing").setHittype(CHitters::yeet).setTracerColor(SColor(255, 255, 150, 150)).setAmmotype("yeetammopack").setBlobFx(@yeetBlobHit),//YEET
	CCrossBowPart(true, 1, 1, 1, 1, 1, 1, 1, 		1, 1, "Piercing").setBlobPiercing(2).setTracerColor(SColor(255, 0, 200, 200)).setTileDamageChance(2).setAmmotype("piercingammopack"),//PIERCING
	CCrossBowPart(true, 0.5, 1, 1, 1, 1, 1, 1, 		1, 1, "Explosive").setTracerColor(SColor(255, 255, 200, 100)).setAmmotype("explosiveammopack").setBlobFx(@explosiveBlobHit).setTileFx(@explosiveTileHit)//EXPLOSIVE
}*/
};

array<array<CCrossbowRequirements>> cbowreqs = {

	{
		CCrossbowRequirements().addRequirement("mat_wood", 100).addRequirement("mat_component", 4),//STANDARD
		CCrossbowRequirements().addRequirement("mat_wood", 50).addRequirement("mat_component", 2)//LIGHT
	},
	{
		CCrossbowRequirements().addRequirement("mat_component", 2),//STANDARD
		CCrossbowRequirements().addRequirement("mat_metal", 1).addRequirement("mat_accelplate", 2).setHidden(true)//ACCEL
	},
	{
		CCrossbowRequirements().addRequirement("mat_wood", 50)//WOOD
	},
	{
		CCrossbowRequirements().addRequirement("mat_wood", 50),//STANDARD, change to string mat later
		CCrossbowRequirements().addRequirement("mat_gold", 25)//GOLDEN, maybe add loom and stuff to make string materials, maybe even clothes and similar eventually
	}/*,
	
	{
		CCrossbowRequirements().addRequirement("mat_metal", 2),//LOWCAP
		CCrossbowRequirements().addRequirement("mat_metal", 4),//HIGHCAP
		CCrossbowRequirements().addRequirement("mat_metal", 2).addRequirement("holyammopack", 1).setHidden(true),//HOLY
		CCrossbowRequirements().addRequirement("mat_metal", 8),//DRUM
		CCrossbowRequirements().addRequirement("mat_metal", 2).addRequirement("yeetammopack", 1).setHidden(true),//YEET
		CCrossbowRequirements().addRequirement("mat_metal", 2).addRequirement("mat_glass", 100).setHidden(true),//PIERCING
		CCrossbowRequirements().addRequirement("mat_metal", 2).addRequirement("unstablecore", 2).setHidden(true)//EXPLOSIVE
	}*/
};

void buildGun(CBlob@ this)
{
	u8 coreindex = this.get_u8("coreindex");
	u8 barrelindex = this.get_u8("barrelindex");
	u8 stockindex = this.get_u8("stockindex");
	u8 gripindex = this.get_u8("gripindex");
	u8 magindex = this.get_u8("magindex");
	
	//FIRST INDEX IS TYPE, SECOND IS PART
	if(coreindex >= cbowparts[0].length || barrelindex >= cbowparts[1].length || stockindex >= cbowparts[2].length || gripindex >= cbowparts[3].length)
	{
		this.server_Die();
		print("INVALID CUSTOM GUN PARTS");
		return;
	}
	CCrossBowPart@ corepart = @(cbowparts[0][coreindex]);
	CCrossBowPart@ barrelpart = @(cbowparts[1][barrelindex]);
	CCrossBowPart@ limbpart = @(cbowparts[2][stockindex]);
	CCrossBowPart@ stringpart = @(cbowparts[3][gripindex]);
	CCrossBowPart@ magpart = null;
	
	CGunEquipment@ gun = calculateGunStats(corepart, barrelpart, limbpart, stringpart, magpart);
	if(coreindex != 1)
		gun.twohand = true;
	
	setEquipment(this, @gun);

	this.setInventoryName(getGunTitle(corepart, barrelpart, limbpart, stringpart, magpart) + "\n" + getGunDescription(corepart, gun));

	//part.spriteoffset = Vec2f(0, 1.25);
	//part.tracercolor = SColor(255, 150, 255, 255);
	//part.tiledamagechance = 0.5;
	
	//SPRITE BUILDING
	if(isClient())
	{
		CSprite@ sprite = this.getSprite();
		string texname = "customcbow" + coreindex + "" + barrelindex + "" + stockindex + "" + gripindex + "" + magindex;
		//print(texname);
		Vec2f spritesize(32, 16);
		if(Texture::exists(texname))
		{
			sprite.SetTexture(texname, 32, 16);
			sprite.SetFrame(0);
		}
		else
		{
			
			if(!Texture::exists("CustomCrossbowBase"))
			{
				if(!Texture::createFromFile("CustomCrossbowBase", "CustomCrossbow.png"))
					print("oh this is a problem");
			}
			ImageData@ baseimage = Texture::data("CustomCrossbowBase");
			//if(!Texture::createBySize(texname, 32, 16))
				//print("ohno");
			ImageData@ newimage = @ImageData(32, 16);
			
			Vec2f barrelpos = corepart.barrelpoint;
			//Vec2f stockpos = corepart.stockpoint;
			Vec2f limbpos = barrelpos + barrelpart.limbpoint;
			Vec2f stringpos = limbpos + limbpart.stringpoint;
			
			for(int x = 0; x < 32; x++)
			{
				for(int y = 0; y < 16; y++)
				{
					newimage.put(x, y, SColor(0, 0, 0, 0));
				}
			}
			
			
			Vec2f startpos = Vec2f(0, 16 * coreindex);
			mergeOnto(newimage, baseimage, Vec2f_zero, startpos, startpos + spritesize);
			startpos = Vec2f(32, 16 * barrelindex);
			mergeOnto(newimage, baseimage, barrelpos, startpos, startpos + spritesize);
			startpos = Vec2f(64, 16 * stockindex);
			mergeOnto(newimage, baseimage, limbpos, startpos, startpos + spritesize);
			startpos = Vec2f(96, 16 * gripindex);
			mergeOnto(newimage, baseimage, stringpos, startpos, startpos + spritesize);
			//startpos = Vec2f(128, 16 * magindex);
			//mergeOnto(newimage, baseimage, magpos, startpos, startpos + spritesize);
			
			//sprite.ReloadSprite(texname);
			Texture::createFromData(texname, newimage);
			sprite.SetTexture(texname, 32, 16);
			sprite.SetFrame(0);
			//FML everytime i use imagedata i want to die
			//ill get used to it eventually
		}
	}
}

string getGunTitle(CCrossBowPart@ corepart, CCrossBowPart@ barrelpart, CCrossBowPart@ limbpart, CCrossBowPart@ stringpart, CCrossBowPart@ magpart)
{
	return (barrelpart.name + " " + corepart.name + " with " + limbpart.name + " and " + stringpart.name);
}

string getGunDescription(CCrossBowPart@ corepart, CGunEquipment@ gun)
{
	return getSymbol(gun.damage, corepart.damage) + "Damage: " + gun.damage +
	"\n" + getSymbol(corepart.firerate, gun.firerate) + "Firerate: " + (30.0 / gun.firerate) +
	"\n" + getSymbol(gun.shotcount, corepart.shotcount) + "Bullet Count: " + gun.shotcount +
	"\n" + getSymbol(corepart.spread, gun.spread) + "Spread: " + gun.spread +
	"\n" + getSymbol(gun.projspeed, corepart.projspeed) + "Shot Speed: " + gun.projspeed +
	"\n" + getSymbol(gun.movespeed, corepart.movespeed) + "Movement Penalty: " + (100.0 - gun.movespeed * 100.0) + "%" +
	"\n" + getSymbol(corepart.recoil, gun.recoil) + "Recoil: " + gun.recoil +
	//"\n" + getSymbol(gun.maxammo, corepart.maxammo) + "Max Ammo: " + gun.maxammo +
	"\n" + getSymbol(corepart.reloadspeed, gun.reloadtime) + "Reload Time: " + (gun.reloadtime / 30.0) +
	"\nUses: " + gun.ammotype;
}

CGunEquipment@ calculateGunStats(CCrossBowPart@ corepart, CCrossBowPart@ barrelpart, CCrossBowPart@ limbpart, CCrossBowPart@ stringpart, CCrossBowPart@ magpart)
{
	//STAT BUILDING
	float damage = 0;
	float firerate = 0;
	float shotcount = 0;
	float spread = 0;
	float projspeed = 0;
	float movespeed = 0;
	float recoil = 0;
	float maxammo = 0;
	float reloadspeed = 0;
	int blobpiercing = 0;
	float homingrange = 0;
	float tiledamagechance = 0;
	array<gunHitBlob@> blobfx;
	array<gunHitTile@> tilefx;
	
	array<CCrossBowPart@> parts = {@corepart, @barrelpart, @limbpart, @stringpart/*, @magpart*/};
	for(int i = 0; i < parts.size(); i++)
	{
		if(parts[i].blobfx !is null)
			blobfx.push_back(@parts[i].blobfx);
		if(parts[i].tilefx !is null)
			tilefx.push_back(@parts[i].tilefx);
		if(parts[i].multi)
		{
			damage *= parts[i].damage;
			firerate *= parts[i].firerate;
			shotcount *= parts[i].shotcount;
			spread *= parts[i].spread;
			projspeed *= parts[i].projspeed;
			movespeed *= parts[i].movespeed;
			recoil *= parts[i].recoil;
			maxammo *= parts[i].maxammo;
			reloadspeed *= parts[i].reloadspeed;
			tiledamagechance *= parts[i].tiledamagechance;
			//Forced to be additive
			blobpiercing += parts[i].blobpiercing;
			homingrange += parts[i].homingrange;
		}
		else
		{
			damage += parts[i].damage;
			firerate += parts[i].firerate;
			shotcount += parts[i].shotcount;
			spread += parts[i].spread;
			projspeed += parts[i].projspeed;
			movespeed += parts[i].movespeed;
			recoil += parts[i].recoil;
			maxammo += parts[i].maxammo;
			reloadspeed += parts[i].reloadspeed;
			blobpiercing += parts[i].blobpiercing;
			homingrange += parts[i].homingrange;
			tiledamagechance += parts[i].tiledamagechance;
		}
	}
	
	CGunEquipment@ gun;
	if(corepart.guntype == 0)
	{
		@gun = @CGunEquipment(damage, firerate, shotcount, spread);
	}
	else if(corepart.guntype == 1)
	{
		CChargeGunEquipment tempgun(damage, 10, shotcount, spread, firerate / 3, firerate);
		tempgun.basetracerwidth *= Maths::Max(damage / corepart.damage, 0.5);
		@gun = cast<CGunEquipment>(@tempgun);
	}
	else if(corepart.guntype == 2)
	{
		CSpoolGunEquipment tempgun(damage, firerate, shotcount, spread, firerate * 0.8, firerate * firerate * 0.005);
		@gun = cast<CGunEquipment>(@tempgun);
	}
	
	gun.recoil = recoil;
	gun.movespeed = Maths::Max(Maths::Min(movespeed, 1), 0);
	gun.projspeed = projspeed;
	gun.semi = true;
	gun.reloadtime = reloadspeed;
	gun.maxammo = maxammo;
	gun.range = 1000;
	//gun.hittype = magpart.hittype;
	gun.ammotype = "mat_bolts";
	gun.projectile = true;
	gun.projname = "crossbolt";
	gun.tiledamagechance = tiledamagechance * Maths::Max(damage / corepart.damage, 0.5);
	//gun.tracercolor = magpart.tracercolor;
	gun.texture = true;
	gun.tracerwidth *= Maths::Max(damage / corepart.damage, 0.5);
	gun.homingrange = homingrange;
	gun.blobpiercing = blobpiercing;
	@gun.blobfx = @blobfx;
	@gun.tilefx = @tilefx;
	gun.ammoguifile = corepart.ammoguifile;
	gun.ammoguisize = corepart.ammoguisize;	

	return @gun;
}

string getSymbol(float val, float baseval)
{
	if(val > baseval / 0.4)
		return "+++";
	else if(val > baseval / 0.7)
		return " ++";
	else if(val > baseval)
		return "  +";
	else if(val == baseval)
		return "  =";
	else if(val < baseval * 0.4)
		return "---";
	else if(val < baseval * 0.7)
		return " --";
	else if(val < baseval)
		return "  -";
	return "   ";
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


//FUNCS FOR HANDLES
//funcdef float gunHitBlob(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, CGunEquipment@ gun, float damage);
//funcdef float gunHitTile(CBlob@ user, Vec2f pos, float angle, CGunEquipment@ gun, float damage);

//----------------------------------EXPLOSIVE--------------------------------																			 
float explosiveBlobHit(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, CGunEquipment@ gun, float damage)
{
	//radius 48, damage 3, sound Bomb.ogg, map radius 24, map ratio 0.4
	Explode(user, pos, 48 * (damage * damage + 0.5), damage, "Bomb.ogg", 24 * (damage * damage + 0.5),  (damage) * 0.5, true, gun.hittype, true, true);
	return damage;
}

float explosiveTileHit(CBlob@ user, Vec2f pos, float angle, CGunEquipment@ gun, float damage)
{
	float rotation = (angle / 180.0) * Maths::Pi;
	pos -= Vec2f(Maths::Cos(rotation), Maths::Sin(rotation)) * 8;
	Explode(user, pos, 48 * (damage * damage + 0.5), damage, "Bomb.ogg", 24 * (damage * damage + 0.5),  (damage) * 0.5, true, gun.hittype, true, true);
	return damage;
}

//------------------PRETTY--------------------------													
float prettyBlobHit(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, CGunEquipment@ gun, float damage)
{
	if(getNet().isClient())
	{
		for (int i = 0; i < 16; i++)
		{
			CRenderParticleArrow newpart(2, false, false, 4, 0, SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(XORRandom(360)) * 8 * (XORRandom(1000) / 2000.0 + 0.5);
			newpart.position = pos /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
	return damage;
}

float prettyTileHit(CBlob@ user, Vec2f pos, float angle, CGunEquipment@ gun, float damage)
{
	float rotation = (angle / 180.0) * Maths::Pi;
	pos -= Vec2f(Maths::Cos(rotation), Maths::Sin(rotation)) * 8;
	if(getNet().isClient())
	{
		for (int i = 0; i < 16; i++)
		{
			CRenderParticleArrow newpart(2, false, false, 4, 0, SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(XORRandom(360)) * 8 * (XORRandom(1000) / 2000.0 + 0.5);
			newpart.position = pos /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			addParticleToList(newpart);
		}
	}
	return damage;
}

//----------------------------------------KNOCKBACK--------------------------------

float yeetBlobHit(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, CGunEquipment@ gun, float damage)
{
	CMap@ map = getMap();
	CBlob@[] blobs;
	if(map.getBlobsInRadius(hit_blob.getPosition(), 24, @blobs))
	{
		for(int i = 0; i < blobs.length; i++)
		{
			blobs[i].setVelocity(blobs[i].getVelocity() + Vec2f_lengthdir_deg(damage * 175, angle));
		}
	}
	//hit_blob.setVelocity(hit_blob.getVelocity() + Vec2f_lengthdir_deg(damage * 175, angle));
	return damage;
}

//--------------------------------------FIRST SHOT--------------------------------------

float firstDamageBlobHit(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, CGunEquipment@ gun, float damage)
{
	if(gun.ammobak == gun.maxammo - 1)
	{
		damage *= 3;
		for (int i = 0; i < 12; i++)
		{
			CRenderParticleArrow newpart(1, false, false, 12, 0, SColor(255, 200, 50, 200), true, 0);
			newpart.velocity = Vec2f(1, 0).RotateBy(XORRandom(360)) * 4;
			newpart.position = pos /*+ Vec2f(float(XORRandom(1000) / 1000.0 - 0.5) * 16, float(XORRandom(1000) / 1000.0 - 0.5) * 16)*/;
			//newpart.yscale = 3.0;
			//newpart.diamond = true;
			addParticleToList(newpart);
		}
	}
	return damage;
}																				   













