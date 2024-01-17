#define CLIENT_ONLY

enum EShaderLayer
{
    testShader = 2,//game doesn't like it if you don't start at 2 :v
    GolemiteVision,
    disoriented,
	Fog
}

void onInit(CRules@ this)
{
    this.set_bool("GolemiteVisionRunning",false);
    this.set_bool("testShader",false);
    this.set_u32("disoriented",0);

    getDriver().SetShader("hq2x",false);//ew blury
    getDriver().ForceStartShaders(); //need dem shaders doh
    if(this.get_bool("testShader"))
    {
        getDriver().AddShader("testShader",EShaderLayer::testShader);
        getDriver().SetShader("testShader",true);
    }

    getDriver().AddShader("disoriented",EShaderLayer::disoriented);

	getDriver().AddShader("Fog", EShaderLayer::Fog);
	getDriver().SetShader("Fog",true);
    
}

void onTick(CRules@ this)
{
    if(this.get_bool("testShader"))
    {
        getDriver().SetShaderFloat("testShader", "time",getGameTime());
    }

    if(getLocalPlayerBlob() !is null && getLocalPlayerBlob().getConfig() == "golemites")
    {
        if(this.get_bool("GolemiteVisionRunning") == false)
        {
            this.set_bool("GolemiteVisionRunning",true);
            getDriver().AddShader("GolemiteVision",EShaderLayer::GolemiteVision);
            getDriver().SetShader("GolemiteVision", true);
        }
        else
        {
			CFileMatcher matchy("Shaders/ExtraTextures/noiseTexture ("+XORRandom(5)+").png");
		

            getDriver().SetShaderExtraTexture("GolemiteVision", matchy.getFirst());
        }
    }
    else if(this.get_bool("GolemiteVisionRunning"))
    {
        getDriver().SetShader("GolemiteVision",false);
        this.set_bool("GolemiteVisionRunning",false);
    }

    if(this.get_u32("disoriented") > 0 && getLocalPlayerBlob() !is null)
    {
        getDriver().SetShader("disoriented",true);
        this.add_u32("disoriented",-1);
        getDriver().SetShaderInt("disoriented","time",getGameTime());

        if(getGameTime() % 30 == 0)
        {
            getDriver().SetShaderFloat("disoriented","_1",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_2",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_3",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_4",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_5",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_6",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_7",XORRandom(100)/100.0);
            getDriver().SetShaderFloat("disoriented","_8",XORRandom(100)/100.0);
        }
    }
    else
    {
        getDriver().SetShader("disoriented",false);
    }
	
    
	Vec2f center = getLocalPlayerBlob() is null ? Vec2f(getScreenWidth() / 2.0, getScreenHeight() / 2.0) : getLocalPlayerBlob().getScreenPos(); 

    center /= Vec2f(getScreenWidth(), getScreenHeight());
        center.y = 1.0 - center.y; 
	getDriver().SetShaderFloat("Fog", "centerposx", center.x);
	getDriver().SetShaderFloat("Fog", "centerposy", center.y);
    getDriver().SetShaderFloat("Fog", "zoomlevel", 1.0 / getCamera().targetDistance);
    getDriver().SetShaderFloat("Fog", "gametime", getGameTime() / 1.0);
    getDriver().SetShaderFloat("Fog", "density", this.get_f32("rainratio") * 2.0);

    getDriver().SetShaderFloat("Fog", "screenWidth", getScreenWidth());
    getDriver().SetShaderFloat("Fog", "screenHeight", getScreenHeight());
    
	
}
