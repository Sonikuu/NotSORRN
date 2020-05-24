

//Sky gradient mixer
//Basically make a certain amount of tiles into a biome
//Only mixes the two highest weighted skies
//can add more features later

shared class CSkyData
{
	string sky;
	int tileupper;
	int tilelower;
	CSkyData(string sky, int tileupper, int tilelower)
	{
		this.sky = sky;
		this.tileupper = tileupper;
		this.tilelower = tilelower;
	}
	bool isThisRange(int tile)
	{
		return(tile >= tilelower && tile <= tileupper);
	}
}



array<CSkyData> skydata = 
{
	CSkyData(
	"skygradient.png",
	399,
	0
	),
	
	CSkyData(
	"skygradient_blood.png",
	405,
	400
	),
	
	CSkyData(
	"skygradient_dust.png",
	408,
	406
	)
};

int getSkyTile(int tile)
{
	for(int i = 0; i < skydata.length; i++)
	{
		if(skydata[i].isThisRange(tile))
			return i;
	}
	return 0;
}

const float updatedist = 8;
const int horzcheck = 16;
const int resetcooldown = 0;

Vec2f poscache = Vec2f_zero;
CFileImage truesky(256, 3, false);
int resettimer = resetcooldown;
array<float>@ weightcache = null;
int raincache = 0;

void onInit(CRules@ this)
{
	truesky.setFilename("mixedsky.png", IMAGE_FILENAME_BASE_MAPS);
	CFileImage::silent_errors = true;
}

void onTick(CRules@ this)
{
	CBlob@ blob = getLocalPlayerBlob();
	CCamera@ cam = getCamera();
	Vec2f currpos = Vec2f_zero;
	CMap@ map = getMap();

	if(resettimer == resetcooldown)
	{
		map.CreateSkyGradient("Maps/mixedsky.png");
	}
	if(resettimer >= 0)
	{
		resettimer--;
		return;
	}
	
	//Getting position
	if(blob !is null)
		currpos = blob.getPosition();
	else if(cam !is null)
		currpos = cam.getPosition();
	else
		return;
		
	if((poscache - currpos).Length() > updatedist || getGameTime() % 30 == 0)
	{
		
		poscache = currpos;
		
		
		//Getting weights
		array<float> weights(skydata.length, 0);
		int totaltiles = 0;
		for(int i = -horzcheck * map.tilesize; i < horzcheck * map.tilesize; i += map.tilesize)
		{
			totaltiles++;
			Vec2f temppos = currpos;
			temppos.x += i;
			if(map.isTileSolid(temppos))
			{
				while(map.isTileSolid(temppos))
				{
					temppos.y -= map.tilesize;
					if(temppos.y < 0)
						break;
				}
				temppos.y += map.tilesize;
			}
			else
			{
				while(!map.isTileSolid(temppos))
				{
					temppos.y += map.tilesize;
					if(temppos.y > map.tilemapheight * map.tilesize)
						break;
				}
			}
			weights[getSkyTile(map.getTile(temppos).type)]++;
		}
		//Managing weights
		if(weightcache !is null)
			if(weightcache == weights && map.getDayTime() < 0.99 && raincache == this.get_u16("raincount"))
				return;
		@weightcache = @weights;
		raincache = this.get_u16("raincount");
		int highest = 0;
		int highestweight = -1;
		int second = 0;
		int secondweight = -1;
		for(int i = 0; i < skydata.length; i++)
		{
			//printInt("Weight " + i + " : ", weights[i]);
			if(weights[i] > highestweight)
			{
				second = highest;
				highest = i;
				secondweight = highestweight;
				highestweight = weights[i];
			}
			else if(weights[i] > secondweight)
			{
				second = i;
				secondweight = weights[i];
			}
		}
		float interpweight = float(weights[highest]) / float(weights[highest] + weights[second]); 
		
		//Getting images
		
		string primsky = skydata[highest].sky;
		if(!Texture::exists(primsky + "data"))
		{
			Texture::createFromFile(primsky + "data", primsky);
		}
		ImageData@ dprimsky = Texture::data(primsky + "data");
		
		string secsky = skydata[second].sky;
		if(!Texture::exists(secsky + "data"))
		{
			Texture::createFromFile(secsky + "data", secsky);
		}
		ImageData@ dsecsky = Texture::data(secsky + "data");
		
		string rainsky = "skygradient_rain.png";
		if(!Texture::exists(rainsky + "data"))
		{
			Texture::createFromFile(rainsky + "data", rainsky);
		}
		ImageData@ drainsky = Texture::data(rainsky + "data");
		
		//Finally making sky
		truesky.setPixelOffset(0);
		float rainratio = this.get_f32("rainratio");
		float divvor = 1.0 + 0.75 * rainratio;
		for(int y = 0; y < dprimsky.height(); y++)
		{
			for(int x = 0; x < dprimsky.width(); x++)
			{
				SColor outcol = dprimsky.get(x, y).getInterpolated(dsecsky.get(x, y), interpweight);
				if(this.get_u16("raincount") > 0) //Is raining
				{
					outcol.set(255, outcol.getRed() / divvor, outcol.getGreen() / divvor, outcol.getBlue() / divvor);
				}
				truesky.setPixelAndAdvance(outcol);
			}
		}
		
		//this is the part where i do something dumb to get past a bug
		//So, the bug is that when calling CreateSkyGradient it flickers to the color of the leftmost side of the gradient
		//What im going to do here is set the leftmost side to whatever it is at the time of making the sky
		//end me
		for(int i = 0; i < 3; i++)
		{
			truesky.setPixelPosition(Vec2f(truesky.getWidth() * map.getDayTime(), i));
			truesky.setPixelAtPosition(0, i, truesky.readPixel(), false);
		}
		
		truesky.Save();
		if(XORRandom(100) == 0)
			print("Enjoy the console spam?");
		resettimer = resetcooldown;
		
		//Now lets see how badly this crashes
		//Heyyy no crashes, just doesnt work
		//woooo got it working
		//only cost my soul
	}
	
	

}