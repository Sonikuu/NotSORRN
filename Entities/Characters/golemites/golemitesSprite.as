


void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if(blob.getPlayer() !is null && blob.getPlayer() is getLocalPlayer())
    {
        //GUI::DrawText("GolemiteCount: " + this.getBlob().get_s32("golemiteCount"), Vec2f(8,45), SColor(255,127,63,30));
    }
}