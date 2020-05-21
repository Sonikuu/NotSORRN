#include "AbilitiesCommon.as"

void onInit(CBlob@ this)
{
    CAbilityManager manager;
    manager.onInit(this);


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

void onReceiveCreateData(CBlob@ this, CBitStream@ stream)
{
    CAbilityManager@ manager;
    this.get("AbilityManager",@manager);

    manager.onReceiveCreateData(stream);
}