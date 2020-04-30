#include "EquipmentCore.as";
#include "CHitters.as";
#include "MaterialCommon.as";
#include "ParticleSparks.as";
#include "DamageModCommon.as";
#include "WorldRenderCommon.as";
#include "RunnerCommon.as";
#include "ExplosionCommon.as";

const u32 firecmdbits = EquipmentBitStreams::Tu32 | EquipmentBitStreams::Tf32;

funcdef float gunHitBlob(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, CGunEquipment@ gun, float damage);
funcdef float gunHitTile(CBlob@ user, Vec2f pos, float angle, CGunEquipment@ gun, float damage);

class CGunEquipment : CEquipmentCore
{
	int cooldown;
	
	float damage;
	int firerate;
	int shotcount;
	float spread;
	
	float angle;
	
	float lastshotrotation;
	bool fixedsprite;
	float kick;
	float recoil;
	float movespeed;
	float range;
	int reloadtime;
	int maxammo;
	bool semi;
	bool homing;
	string ammotype;
	
	//Vec2f spriteoffset;
	float tracerwidth;
	SColor tracercolor;
	
	float tiledamagechance;
	float homingrange;
	
	int hittype;
	int reloadprog;
	int blobpiercing;
	
	bool texture;
	
	array<gunHitBlob@>@ blobfx;
	array<gunHitTile@>@ tilefx;
	
	CGunEquipment(float damage = 2.0, int firerate = 10, int shotcount = 1, float spread = 10.0)
	{
		super();
		this.firerate = firerate;
		this.damage = damage;
		this.shotcount = shotcount;
		this.spread = spread;
		
		cooldown = 0;
		
		lastshotrotation = 0;
		fixedsprite = false;
		
		//spriteoffset = Vec2f_zero;
		tracerwidth = 0.5;
		tracercolor = SColor(255, 255, 255, 0);
		kick = 0;
		hittype = CHitters::bullet;
		recoil = 0;
		movespeed = 1;
		semi = false;
		reloadtime = 60;
		reloadprog = 0;
		ammotype = "mat_ammo";
		maxammo = 30;
		
		range = 512;
		homingrange = 0;
		
		tiledamagechance = 1.0;
		homing = true;
		blobpiercing = 0;
		
		texture = false;
		
		@blobfx = @array<gunHitBlob@>();
		@tilefx = @array<gunHitTile@>();
	}
	
	void onRender(CBlob@ blob, CBlob@ user)
	{
		if(user.isMyPlayer())
		{
			if (getHUD().hasButtons())
			{
				getHUD().SetDefaultCursor();
			}
			else
			{
				getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-32, -32));
				
				int frame = 0;
				if(reloadprog > 0)
				{
					float currcoolratio = 1.0 - float(Maths::Abs(reloadprog)) / float(reloadtime);
					if(reloadprog < reloadtime)
						frame = Maths::Min(1 + currcoolratio * 7, 8);
					if(reloadprog == reloadtime)
						frame = 8;
					if(reloadprog == 0)
						frame = 0;
				}
				else
				{
					float ammo = float(blob.get_u16("ammo"));
					if(ammo > 0 && maxammo != 0)
						frame = 1 + ammo / float(maxammo) * 7;
					if(ammo >= maxammo)
						frame = 8;
					if(ammo == 0)
						frame = 0;
				}
				getHUD().SetCursorFrame(frame);
			}
		}
	}
	
	void standardTickJunk(CBlob@ blob, CBlob@ user)
	{
		cooldown--;
		
		if(user !is null)
		{
			bool actionkey = (semi ? 
							(attachedPoint == "FRONT_ARM" ? user.isKeyJustPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyJustPressed(key_action2) :
							user.isKeyJustPressed(key_action1))
							:
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1)));
			
			if(blob !is null)
			{
				angle = (((user.getAimPos() - user.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
			}
			
			if(reloadprog > 0)
			{
				reloadprog--;
			}
			
			CControls@ controls = getControls();
			if(cooldown < 0 && reloadprog <= 0 && blob !is null && user is getLocalPlayerBlob() && controls !is null && controls.isKeyPressed(KEY_KEY_R))
			{
				sendReloadCommand(blob);
			}
			
			if(actionkey || cooldown >= 0 || reloadprog > 0)
			{
				RunnerMoveVars@ moveVars;
				if (!user.get("moveVars", @moveVars))
				{
					return;
				}
				moveVars.walkFactor *= movespeed;
				moveVars.jumpFactor *= movespeed;
			}
		}
	}
	
	void doRecoil(CBlob@ user, float intensity = 1.0)
	{
		CControls@ controls = getControls();
		if(controls !is null)
		{
			Vec2f recoilpos = Vec2f(XORRandom(recoil) - recoil / 2, XORRandom(recoil) - recoil / 2) * intensity;
			recoilpos *= (controls.getMouseWorldPos() - user.getPosition()).Length() / 100.0;
			recoilpos += controls.getMouseScreenPos();
			recoilpos.x = Maths::Max(0, Maths::Min(recoilpos.x, getScreenWidth()));
			recoilpos.y = Maths::Max(0, Maths::Min(recoilpos.y, getScreenHeight()));
			controls.setMousePosition(recoilpos);
		}
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		standardTickJunk(blob, user);
		
		if(user !is null)
		{
		
			bool actionkey = (semi ? 
							(attachedPoint == "FRONT_ARM" ? user.isKeyJustPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyJustPressed(key_action2) :
							user.isKeyJustPressed(key_action1))
							:
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1)));
							
			if(actionkey && blob !is null && cooldown < 0 && user is getLocalPlayerBlob() && reloadprog <= 0)
			{
				if(blob.get_u16("ammo") > 0)
				{
					doRecoil(user);
				}
				fireWeapon(blob);
			}
		}
	}
	
	bool getAmmo(CBlob@ blob, CBlob@ user)
	{
		bool gotammo = false;
		//TODO: implement ammo getting override thingy
		CInventory@ inv = user.getInventory();
		if(inv !is null)
		{
			for(int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob@ item = inv.getItem(i);
				if(item !is null && item.getConfig() == ammotype)
				{
					int consumed = Maths::Min(item.getQuantity(), maxammo - blob.get_u16("ammo"));
					if(consumed < item.getQuantity())
						item.server_SetQuantity(item.getQuantity() - consumed);
					else
						item.server_Die();
					gotammo = true;
					blob.add_u16("ammo", consumed);
					if(blob.get_u16("ammo") >= maxammo)
						break;
				}
			}
		}
		return gotammo;
	}
	
	void startReload(CBlob@ blob, CBlob@ user)
	{
		//if(maxammo > blob.get_u16("ammo") && reloadprog <= 0)
		{
			if(getAmmo(blob, user))
				reloadprog = reloadtime;
			blob.Sync("ammo", true);
		}
	}
	
	void fireWeapon(CBlob@ blob)
	{
		u32 seed = XORRandom(0x7FFFFFFF);
		CBitStream params;

		params.write_u32(firecmdbits);
		
		params.write_u32(seed);
		params.write_f32(angle);
		
		blob.SendCommand(blob.getCommandID("partcmd"), params);
		
		//if(blob.get_u16("ammo") > 0 && reloadprog <= 0)
			//blob.sub_u16("ammo", 1);
		
		cooldown = firerate;
	}
	
	float doBlobHitEffects(CBlob@ user, CBlob@ hit_blob, Vec2f pos, float angle, float damage)
	{
		for(int i = 0; i < blobfx.length; i++)
		{
			damage = blobfx[i](user, hit_blob, pos, angle, @this, damage);
		}
		return damage;
	}
	
	float doTileHitEffects(CBlob@ user, Vec2f pos, float angle, float damage)
	{
		for(int i = 0; i < tilefx.length; i++)
		{
			damage = tilefx[i](user, pos, angle, @this, damage);
		}
		return damage;
	}
	
	void sendReloadCommand(CBlob@ blob)
	{
		CBitStream params;
		params.write_u32(0);
		blob.SendCommand(blob.getCommandID("partcmd"), params);
	}
	
	bool isSpriteShowing(CBlob@ blob)
	{
		return cooldown > -1 /*&& blob.get_u16("ammo") > 0*/;
	}
	
	void onTick(CSprite@ sprite, CBlob@ user)
	{
		if(!isSpriteShowing(sprite.getBlob()))
		{
			CSprite@ usersprite = user.getSprite();
			if(usersprite !is null && usersprite.getSpriteLayer("equipgunfx") !is null)
			{
				usersprite.RemoveSpriteLayer("equipgunfx");
			}
		}
		else
		{
			CSprite@ usersprite = user.getSprite();
			if(usersprite !is null && usersprite.getSpriteLayer("equipgunfx") is null)
			{
				CSpriteLayer@ layer = (texture ? usersprite.addTexturedSpriteLayer("equipgunfx", sprite.getTextureName(), sprite.getFrameWidth(), sprite.getFrameHeight()) :
												usersprite.addSpriteLayer("equipgunfx", sprite.getFilename(), sprite.getFrameWidth(), sprite.getFrameHeight()));
				layer.SetFrame(0);
				layer.TranslateBy(spriteoffset);
				layer.ScaleBy(Vec2f(1, 1) * spritescale);
				
				
				layer.SetIgnoreParentFacing(true);
				if(lastshotrotation >= 90 && lastshotrotation < 270)
				{
					layer.SetFacingLeft(true);
					lastshotrotation += 180;
				}
				else
				{
					layer.SetFacingLeft(false);
				}
				layer.RotateBy(lastshotrotation, Vec2f_zero);
				layer.SetRelativeZ(5);
				fixedsprite = true;
			}
			else if(!fixedsprite)
			{
				CSpriteLayer@ layer = usersprite.getSpriteLayer("equipgunfx");
				layer.ResetTransform();
				//layer.ScaleBy(Vec2f(0.5, 0.5));
				
				layer.TranslateBy(spriteoffset);
				
				if(lastshotrotation >= 90 && lastshotrotation < 270)
				{
					layer.SetFacingLeft(true);
					lastshotrotation += 180;
				}
				else
				{
					layer.SetFacingLeft(false);
				}
				layer.RotateBy(lastshotrotation, Vec2f_zero);
				
				u8 spoolframes = sprite.getBlob().get_u8("spoolframecount");
				if(spoolframes > 0)
				{
					layer.SetFrame(1 + (getGameTime() / 2) % spoolframes);
				}
				fixedsprite = true;
			}
			
			if(sprite.getBlob().hasTag("haspumpframe") && usersprite.getSpriteLayer("equipgunfx") !is null)
			{
				CSpriteLayer@ layer = usersprite.getSpriteLayer("equipgunfx");
				float refiretimeratio = float(Maths::Max(0, cooldown)) / float(firerate);
				if(refiretimeratio <= 0.10)
				{
					layer.SetFrame(0);
				}
				else if(refiretimeratio <= 0.50)
				{
					layer.SetFrame(1);
				}
			}
		}
	}
	
	bool isValidTarget(CBlob@ blob, CBlob@ user)
	{
		if(blob.getTeamNum() != user.getTeamNum() && blob.hasTag("flesh") && !blob.isAttachedTo(user))
			return true;
		return false;
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		if(bits == firecmdbits && user !is null)
		{
			if(blob.get_u16("ammo") == 0)
			{
				if(isServer()) sendReloadCommand(blob);
				return bits;
			}
			else if(reloadprog > 0)
				return bits;
			else
			{
				//if(isServer())
					blob.sub_u16("ammo", 1);
				//blob.Sync("ammo", true);
			}
			
			CMap@ map = getMap();
			bits &= ~firecmdbits;
			u32 seed = params.read_u32();
			Random random(seed);
			f32 aimdef = params.read_f32();
			lastshotrotation = aimdef;
			fixedsprite = false;
			
			Vec2f kickdir(-1, 0);
			kickdir.RotateBy(aimdef);
			user.setVelocity(user.getVelocity() + kickdir * kick);
			
			Sound::Play("StandardFire.ogg", user.getPosition(), 1.0f, 0.95 + XORRandom(10) / 100.0);
			
			if(user !is getLocalPlayerBlob())
				cooldown = firerate;
				
			//How homing is going to work:
			//Get blobs in homing range + gun range
			//Rotate all blobs and shoot dir so that it's straight upwards
			//if blob's Y is above or below the line, discard
			//if blob's abs x is greater than  homing range, discard
			//then get first blob in list, home to that
			
			
			for (uint x = 0; x < shotcount; x++)
			{
				float endpoint = range;
				f32 offset = (random.NextFloat() * spread) - spread / 2.0;
				f32 aimdir = aimdef + offset;
				int piercesleft = blobpiercing;
				
				if(homingrange > 0)
				{
					//print("homing");
					const float steplength = 10;
					float rangeleft = range;
					bool hastarget = false;
					CBlob@ currtarg = null;
					Vec2f currpos = user.getPosition();
					bool neednewtarg = true;
					bool cantfind = false;
					bool donehits = false;
					while (rangeleft > 0 && !donehits)
					{
						if(!hastarget || neednewtarg)
						{
							CBlob@[] bloblist;
							array<Vec2f> poslist;
							if(map.getBlobsInRadius(currpos, rangeleft + homingrange, @bloblist))
							{
								for (uint i = 0; i < bloblist.length; i++)
								{
									Vec2f nextpos = currpos - bloblist[i].getPosition();
									nextpos.RotateBy(-(aimdir - 90));
									nextpos.y *= -1;
									poslist.push_back(nextpos);
								}
								cantfind = true;
								float closest = 9999;
								for (uint i = 0; i < bloblist.length; i++)
								{
									Vec2f thispos = poslist[i];
									//printVec2f(bloblist[i].getName(), thispos);
									if(thispos.y > 0 && thispos.y < rangeleft && Maths::Abs(thispos.x) <= homingrange && isValidTarget(bloblist[i], user) && currtarg !is bloblist[i] && thispos.y < closest)
									{
										//print("got targ");
										hastarget = true;
										neednewtarg = false;
										cantfind = false;
										@currtarg = @bloblist[i];
										closest = thispos.y;
										//break;
									}
								}
							}
						}
						//Rotating bullet
						if(currtarg !is null && !cantfind)
						{
							float targang = ((currtarg.getPosition() - currpos).Angle() * -1) + 360;
							//Max degrees to turn per step
							float anglediff = Maths::Abs(aimdir - targang) % 360;
							
							float currturn = (anglediff / ((currtarg.getPosition() - currpos).Length() / float(steplength))) * 1.1;
							if(anglediff > 180)
								currturn = ((360 - anglediff) / ((currtarg.getPosition() - currpos).Length() / float(steplength))) * 1.1;
							
							float handmult = Maths::Min(currturn, anglediff);
							
							if (anglediff > 180)
							{
								handmult = Maths::Min(currturn, (360 - anglediff));
							}
							float rotspeed = 0;
							if(aimdir < targang) 
							{
								if(anglediff < 180)
								   rotspeed += handmult;
								else rotspeed -= handmult;
							}
							else 
							{
								if(anglediff < 180)
								   rotspeed -= handmult;
								else rotspeed += handmult;
							}
							//currangdeg += rotspeed;
							aimdir += rotspeed + 360;
							aimdir %= 360;
						}
						
						//Hitting stuff
						
						endpoint = steplength;
						if(cantfind)
						{
							endpoint = rangeleft + 1;
						}
						
						HitInfo@[] hitInfos;
						if (map.getHitInfosFromRay(currpos, aimdir, endpoint, user, @hitInfos))
						{
							for (uint i = 0; i < hitInfos.length; i++)
							{
								HitInfo@ hi = hitInfos[i];

								if (hi.blob !is null) // blob
								{
									if(isValidTarget(hi.blob, user))
									{
										//print("hit");
										float tempdamage = doBlobHitEffects(user, hi.blob, hi.hitpos, aimdir, damage);
										user.server_Hit(hi.blob, hi.hitpos, hi.blob.getPosition() - user.getPosition(), calcAllDamageMods(user, hi.blob, tempdamage, hittype), hittype);
										neednewtarg = true;
										if(piercesleft <= 0)
										{
											endpoint = (hi.hitpos - currpos).Length();
											rangeleft = -1;
											donehits = true;
											break;
										}
										piercesleft--;
									}
								}
								else // map
								{
									if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
										continue;

									TileType tile = hi.tile;
									doTileHitEffects(user, hi.hitpos, aimdir, damage);

									if (getNet().isServer() && tiledamagechance >= random.NextFloat())
									{
										map.server_DestroyTile(hi.hitpos, 1.0f, user);
									}
									
									endpoint = (hi.hitpos - currpos).Length();
									rangeleft = -1;
									donehits = true;
								}
							}
						}
						
						if(getNet().isClient())
						{	
							Vec2f startpoint = currpos;
							//manager.addTracer(user.getPosition(), endpoint, (aimdir / 180.0) * Maths::Pi, tracercolor, 20, tracerwidth);
							array<Vertex> vertlist;
							
							float perp = ((aimdir / 180.0) * Maths::Pi) + Maths::Pi / 2;
							Vec2f perpoffs(Maths::Cos(perp) * tracerwidth, Maths::Sin(perp) * tracerwidth);
							Vec2f endvec = startpoint + Vec2f(Maths::Cos(((aimdir / 180.0) * Maths::Pi)), Maths::Sin(((aimdir / 180.0) * Maths::Pi))) * endpoint;
							
							vertlist.push_back(Vertex(startpoint.x - perpoffs.x, startpoint.y - perpoffs.y, 0, 0, 0, tracercolor));
							vertlist.push_back(Vertex(endvec.x - perpoffs.x, endvec.y - perpoffs.y, 0, 1, 0, tracercolor));
							vertlist.push_back(Vertex(endvec.x + perpoffs.x, endvec.y + perpoffs.y, 0, 1, 1, tracercolor));
							vertlist.push_back(Vertex(startpoint.x + perpoffs.x, startpoint.y + perpoffs.y, 0, 0, 1, tracercolor));
							
							addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLtick");
						}
						
						rangeleft -= endpoint;
						float rotation = (aimdir / 180.0) * Maths::Pi;
						currpos += Vec2f(Maths::Cos(rotation) * endpoint, Maths::Sin(rotation) * endpoint);
					}
				}
				else
				{
					HitInfo@[] hitInfos;
					if (map.getHitInfosFromRay(user.getPosition(), aimdir, range, user, @hitInfos))
					{
						for (uint i = 0; i < hitInfos.length; i++)
						{
							HitInfo@ hi = hitInfos[i];

							if (hi.blob !is null) // blob
							{
								if(isValidTarget(hi.blob, user))
								{
									float tempdamage = doBlobHitEffects(user, hi.blob, hi.hitpos, aimdir, damage);
									user.server_Hit(hi.blob, hi.hitpos, hi.blob.getPosition() - user.getPosition(), calcAllDamageMods(user, hi.blob, tempdamage, hittype), hittype);
									if(piercesleft <= 0)
									{
										endpoint = (hi.hitpos - user.getPosition()).Length();
										break;
									}
									piercesleft--;
								}
							}
							else // map
							{
								if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
									continue;

								TileType tile = hi.tile;
								doTileHitEffects(user, hi.hitpos, aimdir, damage);

								if (getNet().isServer() && tiledamagechance >= random.NextFloat())
								{
									map.server_DestroyTile(hi.hitpos, 1.0f, user);
								}
								endpoint = (hi.hitpos - user.getPosition()).Length();
								
							}
						}
					}
					if(getNet().isClient())
					{	
						Vec2f startpoint = user.getPosition();
						//manager.addTracer(user.getPosition(), endpoint, (aimdir / 180.0) * Maths::Pi, tracercolor, 20, tracerwidth);
						array<Vertex> vertlist;
						
						float perp = ((aimdir / 180.0) * Maths::Pi) + Maths::Pi / 2;
						Vec2f perpoffs(Maths::Cos(perp) * tracerwidth, Maths::Sin(perp) * tracerwidth);
						Vec2f endvec = startpoint + Vec2f(Maths::Cos(((aimdir / 180.0) * Maths::Pi)), Maths::Sin(((aimdir / 180.0) * Maths::Pi))) * endpoint;
						
						vertlist.push_back(Vertex(startpoint.x - perpoffs.x, startpoint.y - perpoffs.y, 0, 0, 0, tracercolor));
						vertlist.push_back(Vertex(endvec.x - perpoffs.x, endvec.y - perpoffs.y, 0, 1, 0, tracercolor));
						vertlist.push_back(Vertex(endvec.x + perpoffs.x, endvec.y + perpoffs.y, 0, 1, 1, tracercolor));
						vertlist.push_back(Vertex(startpoint.x + perpoffs.x, startpoint.y + perpoffs.y, 0, 0, 1, tracercolor));
						
						addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLtick");
					}
				}
				//radius 48, damage 3, sound Bomb.ogg, map radius 24, map ratio 0.4
				//Explode(user, endpos, range * 0.1, damage, "Bomb.ogg", range * 0.05, damage * 0.4, true, Hitters::explosion, true);
			}
		}
		else if (bits == 0)
		{
			startReload(blob, user);
		}
		return bits;
	}
	
	void onEquip(CBlob@ blob, CBlob@ user)
	{
		//CMechCore::onAttach(blob, user);
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{		
		if(user is null) return;
		
		CSprite@ usersprite = user.getSprite();
		if(usersprite !is null && usersprite.getSpriteLayer("equipgunfx") !is null)
		{
			usersprite.RemoveSpriteLayer("equipgunfx");
		}
		
		if(user.isMyPlayer())
		{
			getHUD().SetDefaultCursor();
		}
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "BACK_ARM" || slot == "FRONT_ARM")
			return true;
		return false;
	}
}

class CSpoolGunEquipment : CGunEquipment
{
	int spoollimit;//This is how much below base firerate we can go
	float spoolspeed;//amount per shot to reduce firerate
	
	float spooltime;//current spool speed
	CSpoolGunEquipment(float damage = 2.0, int firerate = 10, int shotcount = 1, float spread = 10.0, int spoollimit = 9, float spoolspeed = 1)
	{
		super(damage, firerate, shotcount, spread);
		
		this.spoollimit = spoollimit;
		this.spoolspeed = spoolspeed;
		
		spooltime = 0;
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		standardTickJunk(blob, user);
		
		if(user !is null)
		{
		
			bool actionkey = (semi ? 
							(attachedPoint == "FRONT_ARM" ? user.isKeyJustPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyJustPressed(key_action2) :
							user.isKeyJustPressed(key_action1))
							:
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1)));
			if(!actionkey)
				spooltime -= spoolspeed;
							
			if(actionkey && blob !is null && cooldown < 0 && user is getLocalPlayerBlob() && reloadprog <= 0)
			{
				spooltime += spoolspeed;
				spooltime = Maths::Min(spoollimit, spooltime);
				spooltime = Maths::Max(0, spooltime);
			
				if(user is getLocalPlayerBlob())
				{
					if(blob.get_u16("ammo") > 0)
					{
						doRecoil(user);
					}
					fireWeapon(blob);
					cooldown = firerate - spooltime;
				}
				
			}
		}
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		bits = CGunEquipment::onCommand(blob, user, bits, params);
		if(user !is getLocalPlayerBlob())
			cooldown = firerate - spooltime;
		return bits;
	}
}

class CChargeGunEquipment : CGunEquipment
{
	float basedamage;
	float basetracerwidth;
	
	int mincharge;
	int maxcharge;
	int currcharge;
	
	CChargeGunEquipment(float damage, int firerate, int shotcount, float spread, int mincharge, int maxcharge)
	{
		super(damage, firerate, shotcount, spread);
		basedamage = damage;
		basetracerwidth = 0.5;
		this.mincharge = mincharge;
		this.maxcharge = maxcharge;
		currcharge = 0;
	
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		standardTickJunk(blob, user);
		
		if(user !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1);

			
			
			
			if(!actionkey && currcharge > 0)
			{
				float chargeratio = float(currcharge) / float(maxcharge);
				if(currcharge >= mincharge)
				{
					angle = (((user.getAimPos() - user.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
			
					if(user is getLocalPlayerBlob())
					{
						doRecoil(user);
						u32 seed = XORRandom(0x7FFFFFFF);
						CBitStream params;
						params.write_u32(firecmdbits);
						
						params.write_f32(chargeratio);
						
						params.write_u32(seed);
						params.write_f32(angle);
						
						//print("CMD Sent");
						blob.SendCommand(blob.getCommandID("partcmd"), params);
					}
					cooldown = firerate;
				}
				currcharge = 0;
			}
				
			
			if(actionkey && blob !is null && cooldown < 0 && reloadprog <= 0 && blob.get_u16("ammo") > 0)
			{
				if(user is getLocalPlayerBlob())
					doRecoil(user, float(currcharge) / float(maxcharge) * 0.1);
				currcharge = Maths::Min(currcharge + 1, maxcharge);
				
				lastshotrotation = angle;
				fixedsprite = false;
			}
		}
	}
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		if(user !is null && firecmdbits == bits)
		{
			//bits &= ~EquipmentBitStreams::Tf32;
			float damageratio = params.read_f32();
			damage = basedamage * damageratio;
			tracerwidth = basetracerwidth * damageratio;
			return CGunEquipment::onCommand(blob, user, bits, params);
		}
		else
		{
			CGunEquipment::onCommand(blob, user, bits, params);
		}
		return bits;
	}
	
	bool isSpriteShowing(CBlob@ blob)
	{
		return CGunEquipment::isSpriteShowing(blob) || currcharge > 0;
	}
	
	void onRender(CBlob@ blob, CBlob@ user)
	{
		if(user.isMyPlayer())
		{
			if (getHUD().hasButtons())
			{
				getHUD().SetDefaultCursor();
			}
			else if(currcharge == 0)
			{
				CGunEquipment::onRender(blob, user);
			}
			else
			{
				getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-32, -32));
				
				int frame = 0;
				
				if(currcharge > 0 && maxcharge != 0)
					frame = 1 + float(currcharge) / float(maxcharge) * 7;
				if(currcharge >= maxcharge)
					frame = 9;
				if(currcharge == 0)
					frame = 0;
				getHUD().SetCursorFrame(frame);
			}
		}
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{
		if(user.isMyPlayer())
		{
			getHUD().SetDefaultCursor();
		}
		
		currcharge = 0;
		CGunEquipment::onUnequip(blob, user);
	}
	
}


