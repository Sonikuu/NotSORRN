#include "AlchemyCommon"

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
    this.addSpriteLayer("lum","lum.png",8,8).setRenderStyle(RenderStyle::Style::additive);
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
        array<CElementSetup> @elementlist = @getElementList();
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
}
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return false;
}