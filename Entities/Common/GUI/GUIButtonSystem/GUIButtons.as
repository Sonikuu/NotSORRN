//Fancy custom button system, maybe

shared class CCustomButton
{
	Vec2f pos;
	Vec2f size;
	bool active;
	SColor color;
	SColor textcolor;
	SColor iconcolor;
	string id;
	string texture;
	string icon;
	string text;
	string hoverText;
	Vec2f imagesize;
	Vec2f iconsize;	//icon does not automatically scale, so modify this and prop below to set frame from spritesheet
	int iconframe;
	
	CCustomButton(string id, Vec2f pos, Vec2f size, string texture)
	{
		this.pos = pos;
		this.size = size;
		this.id = id;
		this.active = true;
		this.color = SColor(255, 255, 255, 255);
		this.textcolor = SColor(255, 255, 255, 255);
		this.iconcolor = SColor(255, 255, 255, 255);
		this.texture = texture;
		this.icon = "EmptySquare.png";
		this.text = "";
		this.hoverText = "";
		this.iconframe = 0;
		getBothSize();
	}
	
	void draw()
	{
		GUI::SetFont("snes");
		GUI::DrawIcon(texture, 0, imagesize, pos, (size.x / imagesize.x) / 2, (size.y / imagesize.y) / 2, color);
		GUI::DrawIcon(icon, iconframe, iconsize, (pos + size / 2) - iconsize, 1, iconcolor);
		GUI::DrawTextCentered(text, (pos + size / 2), textcolor);
	}
	
	void drawHoverText()
	{
	
		//Vec2f dimensions;
		Vec2f textpos = Vec2f(pos.x + size.x / 2, pos.y - 20);
		textpos.x = Maths::Min(getScreenWidth() - 20, Maths::Max(20, textpos.x));
		textpos.y = Maths::Min(getScreenHeight() - 20, Maths::Max(20, textpos.y));
		GUI::SetFont("menu");
		//GUI::GetTextDimensions(mouseBlob.getInventoryName(), dimensions);
		GUI::DrawTextCentered(hoverText, textpos, SColor(255, 255, 255, 255));

	}
	
	void getBothSize()
	{
		getImageSize();
		getIconSize();
	}
	
	void getImageSize()
	{
		Vec2f imgsize(0, 0);
		//GUI::GetImageDimensions(texture, imgsize); causes crashes
		if(!Texture::exists(texture))
			Texture::createFromFile(texture, texture);
		imgsize.x = Texture::width(texture);
		imgsize.y = Texture::height(texture);
		//Texture::destroy(texture);
		
		if(imgsize.x == 0)
		{
			imgsize.x = 1;
		}
		if(imgsize.y == 0)
		{
			imgsize.y = 1;
		}
		imagesize = imgsize;
	}
	
	void getIconSize()
	{
		Vec2f ico(0, 0);
		//GUI::GetImageDimensions(icon, ico);
		if(!Texture::exists(icon))
			Texture::createFromFile(icon, icon);
		ico.x = Texture::width(icon);
		ico.y = Texture::height(icon);
		//Texture::destroy(icon);
		if(ico.x == 0)
		{
			ico.x = 1;
		}
		if(ico.y == 0)
		{
			ico.y = 1;
		}
		iconsize = ico;
	}
	
	void setImage(string image)
	{
		texture = image;
		getImageSize();
	}
	
	void setIcon(string ico)
	{
		icon = ico;
		getIconSize();
	}
}

shared class CCustomButtonSystem
{
	array<CCustomButton@> buttons;
	
	CCustomButton@ addButton(string id, Vec2f pos, Vec2f size, string texture = "")
	{
		CCustomButton@ butt = @CCustomButton(id, pos, size, texture);
		buttons.insertLast(@butt);
		return @butt;
	}
	CCustomButtonSystem()
	{
		buttons = array<CCustomButton@>(0);
	}
	
	void removeButton(string id)//removes all matching
	{
		for (int i = 0; i < buttons.size(); i++)
		{
			if(id == buttons[i].id)
			{
				buttons.removeAt(i);
				i--;
			}
		}
	}
	
	CCustomButton@ getButton(int id)
	{
		CCustomButton@ output = null;
		if(Maths::Abs(id) < buttons.size())
			@output = @(buttons[id]);
		return output;
	}
	
	CCustomButton@ getButton(string id)//gets first
	{
		CCustomButton@ output = null;
		for (int i = 0; i < buttons.size(); i++)
		{
			if(id == buttons[i].id)
			{
				@output = @(buttons[i]);
				break;
			}
		}
		return output;
	}
	
	void removeButton(int id)
	{
		if(Maths::Abs(id) < buttons.size())
			buttons.removeAt(id);
	}
	
	void drawAll()
	{
		for (int i = 0; i < buttons.size(); i++)
		{
			if(buttons[i].active)
			{
				buttons[i].draw();
			}
		}
	}
	
	CCustomButton@ firstAt(Vec2f pos)//dont overlap yer buttons thanks
	{
		CCustomButton@ output = null;
		for (int i = 0; i < buttons.size(); i++)
		{
			Vec2f buttonpos = buttons[i].pos;
			Vec2f buttonsize = buttons[i].size;
			if(buttons[i].active && 
			buttonpos.x <= pos.x && 
			buttonpos.x + buttonsize.x >= pos.x && 
			buttonpos.y <= pos.y && 
			buttonpos.y + buttonsize.y >= pos.y)
			{
				@output = @(buttons[i]);
				break;
			}
		}
		return output;
	}
}














