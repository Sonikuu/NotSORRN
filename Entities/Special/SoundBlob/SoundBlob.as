void onInit(CBlob@ this)
{
	this.getSprite().SetEmitSound("RainLoopFix.ogg");
	this.getSprite().SetEmitSoundPaused(false);
	this.getShape().SetStatic(true);
}

void onTick(CBlob@ this)
{
	if(getRules().get_u16("raincount") == 0)
		this.server_Die();
	CCamera@ cam = getCamera();
	CBlob@ b = getLocalPlayerBlob();
	this.getSprite().SetEmitSoundVolume(getRules().get_f32("rainratio") * 2.0);
	if(b !is null)
	{
		this.setPosition(b.getPosition());
	}
	else if(cam !is null)
	{
		this.setPosition(cam.getPosition());
	}
}