#include "NodeCommon.as";



void onInit(CBlob@ this)
{	
	//Setup tanks
	CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(0, -1.5));
	tank.onlyele = 5;//5 Is ignis
	tank.maxelements = 250;
	this.set_u16("dumptotal", 0);
	
}

void onInit(CSprite@ this)
{
	this.addSpriteLayer("lum","lum.png",64,64).setRenderStyle(RenderStyle::Style::light);
	CSpriteLayer@ l = this.getSpriteLayer("lum");
	//this.ScaleBy(Vec2f(1.0 / 256.0, 1.0 / 256.0));
	l.ScaleBy(Vec2f(1.0 / 16.0, 1.0 / 16.0));
	l.TranslateBy(Vec2f(0, -9.5));
	l.SetColor(SColor(150, 255, 150, 20));
	l.SetLighting(false);
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, 0);
	
	if(input !is null && getGameTime() % 100 == 0)
	{
		//for(int i = 0; i < input.storage.elements.length; i++)
		{
			if(input.storage.elements[5] > 0)
			{
				CMap@ map = getMap();
				CBlob@[] blobs;
				if(map.getBlobsInRadius(this.getPosition(), 512, @blobs))
				{
					CBlob@[] fuelblobs;
					for (int i = 0; i < blobs.length; i++)
					{
						if(blobs[i].exists("fuel") && blobs[i].get_f32("fuel") < (blobs[i].exists("maxFuel") ? blobs[i].get_f32("maxFuel") : 1000) && blobs[i].getConfig() != "alchemyburner")
							fuelblobs.push_back(blobs[i]);
					}
					if(fuelblobs.length > 0)
					{
						int maxdisperse = Maths::Min(input.storage.elements[5], 100);
						int eachdisperse = maxdisperse / fuelblobs.length;
						int dispersed = 0;
						for (int i = 0; i < fuelblobs.length; i++)
						{
							if((fuelblobs[i].getTeamNum() == this.getTeamNum()) || (this.getTeamNum() > 6 && fuelblobs[i].getTeamNum() > 6))
							{
								int toadd = Maths::Min(eachdisperse, 1000 / 2.5 - fuelblobs[i].get_f32("fuel") / 2.5);
								fuelblobs[i].set_f32("fuel", fuelblobs[i].get_f32("fuel") + toadd * 2.5);
								fuelblobs[i].Sync("fuel", true);
								dispersed += toadd;
								if(toadd > 0) 
									makeIgnisPacket(this, fuelblobs[i].getPosition());
							}
						}
						input.storage.elements[5] -= dispersed;
					}
				}
			}
		}
	}
}

void makeIgnisPacket(CBlob@ this, const Vec2f topos)
{
	CRenderParticleBlazing p(2, false, false, 300, 0, SColor(150, 255, 150, 20), false, 0);
	p.position = this.getPosition() - Vec2f(0, 9.5);
	p.topos = topos;
	addParticleToList(p);
}

