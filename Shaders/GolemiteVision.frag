uniform sampler2D basemap;
uniform sampler2D extraMap; //this is noise
varying vec2 texture_coordinate;


void main()
{
    gl_FragColor = texture2D(basemap,texture_coordinate) + (texture2D(extraMap,texture_coordinate).argb - 0.5) * 0.2;
}