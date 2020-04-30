uniform sampler2D baseMap;

varying vec2 texture_coordinate;

void main() 
{
	vec2 targetcyan = texture_coordinate;
	targetcyan.x = targetcyan.x + gl_FragCoord.z * 0.1;
	gl_FragColor.gb = texture2D(baseMap, targetcyan).gb;

	vec2 targetred = texture_coordinate;
	targetred.x = targetred.x - gl_FragCoord.z * 0.1;
	gl_FragColor.r = texture2D(baseMap, targetred).r;
}