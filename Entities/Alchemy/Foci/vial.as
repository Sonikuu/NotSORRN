#include "NodeCommon.as"

int BASE_VIAL_MAX = 100;
float VIAL_COMPACT_BOOST = 2.5;

void onInit(CBlob@ this)
{
    CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(0, 0));
	tank.maxelements = BASE_VIAL_MAX;
	if(this.hasTag("compact"))
		tank.maxelements *= VIAL_COMPACT_BOOST;
	tank.singleelement = true;
	tank.dynamictank = true;

    this.getShape().getConsts().mapCollisions = true;//good code sonic  //rood
    this.addCommandID("upgrade");
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
	bool enh = this.hasTag("enhanced");
	bool comp = this.hasTag("compact");
	string vialname = "";
	if(id > -1)
	{
		if(enh)
			vialname += "Enhanced ";
		if(comp)
			vialname += enh ? "compact " : "Compact ";
		if(!enh && !comp)
			vialname += "Vial of " + elementlist[id].visiblename;
		else
			vialname += "vial of " + elementlist[id].visiblename;
	}
	else
		vialname = "Empty Vial";
    this.setInventoryName(vialname);
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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
    CBlob@ held = caller.getCarriedBlob();
    if(held !is null)
    {
        if((held.getConfig() == "lantern" && !this.hasTag("enhanced")) || (held.getConfig() == "heart" && !this.hasTag("compact")))
            caller.CreateGenericButton(5, Vec2f_zero, this, this.getCommandID("upgrade"), "Upgrade Vial", params);
    }
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("upgrade"))
	{  
        CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
        {
            CBlob@ held = caller.getCarriedBlob();
            if(held !is null)
            {
                if(held.getConfig() == "lantern")
                {
                    held.server_Die();
                    this.Tag("enhanced");
                }
                else if(held.getConfig() == "heart")
                {
                    held.server_Die();
                    this.Tag("compact");
                    getTank(this, 0).maxelements *= VIAL_COMPACT_BOOST;
                }
            }
        }
	}
}

void onDie(CBlob@ this)
{
    Sound::Play("Shatter.ogg", this.getPosition(),1, 0.75 + (XORRandom(25)/100.0));

    CAlchemyTank@ tank = getTank(this, 0);
    int id = firstId(tank);
    if(id <= -1){return;}
    f32 ammount = tank.storage.getElement(id);
    f32 power = ammount / (BASE_VIAL_MAX * 2); //less stronk than drinking

    //For ref: base power: 0.5 | compact boost: * 2.5 | Enhanced: * 2 | Total: 2.5 power
	
	if(this.hasTag("enhanced"))
		power *= 2;

    elementlist[id].vialSplashbehavior(this,power);

    for(int i = 0; i < 50; i++)
    {
        Vec2f vel = getRandomVelocity(0, 5,360);
        ParticlePixelUnlimited(this.getPosition(),vel, elementlist[id].color, true);
        ParticlesFromSprite(this.getSprite());
    }
}