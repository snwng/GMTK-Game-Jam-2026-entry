shader_type canvas_item;

//////////////////////////////////////////////////
// AJUSTES
//////////////////////////////////////////////////

uniform float pixel_size = 8.0;
uniform float movement_speed = 0.015;
uniform float blob_scale = 0.12;

//////////////////////////////////////////////////
// PALETA
//////////////////////////////////////////////////

const vec3 COLOR0 = vec3(0.259,0.016,0.086); // #420416
const vec3 COLOR1 = vec3(0.470,0.110,0.161); // #781C29
const vec3 COLOR2 = vec3(0.756,0.309,0.254); // #C14F41
const vec3 COLOR3 = vec3(0.851,0.424,0.361); // #D96C5C
const vec3 COLOR4 = vec3(0.949,0.631,0.541); // #F2A18A

//////////////////////////////////////////////////

float hash(vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123);
}

float noise(vec2 p)
{
    vec2 i=floor(p);
    vec2 f=fract(p);

    float a=hash(i);
    float b=hash(i+vec2(1.0,0.0));
    float c=hash(i+vec2(0.0,1.0));
    float d=hash(i+vec2(1.0,1.0));

    vec2 u=f*f*(3.0-2.0*f);

    return mix(a,b,u.x)+
           (c-a)*u.y*(1.0-u.x)+
           (d-b)*u.x*u.y;
}

vec3 palette(float v)
{
    if(v<0.20) return COLOR0;
    if(v<0.40) return COLOR1;
    if(v<0.60) return COLOR2;
    if(v<0.80) return COLOR3;
    return COLOR4;
}

void fragment()
{
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;

    vec2 p = UV * resolution;

    // PIXELADO
    p = floor(p/pixel_size);

    // BLOQUES GRANDES
    vec2 world = p*blob_scale;

    world += vec2(TIME*movement_speed,0.0);

    float n = noise(world);

    vec3 col = palette(n);

    //////////////////////////////////////////////
    // DITHER GAME BOY ADVANCE
    //////////////////////////////////////////////

    float checker = mod(p.x+p.y,2.0);

    if(checker>0.5)
        col*=1.06;
    else
        col*=0.94;

    //////////////////////////////////////////////
    // ILUMINACIÓN SUAVE
    //////////////////////////////////////////////

    float light = (UV.y*0.25)+(UV.x*0.10);

    col*=1.15-light;

    //////////////////////////////////////////////
    // BRILLOS GRANDES
    //////////////////////////////////////////////

    float shine = noise(world*0.35+10.0);

    col += shine*0.05;

    COLOR=vec4(col,1.0);
}
//shader_type canvas_item;
//
//uniform vec4 base_color : source_color = vec4(0.756,0.309,0.254,1.0);
//
//uniform float pixel_size = 1.0;
//uniform float movement_speed = 0.015;
//uniform float contrast = 0.28;
//
//float hash(vec2 p)
//{
    //return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
//}
//
//float noise(vec2 p)
//{
    //vec2 i = floor(p);
    //vec2 f = fract(p);
//
    //float a = hash(i);
    //float b = hash(i+vec2(1,0));
    //float c = hash(i+vec2(0,1));
    //float d = hash(i+vec2(1,1));
//
    //vec2 u = f*f*(3.0-2.0*f);
//
    //return mix(a,b,u.x)
         //+ (c-a)*u.y*(1.0-u.x)
         //+ (d-b)*u.x*u.y;
//}
//
//void fragment()
//{
    //vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
//
    //vec2 p = UV * resolution;
//
    //p = floor(p / pixel_size);
//
    //vec2 world = p*0.18;
//
    //world += vec2(TIME*movement_speed,0);
//
    //float n = noise(world);
//
    //vec3 col = base_color.rgb;
//
    //col *= mix(
        //1.0-contrast,
        //1.0+contrast,
        //n
    //);
//
    //float dither = mod(p.x+p.y,2.0);
//
    //col *= mix(0.95,1.05,dither);
//
    //COLOR = vec4(col,1.0);
//}