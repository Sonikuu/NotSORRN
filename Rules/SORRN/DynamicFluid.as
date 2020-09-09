//Random tile ticking
//Think ill either have this file handle all interactions or have other scripts 'attach' functions to blocks

#include "RenderParticleCommon.as";
#include "WorldRenderCommon.as";

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

array<array<CWaterTile>>@ waterdata;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		@waterdata = @array<array<CWaterTile>>(map.tilemapwidth, array<CWaterTile>(map.tilemapheight, CWaterTile()));
	}
}

void onTick(CRules@ this)
{
	CControls@ con = getControls();
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
	CMap@ map = getMap();
	if(waterdata is null)
		return;
	for(int x = 0; x < waterdata.size(); x++)
	{
		for(int y = 0; y < waterdata[0].size(); y++)
		{
			CWaterTile@ bw = @waterdata[x][y];
			if(bw.b && bw.a)//If water exists there basically
			{
				bool mdt = false; //mdt = moved dis tick
				if(bw.u == bw.d)
				{
					bw.u = 0;
					continue;
				}
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
							if(waterdata[x][y + 1].d >= 15)
								waterdata[x][y + 1].f = true;

							if(x > 0)
								waterdata[x - 1][y].a = true;
							if(x + 1 < waterdata.size())
								waterdata[x + 1][y].a = true;
							if(y > 0)
								waterdata[x][y - 1].a = true;
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
									if(!map.isTileSolid(Vec2f(x - 1, y) * 8) && x - 1 >= 0 && !waterdata[x - 1][y].f && waterdata[x][y].d - waterdata[x - 1][y].d > 0)
										diff = Maths::Ceil(diff / 3.0);
									else
										diff = Maths::Ceil(diff / 2.0);
									
									bw.f = false;
									bw.d -= diff;
									if(bw.d == 0)
										bw.b = false;
									else if(bw.d > 15)
										print("AASDASD" + diff);
									waterdata[x + 1][y].d += diff;
									waterdata[x + 1][y].b = true;
									waterdata[x + 1][y].u += diff;
									if(waterdata[x + 1][y].d >= 15)
										waterdata[x + 1][y].f = true;
									
									if(x > 0)
										waterdata[x - 1][y].a = true;
									if(x + 1 < waterdata.size())
										waterdata[x + 1][y].a = true;
									if(y > 0)
										waterdata[x][y - 1].a = true;
								}
							}
						}
					}
					//else
					{
						if(!map.isTileSolid(Vec2f(x - 1, y) * 8) && x - 1 >= 0 && !waterdata[x - 1][y].f /*&& XORRandom(2) == 0*/)
						{
							s8 diff = bw.d - waterdata[x - 1][y].d;
							diff = Maths::Min(diff, bw.d - bw.u);
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
									waterdata[x - 1][y].d += Maths::Ceil(diff / 2.0);
									waterdata[x - 1][y].b = true;
									if(waterdata[x - 1][y].d >= 15)
										waterdata[x - 1][y].f = true;

									if(x > 0)
										waterdata[x - 1][y].a = true;
									if(x + 1 < waterdata.size())
										waterdata[x + 1][y].a = true;
									if(y > 0)
										waterdata[x][y - 1].a = true;
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
		}
	}
}

void onRender(CRules@ this)
{
	CMap@ map = getMap();
	if(waterdata is null)
		return;
	{
		array<Vertex> vertlist;
		
		for(int x = 0; x < waterdata.size(); x++)
		{
			for(int y = 0; y < waterdata[0].size(); y++)
			{
				if(waterdata[x][y].b)//If water exists there basically
				{
					Vec2f p = Vec2f(x, y) * 8;
					SColor c = SColor(200, waterdata[x][y].a ? 200 : 50, 50, 200);
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
						
		
		
		
		addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLrender");
	}
}
