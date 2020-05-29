
#include "MechCommon.as";
#include "Explosion.as";

//oh man what if we had it just... not tick sometimes?

void onInit(CBlob@ this)
{
	this.set_f32("heatlimit", 100);
	this.set_f32("heat", 0);
	this.set_f32("heatvent", 0.05);
}

void onDie(CBlob@ this)
{
	this.set_f32("map_damage_radius", this.get_f32("heat"));
	for(int i = 0; i < this.get_f32("heat") / 30; i++)
	{
		Explode(this, this.get_f32("heat"), this.get_f32("heat") / 12);
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CBlob@ driver = blob.getAttachments().getAttachedBlob("DRIVER");
	if(driver !is null && driver is getLocalPlayerBlob())
	{
		Vec2f startpoint(getScreenWidth() - 148, 20);
		GUI::DrawIcon("ULMechGUI.png", startpoint);
		Vec2f barstart = startpoint + Vec2f(8, 26);
		float healthratio = blob.getHealth() / blob.getInitialHealth();
		Vec2f heatbar = startpoint + Vec2f(8, 42);
		float heatratio = blob.get_f32("heat") / blob.get_f32("heatlimit");
		GUI::DrawRectangle(barstart, barstart + Vec2f(112 * healthratio, 14), SColor(255, 255, 100, 100));
		GUI::DrawRectangle(heatbar, heatbar + Vec2f(112 * heatratio, 14), SColor(255, 255, 200, 100));
		
		if(healthratio < 0.25)//critical health
		{
			if(Maths::Sin(getGameTime()) / 2 > 0)
				GUI::DrawIcon("CriticalHealth.png", startpoint + Vec2f(-64, 0));

		}
		if(heatratio > 0.75)//critical health
		{
			if(Maths::Sin(getGameTime()) / 2 > 0)
				GUI::DrawIcon("CriticalHeat.png", startpoint + Vec2f(-64, 32));
		}

	}
}