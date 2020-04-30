#include "AlchemyCommon.as";



void onInit(CBlob@ this)
{	
	//Setup tanks
	addTank(this, "input", true, Vec2f(0, -4));
	this.set_u16("dumptotal", 0);
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, "input");
	
	if(input !is null)
	{
		for(int i = 0; i < input.storage.elements.length; i++)
		{
			if(input.storage.elements[i] > 0)
			{
				this.add_u16("dumptotal", input.storage.elements[i]);
				input.storage.elements[i] = 0;
			}
		}
	}
	if(this.get_u16("dumptotal") >= 10)
	{
		this.add_u16("dumptotal", -10);
		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
			sprite.PlaySound("DispenserFire.ogg", 1, 1);
		for (int i = 0; i < 3; i++)
			makeSteamParticle(this, Vec2f(XORRandom(10) - 5, XORRandom(10) - 5) / 10.0);
		CMap@ map = getMap();
		
		if(XORRandom(10) == 0 && isServer())
		{
			CBlob@[] blobs;
			if(map.getBlobsInRadius(this.getPosition(), 32, @blobs))
			{
				for (int i = 0; i < blobs.length; i++)
				{
					if(blobs[i].getConfig() == "mat_stone")
					{
						if(blobs[i].getQuantity() >= 25)
						{
							if(blobs[i].getQuantity() == 25)
								blobs[i].server_Die();
							else
								blobs[i].server_SetQuantity(blobs[i].getQuantity() - 25);
							
							CBlob@ output = server_CreateBlobNoInit("mat_metal");
							output.Tag("custom quantity");
							output.setPosition(blobs[i].getPosition());
							output.server_SetQuantity(1);
							output.Init();
							break;
						}
					}
				}
			}
		}
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}

