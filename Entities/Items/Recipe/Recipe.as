#include "Hitters.as"

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(isClient() && blob.getAttachmentPoint(0).getOccupied() is getLocalPlayerBlob())
		GUI::DrawIcon(blob.get_string("recipe"), blob.getInterpolatedScreenPos() + Vec2f(-64, -128));
}

void onInit(CBlob@ this)
{
	this.set_string("recipe", "RecipeDiffuser.png");
}

//collide with vehicles and structures	- hit stuff if thrown

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle")) || this.getConfig() == blob.getConfig()); // boat
}

