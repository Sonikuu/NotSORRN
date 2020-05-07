varying vec2 texture_coordinate;

uniform sampler2D baseMap;
uniform float time;

void fourColorShader()
{
    float x = texture_coordinate.x;
    float y = texture_coordinate.y;
    vec4 tex = texture2D(baseMap,vec2(x,y));


    float val = (tex.g + tex.r + tex.b)/3.0;

    val += .15;

    if(val > .75)      {tex.r = 0.0; tex.g = 0.0; tex.b = 255.0;}
    else if( val > .5) {tex.r = 0.0; tex.g = 255.0; tex.b = 0.0;}
    else if(val > .25) {tex.r = 255.0; tex.g = 0.0; tex.b = 0.0;}
    else               {tex.r = 0.0; tex.g = 0.0; tex.b = 0.0;  }

    tex.rgb /= 255.0;

    gl_FragColor = tex;
}

void main()
{
    float x = texture_coordinate.x;
    float y = texture_coordinate.y;
    vec4 tex = texture2D(baseMap,vec2(x, y));

    gl_FragColor = tex;

    //fourColorShader();
}
