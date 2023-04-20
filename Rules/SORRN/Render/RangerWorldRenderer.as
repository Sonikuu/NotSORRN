//Script will handle rendering for all world special effects
//Done this way because weapons arent blobs while equipped so we cant have the render script attached to them
//Using quads

#include "WorldRenderCommon.as";

const bool noerase = false;

void onInit(CRules@ this)
{
	array<RenderList@> listt();
	array<RenderList@> listr();
	array<RenderList@> listg();
	array<RenderList@> listb();
	this.set("RLtick", @listt);
	this.set("RLrender", @listr);
	this.set("RLgui", @listg);
	this.set("RLbg", @listb);
	Render::addScript(Render::layer_objects, "RangerWorldRenderer.as", "renderLists", 0);
	Render::addScript(Render::layer_posthud, "RangerWorldRenderer.as", "renderGUI", 0);
	Render::addScript(Render::layer_background, "RangerWorldRenderer.as", "renderBG", 0);
}

void onTick(CRules@ this)
{
	if(!getNet().isClient())
		return;
	CControls@ controls = getControls();
	if(noerase && controls !is null && !controls.isKeyPressed(KEY_KEY_G))	
		return;
	//Think all this has to do is empty the list
	array<RenderList@>@ list;
	this.get("RLtick", @list);
	for(int i = 0; i < list.size(); i++)
	{
		if(list[i].timetodie <= 0)
		{
			list.removeAt(i);
			i--;
		}
		else
		{
			list[i].timetodie--;
		}
	}
	
	//list.clear();
	//CCamera@ cam = getCamera();
	//if(cam !is null)
		//cam.setRotation(0, getGameTime(), 0);
}

void onRender(CRules@ this)
{
	array<RenderList@>@ list;
	this.get("RLrender", @list);
	if(list is null)
		return;
	for(int i = 0; i < list.size(); i++)
	{
		if(list[i].timetodie <= 1)
		{
			list.removeAt(i);
			i--;
		}
		else
		{
			list[i].timetodie--;
		}
		
	}
	
	//list.clear();
}

void renderLists(int id)
{
	Render::SetTransformWorldspace();
	Render::SetAlphaBlend(true);
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	rules.get("RLtick", @list);
	for(int i = 0; i < list.size(); i++)
	{
		//print("Rendering");
		Render::RawQuads(list[i].sprite, list[i].verts);
	}
	//They both get rendered the same way, only difference is when they're cleared
	rules.get("RLrender", @list);
	for(int i = 0; i < list.size(); i++)
	{
		//print("Rendering");
		Render::RawQuads(list[i].sprite, list[i].verts);
	}
}

void renderGUI(int id)
{
	Render::SetTransformScreenspace();
	Render::SetAlphaBlend(true);
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	//GUI Rendering
	rules.get("RLgui", @list);
	for(int i = 0; i < list.size(); i++)
	{
		//print("Rendering");
		Render::RawQuads(list[i].sprite, list[i].verts);
		
		if(list[i].timetodie <= 0)
		{
			list.removeAt(i);
			i--;
		}
		else
		{
			list[i].timetodie--;
		}
	}
}

void renderBG(int id)
{
	Render::SetTransformScreenspace();
	Render::SetAlphaBlend(true);
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	//GUI Rendering
	rules.get("RLbg", @list);
	if(list is null)
	{
		print("Null list in renderBG function");
		return;
	}
	for(int i = 0; i < list.size(); i++)
	{
		//print("Rendering");
		Render::RawQuads(list[i].sprite, list[i].verts);
		
		//if(list[i].timetodie <= 0)
		{
			list.removeAt(i);
			i--;
		}
		//else
		//{
		//	list[i].timetodie--;
		//}
	}
}


