#include "AlchemyCommon"

void onInit(CBlob@ this)
{
    CAlchemyTank@ tank = addTank(this, "input", true, Vec2f(0, 0));
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
    CAlchemyTank@ tank = getTank(this,"input");
    int id = firstId(tank);
    this.setInventoryName(id > -1 ? ("Vial of " + elementlist[id].visiblename) : "Empty Vial");
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();

    CAlchemyTank@ tank = getTank(blob,"input");
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
        if(this.getVelocity().Length() > 2)
        {
            this.server_Die();
        }
    }
}

void onDie(CBlob@ this)
{
    Sound::Play("shatter.ogg", this.getPosition(),1, 0.75 + (XORRandom(25)/100.0));

    CAlchemyTank@ tank = getTank(this,"input");
    int id = firstId(tank);
    if(id <= -1){return;}
    f32 ammount = tank.storage.getElement(id);
    f32 power = ammount/(tank.maxelements * 2); //less stronk than drinking


    CBlob@[] blobs;
    CMap@ map = getMap();
    map.getBlobsInRadius(this.getPosition(),24 * (power * 2), @blobs);
    for(int i = 0; i < blobs.size(); i++)
    {
        CBlob@ blob = blobs[i];
        if(map.rayCastSolidNoBlobs(this.getPosition(),blob.getPosition())){continue;}

        switch(id)
        {
            case EElement::ecto:
                applyFxGhostlike(blob,900 * power,1);
                applyFxLowGrav(blob,900 * power,100);
            break;

            case EElement::life:
                blob.server_Heal(blob.getInitialHealth() * power);
            break;

            case EElement::natura:
                padNatura(blob,power * 5,this);
            break;

            case EElement::force:
            {
                Vec2f thisPos = this.getPosition();
                Vec2f otherPos = blob.getPosition();
                Vec2f dif = thisPos - otherPos;
                dif.Normalize();

                blob.setVelocity(blob.getVelocity() + (-dif * power * 32) );

            }
            break;

            case EElement::aer:
            {
                Vec2f thisPos = this.getPosition();
                Vec2f otherPos = blob.getPosition();
                Vec2f dif = thisPos - otherPos;
                dif.Normalize();

                blob.setVelocity(blob.getVelocity() + (dif * power * 32) );
            }
            break;

            case EElement::ignis:
                this.server_Hit(blob,blob.getPosition(), Vec2f(0,0),1,Hitters::fire,true);
            break;

            case EElement::aqua:
                padAqua(blob,power*5,this);
            break;
        }

    }

    switch(id)
    {
        case EElement::terra:
        {
            for(int i = 0; i < 50 * power; i++)
            {
                sprayTerra(power * 5, 0, 360, 24 * (power * 2), this, this);
            }
        }
        break;
        case EElement::order:
        {
            for(int i = 0; i < 50 * power; i++)
            {
                sprayOrder(power * 5, 0, 360, 24 * (power * 2), this, this);
            }
        }
        break;
        case EElement::entropy:
        {
            for(int i = 0; i < 50 * power; i++)
            {
                sprayEntropy(power * 5, 0, 360, 24 * (power * 2), this, this);
            }
        }
        break;
        case EElement::corruption:
        {
            for(int i = 0; i < 50 * power; i++)
            {
                sprayCorruption(power * 5, 0, 360, 24 * (power * 2), this, this);
            }
        }
        break;
        case EElement::purity:
        {
            for(int i = 0; i < 50 * power; i++)
            {
                sprayPurity(power * 5, 0, 360, 24 * (power * 2), this, this);
            }
        }
        break;
    }

    for(int i = 0; i < 50; i++)
    {
        Vec2f vel = getRandomVelocity(0, 5,360);
        ParticlePixelUnlimited(this.getPosition(),vel, elementlist[id].color, true);
        ParticlesFromSprite(this.getSprite());
    }
}