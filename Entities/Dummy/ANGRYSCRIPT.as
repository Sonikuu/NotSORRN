
void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		sprite.SetZ(999);
		if(this.getTickSinceCreated() > 90)
		{
			if(this.getName() == "dontspawnmepls")
				sprite.SetFrame(1);
			float derf = float(this.getTickSinceCreated() - 90) / 4;
			sprite.TranslateBy(Vec2f(float(XORRandom(derf)) - 0.5 * derf, float(XORRandom(derf)) - 0.5 * derf));
			if(this.getTickSinceCreated() > 900)
				this.server_Die();
		}
	}
}

























