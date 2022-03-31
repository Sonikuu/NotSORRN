//Basically this goes on top of script order to avoid issues
//Means effects added in this way wont be applied to entities without this
//Also inits damage mods
//TBH should just cave and have all effects handled here


//Then I could have it be object oriented
//And have it render a more reasonable way on screen
#include "CHitters.as";
#include "DamageModCommon.as";
#include "RunnerCommon.as";


interface IStatusEffect
{
	void onTick(CBlob@);
	f32 onHit(CBlob@, Vec2f, Vec2f, f32, CBlob@, u8);
	//uhhh, do we need more than this?
	//oh, ill just add something to make other stuff easier
	//yeee, no property accessors, bish
	//gotta add functions for rendering icon and text and shizzzzz
	void renderIcon(Vec2f, CBlob@);
	string getHoverText(CBlob@, bool);//Should I make this take a bool, for if we want to show algorithm or actual effect? maybe
	string getFxName();
	void onApply(CBlob@);
	void onRemove(CBlob@);
}

class CStatusBase : IStatusEffect
{
	void onTick(CBlob@){}
	f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData){return damage;}
	void renderIcon(Vec2f pos, CBlob@ this){}
	string getHoverText(CBlob@ this, bool algo){return "";}
	string getFxName(){return "";}
	void onApply(CBlob@ this){}
	void onRemove(CBlob@ this){}
	//There, blank implementations
}

//Easy first one
class CStatusDamageReduce : CStatusBase
{
	f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
	{
		//It feels somewhat silly to be using netvars instead of making the power a part of blob data
		//But I just cant be bothered to sync that stuff ugh
		damage /= float(this.get_u16("fxdamagereducepower") / 10.0 + 1);
		return damage;
	}
	void onApply(CBlob@ this)
	{
		if(isClient())
		{
			CSpriteLayer@ l = this.getSprite().addSpriteLayer("fxdamagereduce", "DamageReduce.png", 8, 8);
			l.TranslateBy(Vec2f(0, -24));
			l.SetIgnoreParentFacing(true);
			//l.SetRelativeZ(1);
		}
	}
	void onRemove(CBlob@ this)
	{
		if(isClient())
		{
			this.getSprite().RemoveSpriteLayer("fxdamagereduce");
		}
	}
	string getFxName()
	{
		return "fxdamagereduce";
	}

	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 0, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxdamagereducetime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxdamagereducepower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Divide damage taken by $GREEN$((power / 10) + 1)$GREEN$";
		return "Divide damage taken by $GREEN$" + formatFloat(this.get_u16("fxdamagereducepower") / 10.0 + 1, "", 0, 1) + "$GREEN$";
	}
}

//Damage mod type of effect, fun
class CStatusCorrupt : CStatusBase
{
	CCorruptDamageMod mod("fxcorrupt");
	f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
	{
		if(customData == CHitters::pure)
			damage *= float(this.get_u16("fxcorruptpower") / 5.0 + 1);
		return damage;
	}

	string getFxName()
	{
		return "fxcorrupt";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 1, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxcorrupttime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxcorruptpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Multiply damage dealt by $GREEN$((power / 10) + 1)$GREEN$\nIncrease pure damage taken by $RED$((power / 5) + 1)$RED$";
		return "Multiply damage dealt by $GREEN$" + formatFloat(this.get_u16("fxcorruptpower") / 10.0 + 1, "", 0, 1) + "$GREEN$\nIncrease pure damage taken by $RED$" + formatFloat(this.get_u16("fxcorruptpower") / 5.0 + 1, "", 0, 1) + "$RED$";
	}

	void onApply(CBlob@ this)
	{
		addDamageMod(this, @mod);
	}

	void onRemove(CBlob@ this)
	{
		removeDamageMod(this, @mod);
	}
}

class CStatusPure : CStatusBase
{
	CPureDamageMod mod("fxpure");
	f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
	{
		if(customData == CHitters::pure)
			damage /= float(this.get_u16("fxpure") / 2.5 + 1);
		if(customData == CHitters::corrupt)
			damage = 0;
		return damage;
	}

	string getFxName()
	{
		return "fxpure";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 2, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxpuretime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxpurepower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Reduce pure damage taken by $GREEN$((power / 2.5) + 1)" +
			"\nNullify$GREEN$ corrupt damage" +
			"\nReduce corrupt damage dealt by $RED$((power / 10.0) + 1)";
		return "Reduce pure damage taken by $GREEN$" + formatFloat(this.get_u16("fxpurepower") / 2.5 + 1, "", 0, 1) + 
		"\nNullify$GREEN$ corrupt damage" + 
		"\nReduce corrupt damage dealt by $RED$" + formatFloat(this.get_u16("fxpurepower") / 10.0 + 1, "", 0, 1) + "$RED$";
	}

	void onApply(CBlob@ this)
	{
		addDamageMod(this, @mod);
	}

	void onRemove(CBlob@ this)
	{
		removeDamageMod(this, @mod);
	}
}

class CStatusUnholy : CStatusBase
{
	void onTick(CBlob@ this)
	{
		float movemult = this.get_u16("fxunholypower") / 15.0 + 1;
		RunnerMoveVars@ moveVars;
		if (!this.get("moveVars", @moveVars))
		{
			return;
		}
		moveVars.walkFactor *= movemult;
		moveVars.jumpFactor *= movemult;
	}
	string getFxName()
	{
		return "fxunholy";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 3, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxunholytime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxunholypower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Multiply movement speed by $GREEN$((power / 15) + 1)$GREEN$";
		return "Multiply movement speed by $GREEN$" + formatFloat(this.get_u16("fxunholypower") / 15.0 + 1, "", 0, 1) + "$GREEN$";
	}
}

class CStatusHoly : CStatusBase
{
	f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
	{
		if(customData != CHitters::corrupt)
			damage /= this.get_u16("fxholypower") / 7.5 + 1;
		return damage;
	}
	void onTick(CBlob@ this)
	{
		float movemult = this.get_u16("fxholypower") / 10.0 + 1;
		RunnerMoveVars@ moveVars;
		if (!this.get("moveVars", @moveVars))
		{
			return;
		}
		moveVars.walkFactor /= movemult;
		moveVars.jumpFactor /= movemult;
		if((getGameTime() % 10 == 0) && isClient())
		{
			CParticle@ p = makeGibParticle("Holy.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(XORRandom(10) - 5, XORRandom(10) - 5) / 10.0, 0, XORRandom(4), Vec2f(8, 8), 0, 0, "");
			if(p !is null)
			{
				p.gravity = Vec2f(0, 0);
				p.scale = 0.5;
			}
		}
	}
	string getFxName()
	{
		return "fxholy";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 4, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxholytime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxholypower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Reduce non-corrupt damage taken by $GREEN$((power / 7.5) + 1)$GREEN$" +
			"\nReduce movement speed by $RED$((power / 10) + 1)$RED$";
		return "Reduce non-corrupt damage taken by $GREEN$" + formatFloat(this.get_u16("fxholypower") / 7.5 + 1, "", 0, 1) + 
		"\n$GREEN$Reduce movement speed by $RED$" + formatFloat(this.get_u16("fxholypower") / 10.0 + 1, "", 0, 1) + "$RED$";
	}
}

class CStatusGrav : CStatusBase
{
	void onTick(CBlob@ this)
	{
		this.set_f32("basegrav", this.get_f32("basegrav") / (this.get_u16("fxgravpower") / 5.0 + 1));
	}
	string getFxName()
	{
		return "fxgrav";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 5, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxgravtime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxgravpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Reduce gravity by $GREEN$((power / 5) + 1)$GREEN$";
		return "Reduce gravity by $GREEN$" + formatFloat(this.get_u16("fxgravpower") / 5.0 + 1, "", 0, 1) + "$GREEN$";
	}
}

class CStatusRegen : CStatusBase
{
	void onTick(CBlob@ this)
	{
		if(getGameTime() % 15 == 0)
			this.server_SetHealth(Maths::Max(Maths::Min(this.getHealth() + this.get_u16("fxregenpower") * 0.01, getMaxHealth(this)), this.getHealth()));
	}
	string getFxName()
	{
		return "fxregen";
	}
	void onApply(CBlob@ this)
	{
		if(isClient())
		{
			CSpriteLayer@ l = this.getSprite().addSpriteLayer("fxregen", "Regen.png", 8, 8);
			l.TranslateBy(Vec2f(0, -16));
			l.SetIgnoreParentFacing(true);
			l.SetRelativeZ(1);
		}
	}

	void onRemove(CBlob@ this)
	{
		if(isClient())
		{
			this.getSprite().RemoveSpriteLayer("fxregen");
		}
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 6, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxregentime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxregenpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Regenerate $GREEN$(power * 0.01)$GREEN$";
		return "Regenerate $GREEN$" + formatFloat(this.get_u16("fxregenpower") * 0.01, "", 0, 1) + "$GREEN$HP every half-second";
	}
}

class CStatusLightFall : CStatusBase
{
	void onTick(CBlob@ this)
	{
		if((getGameTime() % 15 == 0 || (this.getVelocity().Length() >= 4 && getGameTime() % 2 == 0)) && isClient())
		{
			CParticle@ p = makeGibParticle("LightFall.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(XORRandom(10) - 5, XORRandom(10) - 5) / 10.0 + this.getVelocity() / 2, 0, XORRandom(4), Vec2f(8, 8), 0.1, 0, "");
			if(p !is null)
			{
				p.fadeout = true;
				p.gravity = Vec2f(0, 0.03 + XORRandom(30) / 1000.0);
				p.damping = 0.98;
				p.rotation = Vec2f(XORRandom(100) - 50, XORRandom(100) - 50) / 50.0;
				p.diesoncollide = true;
				p.scale = 1;
				p.freerotationscale = 0.5;
			}
		}
			
	}
	string getFxName()
	{
		return "fxlightfall";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 7, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxlightfalltime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		//GUI::DrawTextCentered("" + this.get_u16("fxregenpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	string getHoverText(CBlob@ this, bool algo)
	{
		return "$GREEN$Negate$GREEN$ fall damage and stun";
	}
}

class CStatusGhostLike : CStatusBase
{
	void onTick(CBlob@ this)
	{
		if(this.isKeyPressed(key_up))
		{
			this.setVelocity(this.getVelocity() + Vec2f(0, -0.2));
		}
		if(this.isKeyPressed(key_down))
		{
			this.setVelocity(this.getVelocity() + Vec2f(0, 0.2));
		}
	}
	void onApply(CBlob@ this)
	{
		CShape@ shape = this.getShape();
		if(!this.exists("ghostliketogglecoll") && shape !is null)
		{
			this.set_bool("ghostliketogglecoll", shape.getConsts().mapCollisions);
		}
		if(this.get_bool("ghostliketogglecoll"))
			shape.getConsts().mapCollisions = false;
	}

	void onRemove(CBlob@ this)
	{
		CShape@ shape = this.getShape();
		if(this.get_bool("ghostliketogglecoll"))
			shape.getConsts().mapCollisions = true;
	}
	string getFxName()
	{
		return "fxghostlike";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 8, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxghostliketime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		//GUI::DrawTextCentered("" + this.get_u16("fxregenpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		return "$GREEN$Allow$GREEN$ phasing through tiles";
	}
}

class CStatusSpeed : CStatusBase
{
	void onTick(CBlob@ this)
	{
		float movemult = this.get_u16("fxspeedpower") / 10.0 + 1;
		RunnerMoveVars@ moveVars;
		if (!this.get("moveVars", @moveVars))
		{
			return;
		}
		moveVars.walkFactor *= movemult;
		//moveVars.jumpFactor *= movemult;
	}
	string getFxName()
	{
		return "fxspeed";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 9, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxspeedtime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxspeedpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Multiply walking speed by $GREEN$((power / 10.0) + 1)$GREEN$";
		return "Multiply walking speed by $GREEN$" + formatFloat(this.get_u16("fxspeedpower") / 10.0 + 1, "", 0, 1) + "$GREEN$";
	}
}

class CStatusLeap : CStatusBase
{
	void onTick(CBlob@ this)
	{
		float movemult = this.get_u16("fxleappower") / 7.5 + 1;
		RunnerMoveVars@ moveVars;
		if (!this.get("moveVars", @moveVars))
		{
			return;
		}
		//moveVars.walkFactor *= movemult;
		moveVars.jumpFactor *= movemult;
		if(moveVars.jumpCount == 0 && this.isKeyPressed(key_up))
		{
			Vec2f force(0, 0);
			if(this.isKeyPressed(key_left))
				force.x -= 1;
			if(this.isKeyPressed(key_right))
				force.x += 1;
			force *= movemult * 40.0f;
			this.AddForce(force);
		}
	}
	string getFxName()
	{
		return "fxleap";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 10, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxleaptime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxleappower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Multiply jumping power by $GREEN$((power / 7.5) + 1)$GREEN$";
		return "Multiply jumping power by $GREEN$" + formatFloat(this.get_u16("fxleappower") / 7.5 + 1, "", 0, 1) + "$GREEN$";
	}
}

class CStatusPoison : CStatusBase
{
	void onTick(CBlob@ this)
	{
		if(getGameTime() % 15 == 0)
			this.server_Hit(this, this.getPosition(), Vec2f_zero, this.get_u16("fxpoisonpower") * 0.01, 38, true);//38 is poison (CHitters.as)

		if((getGameTime() % 10 == 0) && isClient())
		{
			CParticle@ p = makeGibParticle("Poison.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(XORRandom(10) - 5, XORRandom(10) - 10) / 10.0, 0, XORRandom(4), Vec2f(8, 8), 0, 0, "");
			if(p !is null)
			{
				p.gravity = Vec2f(0, 0);
				p.scale = 0.5;
			}
		}
	}
	string getFxName()
	{
		return "fxpoison";
	}
	void renderIcon(Vec2f pos, CBlob@ this)
	{
		GUI::DrawIcon("EffectIcons.png", 11, Vec2f(16, 16), pos);
		GUI::DrawTextCentered("" + this.get_u16("fxpoisontime") / 30, pos + Vec2f(16, 32), SColor(255, 50, 255, 50));
		GUI::DrawTextCentered("" + this.get_u16("fxpoisonpower"), pos + Vec2f(16, -8), SColor(255, 50, 255, 50));
	}
	//Implement the rest later
	string getHoverText(CBlob@ this, bool algo)
	{
		if(algo)
			return "Lose $RED$(power * 0.01)$RED$HP every half-second";
		return "Lose $RED$" + formatFloat(this.get_u16("fxpoisonpower") * 0.01, "", 0, 1) + "$RED$HP every half-second";
	}
}





//----------------------------------END CLASS DEFINITIONS---------------------------------------










array<IStatusEffect@> effectlist = {
	cast<IStatusEffect@>(@CStatusDamageReduce()),	//0
	cast<IStatusEffect@>(@CStatusCorrupt()),		//1
	cast<IStatusEffect@>(@CStatusPure()),			//2
	cast<IStatusEffect@>(@CStatusUnholy()),			//3
	cast<IStatusEffect@>(@CStatusHoly()),			//4
	cast<IStatusEffect@>(@CStatusGrav()),			//5
	cast<IStatusEffect@>(@CStatusRegen()),			//6
	cast<IStatusEffect@>(@CStatusLightFall()),		//7
	cast<IStatusEffect@>(@CStatusGhostLike()),		//8
	cast<IStatusEffect@>(@CStatusSpeed()),			//9
	cast<IStatusEffect@>(@CStatusLeap()),			//10
	cast<IStatusEffect@>(@CStatusPoison())			//11
};

Vec2f getEffectIconCenter(int i)
{
	//return Vec2f(getScreenWidth() - 128 - i * 64, 128);
	return Vec2f(240 + i * 40, getScreenHeight() - 64);
}

bool isInList(string name, array<IStatusEffect@>@ effects)
{
	for(int i = 0; i < effects.size(); i++)
	{
		if(effects[i].getFxName() == name)
			return true;
	}
	return false;
}

array<int>@ getEffectIDs(array<IStatusEffect@>@ effects)
{
	array<int> ids;
	for(int i = 0; i < effects.size(); i++)
	{
		for(int j = 0; j < effectlist.size(); j++)
		{
			if(effects[i].getFxName() == effectlist[j].getFxName())//Why am I doing it like this? because I hate you
			{
				ids.push_back(j);
				break;
			}
		}
	}
	return @ids;
}

IStatusEffect@ addToList(string name, array<IStatusEffect@>@ effects)
{
	for(int i = 0; i < effectlist.size(); i++)
	{
		if(effectlist[i].getFxName() == name)
		{
			effects.push_back(@effectlist[i]);
			return @effectlist[i];
		}
	}
	print("Failed to add " + name + " to effect list!");
	return null;
}

void removeFromList(string name, array<IStatusEffect@>@ effects)
{
	for(int i = 0; i < effects.size(); i++)
	{
		if(effects[i].getFxName() == name)
		{
			effects.removeAt(i);
			return;
		}
	}
	print("Failed to remove effect " + name + ", wrong name given?");
}

void applyFx(CBlob@ blob, int time, int power, string name)
{
	bool didadd = false;
	if(blob.get_u16(name + "time") > 0)
	{
		if(blob.get_u16(name + "power") < power)
		{
			blob.set_u16(name + "time", time);
			blob.set_u16(name + "power", power);
		}
		else if(blob.get_u16(name + "power") == power)
		{
			blob.set_u16(name + "time", Maths::Max(time, blob.get_u16(name + "time")));
		}
	}
	else
	{
		blob.set_u16(name + "time", time);
		blob.set_u16(name + "power", power);
		didadd = true;
	}
	array<IStatusEffect@>@ effects;
	blob.get("effectls", @effects);
	if(effects !is null && !isInList(name, @effects))
	{
		IStatusEffect@ newfx = @addToList(name, @effects);
		if(newfx !is null && didadd)
			newfx.onApply(blob);
	}
	else
	{
		//print("Failed to add effect " + name);
		//Removed debug print cause it happens a lot in normal play :V
	}
}
