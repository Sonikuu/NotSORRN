//Random tile ticking
//Think ill either have this file handle all interactions or have other scripts 'attach' functions to blocks

#include "TileInteractions.as";
#include "RenderParticleCommon.as";
#include "WorldRenderCommon.as";

float tickmult = 0.0025;

void onInit(CRules@ this)
{
	onRestart(this);
	CMap@ map = getMap();
	if(map !is null)
		printInt("Random tile ticks per tick: ", Maths::Ceil(map.tilemapwidth * map.tilemapheight * tickmult));
	this.set_f32("tickmult", 1);
	this.set_u16("raincount", 24);
}

void onRestart(CRules@ this)
{
	this.set_u32("rainseed", XORRandom(0x7FFFFFFF));
	this.Sync("rainseed", true);
}

void onTick(CRules@ this)
{
	//Going to move rain stuff to another file eventually
	//i swear

	//TEMP
	/*{
		CRenderParticleLightning light(1, false, false, 0, 0, SColor(255, 255, 255, 200), false, 0);
		light.frompos = getCamera().getPosition();
		light.topos =  getControls().getMouseWorldPos();
		addParticleToList(light);
	}*/
	

	CMap@ map = getMap();
	Noise noise(this.get_u32("rainseed"));//lel
	float sample = (noise.Sample(getGameTime() / 5000.0, 0) - 0.5) * 4;
	//print("" + sample);
	float rainratio = Maths::Clamp(sample, 0, 1);
	int raincount = 16 * rainratio;
	this.set_u16("raincount", raincount);
	this.set_f32("rainratio", rainratio);
	array<int>@ heightdata;
	map.get("heightdata", @heightdata);
	//Chicken spawning
	if(isServer() && XORRandom(1200) == 0)
	{
		array<CBlob@> chickens;
		getBlobsByName("chicken", @chickens);
		if(chickens.length < 10)
		{
			int newx = XORRandom(map.tilemapwidth);
			server_CreateBlob("chicken", -1, Vec2f(newx, heightdata[newx]) * map.tilesize);
		}
	}
	//Bison spawning
	if(isServer() && XORRandom(3000) == 0)
	{
		array<CBlob@> bison;
		getBlobsByName("bison", @bison);
		if(bison.length < 4)
		{
			int newx = XORRandom(map.tilemapwidth);
			server_CreateBlob("bison", -1, Vec2f(newx, heightdata[newx]) * map.tilesize);
		}
	}
	//Cow spawning
	if(isServer() && XORRandom(3000) == 0)
	{
		array<CBlob@> cow;
		getBlobsByName("cow", @cow);
		if(cow.length < 4)
		{
			int newx = XORRandom(map.tilemapwidth);
			server_CreateBlob("cow", -1, Vec2f(newx, heightdata[newx]) * map.tilesize);
		}
	}

	

	if(raincount > 0)
	{
		CBlob@ b = getBlobByName("soundblob");
		if(b is null && isServer())
			server_CreateBlob("soundblob");
	}
	if(getNet().isClient())
	{
		
		CFileImage sky("mixedsky.png");
		sky.setPixelPosition(Vec2f(int(sky.getWidth() * map.getDayTime()), 1));
		SColor l = sky.readPixel();
		float lr = l.getRed() / 255.0;
		float lg = l.getGreen() / 255.0;
		float lgbt = l.getBlue() / 255.0;
		
		SColor partc(100, 100 * lr, 100 * lg, 255 * lgbt); 
	
		CCamera@ camera = getCamera();
		float zoom = camera.targetDistance;
		Vec2f cpos = camera.getPosition();
		
		for (int i = 0; i < Maths::Min(raincount, 500); i++)
		{
			float scale = (XORRandom(5) + 3) / 12.0;
			CRenderParticleDrop newpart(scale, true, true, 60 / scale, 0, partc, true, 0);
			newpart.velocity = Vec2f(-2.5, 30.0) * scale;
			newpart.position = Vec2f(XORRandom(getScreenWidth()) + cpos.x - (getScreenWidth() / 2.0), XORRandom(40));
			
			float rotdeg = (newpart.velocity.getAngle() - 90) * -1;
			
			newpart.ul = Vec2f(0, scale * -1.0).RotateBy(rotdeg);
			newpart.ur = Vec2f(2 * scale, scale * 0.125).RotateBy(rotdeg);
			newpart.lr = Vec2f(0, scale * 20.0).RotateBy(rotdeg);
			newpart.ll = Vec2f(-2 * scale, scale * 0.125).RotateBy(rotdeg);
			
			@newpart.heightdata = @heightdata;
			
			addParticleToList(newpart);
		}
	}
	
	
	int loopcount = Maths::Ceil(map.tilemapwidth * map.tilemapheight * tickmult * this.get_f32("tickmult"));
	for(int i = 0; i < loopcount; i++)
	{
		Random rando(XORRandom(0x7FFFFFFF));
		Vec2f nexttile(rando.NextRanged(map.tilemapwidth), rando.NextRanged(map.tilemapheight));
		Tile tile = map.getTileFromTileSpace(nexttile);
		if(tile.type >= 400 && tile.type <= 405 && getGameTime() % 2 == 0)
		{
			corruptTick(nexttile, map);
		}
	}

	//Random trader ship spawning
	CBlob@ ship = getBlobByName("tradership");
	if(ship is null && false)//Temp disabled
	{

		int xpos = XORRandom(map.tilemapwidth - 20) + 10;
		bool validspawn = true;
		for(int x = xpos - 8; x < xpos + 8; x++)//8 is clearance width
		{
			for(int y = 0; y < 10; y++)//10 here is the vertical clearance we require to spawn
			{
				if(map.isTileSolid(Vec2f(x, y) * 8))
				{
					validspawn = false;
					break;
				}
			}
			if(!validspawn)
				break;
		}
		if(validspawn)
		{
			print("Found valid spawning area");
			CBlob@ ship = server_CreateBlob("tradership", 254, Vec2f(xpos, 1) * 8);
			ship.setVelocity(Vec2f(0, 1));
			//Do spawn
		}
		else
		print("invalid");
	}
}

void onRender(CRules@ this)
{
	CMap@ map = getMap();
	/*array<int>@ heightdata;
	map.get("heightdata", @heightdata);
	if(heightdata !is null)
	{
		for (int i = 0; i < heightdata.length; i++)
		{
			{
					//printVec2f("Realpos:", last.hitpos);
					//printVec2f("Chkpos:", tilepos);
				
					array<Vertex> vertlist;
					
					vertlist.push_back(Vertex(i * 8 - 1, heightdata[i] * 8 - 1, 500, 0, 0, SColor(255, 100, 255, 100)));
					vertlist.push_back(Vertex(i * 8 + 1, heightdata[i] * 8 - 1, 500, 1, 0, SColor(255, 100, 255, 100)));
					vertlist.push_back(Vertex(i * 8 + 1, heightdata[i] * 8 + 1, 500, 1, 1, SColor(255, 100, 255, 100)));
					vertlist.push_back(Vertex(i * 8 - 1, heightdata[i] * 8 + 1, 500, 0, 1, SColor(255, 100, 255, 100)));
					
					
					addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLrender");
			}
		}
	}*/
	float rainratio = this.get_f32("rainratio");
	if(rainratio > 0)
	{
		array<Vertex> vertlist;
		
		
		CFileImage sky("mixedsky.png");
		sky.setPixelPosition(Vec2f(int(sky.getWidth() * map.getDayTime()), 1));
		SColor l = sky.readPixel();
		float lr = l.getRed() * 0.9;
		float lg = l.getGreen() * 0.9;
		float lgbt = l.getBlue() * 0.9;
						
		vertlist.push_back(Vertex(0, 0, 0, 0, 0, SColor(200 * rainratio, lr, lg, lgbt)));
		vertlist.push_back(Vertex(map.tilemapwidth * 8, 0, 0, 1, 0, SColor(200 * rainratio, lr, lg, lgbt)));
		vertlist.push_back(Vertex(map.tilemapwidth * 8, map.tilemapheight * 8, 0, 1, 1, SColor(200 * rainratio, lr, lg, lgbt)));
		vertlist.push_back(Vertex(0, map.tilemapheight * 8, 0, 0, 1, SColor(200 * rainratio, lr, lg, lgbt)));
		
		
		addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLbg");
	}
}
