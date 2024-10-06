//This is the basic class and functions to be used in alchemy, item routing, and logic
#include "ElementalCore.as";
#include "FuelCommon.as";


const float maxrange = 128;

interface INodeCore
{
	bool isConnectable(INodeCore@, CBlob@, CBlob@);
	void connectTo(INodeCore@, CBlob@, CBlob@);
	void disconnectFrom(INodeCore@, CBlob@, CBlob@);
	void disconnectAll(CBlob@);//A simpler, "temporary" version of disconnect

	void update(CBlob@, int);//Int here is updatedepth i guess, primarly for how i want logic to recursively update up to a certain point
					//Likely wont have any actual use beyond that hmmm
	bool isSame(INodeCore@);	//Check if the node is the same type as your node yeet
	void setState(bool);	//State is going to be strictly logic, and will however be in all other nodes as well
	bool getState();		//Intent is to allow logic stuff to connect to any other node to control it
							//THIS COMES MUCH LATER
	Vec2f getWorldPosition(CBlob@);
	int getID();
	bool isInput();
	string getName();
	void updateSprite(CBlob@, CSprite@);
	Vec2f getOffset();
	string getPipeSprite();

	void writeSyncData(CBlob@, CPlayer@);
	void readSyncData(CBlob@, CBitStream@);

	void onRender(CBlob@);
}

funcdef bool insertionFunc(CBlob@, CBlob@, bool, CBlob@);

bool routingInsertion(CBlob@ toblob, CBlob@ item, bool probe, CBlob@ fromblob)
{
	CItemIO@ outio = getItemIO(toblob, "Output");
	if(outio !is null && outio.connection !is null)
	{
		CBlob@ connectblob = getBlobByNetworkID(outio.connectionid);
		if(connectblob !is null)
			return outio.doTransfer(toblob, connectblob, item, probe);
	}
	return false;
}

bool filterInsertion(CBlob@ toblob, CBlob@ item, bool probe, CBlob@ fromblob)
{

	CItemIO@ outio = getItemIO(toblob, "Output");
	if(item.getConfig() == toblob.get_string("filter"))
		@outio = getItemIO(toblob, "Filter");
	if(outio !is null && outio.connection !is null)
	{
		CBlob@ connectblob = getBlobByNetworkID(outio.connectionid);
		if(connectblob !is null)
			return outio.doTransfer(toblob, connectblob, item, probe);
	}
	return false;
}

bool switchInsertion(CBlob@ toblob, CBlob@ item, bool probe, CBlob@ fromblob)
{
	CItemIO@ outio = getItemIO(toblob, "Left Output");
	if(toblob.get_bool("switched"))
	{
		@outio = getItemIO(toblob, "Right Output");
		if(!probe)
			toblob.set_bool("switched", false);
	}
	else if(!probe)
	{
		toblob.set_bool("switched", true);
	}

	if(outio !is null && outio.connection !is null)
	{
		CBlob@ connectblob = getBlobByNetworkID(outio.connectionid);
		if(connectblob !is null)
			return outio.doTransfer(toblob, connectblob, item, probe);
	}
	return false;
}

array<Vec2f> routingroute;



class CLogicPlug : INodeCore
{
	string name;
	bool input;
	Vec2f offset;
	INodeCore@ connection;
	u16 connectionid;
	bool onlymovetagged;
	u32 laststatecheck;
	u32 lasttrueset;

	bool dynamictank;
	bool dynamicconnection;

	bool logicstate;
	bool oldstate;

	insertionFunc@ insertfunc;
	u8 transfercooldown;
	u8 nodeid;
	u16 thisnetid;
	array<CLogicPlug@> routingcache;
	array<Vec2f> localroutingroute;
	
	CLogicPlug(string name, bool input, Vec2f offset)
	{
		this.name = name;
		this.input = input;
		this.offset = offset;
		//@storage = @CElementalCore();
		@connection = null;
		//lasttransfer = -1;
		dynamictank = false;
		@insertfunc = null;

		//singleelement = false;
		//maxelements = 100;
		//unmixedstorage = false;
		//onlyele = 255;
		//tankid = 0;
		onlymovetagged = false;
		transfercooldown = 60;
		nodeid = 0;
		dynamicconnection = false;
		logicstate = false;
		oldstate = false;
	}

	bool isConnectable(INodeCore@ output, CBlob@ blob, CBlob@ toblob)
	{
		CBlob@ inputblob = @toblob;
		CBlob@ outputblob = @blob;

		return (this !is cast<CLogicPlug>(output) && output.isInput() && !this.input && inputblob !is outputblob && (output.getWorldPosition(inputblob) - getWorldPosition(outputblob)).Length() < maxrange && (isSame(output) || true));
			return true;
		return false;
	}

	void connectTo(INodeCore@ node, CBlob@ blob, CBlob@ toblob)
	{
		if(isConnectable(node, blob, toblob))
		{
			@connection = cast<INodeCore@>(node); 
		}
	}


	void disconnectFrom(INodeCore@ node, CBlob@ blob, CBlob@ toblob)
	{
		if(node is connection)
		{
			disconnectAll(blob);
		}
	}

	void disconnectAll(CBlob@ blob)
	{
		@connection = null;
			
		CSprite@ sprite = blob.getSprite();
					
		if(sprite !is null)
		{
			sprite.RemoveSpriteLayer("pipe" + formatInt(nodeid, ""));
			sprite.RemoveSpriteLayer("pipestart" + formatInt(nodeid, ""));
			sprite.RemoveSpriteLayer("pipeend" + formatInt(nodeid, ""));
		}

	}

	void update(CBlob@ blob, int recursionsleft)
	{
		//Realizing now that all nodes run this, but only output nodes really ever do anything lmao
		//Works for me
		oldstate = logicstate;
		laststatecheck = getGameTime();
		if(lasttrueset < getGameTime() - 2 && input)
			setState(false);
		if(connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			//CBlob@ thisblob = getBlobByNetworkID(thisnetid);
			if(blob is null)
				return; 
			if(toblob is null)
			{
				if(isServer())
				{
					//Detach on death
					CBitStream params;
					params.write_u8(nodeid);
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
						params.write_u8(nodeid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else if(toblob.isInInventory() || blob.isInInventory())
				{
					if(isServer())
					{
						//Detach if in inv
						CBitStream params;
						params.write_u8(nodeid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else
				{
					//Node logic here
					connection.setState(getState());
				}
			}
		}
		return;
	}

	void onRender(CBlob@ blob)
	{
		
		
		if(blob.getInventory() !is null && connection !is null)
		{

		}
	}

	void writeSyncData(CBlob@ blob, CPlayer@ toplayer)
	{
		if(connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob !is null)
			{
				CNodeController@ targcontroll = getNodeController(toblob);
				CBitStream newparams;
				newparams.write_u16(0xFFFF);//Shouldnt matter much
				newparams.write_u8(connection.getID());
				newparams.write_u16(blob.getNetworkID());
				newparams.write_u8(nodeid);
				toblob.server_SendCommandToPlayer(toblob.getCommandID("connect"), newparams, toplayer);
			}
		}
	}

	void readSyncData(CBlob@ blob, CBitStream@ params)
	{
		//Nada, for now
	}

	bool isInput(){return input;}
	string getName(){return name;}
	Vec2f getOffset(){return offset;}
	int getID(){return nodeid;}
	string getPipeSprite(){return "LogicWire.png";}

	bool isSame(INodeCore@ node)
	{
		if(cast<CLogicPlug@>(node) !is null)
			return true;
		return false;
	}	

	void setState(bool newstate)
	{
		if(!newstate && lasttrueset != getGameTime())
			logicstate = newstate;
		if(newstate)
		{
			lasttrueset = getGameTime();
			logicstate = newstate;
		}
			
		
	}

	bool getState()
	{
		if(laststatecheck != getGameTime())
			return oldstate;
		return logicstate;
	}

	Vec2f getWorldPosition(CBlob@ blob)
	{
		Vec2f tempoffset = offset; 
		Vec2f topos = blob.getPosition() + tempoffset.RotateBy(blob.getAngleDegrees());
			
			
		if(blob.get_bool("equipped"))
		{
			CBlob@ equipper = getBlobByNetworkID(blob.get_u16("equipper"));
			if(equipper !is null)
				topos = equipper.getPosition();
		}
		
		return topos;
	}

	

	void updateSprite(CBlob@ blob, CSprite@ sprite)
	{
		{
			
			CSpriteLayer@ pipe = sprite.getSpriteLayer("pipe" + nodeid);
			CSpriteLayer@ pipestart = sprite.getSpriteLayer("pipestart" + nodeid);
			CSpriteLayer@ pipeend = sprite.getSpriteLayer("pipeend" + nodeid);
			
			//MODIFY LATER FOR CUSTOM PIPE COLORING
			//OR OTHER FANCY EFFECTS
			if(pipe !is null)
			{
				if(!logicstate && pipe.getFrame() == 1)
				{
					pipe.SetFrame(4);
					pipestart.SetFrame(3);
					pipeend.SetFrame(5);
				}
				else if(logicstate && pipe.getFrame() == 4)
				{
					pipe.SetFrame(1);
					pipestart.SetFrame(0);
					pipeend.SetFrame(2);
				}
			}
		}
		
		if(connection !is null && (dynamicconnection))
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob !is null)
				updateSpriteNode(blob, toblob, cast<INodeCore@>(this), cast<INodeCore@>(connection), false);
		}
	}
}

class CItemIO : INodeCore
{
	string name;
	bool input;
	Vec2f offset;
	CItemIO@ connection;
	u16 connectionid;
	bool onlymovetagged;
	//int lasttransfer;
	//2 below are used for tanks that can move, so sprite updates properly
	bool dynamictank;
	bool dynamicconnection;
	//Tank limitations
	//bool singleelement;
	//bool unmixedstorage;
	//int maxelements;
	//u8 onlyele;
	//u8 tankid;
	insertionFunc@ insertfunc;
	u8 transfercooldown;
	u8 nodeid;
	u16 thisnetid;
	array<CItemIO@> routingcache;
	array<Vec2f> localroutingroute;
	
	CItemIO(string name, bool input, Vec2f offset)
	{
		this.name = name;
		this.input = input;
		this.offset = offset;
		//@storage = @CElementalCore();
		@connection = null;
		//lasttransfer = -1;
		dynamictank = false;
		@insertfunc = null;

		//singleelement = false;
		//maxelements = 100;
		//unmixedstorage = false;
		//onlyele = 255;
		//tankid = 0;
		onlymovetagged = false;
		transfercooldown = 60;
		nodeid = 0;
		dynamicconnection = false;
	}

	bool isConnectable(INodeCore@ output, CBlob@ blob, CBlob@ toblob)
	{
		CBlob@ inputblob = @toblob;
		CBlob@ outputblob = @blob;

		return (this !is cast<CItemIO>(output) && output.isInput() && !this.input && inputblob !is outputblob && (output.getWorldPosition(inputblob) - getWorldPosition(outputblob)).Length() < maxrange && isSame(output));
			return true;
		return false;
	}

	void connectTo(INodeCore@ node, CBlob@ blob, CBlob@ toblob)
	{
		if(isConnectable(node, blob, toblob))
		{
			@connection = cast<CItemIO@>(node); 
		}
	}


	void disconnectFrom(INodeCore@ node, CBlob@ blob, CBlob@ toblob)
	{
		if(cast<CItemIO@>(node) is connection)
		{
			disconnectAll(blob);
		}
	}

	void disconnectAll(CBlob@ blob)
	{
		@connection = null;
			
		CSprite@ sprite = blob.getSprite();
					
		if(sprite !is null)
		{
			sprite.RemoveSpriteLayer("pipe" + formatInt(nodeid, ""));
			sprite.RemoveSpriteLayer("pipestart" + formatInt(nodeid, ""));
			sprite.RemoveSpriteLayer("pipeend" + formatInt(nodeid, ""));
		}

	}

	void update(CBlob@ blob, int recursionsleft)
	{
		bool moving = false;
		if(connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			//CBlob@ thisblob = getBlobByNetworkID(thisnetid);
			if(blob is null)
				return; 
			if(toblob is null)
			{
				if(isServer())
				{
					//Detach on death
					CBitStream params;
					params.write_u8(nodeid);
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
						params.write_u8(nodeid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else if(toblob.isInInventory() || blob.isInInventory())
				{
					if(isServer())
					{
						//Detach if in inv
						CBitStream params;
						params.write_u8(nodeid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else
				{
					if(blob.getInventory() !is null)
					{
						
						CBlob@ item = getFirstPossibleItem(blob, toblob);
						if(item !is null)
						{
							transfercooldown--;
							moving = true;
						}
						
						if(transfercooldown == 0)
						{
							if(!doTransfer(blob, toblob, item))
							{
								blob.server_PutInInventory(item);
							}
							
							transfercooldown = 60;
						}
					}
				}
			}
		}
		if(!moving)
			transfercooldown = 60;
		return;
	}

	void onRender(CBlob@ blob)
	{
		
		
		if(blob.getInventory() !is null && connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob is null) return;

			CBlob@ item = getFirstPossibleItem(blob, toblob);

		

			if(item !is null && isClient())
			{
				if(transfercooldown == 60 || transfercooldown == 59)//Probe network for route
				{
					routingroute.clear();
					routingroute.push_back(getWorldPosition(blob));
					bool success = doTransfer(blob, toblob, item, true);
					if(!success)//Failed to get route: abort
					{
						routingroute.clear();
						return;
					}
					routingroute.reverse();
					localroutingroute.clear();
					for(int i = 0; i < routingroute.size(); i++)
					{
						localroutingroute.push_back(routingroute[i]);
					}
				}
				int conns = localroutingroute.size() - 1;
				
				
				float transferratio = (transfercooldown - getInterpolationFactor()) / 60.0 * conns;
				if(conns < 0)
					return;
				int floored = Maths::Floor(transferratio);
				Vec2f midpoint = Vec2f_lerp(localroutingroute[floored], localroutingroute[floored + 1], transferratio - floored);

				/*
				float transferratio = (transfercooldown - getInterpolationFactor()) / 60.0;
				Vec2f midpoint = Vec2f_lerp(connection.getWorldPosition(toblob), getWorldPosition(blob), transferratio);
				*/
				array<Vertex> vertlist;

				const float sizeofthisgarbage = 2.0;

				SColor linecol = getAverageItemColor(item);

				vertlist.push_back(Vertex(midpoint.x - sizeofthisgarbage, midpoint.y - sizeofthisgarbage, 100, 0, 0, linecol));
				vertlist.push_back(Vertex(midpoint.x + sizeofthisgarbage, midpoint.y - sizeofthisgarbage, 100, 1, 0, linecol));
				vertlist.push_back(Vertex(midpoint.x + sizeofthisgarbage, midpoint.y + sizeofthisgarbage, 100, 1, 1, linecol));
				vertlist.push_back(Vertex(midpoint.x - sizeofthisgarbage, midpoint.y + sizeofthisgarbage, 100, 0, 1, linecol));

				addVertsToExistingRender(@vertlist, "Entities/Industry/ItemIO/ItemPacket.png", "RLrender");
				
			}
		}
	}

	bool doTransfer(CBlob@ blob, CBlob@ toblob, CBlob@ item, bool probe = false)
	{
		if(!probe)
			item.Untag("outputblob");
		if(connection.insertfunc !is null)//This overrides other behaviors, i guess
		{
			for(int i = 0; i < routingcache.size(); i++)
			{
				if(routingcache[i] is connection)
				{
					routingcache.clear();
					transfercooldown = 60;
					return false;
				}
			}
			routingcache.push_back(@connection);
			if(probe)
			{
				routingroute.push_back(connection.getWorldPosition(toblob));
			}
			else
				transfercooldown = 60;
			bool results = connection.insertfunc(toblob, item, probe, blob);
			routingcache.clear();
			return results;
		}
		else
		{
			/*array<string> checked;
			int stackstaken = 0;
			int maxstacks = toinv.getInventorySlots().x * toinv.getInventorySlots().y;

			for(int i = 0; i < toinv.getItemsCount(); i++)
			{
				CBlob@ thisitem = toinv.getItem(i);
				string itemname = thisitem.getConfig();
				if(checked.find(itemname) == -1)
				{
					checked.push_back(itemname);
					int itemcount = toinv.getCount(itemname); 
					itemcount = Maths::Ceil(Maths::Ceil(itemcount / float(thisitem.maxQuantity)) / float(thisitem.inventoryMaxStacks));
					stackstaken += itemcount * thisitem.inventoryFrameDimension.x * thisitem.inventoryFrameDimension.y;
					//print("" + Maths::Ceil(thisitem.inventoryFrameDimension.x / 24.0) + " " +  Maths::Ceil(thisitem.inventoryFrameDimension.y / 24.0));
				}
			}*/
			//print("Max: " + maxstacks + ", Taken: " + stackstaken);
			if(!probe)
			{
				transfercooldown = 60;
				return toblob.server_PutInInventory(item);
			}
			else
			{
				routingroute.insertLast(connection.getWorldPosition(toblob));
				return true;
			}
		}
		return false;
	}

	CBlob@ getFirstPossibleItem(CBlob@ blob, CBlob@ toblob)
	{
		CInventory@ inv = blob.getInventory();
		CInventory@ toinv = toblob.getInventory();

		int i = 0;
		while(true)
		{
			CBlob@ item = inv.getItem(i);
			if(item !is null)
			{
				//Checking if valid to move here
				if(!onlymovetagged || item.hasTag("outputblob"))
					return item;
				else
					i++;
			}
			else 
				break;
		}
		return null;
	}

	void writeSyncData(CBlob@ blob, CPlayer@ toplayer)
	{
		if(connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob !is null)
			{
				CNodeController@ targcontroll = getNodeController(toblob);
				CBitStream newparams;
				newparams.write_u16(0xFFFF);//Shouldnt matter much
				newparams.write_u8(connection.getID());
				newparams.write_u16(blob.getNetworkID());
				newparams.write_u8(nodeid);
				toblob.server_SendCommandToPlayer(toblob.getCommandID("connect"), newparams, toplayer);
			}
		}
	}

	void readSyncData(CBlob@ blob, CBitStream@ params)
	{
		//Nada, for now
	}

	bool isInput(){return input;}
	string getName(){return name;}
	Vec2f getOffset(){return offset;}
	int getID(){return nodeid;}
	string getPipeSprite(){return "ItemPipe.png";}

	bool isSame(INodeCore@ node)
	{
		if(cast<CItemIO@>(node) !is null)
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
		Vec2f tempoffset = offset; 
		Vec2f topos = blob.getPosition() + tempoffset.RotateBy(blob.getAngleDegrees());
			
			
		if(blob.get_bool("equipped"))
		{
			CBlob@ equipper = getBlobByNetworkID(blob.get_u16("equipper"));
			if(equipper !is null)
				topos = equipper.getPosition();
		}
		
		return topos;
	}

	

	void updateSprite(CBlob@ blob, CSprite@ sprite)
	{
		{
			CSpriteLayer@ pipe = sprite.getSpriteLayer("pipe" + nodeid);
			CSpriteLayer@ pipestart = sprite.getSpriteLayer("pipestart" + nodeid);
			CSpriteLayer@ pipeend = sprite.getSpriteLayer("pipeend" + nodeid);
			
			//MODIFY LATER FOR CUSTOM PIPE COLORING
			//OR OTHER FANCY EFFECTS
		}
		
		if(connection !is null && (dynamicconnection))
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob !is null)
				updateSpriteNode(blob, toblob, cast<INodeCore@>(this), cast<INodeCore@>(connection), false);
		}
	}
}

SColor getAverageItemColor(CBlob@ item)
{
	if(getRules().exists(item.getConfig() + "_avg_r"))
	{
		return SColor(255,
		getRules().get_u8(item.getConfig() + "_avg_r"),
		getRules().get_u8(item.getConfig() + "_avg_g"),
		getRules().get_u8(item.getConfig() + "_avg_b"));
	}
	CSprite@ spr = item.getSprite();
	if(spr !is null)
	{
		string texname = spr.getFilename();

		Texture::createFromFile(texname, texname);
		ImageData@ data = Texture::data(texname);
		if(data !is null)
		{
			float red = 0;
			float green = 0;
			float blue = 0;
			int count = 0;
			for(int i = 0; i < data.size(); i++)
			{
				SColor tc = data[i];
				if(tc.getAlpha() == 255)
				{
					red += tc.getRed();
					green += tc.getGreen();
					blue += tc.getBlue();
					count++;
				}
			}
			if(count == 0)
			{
				print("Average item color has count of 0: strange behavior");
				count = 1;
			}
			red /= count;
			green /= count;
			blue /= count;
			getRules().set_u8(item.getConfig() + "_avg_r", red);
			getRules().set_u8(item.getConfig() + "_avg_g", green);
			getRules().set_u8(item.getConfig() + "_avg_b", blue);
			return SColor(255, red, green, blue);
		}
	}
	return SColor(255, 255, 255, 255);
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
	u8 nodeid;
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
		nodeid = 0;
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
			disconnectAll(blob);
		}
	}

	void disconnectAll(CBlob@ blob)
	{
		@connection = null;

		lasttransfer = -1;
			
		CSprite@ sprite = blob.getSprite();
					
		if(sprite !is null)
		{
			sprite.RemoveSpriteLayer("pipe" + formatInt(nodeid, ""));
			sprite.RemoveSpriteLayer("pipestart" + formatInt(nodeid, ""));
			sprite.RemoveSpriteLayer("pipeend" + formatInt(nodeid, ""));
		}
		
		blob.set_s16("transfercache" + nodeid, -1);
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
					params.write_u8(nodeid);
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
						params.write_u8(nodeid);
						blob.SendCommand(blob.getCommandID("disconnect"), params);
					}
				}
				else if(toblob.isInInventory() || blob.isInInventory())
				{
					if(isServer())
					{
						//Detach if in inv
						CBitStream params;
						params.write_u8(nodeid);
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

	void writeSyncData(CBlob@ blob, CPlayer@ toplayer)
	{
		if(connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob !is null)
			{
				CNodeController@ targcontroll = getNodeController(toblob);
				CBitStream newparams;
				newparams.write_u16(0xFFFF);//Shouldnt matter much
				//What a mess
				//Hope it works
				newparams.write_u8(connection.getID());
				newparams.write_u16(blob.getNetworkID());
				newparams.write_u8(nodeid);
				toblob.server_SendCommandToPlayer(toblob.getCommandID("connect"), newparams, toplayer);
				//ok, so thats connections synced... next is tank storage... urgh
			}
		}

		CBitStream elementparams;
		elementparams.write_u8(nodeid);
		//CElementalCore@ storage = @cast<CAlchemyTank>(controller.nodes[i]).storage;
		for (uint j = 0; j < storage.elements.size(); j++)
		{
			elementparams.write_s32(storage.elements[j]);
		}
		blob.server_SendCommandToPlayer(blob.getCommandID("recsync"), elementparams, toplayer);
		//Maybe works? might actually be too much data to send at once lel
		//oh well
	}

	void readSyncData(CBlob@ blob, CBitStream@ params)
	{
		for (uint j = 0; j < storage.elements.length; j++)
		{
			storage.elements[j] = params.read_s32();
		}
	}

	bool isInput(){return input;}
	string getName(){return name;}
	Vec2f getOffset(){return offset;}
	int getID(){return nodeid;}
	string getPipeSprite(){return "AlchemyPipe.png";}
	void onRender(CBlob@ blob){}

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
		Vec2f tempoffset = offset; 
		Vec2f topos = blob.getPosition() + tempoffset.RotateBy(blob.getAngleDegrees());
			
			
		if(blob.get_bool("equipped"))
		{
			CBlob@ equipper = getBlobByNetworkID(blob.get_u16("equipper"));
			if(equipper !is null)
				topos = equipper.getPosition();
		}
		
		return topos;
	}

	

	void updateSprite(CBlob@ blob, CSprite@ sprite)
	{
		int ltid = lasttransfer;
		//Since apparently SetColor is broken and worthless we'll just make our own sprites on the go
		if(blob.get_s16("transfercache" + nodeid) != ltid)
		{
			CSpriteLayer@ pipe = sprite.getSpriteLayer("pipe" + nodeid);
			CSpriteLayer@ pipestart = sprite.getSpriteLayer("pipestart" + nodeid);
			CSpriteLayer@ pipeend = sprite.getSpriteLayer("pipeend" + nodeid);
			
			
			
			if(pipe !is null && pipestart !is null && pipeend !is null)
			{
				if(ltid == -1)
				{
					pipe.ReloadSprite("AlchemyPipe.png");
					pipestart.ReloadSprite("AlchemyPipe.png");
					pipeend.ReloadSprite("AlchemyPipe.png");
				}
				else
				{
					if(!Texture::exists("AlchemyPipe" + ltid))
					{
						//print("Making image");
						//Makes base alchemypipe texture
						//Making our modified version directly from file seems to have strange side effects
						if(!Texture::exists("AlchemyPipe"))
							Texture::createFromFile("AlchemyPipe", "AlchemyPipe.png");
						//print("New img: " + ltid);
						ImageData@ newimage = Texture::data("AlchemyPipe");
						for(uint x = 0; x < newimage.width(); x++)
						{
							for(uint y = 0; y < newimage.height(); y++)
							{
								SColor mixcolor = newimage.get(x, y);
								mixcolor.set(mixcolor.getAlpha(), 
								float(mixcolor.getRed() * elementlist[ltid].color.getRed()) / 255.0, 
								float(mixcolor.getGreen() * elementlist[ltid].color.getGreen()) / 255.0, 
								float(mixcolor.getBlue() * elementlist[ltid].color.getBlue()) / 255.0);
								newimage.put(x, y, mixcolor);
							}
						}
						Texture::createFromData("AlchemyPipe" + ltid, newimage);
					}
					//print("Setting tex");
					pipe.SetTexture("AlchemyPipe" + ltid);
					pipestart.SetTexture("AlchemyPipe" + ltid);
					pipeend.SetTexture("AlchemyPipe" + ltid);
				}
			}
				//pipe.SetColor(controller.tanks[i].lasttransfer == -1 ? SColor(255, 255, 255, 255) : elementlist[controller.tanks[i].lasttransfer].color);
			blob.set_s16("transfercache" + nodeid, ltid);
		}
		
		if(connection !is null && (dynamicconnection))
		{
			CBlob@ toblob = getBlobByNetworkID(connectionid);
			if(toblob !is null)
				updateSpriteNode(blob, toblob, cast<INodeCore@>(this), cast<INodeCore@>(connection), false);
		}
	}
}

void updateSpriteNode(CBlob@ blob, CBlob@ toblob, INodeCore@ fromtank, INodeCore@ totank, bool deletelayer = true)
{
	CSprite@ sprite = blob.getSprite();
					
	//Making the tube bit
	if(sprite !is null)
	{	
		CSpriteLayer@ pipe;
		CSpriteLayer@ pipestart;
		CSpriteLayer@ pipeend;
		string idstr = formatInt(fromtank.getID(), "");
		
		Vec2f topos = totank.getWorldPosition(toblob);
		Vec2f frompos = fromtank.getWorldPosition(blob);
		
		if(deletelayer)
		{
			sprite.RemoveSpriteLayer("pipe" + idstr);//Shouldnt be necessary, but hey, you never know
			sprite.RemoveSpriteLayer("pipestart" + idstr);
			sprite.RemoveSpriteLayer("pipeend" + idstr);
			//sprite.RemoveSpriteLayer("pipefluid" + idstr);
			@pipe = sprite.addSpriteLayer("pipe" + idstr, fromtank.getPipeSprite(), 8, 8);
			pipe.SetRelativeZ(-3);
			pipe.SetFrame(1);
			pipe.SetIgnoreParentFacing(true);
			pipe.SetFacingLeft(false);
			
			@pipestart = sprite.addSpriteLayer("pipestart" + idstr, fromtank.getPipeSprite(), 8, 8);
			pipestart.SetRelativeZ(-2);
			pipestart.SetFrame(0);
			pipestart.SetIgnoreParentFacing(true);
			pipestart.SetFacingLeft(false);
			
			@pipeend = sprite.addSpriteLayer("pipeend" + idstr, fromtank.getPipeSprite(), 8, 8);
			pipeend.SetRelativeZ(-2);
			pipeend.SetFrame(2);
			pipeend.SetIgnoreParentFacing(true);
			pipeend.SetFacingLeft(false);
		}
		else
		{
			@pipe = sprite.getSpriteLayer("pipe" + idstr);
			@pipestart = sprite.getSpriteLayer("pipestart" + idstr);
			@pipeend = sprite.getSpriteLayer("pipeend" + idstr);
		}
		
		if(pipe is null || pipeend is null || pipestart is null)
		{
			warn("Null sprite layer for pipes in NodeCommon (CAlchemyTank)!");
			return;
		}
		
		pipe.ResetTransform();
		pipeend.ResetTransform();
		pipestart.ResetTransform();
		
		//CSpriteLayer@ pipefluid = sprite.addSpriteLayer("pipefluid" + idstr, "PixelWhite.png", 1, 1);
		//pipefluid.SetRelativeZ(1);
		//pipefluid.SetColor(SColor(0, 0, 0, 0));
		//pipefluid.setRenderStyle(RenderStyle::shadow);
		
		
		
		Vec2f diff = (topos) - (frompos);
		Vec2f enddiff = topos - blob.getPosition();
		enddiff.RotateBy(-blob.getAngleDegrees());
		
		Vec2f tempoffs = -totank.getOffset();
		tempoffs.RotateBy(blob.getAngleDegrees());
		tempoffs += diff;
		tempoffs.RotateBy(-blob.getAngleDegrees());
		
		pipe.ScaleBy(Vec2f(diff.Length() / 8.0, 1));
		pipe.RotateBy(diff.Angle() * -1 + 360 - blob.getAngleDegrees(), Vec2f(diff.Length() / 2, 0));
		pipe.TranslateBy(fromtank.getOffset() + Vec2f(diff.Length() / 2, 0));
		
		//pipefluid.ScaleBy(Vec2f(diff.Length(), 2));
		//pipefluid.RotateBy(diff.Angle() * -1 + 360, Vec2f(diff.Length() / 2, 0));
		//pipefluid.TranslateBy(fromtank.offset + Vec2f(diff.Length() / 2, 0));
		
		pipeend.RotateBy(diff.Angle() * -1 + 360 -blob.getAngleDegrees(), Vec2f_zero);
		pipeend.TranslateBy(enddiff);
		
		//diff *= 8.0 / diff.Length() + 1.0;
		
		pipestart.RotateBy(diff.Angle() * -1 + 360 -blob.getAngleDegrees(), Vec2f_zero);
		pipestart.TranslateBy(fromtank.getOffset());
	}
}

class CNodeController
{
	array<CAlchemyTank@> tanks;
	array<CItemIO@> itemios;
	array<CLogicPlug@> plugs;
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
		newtank.nodeid = nodes.size();
		newtank.thisnetid = blobnetid;
		tanks.push_back(@newtank);
		nodes.push_back(@newtank);
		return @newtank;
	}

	CItemIO@ addItemIO(string name, bool input, Vec2f offset)
	{
		CItemIO newitemio(name, input, offset);
		//newitemio.tankid = tanks.size();
		newitemio.nodeid = nodes.size();
		newitemio.thisnetid = blobnetid;
		itemios.push_back(@newitemio);
		nodes.push_back(@newitemio);
		return @newitemio;
	}

	CLogicPlug@ addLogicPlug(string name, bool input, Vec2f offset)
	{
		CLogicPlug newplug(name, input, offset);
		//newitemio.tankid = tanks.size();
		newplug.nodeid = nodes.size();
		newplug.thisnetid = blobnetid;
		plugs.push_back(@newplug);
		nodes.push_back(@newplug);
		return @newplug;
	}


	CLogicPlug@ getLogicPlug(string name)
	{
		for (int i = 0; i < plugs.length; i++)
		{
			if(plugs[i].name == name)
			{
				return @plugs[i];
			}
		}
		return null;
	}

	CItemIO@ getItemIO(string name)
	{
		for (int i = 0; i < itemios.length; i++)
		{
			if(itemios[i].name == name)
			{
				return @itemios[i];
			}
		}
		return null;
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
			print("Outside of bounds - Tanks");
		return null;
	}

	CLogicPlug@ getLogicPlug(int id)
	{
		if(id < plugs.length && id >= 0)
			return plugs[id];
		else
			print("Outside of bounds - Logic");
		return null;
	}

	INodeCore@ getNode(int id)
	{
		if(id < nodes.length && id >= 0)
			return nodes[id];
		else
			print("Outside of bounds - Nodes");
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

bool hasTanks(CBlob@ blob)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return false;
	if(controller.tanks.size() == 0)
		return false;
	return true;
}

CAlchemyTank@ addTank(CBlob@ blob, string name, bool input, Vec2f offset)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.addTank(name, input, offset);
}

CItemIO@ addItemIO(CBlob@ blob, string name, bool input, Vec2f offset)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.addItemIO(name, input, offset);
}

CLogicPlug@ addLogicPlug(CBlob@ blob, string name, bool input, Vec2f offset)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.addLogicPlug(name, input, offset);
}

CLogicPlug@ getLogicPlug(CBlob@ blob, string name)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.getLogicPlug(name);
}

CItemIO@ getItemIO(CBlob@ blob, string name)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.getItemIO(name);
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

CLogicPlug@ getLogicPlug(CBlob@ blob, int id)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.getLogicPlug(id);
}

INodeCore@ getNode(CBlob@ blob, int id)
{
	CNodeController@ controller;
	blob.get("nodecontroller", @controller);
	if(controller is null)
		return null;
	return @controller.getNode(id);
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

bool getDisabled(CBlob@ this)	//Gets the "disabled" logic plug, returns it's state
{
	CLogicPlug@ p = getLogicPlug(this, "Disable");
	if(p !is null)
		return p.logicstate;
	return false;
}

void addToTank(CAlchemyTank@ tank, int element, int count)
{
	if(element < elementlist.size() && tank !is null)
		tank.storage.elements[element] += count;
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

