// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	InitCosts();
	CRules@ rules = getRules();
	const bool CTF = rules.gamemode_name == "CTF";
	const bool TTH = rules.gamemode_name == "TTH";
	const bool SBX = rules.gamemode_name == "Sandbox";
	const bool SRN = rules.gamemode_name == "SORRN";

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::back_stone_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wood_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::back_wood_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::trap_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::ladder);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_platform);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::spikes);
		blocks[0].push_back(b);
	}

	if(CTF)
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", CTFCosts::workshop_wood);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].insertAt(9, b);
	}
	else if(TTH)
	{
		{
			BuildBlock b(0, "factory", "$building$", "Workshop");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::factory_wood);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[0].insertAt(9, b);
		}
		{
			BuildBlock b(0, "workbench", "$workbench$", "Workbench");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::workbench_wood);
			b.buildOnGround = true;
			b.size.Set(32, 16);
			blocks[0].push_back(b);
		}
	}
	else if(SBX)
	{
		{
			BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[0].insertAt(9, b);
		}

		BuildBlock[] page_1;
		blocks.push_back(page_1);
		{
			BuildBlock b(0, "wire", "$wire$", "Wire");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "elbow", "$elbow$", "Elbow");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "tee", "$tee$", "Tee");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "junction", "$junction$", "Junction");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "diode", "$diode$", "Diode");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "resistor", "$resistor$", "Resistor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "inverter", "$inverter$", "Inverter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "transistor", "$transistor$", "Transistor");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "toggle", "$toggle$", "Toggle");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}

		BuildBlock[] page_2;
		blocks.push_back(page_2);
		{
			BuildBlock b(0, "lever", "$lever$", "Lever");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "push_button", "$pushbutton$", "Button");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[2].push_back(b);
		}

		BuildBlock[] page_3;
		blocks.push_back(page_3);
		{
			BuildBlock b(0, "lamp", "$lamp$", "Lamp");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "emitter", "$emitter$", "Emitter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "receiver", "$receiver$", "Receiver");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "magazine", "$magazine$", "Magazine");
			AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 20);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "bolter", "$bolter$", "Bolter");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "spiker", "$spiker$", "Spiker");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[3].push_back(b);
		}
	}
	else if(SRN)
	{
		{
			BuildBlock b(0, "workbench", "$workbench$", "Workbench");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::workbench_wood);
			b.buildOnGround = true;
			b.size.Set(32, 16);
			blocks[0].push_back(b);
		}
		{
			BuildBlock b(0, "gunbench", "$gunbench$", "Gun Workbench");
			AddRequirement(b.reqs, "blob", "mat_metal", "Metal", 6);
			b.buildOnGround = true;
			b.size.Set(32, 16);
			blocks[0].push_back(b);
			AddIconToken("$gunbench$", "GunBench.png", Vec2f(16, 16), 7);
		}
		{
			BuildBlock b(0, "fireplace", "$fireplace$", "Fireplace");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 80);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[0].push_back(b);
		}
		{
			BuildBlock b(409, "marble_block", "$marble_block$", "Marble Block\nMore durable than stone");
			AddRequirement(b.reqs, "blob", "mat_marble", "Marble", 5);
			blocks[0].push_back(b);
			AddIconToken("$marble_block$", "world.png", Vec2f(8, 8), 409);
		}
		{
			BuildBlock b(419, "marble_back", "$marble_back$", "Marble Back Wall\nLooks cool");
			AddRequirement(b.reqs, "blob", "mat_marble", "Marble", 1);
			blocks[0].push_back(b);
			AddIconToken("$marble_back$", "world.png", Vec2f(8, 8), 419);
		}
		{
			BuildBlock b(428, "basalt_block", "$basalt_block$", "Basalt Block\nMore durable than stone");
			AddRequirement(b.reqs, "blob", "mat_basalt", "Basalt", 5);
			blocks[0].push_back(b);
			AddIconToken("$basalt_block$", "world.png", Vec2f(8, 8), 428);
		}
		{
			BuildBlock b(438, "basalt_back", "$basalt_back$", "Basalt Back Wall\nLooks cool");
			AddRequirement(b.reqs, "blob", "mat_basalt", "Basalt", 1);
			blocks[0].push_back(b);
			AddIconToken("$basalt_back$", "world.png", Vec2f(8, 8), 438);
		}
		{
			BuildBlock b(446, "track_block", "$track_block$", "Track\nTrack riding objects use these");
			AddRequirement(b.reqs, "blob", "mat_metal", "Metal", 1);
			blocks[0].push_back(b);
			AddIconToken("$track_block$", "world.png", Vec2f(8, 8), 446);
		}
		{
			BuildBlock b(452, "gold_block", "$gold_block$", "Gold Block\nFor when you need to show off how rich you are\nMore durable than stone");
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 8);
			blocks[0].push_back(b);
			AddIconToken("$gold_block$", "world.png", Vec2f(8, 8), 452);
		}
		
		//Page 2, alchemy
		BuildBlock[] page_1;
		blocks.push_back(page_1);
		{
			BuildBlock b(0, "alchemycrucible", "$alchemycrucible$", "Alchemic Crucible\nMelts items down into essence\nRequires fuel");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
			b.buildOnGround = true;
			b.size.Set(16, 32);
			blocks[1].push_back(b);
			//Icons for all the other tiles seem to appear out of nowhere, so I guess we add our own here?
			AddIconToken("$alchemycrucible$", "AlchemyCrucible.png", Vec2f(16, 32), 0);
		}
		{
			BuildBlock b(0, "alchemyrouter", "$alchemyrouter$", "Alchemic Router\nMoves essence");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			b.buildOnGround = false;
			b.size.Set(8, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemyrouter$", "AlchemyRouter.png", Vec2f(8, 16), 0);
		}
		{
			BuildBlock b(0, "alchemysorter", "$alchemysorter$", "Alchemic Sorter\nAllows essence to be sorted into 3 different outputs");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			b.buildOnGround = false;
			b.size.Set(32, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemysorter$", "AlchemySorter.png", Vec2f(32, 16), 0);
		}
		{
			BuildBlock b(0, "alchemycollector", "$alchemycollector$", "Wind Collector\nCreates aer essence from the wind");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
			AddRequirement(b.reqs, "blob", "mat_metal", "Alchemic Metal Sheet", 8);
			b.buildOnGround = true;
			b.size.Set(32, 32);
			blocks[1].push_back(b);
			AddIconToken("$alchemycollector$", "AlchemyCollector.png", Vec2f(32, 32), 0);
		}
		{
			BuildBlock b(0, "alchemypad", "$alchemypad$", "Alchemical Pad Focus\nUses elements to manipulate creatures that step on it");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			AddRequirement(b.reqs, "blob", "mat_metal", "Alchemic Metal Sheet", 4);
			b.buildOnGround = true;
			b.size.Set(32, 8);
			blocks[1].push_back(b);
			AddIconToken("$alchemypad$", "AlchemyPad.png", Vec2f(32, 8), 0);
		}
		{
			BuildBlock b(0, "alchemysplitter", "$alchemysplitter$", "Alchemical Splitter\nDistributes essence between two outputs");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 40);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			b.buildOnGround = false;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemysplitter$", "AlchemySplitter.png", Vec2f(16, 16), 0);
		}
		{
			BuildBlock b(0, "alchemyward", "$alchemyward$", "Alchemical Ward\nUses essence to manipulate an area");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			//AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			b.buildOnGround = true;
			b.size.Set(8, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemyward$", "AlchemyWard.png", Vec2f(8, 16), 0);
		}
		{
			BuildBlock b(0, "alchemymixer", "$alchemymixer$", "Alchemical Mixer\nMixes essence into more advanced elements");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			b.buildOnGround = false;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemymixer$", "AlchemyMixer.png", Vec2f(16, 16), 0);
		}
		{
			BuildBlock b(0, "alchemypump", "$alchemypump$", "Alchemical Pump\nCreates aqua essence from water below it");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
			AddRequirement(b.reqs, "blob", "mat_metal", "Alchemic Metal Sheet", 8);
			b.buildOnGround = true;
			b.size.Set(32, 32);
			blocks[1].push_back(b);
			AddIconToken("$alchemypump$", "AlchemyPump.png", Vec2f(32, 32), 0);
		}
		{
			BuildBlock b(0, "alchemyinfuser", "$alchemyinfuser$", "Alchemical Infuser\nInfuses items with essence");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
			AddRequirement(b.reqs, "blob", "mat_metal", "Alchemic Metal Sheet", 4);
			b.buildOnGround = true;
			b.size.Set(32, 32);
			blocks[1].push_back(b);
			AddIconToken("$alchemyinfuser$", "AlchemyInfuser.png", Vec2f(32, 32), 0);
		}
		{
			BuildBlock b(0, "alchemydiffuser", "$alchemydiffuser$", "Alchemical Diffuser\nReleases essence into the air\nMay occasionally tranform nearby stone");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemydiffuser$", "AlchemyDiffuser.png", Vec2f(16, 16), 0);
		}
		{
			BuildBlock b(0, "alchemyburner", "$alchemyburner$", "Alchemical Burner\nCreates ignis essence from fuel");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			AddRequirement(b.reqs, "blob", "mat_metal", "Alchemic Metal Sheet", 8);
			b.buildOnGround = true;
			b.size.Set(16, 32);
			blocks[1].push_back(b);
			AddIconToken("$alchemyburner$", "AlchemyBurner.png", Vec2f(16, 32), 0);
		}
		if(sv_test)
		{
			BuildBlock b(0, "alchemycheatmachine", "$alchemycheatmachine$", "dirty dirty cheater");
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
			AddIconToken("$alchemycheatmachine$", "AlchemyCheatMachine.png", Vec2f(16, 16), 0);
		}
		BuildBlock[] page_2;
		blocks.push_back(page_2);
		BuildBlock[] page_3;
		blocks.push_back(page_3);
	}
}