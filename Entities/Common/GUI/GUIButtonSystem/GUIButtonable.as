//handles gui buttons
#include "GUIButtons.as";

void onInit(CBlob@ this)//this script first so we dont clear anything out that we shouldnt
{
	CCustomButtonSystem buttons();
	this.set("guibuttons", @buttons);
}

void onTick(CBlob@ this)
{
	if(this is getLocalPlayerBlob())
	{
		CCustomButtonSystem@ buttons;
		CControls@ controls = this.getControls();
		this.get("guibuttons", @buttons);
		if(buttons !is null && controls !is null)//just in case
		{
			if(this.isKeyJustPressed(key_action1))//button push checking
			{
				CCustomButton@ butt;
				@butt = @buttons.firstAt(controls.getMouseScreenPos());
				if(butt !is null)
				{
					CBitStream params;
					string[] cmdsplt = butt.id.split(":");
					if(cmdsplt.length > 1)
						params.write_u8(parseInt(cmdsplt[1]));
					
					if(this.hasCommandID(cmdsplt[0]))
						this.SendCommand(this.getCommandID(cmdsplt[0]), params);
					else
						print("Command ID " + cmdsplt[0] + " not registered!");
				}
			}
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob !is null && blob is getLocalPlayerBlob())
	{
		CCustomButtonSystem@ buttons;
		blob.get("guibuttons", @buttons);
		if(buttons !is null)
		{
			buttons.drawAll();
			CControls@ controls = blob.getControls();
			CCustomButton@ butt;
			if(controls !is null)
			{
				@butt = @buttons.firstAt(controls.getMouseScreenPos());
				if(butt !is null)
				{
					butt.drawHoverText();
				}
			}
		}
	}
}















