#include "AbilitiesCommon.as"

class CGolemitesDisorient : CToggleableAbillityBase
{
    CGolemitesDisorient(string _textureName, CBlob@ _blob)
    {
        textureName = _textureName;
        @blob = _blob;
    }

    void onTick()
    {
        if(blob.getPlayer() !is null && blob.getPlayer() is getLocalPlayer())
        {
            getRules().set_u32("disoriented",activated ? 1 : 0);
        }
    }
}

void onInit(CBlob@ this)
{
    CAbilityManager manager;
    manager.onInit(this);

    CGolemitesDisorient@ ability = CGolemitesDisorient("Disorient.png",this);
    manager.abilities.push_back(ability);
    manager.abilities.push_back(ability);
    manager.abilities.push_back(ability);
    manager.abilities.push_back(ability);

    this.set("AbilityManager",manager);
}

void onTick(CBlob@ this)
{
    CAbilityManager@ manager;
    this.get("AbilityManager", @manager);

    manager.onTick(this);
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    CAbilityManager@ manager;
    blob.get("AbilityManager", @manager);

    manager.onRender(this);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    CAbilityManager@ manager;
    this.get("AbilityManager",@manager);

    manager.onCommand(this,cmd,params);
}