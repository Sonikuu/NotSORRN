
//so we dont have to include a bunch of oninit stuff as well when we need access to this class
//used for both render render and tick render
//tick render used for static stuff, like tracers for guns
//render render to be used for moving junk, like projectiles

shared class RenderList
{
	array<Vertex>@ verts;
	string sprite;
	int timetodie;
	RenderList(array<Vertex>@ verts, string sprite)
	{
		@this.verts = @verts;
		this.sprite = sprite;
		timetodie = 1;
	}
}

shared void addToTickList(RenderList newlist)
{
	if(!getNet().isClient())
		return;
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	rules.get("RLtick", @list);
	list.insertLast(@newlist);
}

shared void addToRenderList(RenderList newlist)
{
	if(!getNet().isClient())
		return;
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	rules.get("RLrender", @list);
	list.insertLast(@newlist);
}

shared void addToGuiList(RenderList newlist)
{
	if(!getNet().isClient())
		return;
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	rules.get("RLgui", @list);
	list.insertLast(@newlist);
}


shared void addToBGList(RenderList newlist)
{
	if(!getNet().isClient())
		return;
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	rules.get("RLbg", @list);
	list.insertLast(@newlist);
}

shared void addVertsToExistingRender(array<Vertex>@ verts, string sprite, string listname = "RLrender")//default arg is what it is cause im lazy
{
	if(!getNet().isClient())
		return;
	array<RenderList@>@ list;
	CRules@ rules = getRules();
	rules.get(listname, @list);
	if(list is null)
		return;
	for(int i = 0; i < list.length(); i++)
	{
		if(list[i].sprite == sprite)
		{
			//0xFFFF should be the max a vert array can handle
			if(list[i].verts.length() + verts.length() > 0xFFFF)
				continue;
			for(int j = 0; j < verts.length(); j++)
			{
				list[i].verts.insertLast(verts[j]);
			}
			return;
		}
	}
	array<Vertex>@ newverts = @array<Vertex>();
	for(int j = 0; j < verts.length(); j++)
	{
		newverts.insertLast(verts[j]);
	}
	RenderList newlist(@newverts, sprite);
	list.insertLast(@newlist);
}

shared void addRenderToExistingRender(RenderList newlist)
{
	addVertsToExistingRender(@newlist.verts, newlist.sprite);
}