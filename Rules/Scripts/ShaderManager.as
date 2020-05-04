#define CLIENT_ONLY

void onInit(CRules@ this)
{
    this.set_bool("SoulVisionRunning",false);

    getDriver().SetShader("hq2x",false);//ew blury
    getDriver().ForceStartShaders(); //need dem shaders doh
}

void onTick(CRules@ this)
{
    if(getLocalPlayerBlob() !is null && getLocalPlayerBlob().getConfig() == "soul")
    {
        if(this.get_bool("SoulVisionRunning") == false)
        {
            this.set_bool("SoulVisionRunning",true);
            getDriver().AddShader("SoulVision",2.0);
            getDriver().SetShader("SoulVision", true);
            getDriver().SetShaderInt("SoulVision", "time", getGameTime());
        }
    }
    else if(this.get_bool("SoulVisionRunning"))
    {
        getDriver().SetShader("SoulVision",false);
        this.set_bool("SoulVisionRunning",false);
    }

}
