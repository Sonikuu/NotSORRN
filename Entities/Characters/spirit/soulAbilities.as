#include "AbilitiesCommon.as"

class CSoulDisorient : CAbilityBase
{
    CSoulDisorient(string _textureName, CBlob@ _blob)
    {
        textureName = _textureName;
        @blob = _blob;
    }

    void activate() override
    {
        // CBlob@[] blobs;
        
        // getMap().getBlobsInRadius(blob.getPosition(),4,@blobs);

        // for(int i = 0; i < blobs.length; i++)
        // {
        
        // }

        getRules().set_u32("disoriented",30*15);
    }
}

void onInit(CBlob@ this)
{
    CAbilityManager manager;

    CSoulDisorient@ ability = CSoulDisorient("Disorient.png",this);
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