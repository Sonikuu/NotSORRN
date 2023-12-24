


void onInit(CBlob@ this)
{
	this.getShape().getConsts().collideWhenAttached = false;
}

void onInit(CSprite@ this)
{
	this.SetFrame(3);
	this.SetOffset(Vec2f(0, 20));
	CSpriteLayer@ layer = this.addSpriteLayer("lower");
	layer.SetOffset(Vec2f(0, 40));
	layer.SetFrame(4);
}

void onTick(CSprite@ this)
{
	
}

void onTick(CMovement@ this)
{
	
}

void onTick(CBlob@ this)
{
	
}



