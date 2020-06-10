

class CPlantLoot
{
	string lootname;
	float chance;
	int count;
	CPlantLoot(string lootname, float chance, int count)
	{
		this.lootname = lootname;
		this.chance = chance;
		this.count = count;
	}
}