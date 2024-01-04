uniform sampler2D baseMap;

uniform float screenWidth;
uniform float screenHeight;
uniform float density;
uniform float centerposx;
uniform float centerposy;
uniform float zoomlevel;
uniform float gametime;

varying vec2 texture_coordinate;

vec2 random2(vec2 st){
	st = vec2( dot(st,vec2(127.1,311.7)),
			  dot(st,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}


float valueNoise(vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);

	vec2 u = f*f*(3.0-2.0*f);

	return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ), 
					 dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
				mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ), 
					 dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

void main() 
{
    vec4 tex = texture2D(baseMap,vec2(texture_coordinate.x,texture_coordinate.y ));

    float distmod = distance(vec2(centerposx, centerposy), texture_coordinate) / 2.0 * (zoomlevel / 0.7);

    vec2 fogparra = vec2((gl_FragCoord - vec2(screenWidth / 2.0, screenHeight / 2.0)) * zoomlevel);
    fogparra.x += gametime;

    float noiseval = valueNoise(fogparra / 1000.0);
    fogparra.y += 2000;
    noiseval += valueNoise(fogparra / 600.0) + 0.2;

    noiseval *= density;

    float strength = min(density * distmod + density / 5.0, 1.5) * 1.0;

    strength = strength * 0.7 + noiseval * 0.3;

    float brightness = min(((tex.r + tex.g + tex.b) * 24.0) / 3.0, 1.0);
    brightness = 1.0;

    strength = max(0.0, min(strength, 1.0));

    tex.rgb = tex.rgb * (1.0 - strength) + vec3(1.0 * brightness, 1.0 * brightness, 1.0 * brightness) * strength;

    gl_FragColor = tex;
}