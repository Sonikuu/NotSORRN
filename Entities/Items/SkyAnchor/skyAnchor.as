void onInit(CBlob@ this)
{

	this.maxQuantity = 5;
	this.getShape().SetGravityScale(0);
}

void onTick(CBlob@ this)
{
	Vec2f oldVel = this.getOldVelocity();
	Vec2f curVel = this.getVelocity();
	if(this.getQuantity() < 5)
	{

		this.setVelocity(Vec2f(curVel.x, Maths::Lerp(curVel.y,oldVel.y, this.getQuantity()/5.0)));
	}
	else
	{
		this.setVelocity(Vec2f(oldVel.x,0));
	}
}

void onInit(CSprite@ this)
{
	this.ScaleBy(Vec2f(2,2));
}