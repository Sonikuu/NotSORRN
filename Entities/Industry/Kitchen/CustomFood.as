#include "CustomFoodCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
	
	makeFoodData(this);
}
