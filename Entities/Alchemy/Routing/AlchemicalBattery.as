#include "NodeCommon.as";

void onInit(CBlob@ this)
{
	CAlchemyTank@ input = addTank(this, "Input", true, Vec2f(0, -6));
	CAlchemyTank@ output = addTank(this, "Output", false, Vec2f(0, 6));
	
	input.maxelements = 100;
	input.dynamictank = true;
	
	output.maxelements = 100;
	output.dynamictank = true;
	
	this.getShape().getConsts().mapCollisions = true;
}

void onInit(CSprite@ this)
{
	this.SetZ(2.1);
	CSpriteLayer@ layer = this.addSpriteLayer("runes");
	layer.SetRelativeZ(1);
	layer.SetFrame(1);
	//layer.setRenderStyle(RenderStyle::light);
	layer.SetLighting(false);
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ input = getTank(this, "Input");
	CAlchemyTank@ output = getTank(this, "Output");
	if(input !is null && output !is null)
		transferSimple(input, output, 1);
	
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ layer = this.getSpriteLayer("runes");
	CBlob@ blob = this.getBlob();
	CAlchemyTank@ tank = getTank(blob, 1);
	if(tank !is null)
		layer.SetColor(getAverageElementColor(tank));
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if((blob.hasTag("flesh") && blob.getPosition().y > this.getPosition().y - 4) || blob.isKeyPressed(key_down))
		return false;
	return true;
}


