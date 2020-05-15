#include "EquipmentCore.as";
#include "CHitters.as";
#include "MaterialCommon.as";
#include "ParticleSparks.as";
#include "DamageModCommon.as";
#include "WorldRenderCommon.as";
#include "RunnerCommon.as";
#include "ExplosionCommon.as";

class CFiringData
{
	int piercesleft;
	float endpoint;
	bool addedtiledam;
	float rangeleft;
	bool donehits;
	CBlob@ lasthit;
	bool neednewtarg;
	bool hastarget;
	CBlob@ currtarg;
	
	CFiringData(int piercesleft, float endpoint, bool addedtiledam, float rangeleft, bool donehits, CBlob@ lasthit, bool neednewtarg)
	{
		this.piercesleft = piercesleft;
		this.endpoint = endpoint;
		this.addedtiledam = addedtiledam;
		this.rangeleft = rangeleft;
		this.donehits = donehits;
		@(this.lasthit) = lasthit;
		this.neednewtarg = neednewtarg;
		hastarget = false;
		@currtarg = null;
	}
}

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
	float currtiledam;
	float homingrange;
	
	float currrecoil;
	float recoilrec;
	
	int hittype;
	int reloadprog;
	int blobpiercing;
	
	bool texture;
	bool semiready;
	
	string ammoguifile;
	Vec2f ammoguisize;
	int lastammo;
	
	array<gunHitBlob@>@ blobfx;
	array<gunHitTile@>@ tilefx;
	
	bool remakegui;
	
	int ammobak;	//Because I didnt pass the equipment blob to damage mods ughhhh
	
	float fixedspread; //Spread between each individual shot
	
	bool userissound; //Used for vehicles mainly, cause cant have multiple emit sounds in one so we turn user into sound emitter
	
	CGunEquipment(float damage, int firerate, int shotcount, float spread)
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
		hittype = /*CHitters::bullet*/ 0;
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
		currtiledam = 0.0;
		homing = true;
		blobpiercing = 0;
		
		currrecoil = 0;
		recoilrec = 0.5;
		
		texture = false;
		semiready = true;
		
		ammoguifile = "AmmoGUIPistol.png";
		ammoguisize = Vec2f(5, 8);
		lastammo = -1;
		remakegui = true;
		
		@blobfx = @array<gunHitBlob@>();
		@tilefx = @array<gunHitTile@>();
		
		ammobak = 0;
		fixedspread = 0;
		
		userissound = true;
	}
	
	void onRender(CBlob@ blob, CBlob@ user)
	{
		if(user.isMyPlayer())
		{
			CControls@ controls = getControls();
			CCamera@ camera = getCamera();
			if(camera !is null && controls !is null)
			{
				int currammo = blob.get_u16("ammo" + cmdstr);
				//--------Cursor rendering----
				Vec2f diff = controls.getMouseWorldPos() - user.getPosition();
				float dist = Maths::Min(diff.Length(), range);
				Vec2f maxdistpoint = Vec2f_lengthdir_deg(dist, -diff.Angle()) + user.getPosition();
				float pointdist = Vec2f_lengthdir_deg(dist, -(spread + currrecoil)).y;
				//pointdist /= camera.targetDistance;
				
				Vec2f point1 = maxdistpoint + Vec2f_lengthdir_deg(pointdist / 2, (-diff.Angle()) - 90);
				Vec2f point2 = maxdistpoint + Vec2f_lengthdir_deg(pointdist / 2 - 15 / camera.targetDistance, (-diff.Angle()) - 90);
				GUI::DrawLine(point1, point2, SColor(255, 255, 255, 255));
				
				point1 = maxdistpoint + Vec2f_lengthdir_deg(pointdist / 2, (-diff.Angle()) + 90);
				point2 = maxdistpoint + Vec2f_lengthdir_deg(pointdist / 2 - 15 / camera.targetDistance, (-diff.Angle()) + 90);
				GUI::DrawLine(point1, point2, SColor(255, 255, 255, 255));
				
				
				const int imagex = 272;
				int bulperlayer = imagex / (ammoguisize.x - 1);
					
				int imagey = ammoguisize.y * (maxammo / bulperlayer + 1);
				
				//-----Ammo rendering----
				//Hey cool i did stuff with imagedata and i didnt want to die
				Vec2f startpos = /*controls.getMouseScreenPos() - Vec2f(64, 128)*/ Vec2f_zero;
				Vec2f offspos(0, 0);
				string texname = "AmmoGUIData";
				const float scale = 1;
				
				if(currammo != lastammo || remakegui)
				{
					if(reloadprog > 0)
						currammo = maxammo * (1.0 - (float(reloadprog) / reloadtime));
				
					int ammorange = Maths::Abs(lastammo - currammo);
					int ammostart = Maths::Max(currammo - ammorange, 0);
					int ammoend = Maths::Min(currammo + ammorange, maxammo);
					if(remakegui)
					{
						ammostart = 0;
						ammoend = maxammo;
						print("remak");
					}
					
					
					
					lastammo = currammo;
					if(!Texture::exists(ammoguifile))
					{
						if(!Texture::createFromFile(ammoguifile, ammoguifile))
							print("oh this is a problem");
					}
					ImageData@ baseimage = Texture::data(ammoguifile);
					//if(!Texture::createBySize(texname, 32, 16))
						//print("ohno");
					ImageData@ newimage;
					if(remakegui)
					{
						Texture::destroy(texname);
						print("texdes");
					}
					if(Texture::exists(texname))
						@newimage = Texture::data(texname);
					else
						@newimage = @ImageData(imagex + 16, imagey);	
					
					remakegui = false;
					
					//This is dumb, oh well
					
					offspos = Vec2f((ammostart % bulperlayer) * (ammoguisize.x - 1), (ammostart / bulperlayer) * (ammoguisize.y - 1));
					
					/*for(int i = 0; i < ammostart; i++)
					{
						offspos.x += ammoguisize.x - 1;
						if(offspos.x >= imagex)
						{
							offspos.x = 0;
							offspos.y += ammoguisize.y - 1;
						}
					}*/
					
					for(int i = ammostart; i < ammoend; i++)
					{
						Vec2f startpos = Vec2f((currammo > i ? 1 : 0) * ammoguisize.x, 0);
						Vec2f endpos = startpos + ammoguisize;
						
						for(int x = startpos.x; x < endpos.x; x++)
						{
							for(int y = startpos.y; y < endpos.y; y++)
							{
								SColor pixcol = baseimage.get(x, y);
								Vec2f thispos = (Vec2f(x, y) - startpos) + offspos;
								if(pixcol.getAlpha() > 0)
									newimage.put(thispos.x, thispos.y, pixcol);
							}
						}
						
						offspos.x += ammoguisize.x - 1;
						if(offspos.x >= imagex)
						{
							offspos.x = 0;
							offspos.y += ammoguisize.y - 1;
						}
					}
					
					if(Texture::exists(texname))
						Texture::update(texname, newimage);
					else
						Texture::createFromData(texname, newimage);
				}
				//GUI::DrawIcon(texname, 0, Vec2f(272, 48), startpos, scale);
				
				//GUI::DrawIconDirect(texname, startpos, Vec2f_zero, Vec2f(272, 48));
				
				//GUI::DrawIconByName(texname, startpos, scale);
				
				array<Vertex> verts;
				verts.push_back(Vertex(startpos, 0, Vec2f_zero, SColor(255, 255, 255, 255)));
				verts.push_back(Vertex(startpos + Vec2f(imagex + 16, 0) * scale * 2, 0, Vec2f(1, 0), SColor(255, 255, 255, 255)));
				verts.push_back(Vertex(startpos + Vec2f(imagex + 16, imagey) * scale * 2, 0, Vec2f(1, 1), SColor(255, 255, 255, 255)));
				verts.push_back(Vertex(startpos + Vec2f(0, imagey) * scale * 2, 0, Vec2f(0, 1), SColor(255, 255, 255, 255)));
				
				addVertsToExistingRender(@verts, texname, "RLgui");
			}
			
			if (getHUD().hasButtons())
			{
				getHUD().SetDefaultCursor();
			}
			else
			{
				getHUD().SetCursorImage("Sprites/GunCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-32, -32));
				/*
				int frame = 0;
				if(reloadprog > 0)
				{
					float currcoolratio = 1.0 - float(Maths::Abs(reloadprog)) / float(reloadtime);
					if(reloadprog < reloadtime)
						frame = Maths::Min(1 + currcoolratio * 8, 9);
					if(reloadprog == reloadtime)
						frame = 8;
					if(reloadprog == 0)
						frame = 0;
				}
				else
				{
					float ammo = float(blob.get_u16("ammo"));
					if(ammo > 0 && maxammo != 0)
						frame = 1 + ammo / float(maxammo) * 8;
					if(ammo >= maxammo)
						frame = 9;
					if(ammo == 0)
						frame = 0;
				}
				getHUD().SetCursorFrame(frame);*/
			}
		}
	}
	
	void standardTickJunk(CBlob@ blob, CBlob@ user)
	{
		if(cooldown >= 0)
			cooldown--;
		
		if(user !is null)
		{
			bool actionkey = (semi ? 
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) && semiready :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) && semiready :
							user.isKeyPressed(key_action1) && semiready)
							:
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1)));
								
			if(user.isKeyJustReleased(attachedPoint == "FRONT_ARM" ? key_action1 : attachedPoint == "BACK_ARM" ? key_action2 : key_action1))
				semiready = true;
										
			
			//if(cooldown < 0 && reloadprog <= 0)
				currrecoil = Maths::Max(Maths::Min(currrecoil - recoilrec, currrecoil / ((recoilrec / 4.0) + 1)), 0);
			
			if(blob !is null)
			{
				angle = (((user.getAimPos() - user.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
			}
			
			if(reloadprog > 0)
			{
				reloadprog--;
			}
			
			if(cooldown < 0 || cooldown < firerate - 5)
			{
				if(userissound)
					user.getSprite().SetEmitSoundPaused(true);
				else
					blob.getSprite().SetEmitSoundPaused(true);
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
		/*CControls@ controls = getControls();
		if(controls !is null)
		{
			Vec2f recoilpos = Vec2f(XORRandom(recoil) - recoil / 2, XORRandom(recoil) - recoil / 2) * intensity;
			recoilpos *= (controls.getMouseWorldPos() - user.getPosition()).Length() / 100.0;
			recoilpos += controls.getMouseScreenPos();
			recoilpos.x = Maths::Max(0, Maths::Min(recoilpos.x, getScreenWidth()));
			recoilpos.y = Maths::Max(0, Maths::Min(recoilpos.y, getScreenHeight()));
			controls.setMousePosition(recoilpos);
		}*/
		currrecoil += recoil * intensity;
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		standardTickJunk(blob, user);
		
		if(user !is null)
		{
		
			bool actionkey = (semi ? 
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) && semiready :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) && semiready :
							user.isKeyPressed(key_action1) && semiready)
							:
							(attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1)));
							
							
										
							
			if(actionkey && blob !is null && cooldown < 0 && (user is getLocalPlayerBlob() || (user.getPlayer() is null && isServer())) && reloadprog <= 0)
			{
				
				semiready = false;
				fireWeapon(blob);
				if(blob.get_u16("ammo" + cmdstr) > 0)
				{
					doRecoil(user);
				}
					 
			}
		}
	}
	
	bool isActive(CBlob@ blob, CBlob@ user)
	{
		return cooldown >= 0 || reloadprog > 0;
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
					int consumed = Maths::Min(item.getQuantity(), maxammo - blob.get_u16("ammo" + cmdstr));
					if(consumed < item.getQuantity())
						item.server_SetQuantity(item.getQuantity() - consumed);
					else
						item.server_Die();
					gotammo = true;
					blob.add_u16("ammo" + cmdstr, consumed);
					if(blob.get_u16("ammo" + cmdstr) >= maxammo)
						break;
				}
			}
		}
		blob.set_u16("ammo" + cmdstr, maxammo);
		ammobak = maxammo;
		return true;
	}
	
	void startReload(CBlob@ blob, CBlob@ user)
	{
		//if(maxammo > blob.get_u16("ammo") && reloadprog <= 0)
		{
			if(getAmmo(blob, user))
				reloadprog = reloadtime;
			blob.Sync("ammo" + cmdstr, true);
		}
	}
	
	void fireWeapon(CBlob@ blob)
	{
		u32 seed = XORRandom(0x7FFFFFFF);
		CBitStream params;

		params.write_u32(firecmdbits);
		
		params.write_u32(seed);
		params.write_f32(angle);
		
		params.write_f32(currrecoil);
		
		blob.SendCommand(blob.getCommandID(cmdstr), params);
		
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
		blob.SendCommand(blob.getCommandID(cmdstr), params);
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
				CSpriteLayer@ layer = (texture ? usersprite.addTexturedSpriteLayer("equipgunfx", sprite.getTextureName() + "hnd", sprite.getFrameWidth(), sprite.getFrameHeight()) :
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
		if(blob.getTeamNum() != user.getTeamNum() && (blob.hasTag("flesh") || blob.hasTag("solid")) && !blob.isAttachedTo(user) && blob.getHealth() > 0)
			return true;
		return false;
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		if(bits == firecmdbits && user !is null)
		{
			if(blob.get_u16("ammo" + cmdstr) == 0)
			{
				if(isServer()) sendReloadCommand(blob);
				return bits;
			}
			else if(reloadprog > 0)
				return bits;
			else
			{
				//if(isServer())
					blob.sub_u16("ammo" + cmdstr, 1);
				ammobak = blob.get_u16("ammo" + cmdstr);
				//blob.Sync("ammo", true);
			}
			
			CMap@ map = getMap();
			bits &= ~firecmdbits;
			u32 seed = params.read_u32();
			Random random(seed);
			f32 aimdef = params.read_f32();
			lastshotrotation = aimdef;
			fixedsprite = false;
			float shotrecoil = params.read_f32();
			
			Vec2f kickdir(-1, 0);
			kickdir.RotateBy(aimdef);
			user.setVelocity(user.getVelocity() + kickdir * kick);
			
			//Sound::Play("StandardFire.ogg", user.getPosition(), 1.0f, 0.95 + XORRandom(10) / 100.0);
			if(userissound)
			{
				user.getSprite().SetEmitSoundPaused(false);
				user.getSprite().RewindEmitSound();
			}
			else
			{
				blob.getSprite().SetEmitSoundPaused(false);
				blob.getSprite().RewindEmitSound();
			}
			
			if(user !is getLocalPlayerBlob())
				cooldown = firerate;
				
			//How homing is going to work:
			//Get blobs in homing range + gun range
			//Rotate all blobs and shoot dir so that it's straight upwards
			//if blob's Y is above or below the line, discard
			//if blob's abs x is greater than  homing range, discard
			//then get first blob in list, home to that
			f32 recinacc = (random.NextFloat() * (shotrecoil)) - (shotrecoil) / 2.0;;
			
			for (uint x = 0; x < shotcount; x++)
			{
				float shotspread = (float(x) - float(shotcount - 1) / 2.0) * fixedspread;
				f32 offset = (random.NextFloat() * (spread)) - (spread) / 2.0 + recinacc + shotspread;
				f32 aimdir = aimdef + offset;
				
				if(homingrange > 0)
				{
					//print("homing");
					//bool hastarget = false;
					CBlob@ currtarg = null;
					Vec2f currpos = user.getPosition();
					bool cantfind = false;
					int errorlp = 10000;
					CFiringData firedata(blobpiercing, range, false, range, false, null, true);
					while (firedata.rangeleft > 0 && !firedata.donehits && errorlp > 0)
					{
						//Adjusting gun angle, to curve
						cantfind = homingAdjustment(user, @firedata, currpos, aimdir, aimdir);
						
						//Hitting stuff
						
						if(cantfind)
						{
							firedata.endpoint = firedata.rangeleft + 1;
						}
						
						HitInfo@[] hitInfos;
						if (map.getHitInfosFromRay(currpos, aimdir, firedata.endpoint, user, @hitInfos))
						{
							handleHitInfos(user, currpos, @hitInfos, aimdir, @firedata);
						}
						
						if(getNet().isClient())
						{	
							Vec2f startpoint = currpos;
							addTracers(startpoint, aimdir, firedata.endpoint);
						}
						firedata.rangeleft -= firedata.endpoint;
						float rotation = (aimdir / 180.0) * Maths::Pi;
						currpos += Vec2f(Maths::Cos(rotation) * firedata.endpoint, Maths::Sin(rotation) * firedata.endpoint);
					}
				}
				//---------------------NON HOMINH-------------------
				else
				{
					float endpoint = range;
					HitInfo@[] hitInfos;
					if (map.getHitInfosFromRay(user.getPosition(), aimdir, range, user, @hitInfos))
					{
						CFiringData firedata(blobpiercing, endpoint, false, 999, false, null, true);
						handleHitInfos(user, user.getPosition(), @hitInfos, aimdir, @firedata);
						
						endpoint = firedata.endpoint;
					}
					if(getNet().isClient())
					{	
						Vec2f startpoint = user.getPosition();
						addTracers(startpoint, aimdir, endpoint);
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
	
	void handleHitInfos(CBlob@ user, Vec2f currpos, array<HitInfo@>@ hitInfos, float aimdir, CFiringData@ firedata)
	{
		for (int i = 0; i < hitInfos.length; i++)
		{
			CMap@ map = getMap();
			HitInfo@ last = hitInfos[hitInfos.length - 1];
			//print("loops");
			//-----------------------PIERCE BLOCKS-------------------------
			if(last.blob is null && map.getSectorAtPosition(last.hitpos, "no build") is null)
			{
				//print("map");
				

				TileType tile = last.tile;
				doTileHitEffects(user, last.hitpos, aimdir, damage);
				
				Vec2f tilepos = last.hitpos;
				int lc = 0;
				//Hit ray checks in steps of 4, so maxLC * step should  = 4
				//print("" + getRenderExactDeltaTime());
				while(map.getTile(tilepos).flags & Tile::SOLID == 0 && lc < 10)//Weird  ray bug, can get the wrong tile
				{
					tilepos -= Vec2f_lengthdir_deg(0.4, aimdir);
					lc++;
				}
				//print("" + getRenderExactDeltaTime());
				//print("LC: " + lc);
				/*if(lc == 10)
				{
					//printVec2f("Realpos:", last.hitpos);
					//printVec2f("Chkpos:", tilepos);
				
					array<Vertex> vertlist;
					
					vertlist.push_back(Vertex(last.hitpos.x - 0.5, last.hitpos.y - 0.5, 0, 0, 0, SColor(255, 100, 255, 100)));
					vertlist.push_back(Vertex(last.hitpos.x + 0.5, last.hitpos.y - 0.5, 0, 1, 0, SColor(255, 100, 255, 100)));
					vertlist.push_back(Vertex(last.hitpos.x + 0.5, last.hitpos.y + 0.5, 0, 1, 1, SColor(255, 100, 255, 100)));
					vertlist.push_back(Vertex(last.hitpos.x - 0.5, last.hitpos.y + 0.5, 0, 0, 1, SColor(255, 100, 255, 100)));
					
					vertlist.push_back(Vertex(tilepos.x - 0.5, tilepos.y - 0.5, 0, 0, 0, SColor(255, 255, 100, 100)));
					vertlist.push_back(Vertex(tilepos.x + 0.5, tilepos.y - 0.5, 0, 1, 0, SColor(255, 255, 100, 100)));
					vertlist.push_back(Vertex(tilepos.x + 0.5, tilepos.y + 0.5, 0, 1, 1, SColor(255, 255, 100, 100)));
					vertlist.push_back(Vertex(tilepos.x - 0.5, tilepos.y + 0.5, 0, 0, 1, SColor(255, 255, 100, 100)));
					
					addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLtick");
				}*/
				
				if(!firedata.addedtiledam)
					currtiledam += tiledamagechance;
				firedata.addedtiledam = true;
				//float damthistime = 0.0;
				bool nextloop = false;
				while(currtiledam >= 1.0)
				{
					currtiledam -= 1.0;
					//damthistime += 1.0;
					map.server_DestroyTile(tilepos, 1.0f, user);
					//print("hit");
					if(map.getTile(tilepos).flags & Tile::SOLID == 0)
					{
						hitInfos.clear();
						map.getHitInfosFromRay(currpos, aimdir, firedata.endpoint, user, @hitInfos);
						
						i = -1;
						nextloop = true;
						break;
					}
					/*else
					{
						firedata.rangeleft = -1;
						firedata.donehits = true;
					}*/
				}
				if(nextloop)
					continue;
				firedata.endpoint = (last.hitpos - currpos).Length();
			}
			
			
			//--------------------------------------------------------------------------------------------------
			
			
			
			HitInfo@ hi = hitInfos[i];

			if (hi.blob is null) // map
			{
				firedata.endpoint = (hi.hitpos - currpos).Length();
				firedata.rangeleft = -1;
			}
			else // blob
			{
				if(isValidTarget(hi.blob, user))
				{
					float tempdamage = doBlobHitEffects(user, hi.blob, hi.hitpos, aimdir, damage);
					user.server_Hit(hi.blob, hi.hitpos, hi.blob.getPosition() - currpos, calcAllDamageMods(user, hi.blob, tempdamage, hittype), hittype);
					firedata.neednewtarg = true;
					@firedata.lasthit = @hi.blob;
					if(firedata.piercesleft <= 0)
					{
						firedata.rangeleft = -1;
						firedata.donehits = true;
						firedata.endpoint = (hi.hitpos - currpos).Length();
						break;
					}
					firedata.piercesleft--;
				}
			}
		}
	}
	
	bool homingAdjustment(CBlob@ user, CFiringData@ firedata, Vec2f currpos, float aimdir, float &out angleout)
	{
		CMap@ map = getMap();
		bool cantfind = true;
		const float steplength = 10;
		if(!firedata.hastarget || firedata.neednewtarg)
		{
			CBlob@[] bloblist;
			array<Vec2f> poslist;
			if(map.getBlobsInRadius(currpos, firedata.rangeleft + homingrange, @bloblist))
			{
				for (uint i = 0; i < bloblist.length; i++)
				{
					Vec2f nextpos = currpos - bloblist[i].getPosition();
					nextpos.RotateBy(-(aimdir - 90));
					nextpos.y *= -1;
					poslist.push_back(nextpos);
				}
				float closest = 9999;
				for (uint i = 0; i < bloblist.length; i++)
				{
					Vec2f thispos = poslist[i];
					//printVec2f(bloblist[i].getName(), thispos);
					if(thispos.y > 0 && thispos.y < firedata.rangeleft && Maths::Abs(thispos.x) <= homingrange && isValidTarget(bloblist[i], user) && firedata.currtarg !is bloblist[i] && firedata.lasthit !is bloblist[i] && Maths::Abs(thispos.x) < closest)
					{
						firedata.hastarget = true;
						firedata.neednewtarg = false;
						cantfind = false;
						@firedata.currtarg = @bloblist[i];
						closest = Maths::Abs(thispos.x);
						//break;
					}
				}
			}
		}
		else
		{
			cantfind = false;
		}
		//Rotating bullet
		if(firedata.currtarg !is null && !cantfind)
		{
			float targang = ((firedata.currtarg.getPosition() - currpos).Angle() * -1) + 360;
			//Max degrees to turn per step
			float anglediff = Maths::Abs(aimdir - targang) % 360;
			
			float currturn = (anglediff / ((firedata.currtarg.getPosition() - currpos).Length() / float(steplength))) * 1.1;
			if(anglediff > 180)
				currturn = ((360 - anglediff) / ((firedata.currtarg.getPosition() - currpos).Length() / float(steplength))) * 1.1;
			
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
		firedata.endpoint = steplength;
		angleout = aimdir;
		return cantfind;
	}
	
	void addTracers(Vec2f startpos, float angle, float dist)
	{
		array<Vertex> vertlist;
						
		float perp = ((angle / 180.0) * Maths::Pi) + Maths::Pi / 2;
		Vec2f perpoffs(Maths::Cos(perp) * tracerwidth, Maths::Sin(perp) * tracerwidth);
		Vec2f endvec = startpos + Vec2f(Maths::Cos(((angle / 180.0) * Maths::Pi)), Maths::Sin(((angle / 180.0) * Maths::Pi))) * dist;
		
		vertlist.push_back(Vertex(startpos.x - perpoffs.x, startpos.y - perpoffs.y, 0, 0, 0, tracercolor));
		vertlist.push_back(Vertex(endvec.x - perpoffs.x, endvec.y - perpoffs.y, 0, 1, 0, tracercolor));
		vertlist.push_back(Vertex(endvec.x + perpoffs.x, endvec.y + perpoffs.y, 0, 1, 1, tracercolor));
		vertlist.push_back(Vertex(startpos.x + perpoffs.x, startpos.y + perpoffs.y, 0, 0, 1, tracercolor));
		
		addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLtick");
	}
	
	void onEquip(CBlob@ blob, CBlob@ user)
	{
		//CMechCore::onAttach(blob, user);
		remakegui = true;
		if(userissound)
			user.getSprite().SetEmitSound("StandardFire.ogg");
		else
			blob.getSprite().SetEmitSound("StandardFire.ogg");
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{		
		remakegui = true;
		if(userissound)
			user.getSprite().SetEmitSoundPaused(true);
		else
			blob.getSprite().SetEmitSoundPaused(true);
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
		
			bool actionkey = (semi ? user.isKeyPressed(key_action1) && semiready : 
																		   
																		 
										  
		
								user.isKeyPressed(key_action1));
								
			if(!actionkey || reloadprog > 0)
				 
				spooltime -= spoolspeed;
				
							
			if(actionkey && blob !is null && cooldown < 0 && user is getLocalPlayerBlob() && reloadprog <= 0)
			{
				spooltime += spoolspeed;
				spooltime = Maths::Min(spoollimit, spooltime);
				spooltime = Maths::Max(0, spooltime);
			
				if(user is getLocalPlayerBlob())
				{
					if(blob.get_u16("ammo" + cmdstr) > 0)
					{
						doRecoil(user);
					}
					fireWeapon(blob);
					cooldown = firerate - spooltime;
					semiready = false;
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
	
	float exponent;
	
	CChargeGunEquipment(float damage, int firerate, int shotcount, float spread, int mincharge, int maxcharge)
	{
		super(damage, firerate, shotcount, spread);
		basedamage = damage;
		basetracerwidth = 0.5;
		this.mincharge = mincharge;
		this.maxcharge = maxcharge;
		currcharge = 0;
		exponent = 1;
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		standardTickJunk(blob, user);
		
		if(user !is null)
		{
																				   
			bool actionkey = user.isKeyPressed(key_action1);
									  

			
			
			
			if(!actionkey && currcharge > 0)
			{
				float chargeratio = float(currcharge) / float(maxcharge);
				chargeratio *= Maths::Pow(exponent, currcharge);
				if(currcharge >= mincharge)
				{
					angle = (((user.getAimPos() - user.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
			
					if(user is getLocalPlayerBlob())
					{
					 
						u32 seed = XORRandom(0x7FFFFFFF);
						CBitStream params;
						params.write_u32(firecmdbits);
						
						params.write_f32(chargeratio);
						
						params.write_u32(seed);
						params.write_f32(angle);
						params.write_f32(currrecoil);
						
						//print("CMD Sent");
						blob.SendCommand(blob.getCommandID(cmdstr), params);
						doRecoil(user);
					}
					cooldown = firerate;
				}
				currcharge = 0;
			}
				
			
			if(actionkey && blob !is null && cooldown < 0 && reloadprog <= 0 && blob.get_u16("ammo" + cmdstr) > 0)
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
						   
	
										
	
			//else if(currcharge == 0)
			//{
			//	CGunEquipment::onRender(blob, user);
			//}
			else
			{
				CGunEquipment::onRender(blob, user);
				getHUD().SetCursorImage("Sprites/GunCursor.png", Vec2f(32, 32));
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


