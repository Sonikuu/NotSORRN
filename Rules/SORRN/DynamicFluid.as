//Random tile ticking
//Think ill either have this file handle all interactions or have other scripts 'attach' functions to blocks

#include "RenderParticleCommon.as";
#include "WorldRenderCommon.as";
#include "DynamicFluidCommon.as";

void onInit(CRules@ this)
{
	this.addCommandID("waterupdate");
	this.addCommandID("spawnwater");
	onRestart(this);
}

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		array<array<CWaterTile>>@ waterdata;
		array<bool>@ activelayers;

		//this.get("waterdata", @waterdata);
		//this.get("activelayers", @activelayers);

		/*if(waterdata is null || waterdata.size() != map.tilemapwidth || waterdata[0].size() != map.tilemapheight)
		{
			@waterdata = @array<array<CWaterTile>>(map.tilemapwidth, array<CWaterTile>(map.tilemapheight, CWaterTile()));
			@activelayers = @array<bool>(map.tilemapheight, false);
		}*/
	
		map.AddScript("DynamicFluid.as");
		
		//map.set("waterdata", @waterdata);
		//map.set("activelayers", @activelayers);
	}
}

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	//if(newtile == 0)
	{
		array<array<CWaterTile>>@ waterdata;
		array<bool>@ activelayers;

		this.get("waterdata", @waterdata);
		this.get("activelayers", @activelayers);

		if(waterdata is null || activelayers is null)
			return;

		Vec2f pos(index % this.tilemapwidth, index / this.tilemapwidth);
		waterdata[pos.x][pos.y].a = true;
		if(pos.x < this.tilemapwidth - 1)
			waterdata[pos.x + 1][pos.y].a = true;
		if(pos.x > 0)
			waterdata[pos.x - 1][pos.y].a = true;
		if(pos.y < this.tilemapheight - 1)
			waterdata[pos.x][pos.y + 1].a = true;
		if(pos.y > 0)
			waterdata[pos.x][pos.y - 1].a = true;

		activelayers[pos.y] = true;
		if(pos.y > 0)
			activelayers[pos.y - 1] = true;
		if(pos.y < this.tilemapheight)
			activelayers[pos.y + 1] = true;
	}
}

void onTick(CRules@ this)
{
	CControls@ con = getControls();
	CMap@ map = getMap();
	array<array<CWaterTile>>@ waterdata;
	array<bool>@ activelayers;
	map.get("waterdata", @waterdata);
	map.get("activelayers", @activelayers);

	if(!isServer())
	{
		if(con !is null)
		{
			if(con.isKeyPressed(KEY_KEY_K))
			{
				Vec2f pos = con.getMouseWorldPos() / 8;
				if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata.size() && pos.y < waterdata[0].size())
				{
					CBitStream params;
					params.write_Vec2f(pos);
					this.SendCommand(this.getCommandID("spawnwater"), params);
				}
			}
			if(con.isKeyPressed(KEY_KEY_L))
			{
				Vec2f pos = con.getMouseWorldPos() / 8;
				if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata.size() && pos.y < waterdata[0].size())
				{
				
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
			if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata.size() && pos.y < waterdata[0].size())
			{
				waterdata[pos.x][pos.y].b = true;
				waterdata[pos.x][pos.y].d = 15;
				waterdata[pos.x][pos.y].f = true;
				waterdata[pos.x][pos.y].a = true;
				activelayers[pos.y] = true;

				CBitStream params;
				params.write_Vec2f(pos);
				this.SendCommand(this.getCommandID("spawnwater"), params);
			}
		}
		if(con.isKeyPressed(KEY_KEY_L))
		{
			Vec2f pos = con.getMouseWorldPos() / 8;
			if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata.size() && pos.y < waterdata[0].size())
			{
				waterdata[pos.x][pos.y].b = false;
				waterdata[pos.x][pos.y].d = 0;
				waterdata[pos.x][pos.y].f = false;
			}
		}
		if(!con.isKeyJustPressed(KEY_KEY_J))
		{
			//return;
		}
	}
	
	int actc = 0;
	if(waterdata is null)
		return;
	for(int y = 0; y < waterdata[0].size(); y++)
	{
		if(!activelayers[y])
			continue;
		actc++;
		bool keepactive = false;
		for(int x = 0; x < waterdata.size(); x++)
		{
			CWaterTile@ bw = @waterdata[x][y];
			if(bw.b && bw.a)//If water exists there basically
			{
				bool mdt = false; //mdt = moved dis tick
				if(bw.u >= bw.d)
				{
					bw.u = 0;
					keepactive = true;
					continue;
				}
				int tempunused = bw.u;
				//First try and move down
				if(!map.isTileSolid(Vec2f(x, y + 1) * 8) && (y + 1 >= waterdata[0].size() || !waterdata[x][y + 1].f))
				{
					u8 amt = y + 1 < waterdata[0].size() ? 15 - waterdata[x][y + 1].d : 15;
					amt = Maths::Min(bw.d - bw.u, amt);
					if(amt > 0)
					{
						mdt = true;
						bw.d -= amt;
						bw.f = false;
						if(bw.d == 0)
							bw.b = false;
						if(y + 1 < waterdata[0].size())
						{
							waterdata[x][y + 1].d += amt;
							waterdata[x][y + 1].b = true;
							//waterdata[x][y + 1].moved = true;
							waterdata[x][y + 1].u += amt;
							waterdata[x][y + 1].a = true;	//It's okay if we're 'dirty' about A usage, it wont tick anyway if its empty
							activelayers[y + 1] = true;
							if(waterdata[x][y + 1].d >= 15)
								waterdata[x][y + 1].f = true;

							if(x > 0)
								waterdata[x - 1][y].a = true;
							if(x + 1 < waterdata.size())
								waterdata[x + 1][y].a = true;
							if(y > 0)
							{
								waterdata[x][y - 1].a = true;
								activelayers[y - 1] = true;
							}
							keepactive = true;
						}
					}
				}
				//else
				{
					//if(XORRandom(2) == 0)
					{
						if(!map.isTileSolid(Vec2f(x + 1, y) * 8) && x + 1 < waterdata.size() && !waterdata[x + 1][y].f /*&& XORRandom(2) == 0*/)
						{
							s8 diff = bw.d - waterdata[x + 1][y].d;//This is an s8 cause it makes things a little easier, no judgies
							
							if(diff > 0)
							{
								diff = Maths::Min(diff, bw.d - bw.u);
								mdt = true;
								
								if((XORRandom(2) == 0 || Maths::Ceil(diff) != 1) && diff > 0)
								{
									float divvor = 2.0;
									if(!map.isTileSolid(Vec2f(x - 1, y) * 8) && x - 1 >= 0 && !waterdata[x - 1][y].f && bw.d - waterdata[x - 1][y].d > 0)
									{
										//diff = Maths::Ceil(diff / 3.0);
										//print("tridiv");
										divvor = 3.0;
									}
									else
									{
										//diff = Maths::Ceil(diff / 2.0);
									}
									
									bw.f = false;
									bw.d -= Maths::Ceil(diff / divvor);
									if(bw.d == 0)
										bw.b = false;
									else if(bw.d > 15)
										print("AASDASD" + diff);
									waterdata[x + 1][y].d += Maths::Ceil(diff / divvor);
									waterdata[x + 1][y].b = true;
									//waterdata[x + 1][y].u += diff;
									//if(diff == 1)
										//waterdata[x + 1][y].u = 15;
									if(waterdata[x + 1][y].d >= 15)
										waterdata[x + 1][y].f = true;
									
									if(x > 0)
										waterdata[x - 1][y].a = true;
									if(x + 1 < waterdata.size())
										waterdata[x + 1][y].a = true;
									if(y > 0)
									{
										waterdata[x][y - 1].a = true;
										activelayers[y - 1] = true;
									}

									keepactive = true;
								}
							}
						}
					}
					//else
					{
						if(!map.isTileSolid(Vec2f(x - 1, y) * 8) && x - 1 >= 0 && !waterdata[x - 1][y].f /*&& XORRandom(2) == 0*/)
						{
							s8 diff = bw.d - waterdata[x - 1][y].d;
							//diff = Maths::Min(diff, bw.d - bw.u);
							if(diff > 0)
							{
								diff = Maths::Min(diff, bw.d - bw.u);
								mdt = true;
								//if(XORRandom(2) == 0 || Maths::Ceil(diff / 2.0) != 1)
								if(diff > 0)
								{
									bw.f = false;
									bw.d -= Maths::Ceil(diff / 2.0);
									if(bw.d == 0)
										bw.b = false;
									else if(bw.d > 15)
										print("ssssss");
									//if(x + 1 < waterdata.size())
										//if(waterdata[x + 1][y].d == bw.d)
											//waterdata[x + 1][y].u = 15;
									waterdata[x - 1][y].d += Maths::Ceil(diff / 2.0);
									waterdata[x - 1][y].b = true;

									if(waterdata[x - 1][y].d >= 15)
										waterdata[x - 1][y].f = true;

									if(x > 0)
										waterdata[x - 1][y].a = true;
									if(x + 1 < waterdata.size())
										waterdata[x + 1][y].a = true;
									if(y > 0)
									{
										waterdata[x][y - 1].a = true;
										activelayers[y - 1] = true;
									}
									keepactive = true;
								}
							}
						}
					}
				}
				if(!mdt)
					bw.a = false;
				else
					bw.a = true;
				
			}
			else
			{
				//if(bw.d > 0)
				//	print("Water error");
			}
			bw.u = 0;
			if(bw.a && bw.b)
				keepactive = true;
		}
		if(!keepactive)
		{
			activelayers[y] = false;
			//print("Killed layer " + y);
		}
	}
	//print("" + actc);
	if(getGameTime() % 1 == 0)
	{
		for(int y = 0; y < activelayers.size(); y++)
		{
			if(activelayers[y])
			{
				CBitStream layerstream;
				layerstream.write_u16(y);
				for(int x = 0; x < waterdata.size(); x++)
				{
					layerstream.write_u8(waterdata[x][y].d);
				}
				this.SendCommand(this.getCommandID("waterupdate"), layerstream);
			}
		}
			//print("sent cmd");
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	//print("hook runs");
	if(cmd == this.getCommandID("waterupdate") && !isServer())
	{
		//print("updcmd");
		array<array<CWaterTile>>@ waterdata;
		array<bool>@ activelayers;
		CMap@ map = getMap();
		map.get("waterdata", @waterdata);
		map.get("activelayers", @activelayers);


		if(waterdata is null || waterdata.size() != map.tilemapwidth || waterdata[0].size() != map.tilemapheight)
		{
			@waterdata = @array<array<CWaterTile>>(map.tilemapwidth, array<CWaterTile>(map.tilemapheight, CWaterTile()));
			@activelayers = @array<bool>(map.tilemapheight, false);

			map.set("waterdata", @waterdata);
			map.set("activelayers", @activelayers);
		}

		int y = params.read_u16();
		//for(int y = 0; y > activelayers.size(); y++)
		{
			//if(activelayers[y])
			{
				for(int x = 0; x < waterdata.size(); x++)
				{
					u8 read_val = params.read_u8();
					waterdata[x][y].d = read_val;
					waterdata[x][y].b = read_val > 0;
					waterdata[x][y].f = read_val >= 15;
				}
			}
		}
	}
	if(cmd == this.getCommandID("spawnwater") && isServer())
	{
		array<array<CWaterTile>>@ waterdata;
		array<bool>@ activelayers;
		CMap@ map = getMap();
		map.get("waterdata", @waterdata);
		map.get("activelayers", @activelayers);

		Vec2f pos = params.read_Vec2f();
		if(pos.x >= 0 && pos.y >= 0 && pos.x < waterdata.size() && pos.y < waterdata[0].size())
		{
			waterdata[pos.x][pos.y].b = true;
			waterdata[pos.x][pos.y].d = 15;
			waterdata[pos.x][pos.y].f = true;
			waterdata[pos.x][pos.y].a = true;
			activelayers[pos.y] = true;
		}
	}
}

void onRender(CRules@ this)
{
	CMap@ map = getMap();
	array<array<CWaterTile>>@ waterdata;
	array<bool>@ activelayers;

	map.get("waterdata", @waterdata);
	map.get("activelayers", @activelayers);

	
	if(waterdata is null)
		return;
	{
		array<Vertex> vertlist;
		CCamera@ cam = getCamera();
		
		//print("" + cam.targetDistance);

		const int maxy = Maths::Min(waterdata[0].size(), (cam.getPosition().y + 384 / (cam.targetDistance * 2)) / 8);
		const int maxx = Maths::Min(waterdata.size(), (cam.getPosition().x + 640 / (cam.targetDistance * 2)) / 8);
		for(int y = Maths::Max(0, (cam.getPosition().y - 384 / (cam.targetDistance * 2)) / 8); y < maxy; y++)
		{
			//if(!activelayers[y])
				//continue;

			for(int x = Maths::Max(0, (cam.getPosition().x - 640 / (cam.targetDistance * 2)) / 8); x < maxx; x++)
			{
				if(waterdata[x][y].b)//If water exists there basically
				{
					Vec2f p = Vec2f(x, y) * 8;
					SColor light = map.getColorLight(Vec2f(x + 0.5, y + 0.5) * 8);
					SColor c = SColor(200, (50 * light.getRed()) / 255, (50 * light.getGreen()) / 255, (200 * light.getBlue()) / 255);
					float dr = (15.0 - waterdata[x][y].d) / 15.0;
					if(dr > 1)
						print("aa" + dr);
					if(y > 0 && waterdata[x][y - 1].b)
						dr = 0.0;
					dr *= 8;
					vertlist.push_back(Vertex(p.x, p.y + dr, 0, 0, 0, c));
					vertlist.push_back(Vertex(p.x + 8, p.y + dr, 0, 1, 0, c));
					vertlist.push_back(Vertex(p.x + 8, p.y + 8, 0, 1, 1, c));
					vertlist.push_back(Vertex(p.x, p.y + 8, 0, 0, 1, c));
				}
			}
		}

		CControls@ cont = getControls();
		if(cont !is null)
		{
			Vec2f mousepos = cont.getMouseWorldPos() / 8;
			Vec2f drawpos = cont.getMouseScreenPos();

			if(mousepos.x >= 0 && mousepos.x < waterdata.size() && mousepos.y >= 0 && mousepos.y < waterdata[0].size())
			{
				GUI::DrawText("Depth: " + waterdata[mousepos.x][mousepos.y].d, drawpos, SColor(255, 255, 255, 255));
				GUI::DrawText("Active: " + waterdata[mousepos.x][mousepos.y].a, drawpos + Vec2f(0, 20), SColor(255, 255, 255, 255));
				GUI::DrawText("Full: " + waterdata[mousepos.x][mousepos.y].f, drawpos + Vec2f(0, 40), SColor(255, 255, 255, 255));
				GUI::DrawText("Unusable: " + waterdata[mousepos.x][mousepos.y].u, drawpos + Vec2f(0, 60), SColor(255, 255, 255, 255));
				GUI::DrawText("HasWater: " + waterdata[mousepos.x][mousepos.y].b, drawpos + Vec2f(0, 80), SColor(255, 255, 255, 255));
			}
		}

		/*for(int y = 0; y < activelayers.size(); y++)
		{
			if(!activelayers[y])
				continue;
			float p = y * 8;
			SColor c = SColor(200, 50, 200, 200);
			//float dr = (15.0 - waterdata[x][y].d) / 15.0;
			
			vertlist.push_back(Vertex(0, p + 3, 0, 0, 0, c));
			vertlist.push_back(Vertex(1000, p + 3, 0, 1, 0, c));
			vertlist.push_back(Vertex(1000, p + 5, 0, 1, 1, c));
			vertlist.push_back(Vertex(0, p + 5, 0, 0, 1, c));
		}*/

		
		
		
		addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLrender");
	}
}
