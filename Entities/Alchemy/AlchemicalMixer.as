#include "NodeCommon.as";

class CAlchemyMix
{
	string element1;
	string element2;
	string output;
	CAlchemyMix(string element1, string element2, string output)
	{
		this.element1 = element1;
		this.element2 = element2;
		this.output = output;
	}
}

array<CAlchemyMix@> mixrecipes =
{
	@CAlchemyMix(
	"aqua",//input
	"terra",//input
	"life"//output
	),
	
	@CAlchemyMix(
	"aer",
	"terra",
	"force"
	),
	
	@CAlchemyMix(
	"life",
	"entropy",
	"ecto"
	),
	
	@CAlchemyMix(
	"life",
	"terra",
	"natura"
	),
	
	@CAlchemyMix(
	"order",
	"natura",
	"purity"
	),
	
	@CAlchemyMix(
	"entropy",
	"natura",
	"corruption"
	),
	
	@CAlchemyMix(
	"force",
	"aer",
	"yeet"
	),

	@CAlchemyMix(
	"purity",
	"order",
	"holy"
	),

	@CAlchemyMix(
	"corruption",
	"entropy",
	"unholy"
	)
};


void onInit(CBlob@ this)
{	
	//Setup tanks
	addTank(this, "Left Input", true, Vec2f(-4, -4));
	addTank(this, "Right Input", true, Vec2f(4, -4));
	addTank(this, "Output", false, Vec2f(0, 4));
	
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ inputl = getTank(this, "Left Input");
	CAlchemyTank@ inputr = getTank(this, "Right Input");
	CAlchemyTank@ output = getTank(this, "Output");
	
	if(inputl !is null && inputr !is null && output !is null)
	{
		for(int i = 0; i < inputl.storage.elements.length; i++)
		{
			if(inputl.storage.elements[i] > 0)
			{
				for(int j = 0; j < mixrecipes.length; j++)
				{
					if(elementlist[i].name == mixrecipes[j].element1 || elementlist[i].name == mixrecipes[j].element2)
					{
						bool isele1 = elementlist[i].name == mixrecipes[j].element1;
						for(int k = 0; k < inputr.storage.elements.length; k++)
						{
							if(inputr.storage.elements[k] > 0 && elementlist[k].name == (isele1 ? mixrecipes[j].element2 : mixrecipes[j].element1))
							{
								inputl.storage.addElement(i, -1);
								inputr.storage.addElement(k, -1);
								output.storage.addElement(mixrecipes[j].output, 1);
								return;
							}
						}
					}
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
}

