// draws a health bar on mouse hover

#include "CHealth.as";

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
	CMap@ map = getMap();
	if (map is null)
		return;
	

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();

	if(map.getColorLight(center).getLuminance() < 0.1)
		return;

	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	const f32 initialHealth = getMaxHealth(blob);
	const f32 perc = blob.getHealth() / initialHealth;
	if(perc <= 0.25)
		blob.set_s16("hptimeout", 95);
	if (blob.get_s16("hptimeout") > 0)
	{
		//VV right here VV
		Vec2f pos2d = blob.getInterpolatedScreenPos() + Vec2f(0, 20);
		Vec2f dim = Vec2f(40, 8);
		const f32 y = blob.getHeight() * getCamera().targetDistance * 2.4f;
		
		float opacity = Maths::Min(1.0, (blob.get_s16("hptimeout")) / 5.0);
		if (initialHealth > 0.0f)
		{
			
			if (perc >= 0.0f)
			{
				GUI::DrawIcon("FancyHealthBar.png", 0, Vec2f(40, 8 * opacity), Vec2f(pos2d.x - dim.x, pos2d.y + y));
				//GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
				if(blob.get_s16("hptimeout") > 2)
				{
					if(perc <= 0.25 && (getGameTime() % 30 == 0 || (getGameTime() + 2) % 30 == 0))
						GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 4, pos2d.y + y + 4), Vec2f(pos2d.x - dim.x + (perc * 2.0f * (dim.x - 4)) + 4, pos2d.y + y + dim.y + 0), SColor(0xffffffff));
					else
						GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 4, pos2d.y + y + 4), Vec2f(pos2d.x - dim.x + (perc * 2.0f * (dim.x - 4)) + 4, pos2d.y + y + dim.y + 0), SColor(0xffac1512));
				}
			}
		}
	}

	/*CControls@ cont = getControls();
	if(cont !is null && blob.isMyPlayer())
	{
		Vec2f mousepos = cont.getMouseWorldPos() / 8;
		Vec2f drawpos = cont.getMouseScreenPos();

		{
			GUI::DrawText("HP: " + blob.getHealth() + "/" + getMaxHealth(blob), drawpos, SColor(255, 255, 255, 255));
		}
	}*/
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	this.set_s16("hptimeout", 95);
	//damageNumbers(this.getPosition(), (oldHealth - this.getHealth()) * 10, this.getTeamNum());
}

void onTick(CBlob@ this)
{
	if(this.get_s16("hptimeout") > 0)
		this.sub_s16("hptimeout", 1);
}

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void damageNumbers(Vec2f pos, float damage, int team, bool money = false, bool spent = false)
{
	if(!isClient())
		return;
	bool friendly = false;
	bool heal = damage < 0.0;
	CBlob@ blob = getLocalPlayerBlob();
	SColor pcolor(255, 255, 255, 255);
	Vec2f particlevel(3, -9);
	//TODO: green color for heals, maybe yellow for enemy heals?
	if(blob !is null)
	{
		if(blob.getTeamNum() == team)
		{
			friendly = true;
		}
	}
	else
	{
		CPlayer@ player = getLocalPlayer();
		if(player !is null)
		{
			if(player.getTeamNum() == team) //oh right players have a team too... we'll use that if blob check fails
			{
				friendly = true;
			}
		}
	}
	if(heal)
	{
		if(friendly)
			pcolor = SColor(255, 50, 255, 50);
		else
			pcolor = SColor(255, 255, 255, 50);
	}
	else
	{
		if(!friendly)
			pcolor = SColor(255, 255, 50, 50);
	}
	if(money)
	{
		pcolor = SColor(255, 255, 255, 0);
		particlevel = Vec2f(0, -9);
	}
	if(spent)
	{
		pcolor = SColor(255, 255, 255, 0);
		particlevel = Vec2f(-3, -9);
	}
	damage = Maths::Abs(damage);
	//if(Maths::Floor(damage) > 9999)
	//	damage = 9999;
	float currmult = 1;
	Vec2f currpos = pos;
	
	//Decimal
	if(Maths::Floor(damage) < 10 && !money && !spent)
	{
		CParticle@ particle = makeGibParticle("JustADot.png", pos - Vec2f(-2, 0), particlevel, 0, 0, Vec2f(8, 8), 1, 0, "");
		if(particle !is null)
		{
			particle.rotates = false;
			particle.lighting = false;
			particle.collides = false;
			particle.Z = 999;
			particle.colour = pcolor;
		}
		CParticle@ particle2 = makeGibParticle("NumberParticle.png", pos - Vec2f(-6, 0), particlevel, 0, Maths::Floor(damage * 10) % 10, Vec2f(8, 8), 1, 0, "");
		if(particle2 !is null)
		{
			particle2.rotates = false;
			particle2.lighting = false;
			particle2.collides = false;
			particle2.Z = 999;
			particle2.colour = pcolor;
		}
	}
	
	while(Maths::Floor(damage) >= currmult)
	{
		CParticle@ particle = makeGibParticle("NumberParticle.png", currpos, particlevel, 0, Maths::Floor(damage / int(currmult)) % 10, Vec2f(8, 8), 1, 0, "");
		if(particle !is null)
		{
			particle.rotates = false;
			particle.lighting = false;
			particle.collides = false;
			particle.Z = 999;
			particle.colour = pcolor;
		}
		currmult *= 10;
		currpos.x -= 4;
	}
}