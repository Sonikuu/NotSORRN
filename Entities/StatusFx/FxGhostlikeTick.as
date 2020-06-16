//Gravity Status effect
#include "FxGhostlike.as";

void onTick(CBlob@ this)
{
	if(this.get_u16("fxghostliketime") == 0)
		FxGhostlike::remove(this);
	else
		this.add_u16("fxghostliketime", -1);
		
	if(this.isKeyPressed(key_up))
	{
		this.setVelocity(this.getVelocity() + Vec2f(0, -0.2));
	}
	if(this.isKeyPressed(key_down))
	{
		this.setVelocity(this.getVelocity() + Vec2f(0, 0.2));
	}
}

