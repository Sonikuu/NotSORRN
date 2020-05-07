interface IAbility
{
    string getTextureName();
    CBlob@ getBlob();
    void activate();
}

class CAbilityBase : IAbility
{
    string textureName;
    CBlob@ blob;

    string getTextureName() {return textureName;}
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
}

class CAbilityManager
{
    IAbility@[] abilities;
    uint selected = 0;

    IAbility@ getSelected() {return abilities[selected];}

    void activeAbilityIndex(int i)
    {
        if(i > abilities.length())
        {
            error("Attempted to run ability out of index");
            return;
        }

        abilities[i].activate();
    }

    void onTick(CBlob@ blob)
    {
        if(getControls().isKeyJustPressed(KEY_KEY_B))
        {
            getSelected().activate();
        }

        if(getControls().isKeyJustPressed(KEY_LBUTTON))
        {
            Vec2f mpos = getControls().getMouseScreenPos();

            if(mpos.y <= 40 && mpos.y >= 4)
            {
                int index = -1;
                for(int i = 0; i < abilities.length(); i++)
                {
                    int x = (4 + 4*i + 32 * i);
                    if(mpos.x >= x && mpos.x <= x + 32)
                    {
                        index = i;
                        break;
                    }
                }
                if(index > -1)
                {
                    selected = index;
                }
            }
        }
    }

    void onRender(CSprite@ this)
    {
        for(int i = 0; i < abilities.length(); i++)
        {
            GUI::DrawIcon(abilities[i].getTextureName(), 0, Vec2f(16,16), Vec2f(4 + 4*i + 32 * i,4), 1);
        }
        GUI::DrawIcon("Border.png",0,Vec2f(18,18), Vec2f(2 + 4*selected + 32 * selected,2),1);

        GUI::DrawTextCentered("{B}", Vec2f(16,40), SColor(255,127,127,127));
    }
}