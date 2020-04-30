//This will set up a system for damage modifiers

funcdef f32 damageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata);

interface IDamageMod
{
	f32 damageMod(CBlob@, CBlob@, f32, u8);
}

class CDamageModCore : IDamageMod
{
	string name;
	
	CDamageModCore(string name)
	{
		this.name = name;
	}
	
	f32 damageMod(CBlob@ this, CBlob@ blob, f32 damage, u8 customdata)
	{
		return damage;
	}
}

void addDamageMod(CBlob@ this, CDamageModCore@ mod)
{
	array<CDamageModCore@>@ list;
	this.get("damagemods", @list);
	if(list is null)
		return;
	for(int i = 0; i < list.length; i++)
	{
		if(list[i].name == mod.name)
		{
			print("Attempted to add a damage mod that already exists - Do not do this");
			return;
		}
	}
	list.push_back(@mod);
}

void removeDamageMod(CBlob@ this, CDamageModCore@ mod)
{
	array<CDamageModCore@>@ list;
	this.get("damagemods", @list);
	if(list is null)
		return;
	for(int i = 0; i < list.length; i++)
	{
		if(list[i].name == mod.name)
		{
			list.removeAt(i);
			return;
		}
	}
	print("Attempted to remove a damage mod that doesnt exist");
}

f32 calcAllDamageMods(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
{
	array<CDamageModCore@>@ list;
	this.get("damagemods", @list);
	if(list is null)
		return damage;
	for(int i = 0; i < list.length; i++)
	{
		damage = cast<IDamageMod>(list[i]).damageMod(this, hitblob, damage, customdata);
	}
	return damage;
}