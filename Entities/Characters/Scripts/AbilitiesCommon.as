#include "Hitters.as"
#include "ExplosionCommon.as"

interface IAbility
{
    string getTextureName();
    CBlob@ getBlob();
    void activate();
    void onTick();
    void onRender(CSprite@ sprite);
    void onCommand(CBlob@ blob, u8 cmd, CBitStream @params);
    string getBorder();
    string getDescription();
}

class CAbilityBase : IAbility
{
    void onTick(){}
    string getBorder(){return border;}
    string textureName;
    string border = "Border.png";
    string description = "Description not added";
    CBlob@ blob;

    string getTextureName() {return textureName;}
    string getDescription(){return description;}
    CBlob@ getBlob() {return blob;}


    CAbilityBase(string _textureName, CBlob@ _blob)
    {
        textureName = _textureName;
        @blob = _blob;
    }

    void activate()
    {
        print("Base ability activated for some reason on blob " + blob.getConfig());
    }

    void onRender(CSprite@ sprite){}

    void onCommand(CBlob@ blob, u8 cmd, CBitStream @params ){}
}

class CAbilityEmpty : CAbilityBase
{
	string getTextureName() override
	{
		return "abilityEmpty.png";
	}
	void activate() override
	{
		//I know this part may be hard to under stand, a lot is going on here but I think you can work through it if you try
	}

    string getDescription() override
    {
        return "Empty";
    }
}

class CToggleableAbillityBase : CAbilityBase
{
    CToggleableAbillityBase()
    {
        border = "BorderRed.png";
    }
    bool activated = false;
    void activate() override
    {
        activated = !activated;

        border = activated ? "BorderGreen" : "BorderRed";
    }
}

class CAbilityManager
{
    IAbility@[] abilities;
	u32[] abilityBar;
    uint selected = 0;
    CBlob@ blob;
	bool menuOpen = false;

    IAbility@ getSelected() {return abilities[abilityBar[selected]];}

    void onInit(CBlob@ blob)
    {	

        abilities.push_back(CAbilityEmpty());//0
        abilities.push_back(CPoint(blob,"abilityPoint.png"));//1
        abilities.push_back(CConsume("abilityConsume.png",blob));//2

        abilityBar.push_back(1);
        abilityBar.push_back(2);
        abilityBar.push_back(0);
        abilityBar.push_back(0);
        abilityBar.push_back(0);


		

        @this.blob = blob;
        blob.addCommandID("ActivateAbilityIndex");
        blob.addCommandID("syncAbilityBar");
    }

    void sendActivateAbilityIndexCommand(int i)
    {
        CBitStream params;
        params.write_s32(i);
        this.blob.SendCommand(this.blob.getCommandID("ActivateAbilityIndex"),params);
    }
    
    void syncAbilityBar()
    {
        CBitStream params;
        for(int i = 0; i < abilityBar.length(); i++)
        {
            params.write_u32(abilityBar[i]);
        }

        blob.SendCommand(blob.getCommandID("syncAbilityBar"),params);
    }

    void onCommand( CBlob@ blob, u8 cmd, CBitStream @params )
    {
        if(cmd == blob.getCommandID("ActivateAbilityIndex"))
        {
            activateAbilityIndex(params.read_s32());
        }
        else if(cmd == blob.getCommandID("syncAbilityBar"))
        {
            for(int i = 0; i < abilityBar.length(); i++)
            {
                abilityBar[i] = params.read_u32();
            }
        }
        else
        {
            for(int i = 0; i < abilities.length(); i++)
            {
                abilities[i].onCommand(blob,cmd,params);
            }
        }
    }

    void activateAbilityIndex(int i)
    {
        if(i > abilityBar.length())
        {
            error("Attempted to run ability out of index");
            return;
        }

        abilities[abilityBar[i]].activate();
    }

	int holdingIndex = -1;

    void onTick(CBlob@ blob)
    {
        for(int i = 0; i < abilities.length(); i++)
        {
            abilities[i].onTick();
        }
        
        if(isMe(blob))
        {
			if(getControls().isKeyJustPressed(KEY_KEY_I))
			{
				start = getControls().getMouseScreenPos();
				menuOpen = !menuOpen;
			}
            if(getControls().isKeyJustPressed(KEY_KEY_B))
            {
                sendActivateAbilityIndexCommand(selected);
            }

            if(getControls().isKeyJustPressed(KEY_LBUTTON))
            {
                Vec2f mpos = getControls().getMouseScreenPos();
				
				int newselection = getAbilityIndexHovered(mpos);
                selected = newselection > -1 ? newselection : selected;

				if(menuOpen)
				{
					holdingIndex = getAbilityMenuIndexHovered(mpos);

                    if(mpos.x < start.x || mpos.x > end.x || mpos.y > end.y || mpos.y < start.y)
                    {
                        menuOpen = false;
                    }
				}
                
                Vec2f buttonDimentions = Vec2f(32,16);
                Vec2f drawPos = Vec2f(4,40);

                if(mpos.x > drawPos.x && mpos.x < buttonDimentions.x*2 + drawPos.x && mpos.y > drawPos.y && mpos.y < drawPos.y + buttonDimentions.y *2)
                {
                    menuOpen = true;
                    start = drawPos;
                }

            }

			if(!getControls().isKeyPressed(KEY_LBUTTON))
			{
				if(holdingIndex > -1)
				{
					int abilityBarIndex = getAbilityIndexHovered(getControls().getMouseScreenPos());
					if(abilityBarIndex > -1)
					{
						abilityBar[abilityBarIndex] = holdingIndex;
                        syncAbilityBar();
					}
				}
				holdingIndex = -1;
			}
        }
    }

    Vec2f getAbilityPos(int index)
    {
        return Vec2f(4 + 4*index + 32 * index, 4);
    }

    int getAbilityIndexHovered(Vec2f pos)
    {
		int index = -1;
        if(pos.y <= 40 && pos.y >= 4)
        {
            for(int i = 0; i < abilityBar.length(); i++)
            {
                int x = (4 + 4*i + 32 * i);
                if(pos.x >= x && pos.x <= x + 32)
                {
                    index = i;
                    break;
                }
            }
        }
		return index;
    }

	int getAbilityMenuIndexHovered(Vec2f pos)
	{
		int index = -1;

		for(int i = 0; i < abilities.length(); i++)
		{
			Vec2f abilityPos = Vec2f(i%numColumns * 36, i / numColumns * 36) + start + Vec2f(4,4);

			if(pos.x >= abilityPos.x && pos.x <= abilityPos.x + 32 && pos.y >= abilityPos.y && pos.y <= abilityPos.y + 32)
			{
				index = i;
				break;
			}
		}

		return index;
	}

	u32 numColumns = 5;

	Vec2f start;
	Vec2f end;
	int getRowCount()
	{
		int rowCount;
		float fNumColumns = numColumns;
		float rowsUneven = (abilities.length() / fNumColumns );
		rowCount = Maths::Ceil(rowsUneven);
		return rowCount;
	}
    void onRender(CSprite@ this)
    {
        for(int i = 0; i < abilities.length(); i++)
        {
            abilities[i].onRender(this);
        }

        if(!isMe(blob)) {return;}
        for(int i = 0; i < abilityBar.length(); i++)//draw toolbar abilities
        {
            GUI::DrawIcon(abilities[abilityBar[i]].getTextureName(), 0, Vec2f(16,16), getAbilityPos(i), 1);
			int hovered = getAbilityIndexHovered(getControls().getMouseScreenPos());
			if(hovered > -1)
			{
				GUI::DrawIcon(abilities[abilityBar[hovered]].getBorder(),0,Vec2f(18,18), Vec2f(2 + 4*hovered + 32 * hovered,2),1,SColor(127,127,127,127));
			}
        }
        GUI::DrawIcon(getSelected().getBorder(),0,Vec2f(18,18), Vec2f(2 + 4*selected + 32 * selected,2),1);// draw toolbar selected

        //GUI::DrawText("Activate: {B}\nManage: {I}", Vec2f(16,40), SColor(255,127,127,127));
        Vec2f mpos = getControls().getMouseScreenPos();
        Vec2f buttonDimentions = Vec2f(32,16);
        Vec2f drawPos = Vec2f(4,40);
        if(mpos.x > drawPos.x && mpos.x < buttonDimentions.x*2 + drawPos.x && mpos.y > drawPos.y && mpos.y < drawPos.y + buttonDimentions.y *2) //all *2 because default scale is *2
        {
            GUI::DrawIcon("Manage.png",0, buttonDimentions, drawPos,1,SColor(127,127,127,127));
        }
        else
        {
            GUI::DrawIcon("Manage.png",0, buttonDimentions, drawPos,1);
        }

		if(menuOpen)//menu rendering
		{
			end = Vec2f(start.x + numColumns * 4 + numColumns * 32 +4,start.y + getRowCount() * 36 + 4);

			GUI::DrawRectangle(start,end);

			for(int i = 0; i < abilities.length; i++)
			{
				Vec2f iconPos = Vec2f(i%numColumns * 36, i / numColumns * 36) + start + Vec2f(4,4);
				if(holdingIndex > -1 && holdingIndex == i)
				{
					GUI::DrawIcon(abilities[i].getTextureName(), 0, Vec2f(16,16), iconPos, 1,SColor(127,60,60,60));
				}
				else
				{
					GUI::DrawIcon(abilities[i].getTextureName(), 0, Vec2f(16,16), iconPos, 1);
				}
			}

			int hovered = holdingIndex > -1 ? holdingIndex : getAbilityMenuIndexHovered(getControls().getMouseScreenPos());
			if(hovered > -1)
			{
				GUI::DrawIcon(getSelected().getBorder(),0,Vec2f(18,18), start + Vec2f(2,2) + Vec2f(hovered%numColumns * 36, hovered/numColumns * 36),1);

                GUI::DrawText(abilities[hovered].getDescription(),start + Vec2f(0,-12),SColor(255,250,250,255));
			}
		}

		if(holdingIndex > -1)
		{
			GUI::DrawIcon(abilities[holdingIndex].getTextureName(),0,Vec2f(16,16),getControls().getMouseScreenPos() - Vec2f(16,16),1);
		}
    }
}

bool isMe(CBlob@ blob)
{
    return blob.getPlayer() !is null && blob.getPlayer() is getLocalPlayer();
}

class CPoint : CAbilityBase
{
    CPoint(CBlob@ blob, string textureName)
    {
        super(textureName,blob);

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
        return "Point";
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

    void onCommand(CBlob@ blob, u8 cmd, CBitStream@ params)
    {
        if(cmd == blob.getCommandID("CPoint_timeSync")){ _time = params.read_u32();}
        else if(cmd == blob.getCommandID("CPoint_tposSync")){ _tpos = params.read_Vec2f();}
    }
}

class CConsume : CAbilityBase
{
    int stomachItems = 0;
    int stomachMax = 10;
    CConsume(string _textureName, CBlob@ _blob)
    {
        super(_textureName,_blob);
        blob.addCommandID("CONSUME_held_item");
    }
    string getDescription() override
    {
        return "Consume";
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
            stomachItems = Maths::Max(stomachItems--,0);
        } 
    }

    void onCommand(CBlob@ blob, u8 cmd, CBitStream@ params)
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

                if(itemName == "fishy")
                {   
                    addToMyChat("The fish" + (held.hasTag("dead") ? " slowly slides " : " agressivly wiggles ") + "down your throat nearly causing to to gag\nYou feel fuller but not much else");
                    stomachItems++;
                    held.server_Die();
                } else if(itemName == "grain")
                {
                    addToMyChat("The grain is dry but you manage to get it down\nYou feel fuller but not much else");
                    stomachItems++;
                    held.server_Die();
                } else if(itemName == "builder")
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
                    addToMyChat("You consider to do the unthinkable and the next thing you know it's over\nYou feel unstable\nYou've gained a new ability: Self Destruct!");
                    manager.abilities.push_back(CSelfDestcruct("abilitySelfDestruct.png",blob));
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
                }
                else if(itemName == "nothing") {addToMyChat("You prepare to take a big bite but then chop down on nothing\nYou can't eat nothing");}
            }
            else{addToMyChat("You don't think you can eat anymore for a while");}

        }
    }

    void addToMyChat(string msg)
    {
        if(blob.isMyPlayer())
        {
            client_AddToChat(msg, SColor(255,60,60,255));
        }
    }

}

class CSelfDestcruct : CAbilityBase
{
    CSelfDestcruct(string textureName, CBlob@ blob)
    {
        super(textureName,blob);

        blob.SetLightColor(SColor(255, 252, 86, 10));
        blob.SetLightRadius(24.0f);
	    blob.SetLight(true);
    }

    void onTick()
    {
        CBlob@ blob = this.getBlob();
        if(getGameTime() % 10 == 0)
        {
            CParticle@ p = ParticlePixel(blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), Vec2f(XORRandom(16) - 8, XORRandom(16) - 8) / 16.0, SColor(255, 200 + XORRandom(50), 100 + XORRandom(50), 50 + XORRandom(25)), true, 60);
            if(p !is null)
            {
                p.gravity = Vec2f_zero;
            }
        }
    }

    string getDescription() override
    {
        return "Self Destruct";
    }

    void activate() override
    {
        Explode(blob, blob.getPosition(), 80, 6, "Bomb.ogg", 16 * 5, 1.0, true, Hitters::explosion, true);
        blob.server_Hit(blob, blob.getPosition(), Vec2f_zero, 3.0, Hitters::explosion, true);
    }
}