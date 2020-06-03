

class CPlantGrowthData
{
	string blobname;
	int growthtime;	//Note: just for the seed
	int index;			//For the seed sprite
	float radius;		//Might need to manipulate for different sized plants
	CPlantGrowthData(string blobname, int growthtime, int index, float radius)
	{
		this.blobname = blobname;
		this.growthtime = growthtime;
		this.index = index;
		this.radius = radius;
	}
}

array<CPlantGrowthData@> growthdatas = {
@CPlantGrowthData("lettuce_plant", 300, 9, 4),
@CPlantGrowthData("tomato_plant", 400, 10, 4),
@CPlantGrowthData("cucumber_plant", 400, 11, 4)
};

CPlantGrowthData@ getGrowthData(string plantname)
{
	for(int i = 0; i < growthdatas.size(); i++)
	{
		if(growthdatas[i].blobname == plantname)
			return @growthdatas[i];
	}
	return null;
}