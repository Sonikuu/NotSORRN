uniform sampler2D baseMap;

uniform float screenWidth;
uniform float screenHeight;
uniform float time;

varying vec2 texture_coordinate;


float map(float n, float start1, float stop1, float start2, float stop2)
{
    return ((n-start1)/(stop1-start1))*(stop2-start2)+start2;
}

void main() 
{
    vec4 tex = texture2D(baseMap,vec2(texture_coordinate.x,texture_coordinate.y ));

    float MinStrength = .25;
    float MaxStrength = .25;

    float speed = .01;

    float effectiveStrength = map(sin(time * speed), -1,1,MinStrength,MaxStrength);

    tex.rgb += (abs(texture_coordinate.x - .5 ) + abs(texture_coordinate.y - .5 )) * effectiveStrength;

    gl_FragColor = tex;
}