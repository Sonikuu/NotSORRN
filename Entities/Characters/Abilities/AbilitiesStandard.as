#include "AbilitiesCommon.as"

void onInit(CBlob@ this)
{
	CAbilityManager@ manager;
	this.get("AbilityManager",@manager);

	manager.abilityMenu.addAbility(EAbilities::Point);
	manager.abilityMenu.addAbility(EAbilities::Consume);

	manager.abilityBar.setSlot(0,EAbilities::Point);
	manager.abilityBar.setSlot(1, EAbilities::Consume);

}