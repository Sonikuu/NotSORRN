void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
	if(blob.get_s32("golemiteCount") > 0)
	{
		if(blob.getPlayer() !is null && blob.getPlayer() is getLocalPlayer())
		{
			Vec2f meterPos = Vec2f(8,105);
			f32 scale = 2;
			GUI::DrawIcon("golemitemeter.png", 0, Vec2f(16,32), meterPos, scale,scale);
			
			Vec2f fss = Vec2f(6,6) * scale;//first slot spacing

			f32 golemiteMax = this.getBlob().get_s32("golemiteMax");
			f32 golemiteCount = this.getBlob().get_s32("golemiteCount");

			for(int i = Maths::Ceil(9 * (golemiteCount/golemiteMax)); i >= 1; i--)
			{
				int x = 10 - i;
				Vec2f pos = fss + meterPos + (Vec2f(0,3 * scale) * (x - 1) * scale);
				GUI::DrawIcon("golemitemetercontents",XORRandom(9), Vec2f(10,2), pos,scale,scale);
			}
		}
	}
}