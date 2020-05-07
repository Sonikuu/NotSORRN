#define CLIENT_ONLY

enum EShaderLayer
{
    testShader = 2,//game doesn't like it if you don't start at 2 :v
    SoulVision
}

void onInit(CRules@ this)
{
    this.set_bool("SoulVisionRunning",false);
    this.set_bool("testShader",true);

    getDriver().SetShader("hq2x",false);//ew blury
    getDriver().ForceStartShaders(); //need dem shaders doh
    if(this.get_bool("testShader"))
    {
        getDriver().AddShader("testShader",EShaderLayer::testShader);
        getDriver().SetShader("testShader",true);
    }
    
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

}
