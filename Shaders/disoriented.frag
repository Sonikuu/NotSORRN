varying vec2 texture_coordinate;
uniform sampler2D baseMap;
uniform float time;

uniform float _1;
uniform float _2;
uniform float _3;
uniform float _4;
uniform float _5;
uniform float _6;
uniform float _7;
uniform float _8;


void main()
{
    time *= .01;

    float x = texture_coordinate.x;
    float y = texture_coordinate.y;
    vec4 tex = texture2D(baseMap,texture_coordinate);

    tex.r *= sqrt(pow(_1 - x,2) + pow(_2 - y,2))*abs(sin(time*.9));
    tex.g *= sqrt(pow(_3 - x,2) + pow(_4 - y,2))*abs(cos(time*.8));
    tex.b *= sqrt(pow(_5 - x,2) + pow(_6 - y,2))*abs(sin(time*.7 + 1.3));

    tex.argb *= min(sqrt(pow(_7 - x,2) + pow(_8 - y,2)) + .5,1);


    gl_FragColor = tex;
}