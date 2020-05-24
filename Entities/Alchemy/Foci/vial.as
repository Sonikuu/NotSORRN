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