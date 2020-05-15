uniform sampler2D basemap;
varying vec2 texture_coordinate;


void main()
{
    gl_FragColor = texture2D(basemap,texture_coordinate);
}