#include "AlchemyCommon"

void onInit(CBlob@ this)
{
    CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(0, 0));
	tank.maxelements = 100;
	tank.singleelement = true;
	tank.dynamictank = true;

    this.getShape().getConsts().mapCollisions = true;//good code sonic
}

void onInit(CSprite@ this)
{
    this.addSpriteLayer("content","vialContents",8,8);

    this.getBlob().set_s32("frame",0);
}

void onTick(CBlob@ this)
{
    CAlchemyTank@ tank = getTank(this, 0);
    int id = firstId(tank);
    this.setInventoryName(id > -1 ? ("Vial of " + elementlist[id].visiblename) : "Empty Vial");
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();

    CAlchemyTank@ tank = getTank(blob, 0);
    CSpriteLayer@ layer = this.getSpriteLayer("content");

    if(getGameTime() % 4 == 0)
    {
        blob.add_s32("frame",1);
    }
    layer.SetFrameIndex((blob.get_s32("frame") + blob.getNetworkID()) % 4);

    SColor color = SColor(0,0,0,0);

    s32 i = firstId(tank);
    if(i > -1)
    {
        color = elementlist[i].color;
        layer.SetVisible(true);
        layer.SetColor(color);
    }
    else
    {
        layer.SetVisible(false);
    }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    if(solid)
    {
		Vec2f absVel = Vec2f(Maths::Abs(this.getVelocity().x),Maths::Abs(this.getVelocity().y));
		if(blob !is null)
		{
			absVel += Vec2f(Maths::Abs(blob.getVelocity().x), Maths::Abs(blob.getVelocity().y));
		}
        if(absVel.Length() > 2)
        {
            this.server_Die();
        }
    }
}

void onDie(CBlob@ this)
{
    Sound::Play("shatter.ogg", this.getPosition(),1, 0.75 + (XORRandom(25)/100.0));

    CAlchemyTank@ tank = getTank(this, 0);
    int id = firstId(tank);
    if(id <= -1){return;}
    f32 ammount = tank.storage.getElement(id);
    f32 power = ammount/(tank.maxelements * 2); //less stronk than drinking

    elementlist[id].vialSplashbehavior(this,power);

    for(int i = 0; i < 50; i++)
    {
        Vec2f vel = getRandomVelocity(0, 5,360);
        ParticlePixelUnlimited(this.getPosition(),vel, elementlist[id].color, true);
        ParticlesFromSprite(this.getSprite());
    }
}