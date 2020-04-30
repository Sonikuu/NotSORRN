uniform sampler2D baseMap;
uniform sampler2D extraMap;


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
	gl_FragColor = texture2D(baseMap, texture_coordinate); 
	vec4 worldcolor = texture2D(extraMap, texture_coordinate);
	float static_intensity = gl_FragCoord.w * 1.0 * worldcolor.a;
	
	float r = valueNoise(vec2(gl_FragCoord) / 2.0);
	float g = valueNoise(vec2(gl_FragCoord + 1000.0) / 2.0);
	float b = valueNoise(vec2(gl_FragCoord + 2000.0) / 2.0);

	vec4 noisecolor = vec4(r, g, b, 1.0);

	gl_FragColor = gl_FragColor / max(2.0 * static_intensity, 1.0) + noisecolor / (2.0 / static_intensity);
}