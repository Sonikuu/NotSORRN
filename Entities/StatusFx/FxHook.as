//Basically this goes on top of script order to avoid issues
//Means effects added in this way wont be applied to entities without this
//Also inits damage mods
//TBH should just cave and have all effects handled here


//Then I could have it be object oriented
//And have it render a more reasonable way on screen
#include "CHitters.as";
#include "DamageModCommon.as";
#include "FxHookCommon.as";

//Fook it, time to redo the fx systems
void onInit(CBlob@ this)
{
	array<CDamageModCore@> mods;
	this.set("damagemods", @mods);
	array<IStatusEffect@> effects;
	//We're gonna add all the effects to the active list on init, most if not all will be removed on the first tick but its worth it just to not deal with syncing
	//Oh, and active list is just to try and save on performance a lil
	for(int i = 0; i < effectlist.size(); i++)
	{
		if(this.get_u16(effectlist[i].getFxName() + "time") > 0)
		{
			effects.push_back(@effectlist[i]);
			if(effectlist[i] is null)
				print("	AAAA " + i);
			else
				effectlist[i].onApply(this);
		}
	}
	this.set("effectls", @effects);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	array<IStatusEffect@>@ effects;
	blob.get("effectls", @effects);
	if(effects !is null)
	{
		GUI::SetFont("menu");
		for(int i = 0; i < effects.size(); i++)
		{
			Vec2f thiscenter = getEffectIconCenter(i);
			Vec2f icondraw = thiscenter - Vec2f(16, 16);
			effects[i].renderIcon(icondraw, blob);
			//GUI::DrawIcon("EffectIcons.png", 0, Vec2f(16, 16), icondraw);
			CControls@ con = getControls();
			if(con !is null)
			{
				Vec2f mpos = con.getMouseScreenPos();
				if(mpos.x >= icondraw.x && mpos.y >= icondraw.y && mpos.x <= icondraw.x + 32 && mpos.y <= icondraw.y + 32)
					GUI::DrawText(effects[i].getHoverText(blob, con.isKeyPressed(KEY_LSHIFT)), con.getMouseScreenPos() - Vec2f(256, 64), con.getMouseScreenPos() + Vec2f(256, 64), color_black, true, true, true);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	this.set_f32("basegrav", 1.0);//Resetting, effect onticks can modify afterwards and it should apply to the next movement tick
	array<IStatusEffect@>@ effects;
	this.get("effectls", @effects);
	if(effects !is null)
	{
		for(int i = 0; i < effects.size(); i++)
		{
			string name = effects[i].getFxName();
			if(this.get_u16(name + "time") == 0)
			{
				effects[i].onRemove(this);
				removeFromList(name, @effects);
			}
			else
			{
				effects[i].onTick(this);
				this.sub_u16(name + "time", 1);
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	array<IStatusEffect@>@ effects;
	this.get("effectls", @effects);
	if(effects !is null)
	{
		for(int i = 0; i < effects.size(); i++)
		{
			damage = effects[i].onHit(this, worldPoint, velocity, damage, hitterBlob, customData);
		}
	}
	return damage;
}
