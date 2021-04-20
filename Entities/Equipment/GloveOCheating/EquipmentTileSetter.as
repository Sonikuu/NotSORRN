//weapons common

#include "EquipmentCore.as";

class CTileSetterEquipment : CEquipmentCore
{
	int selected;
	bool menuopen;

	
	CTileSetterEquipment()
	{
		super();
		//name = "Tile Setting Glove";
		//color = SColor(255, 100, 50, 0);
		
		selected = 0;
		menuopen = false;
	}
	
	void onRender(CBlob@ blob, CBlob@ user)
	{
		if(user is getLocalPlayerBlob())
		{
			GUI::DrawText("Selected Tile: " + formatInt(selected, ""), Vec2f(getScreenWidth() - 600, 20), SColor(255, 255, 255, 255));
			GUI::DrawText("O to open tile selection", Vec2f(getScreenWidth() - 600, 60), SColor(255, 255, 255, 255));
			if(menuopen)
			{
				GUI::DrawIcon("world.png", Vec2f(getScreenWidth() / 2 - 128, 0));
			}
		}
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		Vec2f pos = user.getPosition();
		const bool right_click = user.isKeyPressed(key_action2);
		const bool left_click = user.isKeyJustPressed(key_action1);

		CMap@ map = getMap();
		CControls@ controls = getControls();
		if(controls !is null)
		{
			if(controls.isKeyPressed(KEY_KEY_O))
			{
				menuopen = true;
				//selected--;
			}
			if(menuopen && left_click)
			{
				Vec2f startpos(getScreenWidth() / 2 - 128, 0);
				Vec2f aimpos = controls.getMouseScreenPos();
				Vec2f selectorpos = aimpos - startpos;
				if(selectorpos.x >=0 && selectorpos.x <= 256)
				{
					selected = Maths::Floor(selectorpos.y / 16) * 16 + Maths::Floor(selectorpos.x / 16);
				}
				menuopen = false;
			}
		}
		if (right_click && user is getLocalPlayerBlob())
		{
			Vec2f aimpos = user.getAimPos();
			//aimpos /= map.tilesize;
			//aimpos.x += 0.5;
			//aimpos.y += 0.5;
			CBitStream params;
			params.write_u32(0);
			params.write_u16(selected);
			params.write_Vec2f(aimpos);
			blob.SendCommandOnlyServer(blob.getCommandID("partcmd"), params);
		}
		
	}
	
	

	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		u16 tileid = 0;
		//if(WeaponBitStreams::Nextu16 & bits == WeaponBitStreams::Tu16)
		{
			tileid = params.read_u16();
			//bits &= ~WeaponBitStreams::Tu16;
			
			Vec2f setpos = Vec2f(0, 0);
			//if(WeaponBitStreams::NextVec2f & bits == WeaponBitStreams::TVec2f)
			{
				setpos = params.read_Vec2f();
				//bits &= ~WeaponBitStreams::TVec2f;
				CMap@ map = getMap();
				map.server_SetTile(setpos, tileid);
			}
		}
		
		return bits;
	}
	
	bool canBeEquipped(CBlob@ blob, int slot)
	{
		if(slot == 0)
			return true;
		return false;
	}
	
	string getDescription()
	{
		return "Basically a map editor";
	}
}
