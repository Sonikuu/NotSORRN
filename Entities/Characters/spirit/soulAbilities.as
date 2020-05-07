#include "AbilitiesCommon.as"

class CSoulAbility : CAbilityBase
{
    CSoulAbility(string _textureName, CBlob@ _blob)
    {
        textureName = _textureName;
        @blob = _blob;
    }

    void activate() override
    {
        print("This is a soul ability " + blob.getConfig());
    }
}

void onInit(CBlob@ this)
{
    CAbilityManager manager;

    CSoulAbility@ ability = CSoulAbility("Disorient.png",this);
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