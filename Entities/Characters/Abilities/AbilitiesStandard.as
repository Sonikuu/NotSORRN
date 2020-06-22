#include "AbilitiesCommon.as"

void onInit(CBlob@ this)
{
	CAbilityManager@ manager;
	this.get("AbilityManager",@manager);

	manager.abilityMenu.addAbility(EAbilities::Point,false);
	manager.abilityMenu.addAbility(EAbilities::Consume,false);

	manager.abilityBar.setSlot(0,EAbilities::Point);
	manager.abilityBar.setSlot(1, EAbilities::Consume);

}