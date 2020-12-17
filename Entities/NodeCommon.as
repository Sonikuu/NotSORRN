//This is the basic class and functions to be used in alchemy, item routing, and logic
#include "ElementalCore.as";


const float maxrange = 128;

interface INodeCore
{
	bool isConnectable(INodeCore@, CBlob@, CBlob@);
	void connectTo(INodeCore@, CBlob@, CBlob@);
	void disconnectFrom(INodeCore@, CBlob@, CBlob@);

	void update(CBlob@, int);//Int here is updatedepth i guess, primarly for how i want logic to recursively update up to a certain point
					//Likely wont have any actual use beyond that hmmm
	bool isSame(INodeCore@);	//Check if the node is the same type as your node yeet
	void setState(bool);	//State is going to be strictly logic, and will however be in all other nodes as well
	bool getState();		//Intent is to allow logic stuff to connect to any other node to control it
							//THIS COMES MUCH LATER
	Vec2f getWorldPosition(CBlob@);
	bool isInput();
	string getName();
}

class CAlchemyTank : INodeCore
{
	string name;
	bool input;
	Vec2f offset;
	CElementalCore@ storage;
	CAlchemyTank@ connection;
	u16 connectionid;
	int lasttransfer;
	//2 below are used for tanks that can move, so sprite updates properly
	bool dynamictank;
	bool dynamicconnection;
	//Tank limitations
	bool singleelement;
	bool unmixedstorage;
	int maxelements;
	u8 onlyele;
	u8 tankid;
	u16 thisnetid;
	CAlchemyTank(string name, bool input, Vec2f offset)
	{
		this.name = name;
		this.input = input;
		this.offset = offset;
		@storage = @CElementalCore();
		@connection = null;
		lasttransfer = -1;
		dynamictank = false;
		singleelement = false;
		maxelements = 100;
		unmixedstorage = false;
		onlyele = 255;
		tankid = 0;
		dynamicconnection = false;
	}

	bool isConnectable(INodeCore@ output, CBlob@ blob, CBlob@ toblob)
	{
		CBlob@ inputblob = @toblob;
		CBlob@ outputblob = @blob;

		return (this !is cast<CAlchemyTank>(output) && output.isInput() && !this.input && inputblob !is outputblob && (output.getWorldPosition(inputblob) - getWorldPosition(outputblob)).Length() < maxrange && isSame(output));
			return true;
		return false;
	}

	void connectTo(INodeCore@ node, CBlob@ blob, CBlob@ toblob)
	{
		if(isConnectable(node, blob, toblob))
		{
			@connection = cast<CAlchemyTank@>(node); 
		}
	}


	void disconnectFrom(INodeCore@ node, CBlob@ blob, CBlob@ toblob)
	{
		if(cast<CAlchemyTank@>(node) is connection)
		{
			@connection = null;
		}
	}

	void update(CBlob@ blob, int recursionsleft)
	{
		if(connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			CBlob@ thisblob = getBlobByNetworkID(thisnetid);
			if(blob is null)
				return; 
			if(toblob is null)
			{
				if(isServer())
				{
					//Detach on death
					CBitStream params;
					params.write_u8(tankid);
					blob.SendCommand(blob.getCommandID("disconnect"), params);
				}
			}
			else
			{
				if((getWorldPosition(blob) - connection.getWorldPosition(toblob)).Length() > maxrange)
				{
					if(isServer())
					{
						//Detach out of range
						CBitStream params;
						params.write_u8(tankid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else if(toblob.isInInventory() || blob.isInInventory())
				{
					if(isServer())
					{
						//Detach if in inv
						CBitStream params;
						params.write_u8(tankid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else
				{
					if(connection.singleelement)
						transferOnly(this, connection, blob.get_u16("transferrate"), firstId(connection));
					else if(connection.onlyele < elementlist.length)
						transferOnly(this, connection, blob.get_u16("transferrate"), connection.onlyele);
					else
						transferSimple(this, connection, blob.get_u16("transferrate"));
				}
			}
		}
		return;
	}

	bool isSame(INodeCore@ node)
	{
		if(cast<CAlchemyTank@>(node) !is null)
			return true;
		return false;
	}	

	void setState(bool)
	{
		//Uh, this too
	}

	bool getState()
	{
		return true;
		//You know whats up
	}

	Vec2f getWorldPosition(CBlob@ blob)
	{
		Vec2f topos = blob.getPosition() + offset.RotateBy(blob.getAngleDegrees());
			
			
		if(blob.get_bool("equipped"))
		{
			CBlob@ equipper = getBlobByNetworkID(blob.get_u16("equipper"));
			if(equipper !is null)
				topos = equipper.getPosition();
		}
		
		return topos;
	}
	bool isInput()
	{
		return input;
	}
	string getName()
	{
		return name;
	}
}

class CNodeController
{
	array<CAlchemyTank@> tanks;
	array<INodeCore@> nodes;//Backwards compat be like
	u16 blobnetid;
	
	CNodeController()
	{
		//actually dont have to do anything here
		blobnetid = 0;
	}
	
	CAlchemyTank@ addTank(string name, bool input, Vec2f offset)
	{
		CAlchemyTank newtank(name, input, offset);
		newtank.tankid = tanks.size();
		newtank.thisnetid = blobnetid;
		tanks.push_back(@newtank);
		nodes.push_back(@newtank);
		return @newtank;
	}
	
	CAlchemyTank@ getTank(string name)
	{
		for (int i = 0; i < tanks.length; i++)
		{
			if(tanks[i].name == name)
			{
				return @tanks[i];
			}
		}
		return null;
	}
	u8 getTankID(string name)
	{
		for (int i = 0; i < tanks.length; i++)
		{
			if(tanks[i].name == name)
			{
				return i;
			}
		}
		return 255;
	}
	u8 getTankID(CAlchemyTank@ tank)
	{
		int output = tanks.find(@tank);
		if(output >= 0)
			return output;
		return 255;
	}
	CAlchemyTank@ getTank(int id)
	{
		if(id < tanks.length && id >= 0)
			return tanks[id];
		else
			print("Outside of bounds");
		return null;
	}
}

CNodeController@ getNodeController(CBlob@ blob)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	return @controller;
}

void addNodeController(CBlob@ blob)
{
	CNodeController controller();
	controller.blobnetid = blob.getNetworkID();
	blob.set("nodecontroller", @controller);
}

CAlchemyTank@ addTank(CBlob@ blob, string name, bool input, Vec2f offset)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.addTank(name, input, offset);
}

CAlchemyTank@ getTank(CBlob@ blob, string name)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.getTank(name);
}

CAlchemyTank@ getTank(CBlob@ blob, int id)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.getTank(id);
}

u8 getTankID(CBlob@ blob, string name)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return 255;
	return controller.getTankID(name);
}

u8 getTankID(CBlob@ blob, CAlchemyTank@ tank)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return 255;
	return controller.getTankID(tank);
}

void addToTank(CAlchemyTank@ tank, array<int>@ elements)
{
	for (int i = 0; i < elements.length; i++)
	{
		tank.storage.elements[i] += elements[i];
	}
}

void addToTank(CAlchemyTank@ tank, string element, int count)
{
	for (int i = 0; i < elementlist.length; i++)
	{
		if(elementlist[i].name == element)
		{
			tank.storage.elements[i] += count;
			return;
		}
	}
}

int getTotal(array<int>@ values)
{
	int output = 0;
	for (uint i = 0; i < values.length; i++)
	{
		output += values[i];
	}
	return output;
}

int storageLeft(CAlchemyTank@ tank, int id)
{
	int output = 0;
	if(tank.unmixedstorage)
		return tank.maxelements - tank.storage.elements[id];
	for (int i = 0; i < tank.storage.elements.length; i++)
	{
		if(tank.storage.elements[i] > 0)
		{
			if(tank.singleelement)
				return Maths::Max(tank.maxelements - tank.storage.elements[i], 0);
			output += tank.storage.elements[i];
		}
		
	}
	return Maths::Max(tank.maxelements - output, 0);
}

int firstId(CAlchemyTank@ tank)
{
	for (int i = 0; i < tank.storage.elements.length; i++)
	{
		if(tank.storage.elements[i] > 0)
		{
			return i;
		}
		
	}
	return -1;
}

void transferSimple(CAlchemyTank@ input, CAlchemyTank@ output, int amount)
{
	for (int i = 0; i < input.storage.elements.length; i++)
	{
		if(input.storage.elements[i] == 0)
			continue;
		if(amount <= input.storage.elements[i])
		{
			int moveamnt = Maths::Min(storageLeft(output, i), amount);
			input.storage.elements[i] -= moveamnt;
			output.storage.elements[i] += moveamnt;
			input.lasttransfer = i;
			if(!output.unmixedstorage)
				return;
		}
		else
		{
			int moveamnt = Maths::Min(storageLeft(output, i), input.storage.elements[i]);
			output.storage.elements[i] += moveamnt;
			input.storage.elements[i] -= moveamnt;
			input.lasttransfer = i;
			if(input.storage.elements[i] > 0 && !output.unmixedstorage)
				return;
			amount -= moveamnt;
			
		}
	}
}

void transferBlacklist(CAlchemyTank@ input, CAlchemyTank@ output, int amount, array<string>@ blacklist)
{
	for (int i = 0; i < input.storage.elements.length; i++)
	{
		bool skip = false;
		for (int j = 0; j < blacklist.length; j++)
		{
			if(elementlist[i].name == blacklist[j])
			{
				skip = true;
				break;
			}
		}
		if(skip || input.storage.elements[i] == 0)
			continue;
		if(amount <= input.storage.elements[i])
		{
			int moveamnt = Maths::Min(storageLeft(output, i), amount);
			input.storage.elements[i] -= moveamnt;
			output.storage.elements[i] += moveamnt;
			input.lasttransfer = i;
			if(!output.unmixedstorage)
				return;
		}
		else
		{
			int moveamnt = Maths::Min(storageLeft(output, i), input.storage.elements[i]);
			output.storage.elements[i] += moveamnt;
			input.storage.elements[i] -= moveamnt;
			input.lasttransfer = i;
			if(input.storage.elements[i] > 0 && !output.unmixedstorage)
				return;
			amount -= moveamnt;
		}
	}
}

void transferOnly(CAlchemyTank@ input, CAlchemyTank@ output, int amount, string only)
{
	int onlyid = elementIdFromName(only);
	if(only == "any")
	{
		transferSimple(input, output, amount);
		return;
	}
		
	if(onlyid < 0 || input.storage.elements[onlyid] == 0)
		return;
	
	if(amount <= input.storage.elements[onlyid])
	{
		int moveamnt = Maths::Min(storageLeft(output, onlyid), amount);
		input.storage.elements[onlyid] -= moveamnt;
		output.storage.elements[onlyid] += moveamnt;
		input.lasttransfer = onlyid;
		return;
	}
	else
	{
		int moveamnt = Maths::Min(storageLeft(output, onlyid), input.storage.elements[onlyid]);
		output.storage.elements[onlyid] += moveamnt;
		input.storage.elements[onlyid] -= moveamnt;
		input.lasttransfer = onlyid;
		if(input.storage.elements[onlyid] > 0)
			return;
		amount -= moveamnt;
	}
}


void transferOnly(CAlchemyTank@ input, CAlchemyTank@ output, int amount, int only)
{
	if(only == -1)
	{
		transferSimple(input, output, amount);
		return;
	}
	string onlyname = elementlist[only].name;
	transferOnly(input, output, amount, onlyname);
}

void transferOnlyBlacklist(CAlchemyTank@ input, CAlchemyTank@ output, int amount, string only, array<string>@ blacklist)
{
	int onlyid = elementIdFromName(only);
	if(only == "any")
	{
		transferBlacklist(input, output, amount, @blacklist);
		return;
	}
	
	transferOnly(input, output, amount, only);
}

SColor getAverageElementColor(CAlchemyTank@ tank)
{
	SColor output(255, 0, 0, 0);
	for (int i = 0; i < tank.storage.elements.length; i++)
	{
		float ratio = float(tank.storage.elements[i]) / float(tank.maxelements);
		SColor elecol = elementlist[i].color;
		output.set(255, output.getRed() + elecol.getRed() * ratio, output.getGreen() + elecol.getGreen() * ratio, output.getBlue() + elecol.getBlue() * ratio);
	}
	return output;
}

Vec2f getWorldTankPos(CBlob@ blob, CAlchemyTank@ tank)
{
	Vec2f offset = tank.offset;
	Vec2f topos = blob.getPosition() + offset.RotateBy(blob.getAngleDegrees());
		
		
	if(blob.get_bool("equipped"))
	{
		CBlob@ equipper = getBlobByNetworkID(blob.get_u16("equipper"));
		if(equipper !is null)
			topos = equipper.getPosition();
	}
	
	return topos;
}

