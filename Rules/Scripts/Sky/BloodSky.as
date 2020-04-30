

void onTick(CMap@ this)
{
	if(getGameTime() % 30 != 0)
		return;
	//this.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
	
	this.CreateSkyGradient("skygradient_blood.png");
	/*
	this.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, 0.0f), Vec2f(0.3f, 0.3f), color_white);
	this.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  19.0f), Vec2f(0.4f, 0.4f), color_white);
	//map.AddBackground( "Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, 50.0f), Vec2f(0.5f, 0.5f), color_white );
	this.AddBackground("Sprites/Back/BackgroundCastle.png", Vec2f(0.0f, 50.0f), Vec2f(0.6f, 0.6f), color_white);
*/
	// fade in
	//SetScreenFlash(255, 0, 0, 0);
	//SetScreenFlash(255, 0, 0, 0);
}