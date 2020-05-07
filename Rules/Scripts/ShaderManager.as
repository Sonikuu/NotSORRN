#define CLIENT_ONLY

enum EShaderLayer
{
    testShader = 2,//game doesn't like it if you don't start at 2 :v
    SoulVision,
    disoriented
}

void onInit(CRules@ this)
{
    this.set_bool("SoulVisionRunning",false);
    this.set_bool("testShader",true);
    this.set_u32("disoriented",0);

    getDriver().SetShader("hq2x",false);//ew blury
    getDriver().ForceStartShaders(); //need dem shaders doh
    if(this.get_bool("testShader"))
    {
        getDriver().AddShader("testShader",EShaderLayer::testShader);
        getDriver().SetShader("testShader",true);
    }

    getDriver().AddShader("disoriented",EShaderLayer::disoriented);
    
}

void onTick(CRules@ this)
{
    if(this.get_bool("testShader"))
    {
        getDriver().SetShaderFloat("testShader", "time",getGameTime());
    }

    if(getLocalPlayerBlob() !is null && getLocalPlayerBlob().getConfig() == "soul")
    {
        if(this.get_bool("SoulVisionRunning") == false)
        {
            this.set_bool("SoulVisionRunning",true);
            getDriver().AddShader("SoulVision",EShaderLayer::SoulVision);
            getDriver().SetShader("SoulVision", true);
        }
        else
        {
            getDriver().SetShaderInt("SoulVision", "time", getGameTime());
        }
    }
    else if(this.get_bool("SoulVisionRunning"))
    {
        getDriver().SetShader("SoulVision",false);
        this.set_bool("SoulVisionRunning",false);
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
}
