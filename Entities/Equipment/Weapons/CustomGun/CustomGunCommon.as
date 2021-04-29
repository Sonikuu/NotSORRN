#include "EquipmentCore.as";
#include "EquipmentGunCommon.as";
#include "RenderParticleCommon.as";


class CGunPart
{
	//How to determine if stat is additive or mult?
	//Maybe just have one bool for all stats?
	float damage;
	float firerate;
	float range;
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
	Vec2f grippoint;
	Vec2f magpoint;
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
	CGunPart(bool multi, float damage, float firerate, float shotcount, float spread, float range, float movespeed, float recoil, float maxammo, float reloadspeed, string name)
	{
		this.damage = damage;
		this.firerate = firerate;
		this.shotcount = shotcount;
		this.spread = spread;
		this.range = range;
		this.multi = multi;
		this.movespeed = movespeed;
		this.recoil = recoil;
		this.name = name;
		this.maxammo = maxammo;
		this.reloadspeed = reloadspeed;
		
		barrelpoint = Vec2f_zero;
		stockpoint = Vec2f_zero;
		grippoint = Vec2f_zero;
		magpoint = Vec2f_zero;
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
		
		ammotype = "ammopack";
		ammoguifile = "AmmoGUIPistol.png";							
		
		semi = false;
		
		@blobfx = null;
		@tilefx = null;
	}
	CGunPart setBarrel(Vec2f point)
	{
		this.barrelpoint = point;
		return this;
	}
	CGunPart setStock(Vec2f point)
	{
		this.stockpoint = point;
		return this;
	}
	CGunPart setGrip(Vec2f point)
	{
		this.grippoint = point;
		return this;
	}
	CGunPart setMag(Vec2f point)
	{
		this.magpoint = point;
		return this;
	}
	CGunPart setSemi(bool semi)
	{
		this.semi = semi;
		return this;
	}
	CGunPart setHittype(int hittype)
	{
		this.hittype = hittype;
		return this;
	}
	CGunPart setGuntype(int guntype)
	{
		this.guntype = guntype;
		return this;
	}
	CGunPart setTileDamageChance(float tiledamagechance)
	{
		this.tiledamagechance = tiledamagechance;
		return this;
	}
	CGunPart setTracerColor(SColor tracercolor)
	{
		this.tracercolor = tracercolor;
		return this;
	}
	CGunPart setAmmotype(string ammotype)
	{
		this.ammotype = ammotype;
		return this;
	}
	CGunPart setHomingrange(float homingrange)
	{
		this.homingrange = homingrange;
		return this;
	}
	CGunPart setBlobPiercing(int blobpiercing)
	{
		this.blobpiercing = blobpiercing;
		return this;
	}
	CGunPart setBlobFx(gunHitBlob@ blobfx)
	{
		@this.blobfx = @blobfx;
		return this;
	}
	CGunPart setTileFx(gunHitTile@ tilefx)
	{
		@this.tilefx = @tilefx;
		return this;
	}
	CGunPart setAmmoGUI(string ammoguifile, Vec2f ammoguisize)
	{
		this.ammoguifile = ammoguifile;
		this.ammoguisize = ammoguisize;
		return this;
	}
}

class CGunRequirements
{
	array<string> materials;
	array<int> amt;
	bool hidden;
	CGunRequirements()
	{
		hidden = false;
	}

	CGunRequirements addRequirement(string material, int amount)
	{
		materials.push_back(material);
		amt.push_back(amount);
		return this;
	}
	CGunRequirements setHidden(bool hidden)
	{
		this.hidden = hidden;
		return this;
	}
}

array<array<CGunPart>> gunparts = {
//CORES
{
	//DAMAGE, FIRERATE, BULLET COUNT, SPREAD, RANGE, MOVE SPEED, RECOIL, MAXAMMO, RELOAD SPEED
	CGunPart(false, 0.5, 8, 1, 2, 512, 1.5, 3, 15, 20, "Pistol").setBarrel(Vec2f(1, 0)).setStock(Vec2f(-2, 0)).setMag(Vec2f(0, 1)).setSemi(true).setTileDamageChance(1),//PISTOL
	CGunPart(false, 0.4, 4, 1, 3, 512, 1.2, 6, 40, 30, "Assault Rifle").setBarrel(Vec2f(4, 0)).setStock(Vec2f(-3, -1)).setMag(Vec2f(0, 2)).setTileDamageChance(0.7).setAmmoGUI("AmmoGUISmall.png", Vec2f(3, 8)),//ASSUALT RIFLE
	CGunPart(false, 0.3, 2, 1, 4, 512, 1, 6, 60, 50, "Sprayer").setBarrel(Vec2f(2, 0)).setStock(Vec2f(-3, -1)).setMag(Vec2f(1, 2)).setTileDamageChance(0.5).setAmmoGUI("AmmoGUISmall.png", Vec2f(3, 8)),//SOMETHING, UZI MAYBE
	CGunPart(false, 1.2, 30, 1, 1, 512, 1, 16, 10, 35, "Charge Rifle").setBarrel(Vec2f(3, 0)).setStock(Vec2f(-5, -2)).setMag(Vec2f(-4, -1)).setGuntype(1).setTileDamageChance(3).setAmmoGUI("AmmoGUIHeavy.png", Vec2f(7, 14)),//CHARGE RIFLE
	CGunPart(false, 0.3, 25, 6, 30, 400, 1, 40, 10, 30, "Shotgun").setBarrel(Vec2f(5, -1)).setStock(Vec2f(-6, 0)).setMag(Vec2f(-1, 0)).setSemi(true).setTileDamageChance(1).setAmmoGUI("AmmoGUIShotgun.png", Vec2f(7, 14)),//SHOTGUN
	CGunPart(false, 0.9, 20, 1, 1, 512, 1, 40, 10, 40, "Sniper Rifle").setBarrel(Vec2f(5, 0)).setStock(Vec2f(-6, -1)).setMag(Vec2f(-2, 0)).setSemi(true).setTileDamageChance(2.5).setAmmoGUI("AmmoGUIHeavy.png", Vec2f(7, 14)),//SNIPER RIFLE
	CGunPart(false, 0.4, 10, 1, 5, 512, 0.9, 4, 100, 70, "Gatling").setBarrel(Vec2f(6, 0)).setStock(Vec2f(-6, -1)).setMag(Vec2f(-3, 3)).setGuntype(2).setTileDamageChance(0.5).setAmmoGUI("AmmoGUISmall.png", Vec2f(3, 8))//GATLING
},
//BARRELS
{
	CGunPart(true, 1, 1, 1, 		1, 1, 1, 		1, 1, 1, "Short-Barreled").setGrip(Vec2f(3, 1)),//SHORT
	CGunPart(true, 1.25, 1.2, 1, 	0.75, 1.5, 0.9, 1.2, 1, 1, "Long-Barreled").setGrip(Vec2f(4, 1)),//LONG
	CGunPart(true, 0.75, 1.2, 2, 	1.5, 0.9, 0.9, 	1.5, 0.5, 1, "Double-Barreled").setGrip(Vec2f(3, 2)),//SPLIT LUL
	CGunPart(true, 1.75, 1.5, 1, 	1, 1.75, 0.8, 	1.5, 0.8, 1.2, "Accelerated-Barrel").setGrip(Vec2f(4, 1)),//ACCELERATED
	CGunPart(true, 0.75, 0.5, 1, 	1.25, 0.9, 1, 	1.0, 1.5, 1.25, "Unstable").setGrip(Vec2f(2, 1)),//UNSTABLE?
	CGunPart(true, 0.5, 1, 1, 		1.25, 1, 0.9, 	2, 0.8, 1.25, "Guided").setGrip(Vec2f(4, 1)).setHomingrange(32)//GUIDED
},
//STOCK
{
	CGunPart(true, 1, 1, 1, 1.25, 1, 1, 1.25, 1, 1, "no Stock"),//NONE
	CGunPart(true, 1, 1, 1, 0.8, 1, 0.9, 1, 1, 1, "a Light Stock"),//LIGHT
	CGunPart(true, 1, 1, 1, 0.8, 1, 0.75, 0.75, 1, 1, "a Wooden Stock"),//WOOD
	CGunPart(true, 1, 1, 1, 0.7, 1, 0.5, 0.5, 1, 1, "a Heavy Stock"),//HEAVY
	CGunPart(true, 1.35, 1.15, 1, 1, 1.2, 0.5, 1.2, 0.8, 1, "an Accelerating Stock"),//ACCELERATED
	CGunPart(true, 0.5, 1, 1, 1.25, 1, 0.5, 1, 0.8, 1, "a Guiding Stock").setHomingrange(32)//GUIDED
	//CGunPart(true, 1, 1, 1, 1.25, 1, 0.4, 1, 0.8, 1, "a Strange Stock").setBlobFx(@firstDamageBlobHit)//FIRST-SHOT BONUS
},
//GRIP
{
	CGunPart(true, 1, 1, 1, 1.25, 1, 1, 1.25, 1, 1, "no Grip"),//NONE
	CGunPart(true, 1, 1, 1, 0.8, 1, 0.9, 1, 1, 1, "a Small Grip"),//SMALL
	CGunPart(true, 1, 1, 1, 1, 1, 0.8, 0.6, 1, 1, "a Vertical Grip"),//VERT
	CGunPart(true, 1, 1, 1, 0.75, 1, 0.8, 1, 1, 1, "a Horizontal Grip"),//HORZ
	CGunPart(true, 0.8, 1, 1, 0.6, 0.9, 0.8, 0.5, 1, 1, "a Compensating Grip"),//COMP + GRIP
	CGunPart(true, 0.75, 0.5, 1, 1, 0.9, 0.8, 0.9, 1.2, 1.4, "a Destabalizing Grip"),//UNSTABLE
	CGunPart(true, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, "a Pretty Grip").setBlobFx(@prettyBlobHit).setTileFx(@prettyTileHit)//LUL
},
//MAG
{
	CGunPart(true, 1, 1, 1, 1, 1, 1, 0.8, 		1, 1, "Basic"),//LOWCAL?
	CGunPart(true, 1, 1, 1, 1, 1, 0.8, 1, 		1.5, 1, "High Capacity"),//HIGHCAL?
	CGunPart(true, 1, 1, 1, 1, 1, 1, 1, 		1, 1, "Holy").setHittype(CHitters::pure).setTracerColor(SColor(255, 255, 255, 200)).setAmmotype("holyammopack"),//HOLY
	CGunPart(true, 1, 1, 1, 1, 1, 0.7, 1, 		2.5, 2, "Drum Fed"),//DRUM
	CGunPart(true, 0.1, 2, 1, 0.7, 1, 1.2, 0.7, 1, 1, "YEETing").setHittype(CHitters::yeet).setTracerColor(SColor(255, 255, 150, 150)).setAmmotype("yeetammopack").setBlobFx(@yeetBlobHit),//YEET
	CGunPart(true, 1, 1, 1, 1, 1, 1, 1, 		1, 1, "Piercing").setBlobPiercing(2).setTracerColor(SColor(255, 0, 200, 200)).setTileDamageChance(2).setAmmotype("piercingammopack"),//PIERCING
	CGunPart(true, 0.5, 1, 1, 1, 1, 1, 1, 		1, 1, "Explosive").setTracerColor(SColor(255, 255, 200, 100)).setAmmotype("explosiveammopack").setBlobFx(@explosiveBlobHit).setTileFx(@explosiveTileHit)//EXPLOSIVE
}
};

array<array<CGunRequirements>> gunreqs = {

	{
		CGunRequirements().addRequirement("mat_metal", 2),//PISTOL
		CGunRequirements().addRequirement("mat_metal", 4),//ASSUALT RIFLE
		CGunRequirements().addRequirement("mat_metal", 3),//SOMETHING, UZI MAYBE
		CGunRequirements().addRequirement("mat_metal", 5).addRequirement("powercrystal", 1).setHidden(true),//CHARGE RIFLE
		CGunRequirements().addRequirement("mat_metal", 5),//SHOTGUN
		CGunRequirements().addRequirement("mat_metal", 5).addRequirement("mat_accelplate", 1).setHidden(true),//SNIPER RIFLE
		CGunRequirements().addRequirement("mat_metal", 6).addRequirement("unstablecore", 1).setHidden(true)//GATLING
	},
	{
		CGunRequirements().addRequirement("mat_metal", 1),//SHORT
		CGunRequirements().addRequirement("mat_metal", 2),//LONG
		CGunRequirements().addRequirement("mat_metal", 2),//SPLIT LUL
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("mat_accelplate", 2).setHidden(true),//ACCELERATED
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("unstablecore", 1).setHidden(true),//UNSTABLE?
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("natureheart", 1).setHidden(true)//GUIDED
	},
	{
		CGunRequirements(),//NONE
		CGunRequirements().addRequirement("mat_metal", 1),//LIGHT
		CGunRequirements().addRequirement("mat_wood", 100),//WOOD
		CGunRequirements().addRequirement("mat_metal", 3),//HEAVY
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("mat_accelplate", 2).setHidden(true),//ACCELERATED
		CGunRequirements().addRequirement("mat_metal", 1).addRequirement("natureheart", 1).setHidden(true)//GUIDED
	},
	{
		CGunRequirements(),//NONE
		CGunRequirements().addRequirement("mat_metal", 1),//SMALL
		CGunRequirements().addRequirement("mat_metal", 2),//VERT
		CGunRequirements().addRequirement("mat_metal", 2),//HORZ
		CGunRequirements().addRequirement("mat_metal", 2),//COMP + GRIP
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("unstablecore", 1).setHidden(true),//UNSTABLE
		CGunRequirements().addRequirement("mat_metal", 1).addRequirement("decorheart", 1).setHidden(true)//LUL
	},
	{
		CGunRequirements().addRequirement("mat_metal", 2),//LOWCAP
		CGunRequirements().addRequirement("mat_metal", 4),//HIGHCAP
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("holyammopack", 1).setHidden(true),//HOLY
		CGunRequirements().addRequirement("mat_metal", 8),//DRUM
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("yeetammopack", 1).setHidden(true),//YEET
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("mat_glass", 100).setHidden(true),//PIERCING
		CGunRequirements().addRequirement("mat_metal", 2).addRequirement("unstablecore", 2).setHidden(true)//EXPLOSIVE
	}
};

void buildGun(CBlob@ this)
{
	u8 coreindex = this.get_u8("coreindex");
	u8 barrelindex = this.get_u8("barrelindex");
	u8 stockindex = this.get_u8("stockindex");
	u8 gripindex = this.get_u8("gripindex");
	u8 magindex = this.get_u8("magindex");
	
	//FIRST INDEX IS TYPE, SECOND IS PART
	if(coreindex >= gunparts[0].length || barrelindex >= gunparts[1].length || stockindex >= gunparts[2].length || gripindex >= gunparts[3].length || magindex >= gunparts[4].length)
	{
		this.server_Die();
		print("INVALID CUSTOM GUN PARTS");
		return;
	}
	CGunPart@ corepart = @(gunparts[0][coreindex]);
	CGunPart@ barrelpart = @(gunparts[1][barrelindex]);
	CGunPart@ stockpart = @(gunparts[2][stockindex]);
	CGunPart@ grippart = @(gunparts[3][gripindex]);
	CGunPart@ magpart = @(gunparts[4][magindex]);
	
	CGunEquipment@ gun = calculateGunStats(corepart, barrelpart, stockpart, grippart, magpart);
	if(coreindex != 0)
		gun.twohand = true;
	
	setEquipment(this, @gun);

	this.setInventoryName(getGunTitle(corepart, barrelpart, stockpart, grippart, magpart) + "\n" + getGunDescription(corepart, gun));

	//part.spriteoffset = Vec2f(0, 1.25);
	//part.tracercolor = SColor(255, 150, 255, 255);
	//part.tiledamagechance = 0.5;
	
	//SPRITE BUILDING
	if(isClient())
	{
		CSprite@ sprite = this.getSprite();
		string texname = "customgun" + coreindex + "" + barrelindex + "" + stockindex + "" + gripindex + "" + magindex;
		//print(texname);
		Vec2f spritesize(32, 16);
		if(Texture::exists(texname))
		{
			sprite.SetTexture(texname, 32, 16);
			sprite.SetFrame(0);
		}
		else
		{
			
			if(!Texture::exists("CustomGunBase"))
			{
				if(!Texture::createFromFile("CustomGunBase", "CustomGun.png"))
					print("oh this is a problem");
			}
			ImageData@ baseimage = Texture::data("CustomGunBase");
			//if(!Texture::createBySize(texname, 32, 16))
				//print("ohno");
			ImageData@ newimage = @ImageData(32, 16);
			
			Vec2f barrelpos = corepart.barrelpoint;
			Vec2f stockpos = corepart.stockpoint;
			Vec2f grippos = barrelpos + barrelpart.grippoint;
			Vec2f magpos = corepart.magpoint;
			
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
			mergeOnto(newimage, baseimage, stockpos, startpos, startpos + spritesize);
			startpos = Vec2f(96, 16 * gripindex);
			mergeOnto(newimage, baseimage, grippos, startpos, startpos + spritesize);
			startpos = Vec2f(128, 16 * magindex);
			mergeOnto(newimage, baseimage, magpos, startpos, startpos + spritesize);
			
			//sprite.ReloadSprite(texname);
			Texture::createFromData(texname, newimage);
			sprite.SetTexture(texname, 32, 16);
			sprite.SetFrame(0);
			//FML everytime i use imagedata i want to die
			//ill get used to it eventually
		}
	}
}

string getGunTitle(CGunPart@ corepart, CGunPart@ barrelpart, CGunPart@ stockpart, CGunPart@ grippart, CGunPart@ magpart)
{
	return (magpart.name + " " + barrelpart.name + " " + corepart.name + " with " + stockpart.name + " and " + grippart.name);
}

string getGunDescription(CGunPart@ corepart, CGunEquipment@ gun)
{
	return getSymbol(gun.damage, corepart.damage) + "Damage: " + gun.damage +
	"\n" + getSymbol(corepart.firerate, gun.firerate) + "Firerate: " + (30.0 / gun.firerate) +
	"\n" + getSymbol(gun.shotcount, corepart.shotcount) + "Bullet Count: " + gun.shotcount +
	"\n" + getSymbol(corepart.spread, gun.spread) + "Spread: " + gun.spread +
	"\n" + getSymbol(gun.range, corepart.range) + "Range: " + gun.range +
	"\n" + getSymbol(gun.movespeed, corepart.movespeed) + "Movement Penalty: " + (100.0 - gun.movespeed * 100.0) + "%" +
	"\n" + getSymbol(corepart.recoil, gun.recoil) + "Recoil: " + gun.recoil +
	"\n" + getSymbol(gun.maxammo, corepart.maxammo) + "Max Ammo: " + gun.maxammo +
	"\n" + getSymbol(corepart.reloadspeed, gun.reloadtime) + "Reload Time: " + (gun.reloadtime / 30.0) +
	"\nUses: " + gun.ammotype;
}

CGunEquipment@ calculateGunStats(CGunPart@ corepart, CGunPart@ barrelpart, CGunPart@ stockpart, CGunPart@ grippart, CGunPart@ magpart)
{
	//STAT BUILDING
	float damage = 0;
	float firerate = 0;
	float shotcount = 0;
	float spread = 0;
	float range = 0;
	float movespeed = 0;
	float recoil = 0;
	float maxammo = 0;
	float reloadspeed = 0;
	int blobpiercing = 0;
	float homingrange = 0;
	float tiledamagechance = 0;
	array<gunHitBlob@> blobfx;
	array<gunHitTile@> tilefx;
	
	array<CGunPart@> parts = {@corepart, @barrelpart, @stockpart, @grippart, @magpart};
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
			range *= parts[i].range;
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
			range += parts[i].range;
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
	gun.range = range;
	gun.semi = corepart.semi;
	gun.reloadtime = reloadspeed;
	gun.maxammo = maxammo;
	gun.hittype = magpart.hittype;
	gun.ammotype = magpart.ammotype;
	gun.tiledamagechance = tiledamagechance * Maths::Max(damage / corepart.damage, 0.5);
	gun.tracercolor = magpart.tracercolor;
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













