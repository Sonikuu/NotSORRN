#include "NodeCommon.as"

void onInit(CBlob@ this)
{
    this.getShape().SetGravityScale(0);

    this.SetLightRadius(80);
    this.SetLight(true);
    this.SetLightColor(SColor(255,255,255,255));
}

void onTick(CBlob@ this)
{
    f32 dist = distanceToGround(this.getPosition()) ;
    if(dist > 80)
    {
        this.getShape().SetGravityScale(0.5);
    }
    else
    {
        this.getShape().SetGravityScale(0);
    }
}

f32 distanceToGround(Vec2f pos)
{
    CMap@ map = getMap();
    for(int i = pos.y; i < map.tilemapheight*8; i+=8)
    {
        if(map.isTileSolid(Vec2f(pos.x,i)))
        {
            return (Vec2f(pos.x,i) - pos).Length();
        }
    }

    return -1;
}

void onInit(CSprite@ this)
{
    this.addSpriteLayer("lum","lum.png",64,64).setRenderStyle(RenderStyle::Style::light);
	CSpriteLayer@ l = this.getSpriteLayer("lum");
	//this.ScaleBy(Vec2f(1.0 / 256.0, 1.0 / 256.0));
	l.ScaleBy(Vec2f(1.0 / 8.0, 1.0 / 8.0));
    //need to use sprite layer to tint :v
}

void onTick(CSprite@ this)
{
    this.SetVisible(false);
    CSpriteLayer@ lum = this.getSpriteLayer("lum");
    CMap@ map = getMap();
    CBlob@[] blobs;

    lum.SetFrame(this.getFrame());

    map.getBlobsInRadius(this.getBlob().getPosition(),24,@blobs);
    int r = 0,g = 0,b = 0;
    int essenceCount = 1;
    for(int i = 0; i < blobs.length; i++)
    {
        CBlob@ blob = blobs[i];
        CAlchemyTank@ tank = getTank(blob, 0);

        if(tank !is null)
        {
            for(int i = 0; i < elementlist.size(); i++)
            {
                if(tank.storage.getElement(i) > 0)
                {
                    r+=elementlist[i].color.getRed();
                    g+=elementlist[i].color.getGreen();
                    b+=elementlist[i].color.getBlue();
                    essenceCount++;
                }
            }
        }
    }

    if(r + g + b == 0){r = 255; g = 255; b = 255;}

    SColor color = SColor(255,r/essenceCount * 2,g/essenceCount * 2,b/essenceCount * 2);
    lum.SetColor(color);

    this.getBlob().SetLightColor(color);
	
	if(XORRandom(30) == 0)
	{
		CBlob@ blob = this.getBlob();
		//CParticle@ p = makeGibParticle("lum.png", blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), Vec2f(XORRandom(10) - 10, XORRandom(10) - 10) / 30.0 + blob.getVelocity() / 2, 0, 0, Vec2f(64, 64), 0.1, 0, "");
		CParticle@ p = ParticleAnimated("lum.png", blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4) / 3.0, Vec2f(XORRandom(10) - 5, XORRandom(10) - 10) / 60.0 + blob.getVelocity() / 2, 0, 1.0 / 16.0, 0, 0, Vec2f(64, 64), 1, -0.002, true);
		if(p !is null)
		{
			//p.deadeffect = 1;
			//p.rotates = false;
			//p.fadeout = true;
			//p.diesonanimate = true;
			//p.gravity = Vec2f(0, -0.01);
			//p.framesize = 64;
			p.damping = 0.98;
			p.animated = 40;
			//p.rotation = Vec2f(XORRandom(100) - 50, XORRandom(100) - 50) / 50.0;
			//p.diesoncollide = true;
			//p.scale = 1.0 / 8.0;
			p.growth = -0.0005;
			//p.framestep = 1;
			//p.alivetime = 1;
			//p.timeout = 30;
			//p.emiteffect = 0;
			//p.freerotationscale = 0.5;
			p.colour = color;
			p.setRenderStyle(RenderStyle::light);
		}
	}
}
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return false;
}