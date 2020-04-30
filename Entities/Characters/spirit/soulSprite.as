
void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    this.ScaleBy(Vec2f(0.5,0.5));

    blob.set_s32("spinSpeed", 0);
    blob.set_s32("targetSpinSpeed", XORRandom(50) - 25);
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();

    s32 spinSpeed = blob.get_s32("spinSpeed");
    s32 targetSpinSpeed = blob.get_s32("targetSpinSpeed");
    if(spinSpeed < targetSpinSpeed)
    {
        blob.add_s32("spinSpeed",1);
    }
    else if(spinSpeed > targetSpinSpeed)
    {
        blob.add_s32("spinSpeed",-1);
    }
    else
    {
        blob.set_s32("targetSpinSpeed",XORRandom(500) -250);
    }

    this.RotateBy(spinSpeed/10.0, Vec2f_zero);
}