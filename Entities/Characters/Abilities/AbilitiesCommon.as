#include "Hitters.as"
#include "NodeCommon.as"
#include "ElementalCore.as"
#include "ExplosionCommon.as"
#include "Hitters.as"
#include "FxHookCommon.as"
#include "Utilities"

interface IAbility
{
    string getTextureName();
    CBlob@ getBlob();
    void activate();
    void onTick();
	void onDie();
	void onInit();
    void onReceiveCreateData(CBitStream@ steam);
    void onRender(CSprite@ sprite);
    void onCommand(u8 cmd, CBitStream @params);
    string getBorder();
    string getDescription();
	string getName();
	bool isEnabled();
}

class CAbilityBase : IAbility
{
    void onTick(){}
	void onDie(){}
	void onInit(){}
	string name = "CABilityBase";
    CBlob@ blob;

    string getTextureName() {error("Attempted to get texture on CABilityBase. Returning \"\""); return "";}
    string getDescription(){error("Attempted to get description on CABilityBase. Returning \"\""); return "";}
    string getBorder(){error("Attempted to get border on CABilityBase. Returning \"\""); return "";}

    CBlob@ getBlob() {return blob;}
	string getName(){return name;}


    CAbilityBase(CBlob@ _blob)
    {
        @blob = _blob;
    }

    void activate()
    {
        print("Base ability activated for some reason on blob " + blob.getConfig());
    }
    void onReceiveCreateData(CBitStream@ steam){}
    void onRender(CSprite@ sprite){}

    void onCommand( u8 cmd, CBitStream @params ){}

	void addToMyChat(string msg, SColor color = SColor(255,60,60,255))
    {
        if(blob.isMyPlayer())
        {
            client_AddToChat(msg, color);
        }
    }
	
	bool isEnabled(){
		return true;
	}
}

class CAbilityEmpty : CAbilityBase
{
	string getTextureName() override
	{
		return "abilityEmpty.png";
	}
	void activate() override
	{
		//I know this part may be hard to understand, a lot is going on here but I think you can work through it if you try
	}

    string getDescription() override
    {
        return "Does absolutely nothing... or does it? Yeah nothing.";
    }
	string getName() override
	{
		return "Empty";
	}
	string getBorder() override
	{
		return "Border.png";
	}
}

class CToggleableAbillityBase : CAbilityBase
{
    bool activated = false;
    void activate() override
    {
        activated = !activated;
    }

	string getBorder() override {return activated ? "BorderGreen" : "BorderRed";}
}

class CPoint : CAbilityBase
{
    CPoint(CBlob@ blob)
    {
        super(blob);

        blob.addCommandID("CPoint_timeSync");
        blob.addCommandID("CPoint_tposSync");
    }

    u32 _time = 0;
    u32 time
    {
        get{return _time;}
        set{CBitStream params; params.write_u32(value); blob.SendCommand(blob.getCommandID("CPoint_timeSync"),params);}
    }
    Vec2f _tpos;
    Vec2f tpos 
    {
        get{return _tpos;}
        set{CBitStream params; params.write_Vec2f(value); blob.SendCommand(blob.getCommandID("CPoint_tposSync"),params);}
    }

    string getDescription() override
    {
        return "Draws arrow to cursor for all to see";
    }

	string getName() override
	{
		return "Point";
	}

	string getTextureName() override
	{
		return "abilityPoint.png";
	}

	string getBorder() override
	{
		return "Border.png";
	}

    void activate() override
    {
        time = getGameTime() + 30*5;

        CPlayer@ p = blob.getPlayer();
        if(p !is null && p.isMyPlayer())
        {
            tpos = getControls().getMouseWorldPos();
        }
    }

    void onRender(CSprite@ sprite) override
    {
        if(time > getGameTime())
        {
            GUI::DrawSplineArrow(sprite.getBlob().getPosition(), tpos, SColor(255,255,127,127));
        }
    }

    void onCommand( u8 cmd, CBitStream@ params)
    {
        if(cmd == blob.getCommandID("CPoint_timeSync")){ _time = params.read_u32();}
        else if(cmd == blob.getCommandID("CPoint_tposSync")){ _tpos = params.read_Vec2f(); Sound::Play("Point.ogg", tpos,1);}
    }
}

class CConsume : CAbilityBase
{
	int unstableCoresConsumed = 0;

    int stomachItems = 0;
    int stomachMax = 10;
    CConsume(CBlob@ _blob)
    {
        super(_blob);
        blob.addCommandID("CONSUME_held_item");
    }
    string getName() override
    {
        return "Consume";
    }
	string getDescription() override
	{
		return "Eats currently held item if you aren't full";
	}
	string getTextureName() override
	{
		return "abilityConsume.png";
	}
	string getBorder() override
	{
		return "Border.png";
	}

    void activate() override
    {
        if(blob.isMyPlayer())
        {
            blob.SendCommand(blob.getCommandID("CONSUME_held_item"));
        }

    }

    void onTick() override
    {
        if(getGameTime() % (30*60) == 0)
        {
			stomachItems--;
            stomachItems = Maths::Max(stomachItems,0);
        } 
    }

    void onCommand(u8 cmd, CBitStream@ params)
    {
        if(cmd == blob.getCommandID("CONSUME_held_item"))
        {   
            CAbilityManager@ manager;
            blob.get("AbilityManager",@manager);

            string itemName;
            CBlob@ held = blob.getCarriedBlob();
            if(held is null){itemName = "nothing";}
            else
            {
                itemName = held.getConfig();
            }

            if(stomachItems < stomachMax)
            {
                int stomachItemsBefore = stomachItems;

				if(itemName == "vial")
				{
					drinkVial(held);
				}else if(itemName == "builder")
                {
                    addToMyChat("The fact that eating someone is crossing your mind is scary but you want to see what happens\nUpon eating the body you feel more evil inside");
                    stomachItems++;
                    held.server_Die();

                } else if(itemName == "log")
                {
                    addToMyChat("You attempt to eat the log but you can't fit it in your mouth");
                } else if(itemName == "chicken")
                {
                    addToMyChat("You attempt to eat this poor chicken but it's moving too much to get a good grip on it");
                } else if(itemName == "souldust")
                {
                    addToMyChat("You manage to eat this strange substance but to your surprise it has fallen right through your stomach and is now on the floor");
                } else if(itemName == "seed")
                {
                    addToMyChat("You eat the seed and with a bitter aftertaste you feel more... natural");
                    held.server_Die();
                    stomachItems++;
                } else if(itemName == "unstablecore")
                {
					unstableCoresConsumed++;
					switch(unstableCoresConsumed)
					{
						case 1: addToMyChat("After eating the core you find it strange that it seems to already have left your stomach, almost like it became part of you. You wonder what will happen if you eat more"); break;
						case 2: addToMyChat("You eat the core more quickly than before. You feel more unstable inside. You wonder what will happen if you eat more"); break;
						case 3: addToMyChat("You feel like you could explode inside but at the same time in control.\nYou unlocked a new ability!"); 
						manager.abilityMenu.addAbility(EAbilities::SelfDestruct);
						break;

						case 4: addToMyChat("After eating yet another core you feel that you're losing control. You worry what would happen if you ate anymore"); break;
					}
					if(unstableCoresConsumed > 4)
					{
						addToMyChat("You feel incredibly unstable");
						cast<CSelfDestruct>(manager.abilityMasterList.getAbility(EAbilities::SelfDestruct)).instability++;
					}
                    held.server_Die();
                } else if(itemName == "chaoscore")
				{
					if(manager.abilityMenu.addAbilityIfUnique(EAbilities::SelfDestruct))
					{
						cast<CSelfDestruct>(manager.abilityMasterList.getAbility(EAbilities::SelfDestruct)).cheaterMode = true;
						addToMyChat("uh oh someone is going to have a bad time");
					}
					else
					{
						addToMyChat("You ate it but to no effect");
					}
					held.server_Die();

				} else if(itemName == "thisisntajokeitem")
                {
                    addToMyChat("Instead of eating the infinity dildo you think of a better idea and shove it in the other end\nYou feel excited and powerful");
                    held.server_Die();
                    stomachItems++;
                } else if (itemName == "lifefruit")
                {
                    addToMyChat("The fruit magicall heals your wounds");
                    held.server_Die();
                    stomachItems++;
                    blob.server_Heal(99999999);
                } else if (held !is null && held.hasTag("Eatable"))
                {
					f32 healAmmount = getHealAmmount(held);
                    blob.server_Heal(healAmmount == 0 ? 1 : healAmmount);
					//Hi, sonic speaking, im modifying your code :^)
					if(held.exists("fxid"))
						applyFx(blob, held.get_u32("fxduration"), held.get_u16("fxpower"), effectlist[held.get_u8("fxid")].getFxName());
					//End sanic code
                    held.server_Die();
                    stomachItems++;
                } else if (itemName == "golemitedust")
				{
					held.server_Die();
					blob.set_string("turn_on_death", "golemites");
					blob.set_s32("golemiteCount",500);
					manager.abilityMenu.addAbility(EAbilities::Overtake);
				}
                else if(itemName == "nothing") {blob.getSprite().PlaySound("NoAmmo.ogg",0.5);}
                if(stomachItems > stomachItemsBefore){nomSound(held);}
            }
            else{addToMyChat("You don't think you can eat anymore for a while");}

        }
    }

	bool isEnabled() override{
		return blob.getCarriedBlob() !is null;
	}

    void nomSound(CBlob@ held)
    {
        if(held !is null)
        {
            blob.getSprite().PlaySound(held.get_string("eat sound"));
        }
    }

	f32 getHealAmmount(CBlob@ item)
	{
		string name = item.getConfig();
		if(name == "grain"){return 1;}
		if(name == "fishy"){return 1;}
		if(name == "heart"){return 1;}
		if(name == "steak"){return 2;}
		if(name == "food"){return 5;}
		return 0;
	}

	void drinkVial(CBlob@ vial)
	{
		CAlchemyTank@ tank = getTank(vial,0);
		int id = firstId(tank);
		if(id <= -1){return;}
		f32 ammount = tank.storage.getElement(id);
		f32 power = ammount/tank.maxelements;

		elementlist[id].vialIngestbehavior(blob,vial,power);

		tank.storage.setElement(id,0);
	}

}

class CSelfDestruct : CAbilityBase
{
	f32 instability = 0;
	bool cheaterMode = false;

    CSelfDestruct(CBlob@ blob)
    {
        super(blob);

		blob.addCommandID("SelfDestruct_Activate");
    }

	void onInit() override
	{
		blob.SetLightColor(SColor(255, 252, 86, 10));
        blob.SetLightRadius(24.0f);
	    blob.SetLight(true);

		if(isClient())
		{
			CSprite@ s = blob.getSprite();
			SColor[] oldColors = {
				SColor(255, 230, 167, 149),
				SColor(255, 207, 127, 74),
				SColor(255, 132, 71, 21),
				SColor(255, 85, 42, 17)
			};
			SColor[] newColors = {
				SColor(255, 246, 105, 65),
				SColor(255, 214, 95, 17),
				SColor(255, 146, 61, 24),
				SColor(255, 73, 21, 0)
			};
			ImageData@ bodyData = Texture::data(s.getTextureName());
			CSpriteLayer@ head = s.getSpriteLayer("head");
			if(head !is null)
			{
				if(!Texture::exists(head.getFilename()))
            	{
					if(!Texture::createFromFile(head.getFilename(), head.getFilename()))
						print("oh this is a problem");
           		}

				ImageData@ headData = Texture::data(head.getFilename());
				headData.remap(oldColors,newColors);
				Texture::createFromData(head.getFilename() + "_remapped",headData);
				head.SetTexture(head.getFilename() + "_remapped", head.getFrameWidth(),head.getFrameHeight());
			}
			bodyData.remap(oldColors,newColors);
			Texture::createFromData(s.getTextureName() + "_remapped",bodyData);
			s.SetTexture(s.getTextureName()+ "_remapped",s.getFrameWidth(),s.getFrameHeight());

		}
	}

    void onTick()
    {
        if(getGameTime() % 10 == 0)
        {
            CParticle@ p = ParticlePixel(blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), Vec2f(XORRandom(16) - 8, XORRandom(16) - 8) / 16.0, SColor(255, 200 + XORRandom(50), 100 + XORRandom(50), 50 + XORRandom(25)), true, 60);
            if(p !is null)
            {
                p.gravity = Vec2f_zero;
            }
        }

		if(instability > 0 && getGameTime() % 30 == 0)
		{
			if(XORRandom(30/instability) == 0)
			{
				activate();
			}
		}
    }

    string getDescription() override
    {
        return "Explode on command dealing extra damage to enemies";
    }
	string getName() override
	{
		return "Self Destruct";
	}
	string getTextureName() override
	{
		return "abilitySelfDestruct.png";
	}
	string getBorder() override
	{
		return "Border.png";
	}

    void activate() override
    {
		blob.SendCommand(blob.getCommandID("SelfDestruct_Activate"));
    }

	void onCommand(u8 cmd, CBitStream@ params)
	{
		if(cmd == blob.getCommandID("SelfDestruct_Activate"))
		{
			activateExplosion();
		}
	}

	void activateExplosion()
	{
		Explode(blob, blob.getPosition(), 80, 6, "Bomb.ogg", 16 * 5, 1.0, true, Hitters::explosion, true);
		blob.server_Hit(blob, blob.getPosition(), Vec2f_zero,cheaterMode ? 0 : 3.0, Hitters::explosion, true);
	}

	void onDie() override
	{
		activateExplosion();
	}
}

class CAbsorb : CAbilityBase
{
	CAbsorb(CBlob@ _blob)
	{
		super(_blob);

		blob.addCommandID("Absorb_activate");
	}

	void activate() override
	{
		blob.SendCommand(blob.getCommandID("Absorb_activate"));
	}

	string getDescription()
	{
		return "Absorbs stone or sand to increase your golemite count";
	}

	string getName()
	{
		return "Absorb";
	}
	string getTextureName() override
	{
		return "abilityAbsorb.png";
	}
	string getBorder() override
	{
		return "Border.png";
	}

	void onCommand(u8 cmd, CBitStream@ params)
	{
		if(cmd == blob.getCommandID("Absorb_activate"))
		{
			if(blob.get_s32("golemiteCount") == blob.get_s32("golemiteMax")){return;}

			CMap@ m = getMap();
			CBlob@[] blobs;
			m.getBlobsInRadius(blob.getPosition(),24,@blobs);
			for(int i = 0; i < blobs.size(); i++)
			{
				CBlob@ b = blobs[i];
				if(b.getConfig() == "mat_stone" || b.getConfig() == "mat_sand")
				{
					blob.set_s32("golemiteCount",Maths::Min(blob.get_s32("golemiteMax"), blob.get_s32("golemiteCount") + b.getQuantity()));
					b.server_Die();
					break;
				}
				else if(b.getConfig() == "boulder")
				{
					blob.set_s32("golemiteCount",Maths::Min(blob.get_s32("golemiteMax"), blob.get_s32("golemiteCount") + 30));
					b.server_Die();
				
					CAbilityManager@ manager;
					blob.get("AbilityManager",@manager);
					if(manager.abilityMenu.addAbilityIfUnique(EAbilities::SynthesizeBoulder))
					{
						addToMyChat("After absorbing the boulder, you learn how to create more from your golemites");
					}

					break;
				}
			}
		}
	}
}

class COvertake : CAbilityBase
{
	COvertake(CBlob@ _blob)
	{
		super(_blob);

		blob.addCommandID("Overtake_overtake");
	}

	string[] overtakeables =
	{
		"builder",
		"golem"
	};

	CBlob@ getNearbyOvertakable()
	{
		CMap@ m = getMap();
		CBlob@[] blobs;

		m.getBlobsInRadius(blob.getPosition(),24,@blobs);

		int index = -1;
		f32 best = 9999999999;

		for(int i = 0; i < blobs.size(); i++)
		{
			bool overtakeable = false;
			for(int j = 0; j < overtakeables.size(); j++)
			{
				if(overtakeables[j] == blobs[i].getConfig() && !blobs[i].hasTag("dead") && blobs[i].getPlayer() is null)
				{
					overtakeable = true;
					break;
				}
			}
			if(!overtakeable){continue;}
			f32 dist = blobs[i].getDistanceTo(blob);
			if(dist < best)
			{
				best = dist;
				index = i;
			}
		}

		if(index > -1)
		{
			return blobs[index];
		}
		return null;
	}

	void onRender(CSprite@ sprite)
	{
		if(blob.getConfig() == "golemites")
		{
			CAbilityManager@ manager;
			blob.get("AbilityManager",@manager);

			if(manager.abilityBar.getSelectedAbility().getName() == "Overtake")
			{
				CBlob@ b = getNearbyOvertakable();
				if(b !is null)
				{
					GUI::DrawArrow(blob.getPosition(), b.getPosition(), SColor(255,127,60,30));
				}
			}
		}
	}

	string getName(){return "Overtake";}
	string getDescription(){return "Attempt to control a nearby creature or object";}
	string getTextureName() override
	{
		return "abilityOvertake.png";
	}
	string getBorder() override
	{
		return "Border.png";
	}

	void activate() override
	{
		blob.SendCommand(blob.getCommandID("Overtake_overtake"));
	}

	void onCommand(u8 cmd, CBitStream@ params) override
	{
		if(cmd == blob.getCommandID("Overtake_overtake"))
		{
			if(blob.getConfig() == "golemites")
			{
				CBlob@ b = getNearbyOvertakable();
				if(b !is null)
				{
					if(b.getPlayer() !is null)
					{
						addToMyChat("You attempt to control the nearby body but it's soul fights back");
						return;
					}

					CAbilityManager@ manager;
					b.get("AbilityManager",@manager);
					manager.abilityMenu.addAbility(EAbilities::Overtake,false);

					CAbilityManager@ gmanager;
					blob.get("AbilityManager",@gmanager);

					b.set_s32("golemiteCount", blob.get_s32("golemiteCount"));
					b.set_s32("golemiteMax", blob.get_s32("golemiteMax"));
					b.server_setTeamNum(blob.getTeamNum());
					b.server_SetPlayer(blob.getPlayer());
					b.set_string("turn_on_death","golemites");
					b.set_bool("hasSynthesizeBoulder",gmanager.abilityMenu.hasAbility(EAbilities::SynthesizeBoulder));
					blob.server_Die();
				}
			}
			else
			{
				if(isServer())
				{
					CBlob@ n = server_CreateBlob("golemites",blob.getTeamNum(),blob.getPosition());
					n.set_s32("golemiteCount",blob.get_s32("golemiteCount"));
					n.Sync("golemiteCount",true);
					if(blob.get_bool("hasSynthesizeBoulder"))
					{
						CAbilityManager@ nManager;
						n.get("AbilityManager",@nManager);
						nManager.abilityMenu.addAbility(EAbilities::SynthesizeBoulder); 
						n.SendCommand(n.getCommandID("Server_Menu_Sync"));
					}
					n.server_SetPlayer(blob.getPlayer());
					blob.set_string("turn_on_death","");
				}
				CAbilityManager@ manager;
				blob.get("AbilityManager",@manager);
				manager.abilityMenu.removeAbilityByName("Overtake");

				setAllKeysPressed(blob,false);
			}
		}
	}
}

class CSynthesizeBoulder : CAbilityBase
{
	CSynthesizeBoulder(CBlob@ _blob)
	{
		super(_blob);

		blob.addCommandID("SynthesizeBoulder_activate");
	}

	string getName() override {return "Synthesize Boulder";}
	string getDescription()override {return "Solidifys $RED$100$RED$ golemites into a boulder";}
	string getTextureName() override
	{
		return "abilitySynthesizeBoulder.png";
	}
	string getBorder() override
	{
		return "Border.png";
	}

	void activate() override
	{
		blob.SendCommand(blob.getCommandID("SynthesizeBoulder_activate"));
	}

	void onCommand(u8 cmd, CBitStream@ params)
	{
		if(cmd == blob.getCommandID("SynthesizeBoulder_activate") && isServer())
		{
			CPlayer@ p = blob.getPlayer();
			if(p is null){return;}
			server_CreateBlob("boulder",blob.getTeamNum(),blob.getPosition()).SetDamageOwnerPlayer(p);

			blob.add_s32("golemiteCount",-100);
			blob.Sync("golemiteCount",true);
		}
	}
}

class CGolemiteRepair : CAbilityBase
{
	CGolemiteRepair(CBlob@ _blob)
	{
		super(_blob);
		blob.addCommandID("GolemiteRepair_activate");
	}

	string getName() override {return "Golemite Repair";}
	string getDescription()override {return "Replaces damged body parts with stone cost: $RED$25$RED$ ";}
	string getTextureName() override
	{
		return "abilityStoneRepair.png";
	}
	string getBorder() override
	{
		return "Border.png";
	}

	void activate() override
	{
		blob.SendCommand(blob.getCommandID("GolemiteRepair_activate"));
	}

	void onCommand(u8 cmd, CBitStream@ params)
	{
		if(cmd == blob.getCommandID("GolemiteRepair_activate"))
		{
			if(isServer())
			{
				blob.server_Heal(0.25);

				blob.add_s32("golemiteCount",-25);
				blob.Sync("golemiteCount",true);
			}

		}
	}

	bool isEnabled() {
		return blob.get_s32("golemiteCount") > 25;
	}
}

enum EAbilities
{
	Empty = 0,
	Point = 1,
	Consume = 2,
	SelfDestruct = 3,
	Absorb = 4,
	Overtake = 5,
	SynthesizeBoulder = 6,
	GolemiteRepair = 7
}

class CAbilityMasterList
{
	private IAbility@[] abilities;
	CBlob@ blob;

	CAbilityMasterList(CBlob@ _blob)
	{
		@this.blob = _blob;
	//order here matters, needs relate to the enum
		IAbility@[] _abilities = {
			CAbilityEmpty	(),
			CPoint				(blob),
			CConsume			(blob),
			CSelfDestruct		(blob),
			CAbsorb				(blob),
			COvertake			(blob),
			CSynthesizeBoulder	(blob),
			CGolemiteRepair(blob)
		};
		abilities = _abilities;//I can't figure out how to do an array litteral outside of right when you create a var so I just copy it into the main one
	}

	IAbility@ getAbility(int i)
	{
		if(i >= abilities.size()){error("Index out of bounds for abilities in CAbilityMasterList");}
		return abilities[i];
	}

	void activateAbility(int i)
	{
		getAbility(i).activate();
	}
}

f32 fDrawScale = 1; // this is actually 2x scale idk why kag does this
f32 fRealScale = fDrawScale/0.5;
Vec2f slotDimentions = Vec2f(16,16);
Vec2f slotSpacing = Vec2f(4,0);
Vec2f borderDimentions = Vec2f(18,18);
Vec2f borderOffset = Vec2f(-2,-2);
class CAbilityBar
{	
	CAbilityMasterList@ masterList;
	CBlob@ blob;

	private Vec2f initialBarOffset = Vec2f(8,8);
	private f32 backgroundThickness = 4;
	private u32 selectedSlot = 0;
	private u32[] slots = {
		EAbilities::Empty,
		EAbilities::Empty,
		EAbilities::Empty,
		EAbilities::Empty,
		EAbilities::Empty
	};


	CAbilityBar(CAbilityMasterList@ _masterList, CBlob@ blob)
	{
		@this.masterList = _masterList;
		@this.blob = blob;
	}

	u32 getSlot(u32 i)
	{
		if(i >= slots.size()) {error("Index out of bounds for slots");}
		return slots[i];
	}

	IAbility@ getAbility(u32 i)
	{
		return masterList.getAbility(getSlot(i));
	}

	IAbility@ getSelectedAbility()
	{
		return getAbility(selectedSlot);
	}

	void activateSelectedAbility()
	{
		activateAbility(selectedSlot);
	}

	void setSlot(u32 slot, u32 i)
	{
		if(slot <= slots.length)
		{
			slots[slot] = i; 
		}
		else 
		{
			error("Tried to set slot out of bounds");
		}
	}

	void setHoveredSlot(u32 i)
	{
		s32 hovered = getHoveredSlot();
		if(hovered > -1)
		{
			setSlot(hovered,i);
		}
	}

	void activateAbility(u32 i)//this should only be called client side on the client activating it, the ability *should* handle sending out the activation to the server
	{
		masterList.getAbility(getSlot(i)).activate();
	}

	Vec2f getSlotPosition(u32 i)
	{
		return initialBarOffset + (slotSpacing * i) + Vec2f(slotDimentions.x * i * fRealScale, initialBarOffset.y);
	}

	bool isSlotHovered(u32 i)
	{
		Vec2f slotPos = getSlotPosition(i);
		Vec2f mpos = getControls().getMouseScreenPos();

		return mpos.x >= slotPos.x && mpos.x <= (slotPos.x + slotDimentions.x * fRealScale) && mpos.y >= slotPos.y && mpos.y <= (slotPos.y + slotDimentions.y * fRealScale);
	}

	int getHoveredSlot()
	{
		for(int i = 0; i < slots.size(); i++)
		{
			if(isSlotHovered(i)){return i;}
		}

		return -1;
	}

	void onTick()
	{
		if(blob.isMyPlayer())
		{
			CControls@ controls = getControls();
			if(controls.isKeyJustPressed(KEY_LBUTTON))
			{
				int hovered = getHoveredSlot();
				if(hovered > -1)
				{
					selectedSlot = hovered;
				}
			}
			if(controls.isKeyJustPressed(KEY_KEY_B))
			{
				if(getSelectedAbility().isEnabled())
				{
					activateSelectedAbility();
					getRules().set_bool("activated_once",true);
				} else 
				{
					blob.getSprite().PlaySound("NoAmmo.ogg",0.5);
				}
			}

			if(controls.isKeyPressed(KEY_LSHIFT))
			{
				if(controls.isKeyJustPressed(KEY_KEY_1)){selectedSlot = 0;}
				if(controls.isKeyJustPressed(KEY_KEY_2)){selectedSlot = 1;}
				if(controls.isKeyJustPressed(KEY_KEY_3)){selectedSlot = 2;}
				if(controls.isKeyJustPressed(KEY_KEY_4)){selectedSlot = 3;}
				if(controls.isKeyJustPressed(KEY_KEY_5)){selectedSlot = 4;}
			}
		}
	}
	Vec2f getBarEndPos()
	{
		return getSlotPosition(slots.length - 1) + slotDimentions * fRealScale + Vec2f(backgroundThickness,backgroundThickness);
	}
	Vec2f getNameDrawStartPos()
	{
		CAbilityManager@ m;
		blob.get("AbilityManager",@m);
		return m.abilityMenu.menuOpenTargetPos+
		Vec2f(m.abilityMenu.menuButtonDimentions.x*fRealScale,0);
	}
	Vec2f getNameDrawEndPos()
	{
		CAbilityManager@ m;
		blob.get("AbilityManager",@m);
		return Vec2f(getBarEndPos().x,m.abilityMenu.menuButtonDimentions.y * fRealScale + m.abilityMenu.menuOpenTargetPos.y);
	}
	void onRender()
	{
		if(blob.isMyPlayer())
		{
			GUI::DrawRectangle(initialBarOffset - Vec2f(backgroundThickness,-1), getBarEndPos()  ); //draw background

			for(int i = 0; i < slots.size(); i++)//draw individual slots
			{
				Vec2f drawPos = getSlotPosition(i);

				if(getAbility(i).isEnabled())
				{
					if(isSlotHovered(i))
					{
						GUI::DrawIcon(getAbility(i).getTextureName(),0,slotDimentions,drawPos,fDrawScale,SColor(127,255,255,255));
					}
					else
					{
						GUI::DrawIcon(getAbility(i).getTextureName(),0,slotDimentions,drawPos,fDrawScale);
					}
				} else {
					GUI::DrawIcon(getAbility(i).getTextureName(),0,slotDimentions,drawPos,fDrawScale,SColor(255,127,127,127));
				}
			}

			GUI::DrawIcon(getSelectedAbility().getBorder(),0,borderDimentions,getSlotPosition(selectedSlot) + borderOffset,fDrawScale);
			GUI::DrawRectangle(getNameDrawStartPos(),getNameDrawEndPos());
			GUI::DrawTextCentered(getSelectedAbility().getName(), (getNameDrawStartPos() + getNameDrawEndPos())/2, SColor(255,0,0,0));
			
			if(!getRules().get_bool("activated_once") || u_showtutorial) 
			{
				GUI::DrawText("Press B to activate ability! Click to navigate GUI", getSlotPosition(slots.size() -1) + Vec2f(36,16), SColor(255,127,127,127));
			}
		}
	}

}

class CAbilityMenu //this will act as the "unlocked" abilities and run them every tick as well as acting as a menu to add to the bar
{
	CAbilityMasterList@ masterList;
	CAbilityBar@ bar;
	CBlob@ blob;
	Vec2f menuStartPos = Vec2f(5,52);
	Vec2f menuOpenTargetPos = Vec2f(5,52);
	Vec2f menuClosedTargetPos; //set in constructor to prevent null poitner access
	Vec2f menuCurrentPos = Vec2f(0,0);
	Vec2f menuButtonDimentions = Vec2f(32,16);
	int columns = 5;
	int yItemSpacing = 4;
	bool menuOpen = false;
	bool newAbility = false;//note abilities are added right away so this could be true by default
	s32 heldItem = -1;

	u32[] list = {
		EAbilities::Empty
	};

	CAbilityMenu(CAbilityMasterList@ _masterList, CAbilityBar@ _bar, CBlob@ _blob)
	{
		@this.masterList = _masterList;
		@this.bar = _bar;
		@this.blob = _blob;

		for(int i = 0; i < list.size(); i++)
		{
			masterList.getAbility(list[i]).onInit();
		}

		blob.addCommandID("Menu_Sync");
		blob.addCommandID("Server_Menu_Sync");

		menuClosedTargetPos = Vec2f(-getMenuDimentions().x,52);
		menuCurrentPos = menuClosedTargetPos;
	}

	void addAbility(u32 i, bool activateNewAbility = true)
	{
		list.push_back(i);
		masterList.getAbility(i).onInit();
		if(activateNewAbility)
		{
			newAbility = true;
			Sound::Play("NewAbility.ogg");
		}
	}

	bool addAbilityIfUnique(u32 i)
	{
		if(!hasAbility(i))
		{
			addAbility(i);
			return true;
		}
		return false;
	}

	IAbility@ getAbility(u32 i)
	{
		return masterList.getAbility(list[i]);
	}

	bool hasAbility(u32 i)
	{
		for(int j = 0; j < list.size(); j++)
		{
			if(list[j] == i) {return true;}
		}
		return false;
	}

	void removeAbilityByName(string s)
	{
		for(int i = 0; i < list.size(); i++)
		{
			if(getAbility(i).getName() == s)
			{
				list.erase(i);
				i--;
			}
		}
	}

	void onTick()
	{
		for(int i = 0; i < list.size(); i++)
		{
			masterList.getAbility(list[i]).onTick();
		}
		if(isServer() && getGameTime() % 30 == 0)
		{
			sendSync();
		}

		if(menuOpen){newAbility = false;}
		if(blob.isMyPlayer())
		{
			CControls@ controls = getControls();
			if(controls.isKeyJustPressed(KEY_KEY_I))
			{
				menuOpen = !menuOpen;
			}
			if(controls.isKeyJustPressed(KEY_LBUTTON))
			{
				if(menuOpen)
				{
					heldItem = getHoveredItem();
				}

				if(!isMenuHovered())
				{
					menuOpen = false;
				}
				if(isMenuButtonHovered())
				{
					menuOpen = true;
				}
			}
			if(!controls.isKeyPressed(KEY_LBUTTON))
			{
				if(menuOpen && heldItem > -1)
				{
					bar.setHoveredSlot(list[heldItem]);
					heldItem = -1;
				}
			}
		}
	}

	void sendSync()
	{
		CBitStream params;
		params.write_u32(list.size());
		for(int i = 0; i < list.size(); i++)
		{
			params.write_u32(list[i]);
		}

		blob.SendCommand(blob.getCommandID("Menu_Sync"),params);
	}

	bool contains(u32[] list, u32 value)
	{
		for(int i = 0; i < list.size(); i++)
		{
			if(value == list[i])
			{
				return true;
			}
		}
		return false;
	}

	void onCommand(u8 cmd, CBitStream@ params)
	{
		for(int i = 0; i < list.size(); i++)
		{
			masterList.getAbility(list[i]).onCommand(cmd,params);
		}

		if(cmd == blob.getCommandID("Menu_Sync"))
		{
			u32 size = params.read_u32();
			u32[] oldList = list;
			list.clear();
			for(int i = 0; i < size; i++)
			{
				list.push_back(params.read_u32());

				if(!contains(oldList, i))
				{
					getAbility(i).onInit();
				}
			}
		}
		if(cmd == blob.getCommandID("Server_Menu_Sync"))
		{
			if(isServer())
			{
				sendSync();
			}
		}
	}

	void onDie()
	{
		for(int i = 0; i < list.size(); i++)
		{
			masterList.getAbility(list[i]).onDie();
		}
	}

	int getRows()
	{
		f32 fColumns = columns; //just a way to cast to float
		return Maths::Ceil(list.size()/fColumns);
	}

	Vec2f getMenuEndPos()
	{
		return menuCurrentPos + getMenuDimentions();
	}

	Vec2f getMenuDimentions()
	{
		return  Vec2f(3 + columns * (slotDimentions.x * fRealScale) + columns * slotSpacing.x, getRows() * (slotDimentions.y * fRealScale) + getRows() * yItemSpacing + 2) + Vec2f(0,4);
	}

	Vec2f getItemPos(u32 i)
	{
		return Vec2f(
			i%columns * (slotDimentions.x * fRealScale + slotSpacing.x),//x
			(i/columns) * (fRealScale * slotDimentions.y + yItemSpacing))//y
		+ menuCurrentPos + Vec2f(4,4);//offset
	}

	s32 getHoveredItem()
	{
		Vec2f mpos = getControls().getMouseScreenPos();
		for(int i = 0; i < list.size(); i++)
		{
			Vec2f itemPos = getItemPos(i);

			if(mpos.x >= itemPos.x && mpos.x <= itemPos.x + (slotDimentions.x * fRealScale) && mpos.y >= itemPos.y && mpos.y <= itemPos.y + (slotDimentions.y * fRealScale))
			{
				return i;
			}
		}

		return -1;
	}

	bool isMenuHovered()
	{
		Vec2f mpos = getControls().getMouseScreenPos();
		return
		mpos.x >= menuCurrentPos.x &&
		mpos.x <= getMenuEndPos().x &&
		mpos.y >= menuCurrentPos.y &&
		mpos.y <= getMenuEndPos().y;
	}

	bool isMenuButtonHovered()
	{
		Vec2f mpos = getControls().getMouseScreenPos();
		return 
		mpos.x >= menuOpenTargetPos.x &&
		mpos.x <= menuOpenTargetPos.x + menuButtonDimentions.x * fRealScale &&
		mpos.y >= menuOpenTargetPos.y  &&
		mpos.y <= menuOpenTargetPos.y + menuButtonDimentions.y * fRealScale;

	}

	void onRender(CSprite@ sprite)
	{
		for(int i = 0; i < list.size(); i++)
		{
			masterList.getAbility(list[i]).onRender(sprite);
		}

		if(blob.isMyPlayer())
		{
			//menu button icon
			if(isMenuButtonHovered())
			{
				GUI::DrawIcon("Manage.png", 0, menuButtonDimentions, menuOpenTargetPos,fDrawScale,SColor(255,127,127,127));
			}
			else if(newAbility)
			{
				f32 val1 = (Maths::Sin(getGameTime()/2) + 1)/2;
				f32 val2 = (Maths::Sin(getGameTime()/2.1) + 1)/2;
				f32 val3 = (Maths::Sin(getGameTime()/1.9) + 1)/2;
				GUI::DrawIcon("Manage.png", 0, menuButtonDimentions, menuOpenTargetPos,fDrawScale,SColor(255,val1 * 127 + 127,val2 * 127 + 127, val3 * 127 + 127));
			}
			else
			{
				GUI::DrawIcon("Manage.png", 0, menuButtonDimentions, menuOpenTargetPos,fDrawScale);
			}

			menuCurrentPos = Vec2f_lerp(menuCurrentPos,menuOpen ? menuOpenTargetPos : menuClosedTargetPos,0.1);
			if(menuOpen || true)
			{
				GUI::DrawRectangle(menuCurrentPos,getMenuEndPos());//background

				for(int i = 0; i < list.size(); i++)//menu
				{
					if(i == heldItem || (heldItem <= -1 && i == getHoveredItem()))
					{
						GUI::DrawIcon(getAbility(i).getTextureName(),0,slotDimentions,getItemPos(i),fDrawScale,SColor(127,255,255,255));
					}
					else
					{
						GUI::DrawIcon(getAbility(i).getTextureName(),0,slotDimentions,getItemPos(i),fDrawScale);
					}
				}

				if(getHoveredItem() > -1) // desc
				{
					string desc = getAbility(getHoveredItem()).getDescription();
					Vec2f textDimentions;
					GUI::SetFont("menu");
					GUI::GetTextDimensions(desc, textDimentions);
					GUI::DrawText(desc, getControls().getMouseScreenPos() + Vec2f(64,0),Vec2f(64,0) + textDimentions, SColor(255,0,0,0), true, true,true);
				}

				//held icon
				if(heldItem > -1)
				{
					GUI::DrawIcon(getAbility(heldItem).getTextureName(), 0, slotDimentions, getControls().getMouseScreenPos() - (slotDimentions * fRealScale)/2,fDrawScale);
				}
			}
		}
	}
}

class CAbilityManager
{
    CAbilityMasterList@ abilityMasterList;
    CAbilityMenu@ abilityMenu;
	CAbilityBar@ abilityBar;
    CBlob@ blob;

	CAbilityManager(CBlob@ blob)
	{
		@this.blob = blob;
		@abilityMasterList = CAbilityMasterList(blob);
		@abilityBar = CAbilityBar(abilityMasterList,blob);
		@abilityMenu = CAbilityMenu(abilityMasterList,abilityBar,blob);
	}

    void onInit()
    {	

    }

    void onCommand( CBlob@ blob, u8 cmd, CBitStream @params )
    {
		abilityMenu.onCommand(cmd,params);
    }

    void onTick(CBlob@ blob)
    {
		abilityMenu.onTick();
		abilityBar.onTick();
    }
    void onRender(CSprite@ sprite)
    {
		abilityBar.onRender();
		abilityMenu.onRender(sprite);
    }
    void onReceiveCreateData(CBitStream@ stream )
    {

    }

	void onDie()
	{
		abilityMenu.onDie();
	}
}
