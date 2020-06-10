


#include "WorldRenderCommon.as";
#include "RenderParticleCommon.as";


void onInit(CRules@ this)
{
	array<IRenderParticleCore@> prlist();
	this.set("PRlist", @prlist);
}

void onTick(CRules@ this)
{
	array<IRenderParticleCore@>@ prlist;
	this.get("PRlist", @prlist);
	for(int i = 0; i < prlist.length(); i++)
	{
		if(!prlist[i].onTick())
		{
			prlist.removeAt(i);
			i--;
		}
	}
	//if(getGameTime() % 30 == 0)
	//	print("Particles: " + prlist.length);
}

void onRender(CRules@ this)
{
	array<IRenderParticleCore@>@ prlist;
	this.get("PRlist", @prlist);
	array<Vertex> vertlist(0);
	if(prlist is null)
		return;
	for(int i = 0; i < prlist.length(); i++)
	{
		prlist[i].appendVerts(@vertlist);
	}
	//if(getGameTime() % 90 == 0)
	//	printInt("VertsCount: ", vertlist.length());
	addRenderToExistingRender(RenderList(@vertlist, "Rules/Render/PixelWhite.png"));
}


