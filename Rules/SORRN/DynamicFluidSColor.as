//Fluid simulation
//Krilling myself

//It was mentioned before that SColor arrays are fancy and special and fast
//So maybe if I replace everything with that and just use the 32 bits provided I can make this run at an acceptable speed

//As of the time of writing most things are working
//Except our logic thinks the water do no existe????????
//So it doesnt tick

#include "RenderParticleCommon.as";
#include "WorldRenderCommon.as";
#include "DynamicFluidCommon.as";






void onInit(CRules@ this)
{
	this.addCommandID("waterupdate");
	this.addCommandID("spawnwater");
	this.addCommandID("removewater");
	onRestart(this);
	//In staging the object render layer is affected by the lightmap
	//Partially hmm
	Render::addScript(Render::layer_objects, "DynamicFluidSColor.as", "renderWater", 0);
}

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		array<array<SColor>>@ waterdata;
		array<bool>@ activelayers;
		array<bool>@ activecolumns;

		map.get("waterdata", @waterdata);
		map.get("activelayers", @activelayers);
		map.get("activecolumns", @activecolumns);

		//NOTE: This usually does not run due to the vars being set in maploader
		if(waterdata is null || waterdata[0].size() != map.tilemapwidth || waterdata.size() != map.tilemapheight)
		{
			print("poo");
			//NOTE: Y and X have been flipped for performance reasons
			@waterdata = @array<array<SColor>>(map.tilemapheight, array<SColor>(map.tilemapwidth, SColor(0, 0, 0, 0)));
			@activelayers = @array<bool>(map.tilemapheight, false);
			@activecolumns = @array<bool>(map.tilemapwidth, false);
		}
	
		map.AddScript("DynamicFluidSColor.as");
		
		map.set("waterdata", @waterdata);
		map.set("activelayers", @activelayers);
		map.set("activecolumns", @activecolumns);
	}
}

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	//if(newtile == 0)
	if(isServer())
	{
		array<array<SColor>>@ waterdata;
		array<bool>@ activelayers;
		array<bool>@ activecolumns;

		this.get("waterdata", @waterdata);
		this.get("activelayers", @activelayers);
		this.get("activecolumns", @activecolumns);

		if(waterdata is null || activelayers is null || activelayers.size() != this.tilemapheight || activecolumns.size() != this.tilemapwidth)
			return;

		Vec2f pos(index % this.tilemapwidth, index / this.tilemapwidth);
			waterdata[pos.y][pos.x] = setWaterA(true, waterdata[pos.y][pos.x]);
		if(pos.x < this.tilemapwidth - 1)
			waterdata[pos.y][pos.x + 1] = setWaterA(true, waterdata[pos.y][pos.x + 1]);
		if(pos.x > 0)
			waterdata[pos.y][pos.x - 1] = setWaterA(true, waterdata[pos.y][pos.x - 1]);
		if(pos.y < this.tilemapheight - 1)
			waterdata[pos.y + 1][pos.x] = setWaterA(true, waterdata[pos.y + 1][pos.x]);
		if(pos.y > 0)
			waterdata[pos.y - 1][pos.x] = setWaterA(true, waterdata[pos.y - 1][pos.x]);

		activelayers[pos.y] = true;
		activecolumns[pos.x] = true;
		if(pos.y > 0)
			activelayers[pos.y - 1] = true;
		if(pos.y < this.tilemapheight)
			activelayers[pos.y + 1] = true;
		if(pos.x > 0)
			activecolumns[pos.x - 1] = true;
		if(pos.x < this.tilemapwidth)
			activecolumns[pos.x + 1] = true;
	}
}

void onTick(CRules@ this)
{
	CControls@ con = getControls();
	//if(!con.isKeyJustPressed(KEY_KEY_N))
		//return;
	
	CMap@ map = getMap();
	array<array<SColor>>@ waterdata;
	array<bool>@ activelayers;
	array<bool>@ activecolumns;
	map.get("waterdata", @waterdata);
	map.get("activelayers", @activelayers);
	map.get("activecolumns", @activecolumns);

	array<CBlob@> blobs;
	getBlobs(@blobs);
	if(blobs !is null)
	{
		for(int i = 0; i < blobs.size(); i++)
		{
			CBlob@ blob = @blobs[i];
			Vec2f pos = blob.getPosition() / map.tilesize;
			CShape@ shape = blob.getShape();
			if(shape !is null && !blob.isInInventory() && pos.y >= 0 && pos.y < waterdata.size() && pos.x >= 0 && pos.x < waterdata[0].size())
			{
				if(waterdata[pos.y][pos.x].getRed() > 0)
				{
					if(!shape.getVars().inwater && blob.getOldVelocity().Length() > 2.5)
					{
						//print("vel: " + blob.getOldVelocity().Length());
						//print("x: " + blob.getOldVelocity().x + " y: " + blob.getOldVelocity().y);
						Sound::Play(blob.getOldVelocity().Length() > 4.5 ? "SplashSlow.ogg" : "SplashFast.ogg", blob.getPosition(), blob.getOldVelocity().Length() / 3.0);
						map.SplashEffect(blob.getPosition(), blob.getOldVelocity() * -1, shape.getWidth() / 2.0);
					}
					
					shape.getVars().inwater = true;
					blob.setVelocity(blob.getVelocity() * ((shape.getDrag() - 1) / 30.0 + 1));
					
					//Ya know, nvm boats are just gonna be a little funky ok
					if(blob.hasTag("vehicle"))
					{
						float buoymult = 0.33;	//0.33 == 1/3 don't @ me
						float range = shape.getWidth() * 0.45;
						Vec2f checkside(range, 0);
						checkside.RotateByDegrees(blob.getAngleDegrees());
						if(dynamicIsInWater(checkside + blob.getPosition()))
						{
							blob.setAngularVelocity(blob.getAngularVelocity() - 0.1);
							buoymult += 0.33;
						}
						checkside.RotateByDegrees(180);
						if(dynamicIsInWater(checkside + blob.getPosition()))
						{
							blob.setAngularVelocity(blob.getAngularVelocity() + 0.1);
							buoymult += 0.33;
						}
						blob.setAngularVelocity(blob.getAngularVelocity() * 0.95);
						int y = blob.getPosition().y / 8.0;
						int x = blob.getPosition().x / 8.0;
						float depthmult = y > 0 ? (waterdata[y - 1][x].getRed() > 0 ? 1.0 : 1.0 - blob.getPosition().y % 1.0) : 1.0 - blob.getPosition().y % 1.0;
						blob.setVelocity(blob.getVelocity() + Vec2f(0, -shape.getConsts().buoyancy / 2.0) * buoymult * depthmult);
					}
					else 
					{
						blob.setVelocity(blob.getVelocity() + Vec2f(0, -shape.getConsts().buoyancy / 2.0));
					}
					//print("Bleh " + shape.getVars().waterDragScale);
				}
				else
				{
					
					shape.getVars().inwater = false;
				}

			} 
		}
	}

	if(!isServer())
	{
		if(con !is null && waterdata !is null)
		{
			if(con.isKeyPressed(KEY_KEY_K))
			{
				Vec2f pos = con.getMouseWorldPos() / 8;
				if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
				{
					CBitStream params;
					params.write_Vec2f(pos);
					this.SendCommand(this.getCommandID("spawnwater"), params);
				}
			}
			if(con.isKeyPressed(KEY_KEY_L))
			{
				Vec2f pos = con.getMouseWorldPos() / 8;
				if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
				{
					CBitStream params;
					params.write_Vec2f(pos);
					this.SendCommand(this.getCommandID("removewater"), params);
				}
			}
		}
		return;
	}


	
	if(con !is null)
	{
		if(con.isKeyPressed(KEY_KEY_K))
		{
			Vec2f pos = con.getMouseWorldPos() / 8;
			if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
			{
				waterdata[pos.y][pos.x] = setWaterB(true, waterdata[pos.y][pos.x]);
				waterdata[pos.y][pos.x].setRed(15);
				waterdata[pos.y][pos.x] = setWaterF(true, waterdata[pos.y][pos.x]);
				waterdata[pos.y][pos.x] = setWaterA(true, waterdata[pos.y][pos.x]);
				activelayers[pos.y] = true;
				activecolumns[pos.x] = true;

				CBitStream params;
				params.write_Vec2f(pos);
				this.SendCommand(this.getCommandID("spawnwater"), params);
			}
		}
		if(con.isKeyPressed(KEY_KEY_L))
		{
			Vec2f pos = con.getMouseWorldPos() / 8;
			if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
			{
				waterdata[pos.y][pos.x] = setWaterB(false, waterdata[pos.y][pos.x]);
				waterdata[pos.y][pos.x].setRed(0);
				waterdata[pos.y][pos.x] = setWaterF(false, waterdata[pos.y][pos.x]);
				waterdata[pos.y][pos.x] = setWaterA(true, waterdata[pos.y][pos.x]);
				activelayers[pos.y] = true;
				activecolumns[pos.x] = true;

				CBitStream params;
				params.write_Vec2f(pos);
				this.SendCommand(this.getCommandID("removewater"), params);
			}
		}
		if(!con.isKeyJustPressed(KEY_KEY_J))
		{
			//return;
		}
	}

	//Random rain spawning
	//Too laggy ATM
	int randox = XORRandom(map.tilemapwidth);
	if(false && XORRandom(30 * (1.0 - this.get_f32("rainmult") - 1.0)) == 0)
	{
		if(!map.isTileSolid(Vec2f(randox, 0)))
		{
			int y = 1;
			while ((!map.isTileSolid(Vec2f(randox, y) * 8)) && y < map.tilemapheight && waterdata[y][randox].getRed() == 0)
			{
				y++;
			}
			if(!map.isTileSolid(Vec2f(randox, y) * 8))
				addWater(Vec2f(randox * 8, (y - 1) * 8), 1);
			
		}
	}

	
	int actc = 0;	//I really should have commented earlier on what this magic number means	//NVM it's a debug print number leftover
	if(waterdata is null)
		return;
	array<bool> columnkeepactive(map.tilemapwidth, false);

	//Cache last current and next line for performance maybe
	array<SColor>@ lline = null;	//Last line
	array<SColor>@ cline = @waterdata[0];	//Current line
	array<SColor>@ nline = @waterdata[1];	//Next line

	for(int y = 0; y < waterdata.size(); y++)
	{
		if(y > 0)
			@lline = @waterdata[y - 1];
		@cline = @waterdata[y];
		if(y < waterdata.size() - 1)
			@nline = @waterdata[y + 1];
		if(!activelayers[y])
			continue;
		actc++;
		bool keepactive = false;
		for(int x = 0; x < waterdata[0].size(); x++)
		{
			if(!activecolumns[x])
				continue;
			SColor bw = cline[x];
			/*print("x do be asctruice");
			print("huh: " + bw.getBlue());	//Thats kinda weird: this reads fine if it's onrender or whatever but not here?
			print("huh2: " + bw.getRed());	//Maybe we're setting the active lines in the wrong spots?
			print("huh3??????: " + waterdata[y][x].getBlue());	//Oh cool so this works???
			print("hu4h!??: " + cline[x].getBlue());	//So the cline is wrong somehow
			Fixed itttt
			*/
			if(getWaterB(bw.getBlue()) && getWaterA(bw.getBlue()))//If water exists there basically
			{
				bool miniupdoot = false;
				//print("water existe?>????");	//water do not existe???????????????????????????????????
				bool mdt = false; //mdt = moved dis tick
				if(bw.getGreen() >= bw.getRed())
				{
					bw.setGreen(0);
					keepactive = true;
					columnkeepactive[x] = true;
					cline[x] = bw;
					continue;
				}
				int tempunused = bw.getGreen();
				//First try and move down
				if(!map.isTileSolid(Vec2f(x, y + 1) * 8) && (y + 1 >= cline.size() || !getWaterF(nline[x].getBlue())))
				{
					u8 amt = y + 1 < cline.size() ? 15 - nline[x].getRed() : 15;
					amt = Maths::Min(bw.getRed() - bw.getGreen(), amt);
					if(amt > 0)
					{
						mdt = true;
						bw.setRed(bw.getRed() - amt);
						bw = setWaterF(false, bw);
						if(bw.getRed() == 0)
						{
							bw = setWaterB(false, bw);
							miniupdoot = true;
						}
						if(y + 1 < cline.size())
						{
							SColor nlw = nline[x];	//Next Line Water
							nlw.setRed(nlw.getRed() + amt);
				
							nlw = setWaterB(true, nlw);
							//nlw.moved = true;
							nlw.setGreen(nlw.getGreen() + amt);
							nlw = setWaterA(true, nlw);	//It's okay if we're 'dirty' about A usage, it wont tick anyway if its empty
							activelayers[y + 1] = true;
							if(nlw.getRed() >= 15)
								nlw = setWaterF(true, nlw);

							if(x > 0)
								cline[x - 1] = setWaterA(true, cline[x - 1]);
							if(x + 1 < waterdata[0].size())
								cline[x + 1] = setWaterA(true, cline[x + 1]);
							if(y > 0)
							{
								lline[x] = setWaterA(true, lline[x]);
								activelayers[y - 1] = true;
							}
							keepactive = true;
							columnkeepactive[x] = true;
							nline[x] = nlw;
						}
					}
				}
				//else
				{
					//if(XORRandom(2) == 0)
					{
						if(!map.isTileSolid(Vec2f(x + 1, y) * 8) && x + 1 < waterdata[0].size() && !getWaterF(cline[x + 1].getBlue()) /*&& XORRandom(2) == 0*/)
						{
							SColor ntw = cline[x + 1];	//Next Tile Water
							s8 diff = bw.getRed() - ntw.getRed();//This is an s8 cause it makes things a little easier, no judgies
							
							if(diff > 0)
							{
								diff = Maths::Min(diff, bw.getRed() - bw.getGreen());

								mdt = true;
								
								if(diff > 0)
								{
									if((XORRandom(2) == 0 || Maths::Ceil(diff) != 1))
									{
										float divvor = 2.0;
										if(!map.isTileSolid(Vec2f(x - 1, y) * 8) && x - 1 >= 0 && !getWaterF(cline[x - 1].getBlue()) && bw.getRed() - cline[x - 1].getRed() > 0)
										{
											//diff = Maths::Ceil(diff / 3.0);
											//print("tridiv");
											//divvor = 3.0;
										}
										else
										{
											//diff = Maths::Ceil(diff / 2.0);
										}
										
										bw = setWaterF(false, bw);
										bw.setRed(bw.getRed() - Maths::Ceil(diff / divvor)) ;
	
										if(bw.getRed() == 0)
										{
											bw = setWaterB(false, bw);
											miniupdoot = true;
										}
										else if(bw.getRed() > 15)
											print("AASDASD" + diff);
							
										ntw.setRed(ntw.getRed() + Maths::Ceil(diff / divvor));
										ntw.setGreen(ntw.getGreen() + Maths::Ceil(diff / divvor));
										//ntw.setGreen(0);
										
										ntw = setWaterB(true, ntw);
										activecolumns[x + 1] = true;
										if(x > 0)
											activecolumns[x - 1] = true;
										//waterdata[x + 1][y].u += diff;
										//if(diff == 1)
											//waterdata[x + 1][y].u = 15;
										if(ntw.getRed() >= 15)
											ntw = setWaterF(true, ntw);
										
										if(x > 0)
											cline[x - 1] = setWaterA(true, cline[x - 1]);
										if(x + 1 < waterdata[0].size())
											ntw = setWaterA(true, ntw);
										if(y > 0)
										{
											lline[x] = setWaterA(true, lline[x]);
											activelayers[y - 1] = true;
										}

									
									}
									keepactive = true;
									columnkeepactive[x] = true;
									columnkeepactive[x + 1] = true;
									if(x > 0)	//This check has not been here for way too long and has caused random crashes the whole time
										columnkeepactive[x - 1] = true;
								}
							}
							cline[x + 1] = ntw;
						}
					}
					//else
					{
						if(!map.isTileSolid(Vec2f(x - 1, y) * 8) && x - 1 >= 0 && !getWaterF(cline[x - 1].getBlue()) /*&& XORRandom(2) == 0*/)
						{
							SColor ptw = cline[x - 1];	//Prev Tile Water
							s8 diff = bw.getRed() - ptw.getRed();
							//diff = Maths::Min(diff, bw.getRed() - bw.u);
							mdt = true;
							
							if(diff > 0)
							{
								diff = Maths::Min(diff, bw.getRed() - bw.getGreen());
								
								//if(XORRandom(2) == 0 || Maths::Ceil(diff / 2.0) != 1)
								if(diff > 0)
								{
									bw = setWaterF(false, bw);
									bw.setRed(bw.getRed() - Maths::Ceil(diff / 2.0)) ;
									if(bw.getRed() == 0)
									{
										bw = setWaterB(false, bw);
										miniupdoot = true;
									}
									//else if(bw.getRed() > 15)
										//print("ssssss");
									//if(x + 1 < waterdata.size())
										//if(waterdata[x + 1][y].d == bw.getRed())
											//waterdata[x + 1][y].u = 15;
									ptw.setRed(ptw.getRed() + Maths::Ceil(diff / 2.0));
									ptw = setWaterB(true, ptw);
									activecolumns[x - 1] = true;
									if(x + 1 < map.tilemapwidth)
										activecolumns[x + 1] = true;

									if(ptw.getRed() >= 15)
										ptw = setWaterF(true, ptw);

									if(x > 0)
										ptw = setWaterA(true, ptw);
									if(x + 1 < waterdata[0].size())
									{
										cline[x + 1] = setWaterA(true, cline[x + 1]);
										activecolumns[x + 1] = true;
										columnkeepactive[x + 1] = true;
									}
									if(y > 0)
									{
										lline[x] = setWaterA(true, lline[x]);
										activelayers[y - 1] = true;
									}
									keepactive = true;
									columnkeepactive[x] = true;
									columnkeepactive[x - 1] = true;
								}
							}
							cline[x - 1] = ptw;
						}
					}
				}
				if(!mdt)
					bw = setWaterA(false, bw);
				else
					bw = setWaterA(true, bw);
				//if(miniupdoot)	Very laggy ATM lets hold off
				//map.EditMiniMap(x, y);
			}
			
			else
			{
				//if(bw.getRed() > 0)
				//	print("Water error");
			}
			bw.setGreen(0);
			if(getWaterA(bw.getBlue()) && getWaterB(bw.getBlue()))
			{
				keepactive = true;
				columnkeepactive[x] = true;
			}
			cline[x] = bw;
			
		}
		if(!keepactive)
		{
			activelayers[y] = false;
			//print("Killed layer " + y);
		}
	}
	for(int i = 0; i < columnkeepactive.size(); i++)
	{
		if(!columnkeepactive[i])
			activecolumns[i] = false;
	}

	//print("" + actc);
	
	
	if(!isClient())
	{
		int fullcount = 0;
		int emptycount = 0;
		int compressedcount = 0;
		for(int y = 0; y < activelayers.size(); y++)
		{
			if((getGameTime() + y) % 5 == 0)
			{
				array<SColor>@ cline = @waterdata[y];
				if(activelayers[y] || (getGameTime() + y) % 300 == 0)
				{
					CBitStream layerstream;
					layerstream.write_u16(y);
					for(int x = 0; x < waterdata[0].size(); x++)
					{
						u8 depth = cline[x].getRed();
						if(depth == 15 && emptycount == 0)
						{
							fullcount++;
							if(fullcount >= 63 || x + 1 >= waterdata[0].size())
							{
								layerstream.write_u8(F_BIT_CMD + fullcount);
								compressedcount += fullcount;
								fullcount = 0;
							}
						}
						else if (depth == 0 && fullcount == 0)
						{
							emptycount++;
							if(emptycount >= 63 || x + 1 >= waterdata[0].size())
							{
								layerstream.write_u8(E_BIT_CMD + emptycount);
								compressedcount += emptycount;
								emptycount = 0;
							}
						}
						else
						{
							if(emptycount > 0)
							{
								layerstream.write_u8(E_BIT_CMD + emptycount);
								compressedcount += emptycount;
								emptycount = 0;
							}
							else if(fullcount > 0)
							{
								layerstream.write_u8(F_BIT_CMD + fullcount);
								compressedcount += fullcount;
								fullcount = 0;
							}
							layerstream.write_u8(cline[x].getRed());
						}
					}
					this.SendCommand(this.getCommandID("waterupdate"), layerstream);
				}
			}
		}
		//print("Tiles 'compressed': " + compressedcount);
	}
		//print("sent cmd");
}


void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	//print("hook runs");
	if(cmd == this.getCommandID("waterupdate") && !isServer())
	{
		//print("updcmd");
		array<array<SColor>>@ waterdata;
		array<bool>@ activelayers;
		array<bool>@ activecolumns;
		CMap@ map = getMap();
		map.get("waterdata", @waterdata);
		map.get("activelayers", @activelayers);
		map.get("activecolumns", @activecolumns);


		if(waterdata is null || waterdata.size() != map.tilemapheight || waterdata[0].size() != map.tilemapwidth)
		{
			@waterdata = @array<array<SColor>>(map.tilemapheight, array<SColor>(map.tilemapwidth, SColor(0, 0, 0, 0)));
			@activelayers = @array<bool>(map.tilemapheight, false);
			@activecolumns = @array<bool>(map.tilemapwidth, false);

			map.set("waterdata", @waterdata);
			map.set("activelayers", @activelayers);
			map.set("activecolumns", @activecolumns);
		}

		int y = params.read_u16();
		//for(int y = 0; y > activelayers.size(); y++)
		{
			//if(activelayers[y])
			{
				int fullcount = 0;
				int emptycount = 0;
				array<SColor>@ cline = @waterdata[y];
				for(int x = 0; x < waterdata[0].size(); x++)
				{
					if(fullcount > 0 )
					{
						cline[x].setRed(15);
						cline[x].setBlue(B_BIT | F_BIT);
						fullcount--;
						continue;
					}
					else if(emptycount > 0)
					{
						cline[x].setRed(0);
						cline[x].setBlue(0);
						emptycount--;
						continue;
					}
					u8 read_val = params.read_u8();
					if(read_val & F_BIT_CMD != 0)
					{
						fullcount = read_val & 0b00111111;
						x--;
						continue;
					}
					if(read_val & E_BIT_CMD != 0)
					{
						emptycount = read_val & 0b00111111;
						x--;
						continue;
					}
					waterdata[y][x].setRed(read_val);
					waterdata[y][x] = setWaterB(read_val > 0, waterdata[y][x]);
					waterdata[y][x] = setWaterF(read_val >= 15, waterdata[y][x]);
				}
			}
		}
	}
	if(cmd == this.getCommandID("spawnwater") && isServer())
	{
		array<array<SColor>>@ waterdata;
		array<bool>@ activelayers;
		array<bool>@ activecolumns;
		CMap@ map = getMap();
		map.get("waterdata", @waterdata);
		map.get("activelayers", @activelayers);
		map.get("activecolumns", @activecolumns);

		Vec2f pos = params.read_Vec2f();
		if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
		{
			waterdata[pos.y][pos.x] = setWaterB(true, waterdata[pos.y][pos.x]);
			waterdata[pos.y][pos.x].setRed(15);
			waterdata[pos.y][pos.x] = setWaterF(true, waterdata[pos.y][pos.x]);
			waterdata[pos.y][pos.x] = setWaterA(true, waterdata[pos.y][pos.x]);
			activelayers[pos.y] = true;
			activecolumns[pos.x] = true;
		}
	}
	if(cmd == this.getCommandID("removewater") && isServer())
	{
		array<array<SColor>>@ waterdata;
		array<bool>@ activelayers;
		array<bool>@ activecolumns;
		CMap@ map = getMap();
		map.get("waterdata", @waterdata);
		map.get("activelayers", @activelayers);
		map.get("activecolumns", @activecolumns);

		Vec2f pos = params.read_Vec2f();
		if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata[0].size() && pos.y < waterdata.size())
		{
			waterdata[pos.y][pos.x] = setWaterB(false, waterdata[pos.y][pos.x]);
			waterdata[pos.y][pos.x].setRed(0);
			waterdata[pos.y][pos.x] = setWaterF(false, waterdata[pos.y][pos.x]);
			waterdata[pos.y][pos.x] = setWaterA(true, waterdata[pos.y][pos.x]);

			if(pos.x < waterdata[0].size() - 1)
				waterdata[pos.y][pos.x + 1] = setWaterA(true, waterdata[pos.y][pos.x + 1]);
			if(pos.x > 0)
				waterdata[pos.y][pos.x - 1] = setWaterA(true, waterdata[pos.y][pos.x - 1]);
			if(pos.y < waterdata.size() - 1)
				waterdata[pos.y + 1][pos.x] = setWaterA(true, waterdata[pos.y + 1][pos.x]);
			if(pos.y > 0)
				waterdata[pos.y - 1][pos.x] = setWaterA(true, waterdata[pos.y - 1][pos.x]);

			activelayers[pos.y] = true;
			activecolumns[pos.x] = true;
			if(pos.y > 0)
				activelayers[pos.y - 1] = true;
			if(pos.y < waterdata.size())
				activelayers[pos.y + 1] = true;
			if(pos.x > 0)
				activecolumns[pos.x - 1] = true;
			if(pos.x < waterdata[0].size())
				activecolumns[pos.x + 1] = true;
		}
	}
}

void onRender(CRules@ this)
{
	CMap@ map = getMap();
	array<array<SColor>>@ waterdata;
	array<bool>@ activelayers;
	array<bool>@ activecolumns;
	SMesh@ mesh;

	map.get("waterdata", @waterdata);
	map.get("activelayers", @activelayers);
	map.get("activecolumns", @activecolumns);
	map.get("watermesh", @mesh);

	if(mesh is null)
	{
		@mesh = @SMesh();
		map.set("watermesh", @mesh);
	}

	
	if(waterdata is null)
		return;
	{
		array<Vertex> vertlist;
		CCamera@ cam = getCamera();
		CControls@ cont = getControls();
		
		//print("" + cam.targetDistance);

		const int maxy = Maths::Min(waterdata.size(), (cam.getPosition().y + 384 / (cam.targetDistance * 2)) / 8);
		const int maxx = Maths::Min(waterdata[0].size(), (cam.getPosition().x + 640 / (cam.targetDistance * 2)) / 8);
		const int startx = Maths::Max(0, (cam.getPosition().x - 640 / (cam.targetDistance * 2)) / 8);
		const int starty = Maths::Max(0, (cam.getPosition().y - 384 /*LMAO I forgot what this number represents so I'm leaving it*/ / (cam.targetDistance * 2)) / 8);

		const float lgo = 0.1;
		const float lgi = 1.0 - lgo;

		const float ftr = 2.0 / 3.0;	//Full Tile Ratio

		Noise waternoise();

		#ifndef STAGING

		array<SColor> prevylights(maxx - startx, SColor(0, 0, 0, 0));
		array<float> nextyto(maxx - startx, 2.0 / 3.0);
		for(int y = starty; y < maxy; y++)
		{


			array<SColor>@ lline = null;
			if(y > 0)
				@lline = @waterdata[y - 1];
			array<SColor>@ cline = @waterdata[y];

			SColor prevxlight(0, 0, 0, 0);
			
			//if(!activelayers[y])
				//continue;
			int waterendercompress = 0;
			SColor lightingcache(0, 0, 0, 0);
			SColor lightingcachecalced(0, 0, 0, 0);
			float lastdr = 999;
			for(int x = startx; x < maxx; x++)
			{
				bool lastyset = false;
				SColor bw = cline[x];

				int trux = x - startx;
				int truy = y - starty;//"True" y/x
				
				if(getWaterB(bw.getBlue()) || waterendercompress != 0)//If water exists there basically
				{
					if(bw.getRed() == 15 && x + 1 < maxx && nextyto[trux] >= 2.0 / 3.0 && (y == 0 || lline[x].getRed() > 0))
					{
						if(waterendercompress == 0)
						{
							SColor newlit = map.getColorLight(Vec2f(x + lgi, y + lgi) * 8);
							/*if(trux > 0 && truy > 0)
							{
								print("Boops: " + prevylights[trux].getBlue());
								print("Poops: " + prevylights[trux - 1].getBlue());
								print("Scoops: " + newlit.getBlue());
							}*/
							if(newlit == lightingcache && ((truy == 0 || trux == 0) || (prevylights[trux] == prevylights[trux - 1])))
							{
								lightingcachecalced = SColor(200, (75 * lightingcache.getRed()) / 255, (75 * lightingcache.getGreen()) / 255, (255 * lightingcache.getBlue()) / 255);
								if(trux > 0)
									prevylights[trux - 1] = prevxlight;
								prevxlight = lightingcachecalced;
								waterendercompress++;
								lightingcache = newlit;
								lastyset = true;
								continue;
							}
							lightingcache = newlit;
						}
						else 
						{
							if(lightingcache == map.getColorLight(Vec2f(x + lgi, y + lgi) * 8) && ((truy == 0 || trux == 0) || (prevylights[trux]) == (prevylights[trux - 1])))
							{
								if(trux > 0)
									prevylights[trux - 1] = prevxlight;
								prevxlight = lightingcachecalced;
								lastyset = true;
								waterendercompress++;
								continue;
							}
						}
					}

					

					if(waterendercompress > 0)
					{
						Vec2f p = Vec2f(x, y) * 8;
						//SColor light = map.getColorLight(Vec2f(x + 0.5, y + 0.5) * 8);
						SColor c = lightingcachecalced;
						SColor u = prevylights[trux - 1];
						
						//SColor c(200, 50, 50, 200);
						float dr = (15.0 - bw.getRed()) / 15.0;

						
						if(dr > 1)
							print("aa" + dr);
						if(y > 0 && getWaterB(waterdata[y - 1][x].getBlue()))
							dr = 0.0;
						dr *= 8;

						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y, 0, 0, ftr, u));
						vertlist.push_back(Vertex(p.x, p.y, 0, 1, ftr, u));
						vertlist.push_back(Vertex(p.x, p.y + 8, 0, 1, 1, c));
						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 8, 0, 0, 1, c));

						if(cont !is null)
						{
							if(cont.isKeyPressed(KEY_KEY_P))
							{
								SColor c = SColor(200, 200, 50, 200);
								vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 1, 0, 0, ftr, c));
								vertlist.push_back(Vertex(p.x, p.y + 1, 0, 1, ftr, c));
								vertlist.push_back(Vertex(p.x, p.y + 3, 0, 1, 1, c));
								vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 3, 0, 0, 1, c));
							}
						}
						waterendercompress = 0;
					}

					if(getWaterB(bw.getBlue()))
					{
						Vec2f p = Vec2f(x, y) * 8;
						SColor light = map.getColorLight(Vec2f(x + lgi, y + lgi) * 8);
						//light = SColor(255, 255, 255, 255);
						SColor c = SColor(200, (75 * light.getRed()) / 255, (75 * light.getGreen()) / 255, (255 * light.getBlue()) / 255);
						//SColor c(200, 50, 50, 200);
						float dr = (15.0 - bw.getRed()) / 15.0;
						if(map.isTileSolid(Vec2f(x, y - 1) * 8) || (x + 1 < map.tilemapwidth) && y > 0 && lline[x + 1].getRed() > 0)
							dr = 0;
						else
						{
							if(dr > 1)
								print("aa" + dr);
							if(y > 0 && getWaterB(lline[x].getBlue()))
								dr = 0.0;
							else 
								dr += waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 3.0;
							dr *= 8;
						}

						float leftdr = dr;
						if(lastdr <= 8.0)
						{
							leftdr = lastdr;
						}
						else if(x > 0 && cline[x].getRed() > 0)
						{
							if(map.isTileSolid(Vec2f(x, y - 1) * 8) || (y > 0 && getWaterB(lline[x].getBlue())))
								leftdr = 0;
							else
							{
								leftdr = (15.0 - cline[x].getRed()) / 15.0;
								leftdr += waternoise.Sample(Vec2f(((x - 1) + getGameTime()) / 3.0 , y) / 5.0) / 3.0;
								leftdr *= 8.0;
							}
						}


						//Worst code ive ever written
						//Fancy texturing stuff
						/*
						dr = Maths::Min(dr, 8);
						leftdr = Maths::Min(leftdr, 8);

						float texl = 2.0 / 3.0;
						float br = 1.0 / 3.0;
						if(y > 1 && lline[x].getRed() > 0 && waterdata[y - 2][x].getRed() > 0 && (y <= 2 || waterdata[y - 3][x].getRed() == 0) && !map.isTileSolid(Vec2f(x, y - 3) * 8))
						{
							texl = 1;
							texl += (15.0 - waterdata[y - 2][x].getRed()) / 15.0 / 3.0;

							texl -= waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 9.0;
							//texl *= 8;
						}
						else if(y > 0 && lline[x].getRed() > 0 && (y <= 1 || waterdata[y - 2][x].getRed() == 0) && !map.isTileSolid(Vec2f(x, y - 2) * 8))
						{
							texl = br;
							texl += (15.0 - lline[x].getRed()) / 15.0 / 3.0;
							texl -= waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 9.0;
						}
						else if((y == 0 || lline[x].getRed() == 0) && !map.isTileSolid(Vec2f(x, y - 1) * 8))
						{
							texl = 0;
							br += (15.0 - bw.getRed()) / 15.0 / 3.0;
							br -= waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 9.0;

						}
						texl = Maths::Min(texl, 2.0 / 3.0);*/
						//SCRAPPED BECAUSE I DID THIS IN A VERY STUPID WAY
						float texl = 2.0 / 3.0;
						float br = 1.0 / 3.0;
						if(y > 0 && lline[x].getRed() == 0)
							nextyto[trux] = 2.0 / 3.0;
						if(nextyto[trux] < texl || (!map.isTileSolid(Vec2f(x, y - 1) * 8) && (y == 0 || lline[x].getRed() == 0)))
						{
							if(nextyto[trux] >= texl)
							{
								texl = 0;
								//br *= (bw.getRed()) / 15.0;
								br -= dr / 8.0 / 3.0;
								//br += waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 9.0;
								nextyto[trux] = br;
							}
							else
							{
								texl = nextyto[trux];
								nextyto[trux] = texl + 1.0 / 3.0;
								//br += waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 9.0;
							}
						}
						else
							nextyto[trux] = texl;

						//End fancy texturing stuff

						//Special lighting additions
						SColor ul = (truy > 0 && trux > 0) ? prevylights[trux - 1] : c;
						if(ul.getAlpha() == 0)
						{
							ul = map.getColorLight(Vec2f(x + lgo, y + lgo) * 8);
							ul = SColor(200, (75 * ul.getRed()) / 255, (75 * ul.getGreen()) / 255, (255 * ul.getBlue()) / 255);
						}
						SColor bl = trux > 0 ? prevxlight : c;
						if(bl.getAlpha() == 0)
						{
							bl = map.getColorLight(Vec2f(x + lgo, y + lgi) * 8);
							bl = SColor(200, (75 * bl.getRed()) / 255, (75 * bl.getGreen()) / 255, (255 * bl.getBlue()) / 255);
						}
						SColor ur = truy > 0 ? prevylights[trux] : c;
						if(ur.getAlpha() == 0)
						{
							ur = map.getColorLight(Vec2f(x + lgi, y + lgo) * 8);
							ur = SColor(200, (75 * ur.getRed()) / 255, (75 * ur.getGreen()) / 255, (255 * ur.getBlue()) / 255);
						}

						float gto = Maths::Sin(getGameTime() / 20.0); //Game Time Offset

						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + leftdr, 0, 0 + gto, texl, ul));
						vertlist.push_back(Vertex(p.x + 8 , p.y + dr, 0, 1 + gto, texl, ur));
						vertlist.push_back(Vertex(p.x + 8, p.y + 8, 0, 1 + gto, texl + br, c));
						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 8, 0, 0 + gto, texl + br, bl));

						lastdr = dr;
						if(trux > 0)
							prevylights[trux - 1] = prevxlight;
						prevxlight = c;
						lastyset = true;
					}
				}
				else 
					lastdr = 999;

				if(!lastyset)
				{
					prevylights[trux] = SColor(0, 0, 0, 0);
					if(trux > 0)
						prevylights[trux - 1] = SColor(0, 0, 0, 0);
					prevxlight = SColor(0, 0, 0, 0);
				}
			}
		}
		#endif

		#ifdef STAGING
		array<float> nextyto(maxx - startx, 2.0 / 3.0);
		for(int y = starty; y < maxy; y++)
		{
			array<SColor>@ lline = null;
			if(y > 0)
				@lline = @waterdata[y - 1];
			array<SColor>@ cline = @waterdata[y];

			int waterendercompress = 0;
			float lastdr = 999;
			for(int x = startx; x < maxx; x++)
			{
				SColor bw = cline[x];

				int trux = x - startx;
				int truy = y - starty;//"True" y/x
				
				if(getWaterB(bw.getBlue()) || waterendercompress != 0)//If water exists there basically
				{
					if(bw.getRed() == 15 && x + 1 < maxx && nextyto[trux] >= 2.0 / 3.0 && (y == 0 || lline[x].getRed() > 0))
					{
						waterendercompress++;
						continue;
					}

					if(waterendercompress > 0)
					{
						Vec2f p = Vec2f(x, y) * 8;
						
						SColor c(200, 75, 75, 255);
						float dr = (15.0 - bw.getRed()) / 15.0;

						
						if(dr > 1)
							print("aa" + dr);
						if(y > 0 && getWaterB(waterdata[y - 1][x].getBlue()))
							dr = 0.0;
						dr *= 8;

						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y, 0, 0, ftr, c));
						vertlist.push_back(Vertex(p.x, p.y, 0, 1, ftr, c));
						vertlist.push_back(Vertex(p.x, p.y + 8, 0, 1, 1, c));
						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 8, 0, 0, 1, c));

						if(cont !is null)
						{
							if(cont.isKeyPressed(KEY_KEY_P))
							{
								SColor c = SColor(200, 200, 50, 200);
								vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 1, 0, 0, ftr, c));
								vertlist.push_back(Vertex(p.x, p.y + 1, 0, 1, ftr, c));
								vertlist.push_back(Vertex(p.x, p.y + 3, 0, 1, 1, c));
								vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 3, 0, 0, 1, c));
							}
						}
						waterendercompress = 0;
					}

					if(getWaterB(bw.getBlue()))
					{
						Vec2f p = Vec2f(x, y) * 8;
						SColor c = SColor(200, 75, 75, 255);

						float dr = (15.0 - bw.getRed()) / 15.0;
						if(map.isTileSolid(Vec2f(x, y - 1) * 8) || (x + 1 < map.tilemapwidth) && y > 0 && lline[x + 1].getRed() > 0)
							dr = 0;
						else
						{
							if(dr > 1)
								print("aa" + dr);
							if(y > 0 && getWaterB(lline[x].getBlue()))
								dr = 0.0;
							else 
								dr += waternoise.Sample(Vec2f((x + getGameTime()) / 3.0 , y) / 5.0) / 3.0;
							dr *= 8;
						}

						float leftdr = dr;
						if(lastdr <= 8.0)
						{
							leftdr = lastdr;
						}
						else if(x > 0 && cline[x].getRed() > 0)
						{
							if(map.isTileSolid(Vec2f(x, y - 1) * 8) || (y > 0 && getWaterB(lline[x].getBlue())))
								leftdr = 0;
							else
							{
								leftdr = (15.0 - cline[x].getRed()) / 15.0;
								leftdr += waternoise.Sample(Vec2f(((x - 1) + getGameTime()) / 3.0 , y) / 5.0) / 3.0;
								leftdr *= 8.0;
							}
						}


						float texl = 2.0 / 3.0;
						float br = 1.0 / 3.0;
						if(y > 0 && lline[x].getRed() == 0)
							nextyto[trux] = 2.0 / 3.0;
						if(nextyto[trux] < texl || (!map.isTileSolid(Vec2f(x, y - 1) * 8) && (y == 0 || lline[x].getRed() == 0)))
						{
							if(nextyto[trux] >= texl)
							{
								texl = 0;
								br -= dr / 8.0 / 3.0;
								nextyto[trux] = br;
							}
							else
							{
								texl = nextyto[trux];
								nextyto[trux] = texl + 1.0 / 3.0;
							}
						}
						else
							nextyto[trux] = texl;

						float gto = Maths::Sin(getGameTime() / 20.0); //Game Time Offset

						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + leftdr, 0, 0 + gto, texl, c));
						vertlist.push_back(Vertex(p.x + 8 , p.y + dr, 0, 1 + gto, texl, c));
						vertlist.push_back(Vertex(p.x + 8, p.y + 8, 0, 1 + gto, texl + br, c));
						vertlist.push_back(Vertex(p.x - (waterendercompress * 8), p.y + 8, 0, 0 + gto, texl + br, c));

						lastdr = dr;
					}
				}
				else 
					lastdr = 999;
			}
		}
		#endif

		/*
		if(cont !is null)
		{
			Vec2f mousepos = cont.getMouseWorldPos() / 8;
			Vec2f drawpos = cont.getMouseScreenPos();
			
			if(mousepos.x >= 0 && mousepos.x < waterdata[0].size() && mousepos.y >= 0 && mousepos.y < waterdata.size())
			{
				GUI::DrawText("Depth: " + waterdata[mousepos.y][mousepos.x].getRed(), drawpos, SColor(255, 255, 255, 255));
				GUI::DrawText("Active: " + getWaterA(waterdata[mousepos.y][mousepos.x].getBlue()), drawpos + Vec2f(0, 20), SColor(255, 255, 255, 255));
				GUI::DrawText("Full: " + getWaterF(waterdata[mousepos.y][mousepos.x].getBlue()), drawpos + Vec2f(0, 40), SColor(255, 255, 255, 255));
				GUI::DrawText("Unusable: " + waterdata[mousepos.y][mousepos.x].getGreen(), drawpos + Vec2f(0, 60), SColor(255, 255, 255, 255));
				GUI::DrawText("HasWater: " + getWaterB(waterdata[mousepos.y][mousepos.x].getBlue()), drawpos + Vec2f(0, 80), SColor(255, 255, 255, 255));
				GUI::DrawText("Press K to spawn water", drawpos + Vec2f(0, 120), SColor(255, 255, 255, 255));
				GUI::DrawText("Press L to remove water", drawpos + Vec2f(0, 140), SColor(255, 255, 255, 255));
			}
		}*/

		if(cont.isKeyPressed(KEY_KEY_P))
		{
			for(int y = 0; y < activelayers.size(); y++)
			{
				if(!activelayers[y])
					continue;
				float p = y * 8;
				SColor c = SColor(200, 50, 200, 200);
				//float dr = (15.0 - waterdata[x][y].d) / 15.0;
				
				vertlist.push_back(Vertex(0, p + 3, 0, 0, 0, c));
				vertlist.push_back(Vertex(5000, p + 3, 0, 1, 0, c));
				vertlist.push_back(Vertex(5000, p + 5, 0, 1, 1, c));
				vertlist.push_back(Vertex(0, p + 5, 0, 0, 1, c));
			}

			for(int x = 0; x < activecolumns.size(); x++)
			{
				if(!activecolumns[x])
					continue;
				float p = x * 8;
				SColor c = SColor(200, 50, 200, 200);
				//float dr = (15.0 - waterdata[x][y].d) / 15.0;
				
				vertlist.push_back(Vertex(p + 3, 0, 0, 0, 0, c));
				vertlist.push_back(Vertex(p + 3, 10000, 0, 1, 0, c));
				vertlist.push_back(Vertex(p + 5, 10000, 0, 1, 1, c));
				vertlist.push_back(Vertex(p + 5, 0, 0, 0, 1, c));
			}
		}
/*
		SMaterial mat;
		mat.AddTexture("PixelWhite.png");
		mat.SetFlag(SMaterial::ZBUFFER, false);
		mat.SetFlag(SMaterial::TEXTURE_WRAP, true);
		mat.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		mat.SetFlag(SMaterial::LIGHTING, false);
		mat.SetBlendOperation(SMaterial::ADD);
		mat.SetColorMask(SMaterial::CMask::ALL);
		//mat.SetColorMaterial(SMaterial::EMISSIVE);
		//mat.SetAmbientColour(color_white);
		//mat.SetDiffuseColor(color_white);
		//mat.SetEmissiveColor(color_white);
		mat.SetLayerAnisotropicFilter(0, 0);
		mat.SetLayerBilinearFilter(0, false);
		mat.SetMaterialType(SMaterial::LIGHTMAP_LIGHTING);
		//mat.SetMaterialType(SMaterial::SOLID);
		u16[] indices;

		for(int i = 0; i < vertlist.size() / 4; i++)
		{
			int ind = i * 4;
			indices.push_back(ind);
			indices.push_back(ind + 1);
			indices.push_back(ind + 3);
			indices.push_back(ind + 3);
			indices.push_back(ind + 1);
			indices.push_back(ind + 2);
		}

		mesh.SetMaterial(@mat);

		//array<Vertex> testverts;
		//testverts.push_back(Vertex(0, 0, 0, 0, 0, SColor(255, 255, 255, 255)));
			//testverts.push_back(Vertex(1000, 0, 1000, 1, 0, SColor(255, 255, 255, 255)));
				//testverts.push_back(Vertex(1000, 1000, 1000, 1, 1, SColor(255, 255, 255, 255)));
					//vertlist.push_back(Vertex(0, 1000, 0, 0, 0, SColor(255, 255, 255, 255)));
		
		if(vertlist.size() > 0)
			mesh.SetVertex(vertlist);
		if(indices.size() > 0)
			mesh.SetIndices(indices);

		mesh.BuildMesh();*/

		this.set("waterverts", @vertlist);

		//addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "Waterrender");
	}
}


void renderWater(int id)
{
	Render::SetTransformWorldspace();
	Render::SetAlphaBlend(true);
	Render::SetZBuffer(false, false);
	array<Vertex>@ vertlist;

	CRules@ rules = getRules();
	//SMesh@ mesh;
	//getMap().get("watermesh", @mesh);
	rules.get("waterverts", @vertlist);
	if(vertlist !is null)
	{
		Render::RawQuads("WaterTex.png", vertlist);
	}
	//if(mesh !is null)
	{
		//print("we do be renderin");
		//mesh.RenderMeshWithMaterial();
	}
}
