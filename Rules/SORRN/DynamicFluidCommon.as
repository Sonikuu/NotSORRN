//Random tile ticking
//Think ill either have this file handle all interactions or have other scripts 'attach' functions to blocks

#include "RenderParticleCommon.as";
#include "WorldRenderCommon.as";

class CWaterTile
{
	bool b;		//If water
	bool f;		//If water full
	bool moved;	//If water already moved this tick, probs depreciate lel
	u8 d;		//Amount of water
	u8 u;		//Unusable amount of water, should make moved unnecessary
	bool a;		//Uh oh more bools, this one is a sort of active flag i guess

	CWaterTile()
	{
		b = false;
		moved = false;
		d = 0;
		u = 0;
		f = false;
		a = false;
	}
}

//array<array<CWaterTile>>@ waterdata;
//array<bool>@ activelayers;


