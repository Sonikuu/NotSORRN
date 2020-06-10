
#include "MechCommon.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.set_f32("heatlimit", 200);
	this.set_f32("heat", 0);
	this.set_f32("heatvent", 0.75);
}

void onDie(CBlob@ this)
{
	this.set_f32("map_damage_radius", 64.0);
	Explode(this, 64.0, 4.0);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CBlob@ driver = blob.getAttachments().getAttachedBlob("DRIVER");
	if(driver !is null && driver is getLocalPlayerBlob())
	{
		Vec2f startpoint(getScreenWidth() - 148, 20);
		GUI::DrawIcon("MIMechGUI.png", startpoint);
		Vec2f barstart = startpoint + Vec2f(10, 14);
		float healthratio = blob.getHealth() / blob.getInitialHealth();
		Vec2f heatbar = startpoint + Vec2f(10, 46);
		float heatratio = blob.get_f32("heat") / blob.get_f32("heatlimit");
		GUI::DrawRectangle(barstart, barstart + Vec2f(108 * healthratio, 14), SColor(255, 255, 100, 100));
		GUI::DrawRectangle(heatbar, heatbar + Vec2f(108 * heatratio, 12), SColor(255, 255, 200, 100));
		
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