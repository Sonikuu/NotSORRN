#include "AbilitiesCommon.as"

// class CGolemitesDisorient : CToggleableAbillityBase
// {
//     CGolemitesDisorient(string _textureName, CBlob@ _blob)
//     {
//         textureName = _textureName;
//         @blob = _blob;
//     }

//     void onTick()
//     {
//         if(blob.getPlayer() !is null && blob.getPlayer() is getLocalPlayer())
//         {
//             getRules().set_u32("disoriented",activated ? 1 : 0);
//         }
//     }
// }


void onInit(CBlob@ this)
{
	CAbilityManager@ manager;
	this.get("AbilityManager",@manager);

	manager.abilityMenu.addAbility(EAbilities::Point);
	manager.abilityMenu.addAbility(EAbilities::Absorb);

	manager.abilityBar.setSlot(0,EAbilities::Point);
	manager.abilityBar.setSlot(1,EAbilities::Absorb);

}