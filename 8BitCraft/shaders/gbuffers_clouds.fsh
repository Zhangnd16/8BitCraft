/*
    XorDev's "Default Shaderpack"

    This was put together by @XorDev to make it easier for anyone to make their own shaderpacks in Minecraft (Optifine).
    You can do whatever you want with this code! Credit is not necessary, but always appreciated!

    You can find more information about shaders in Optfine here:
    https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt

*/
//Declare GL version.
#version 150 compatibility

//Diffuse (color) texture.
uniform sampler2D texture;

//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

//Vertex color.
varying vec4 color;
//Diffuse texture coordinates.
varying vec2 coord0;

void main()
{
    //Visibility amount.
    vec3 light = vec3(1. - blindness);
    //Sample texture times Visibility.
    vec4 col = color * vec4(light, 1) * texture2D(texture, coord0);

    //Calculate fog intensity in or out of water.
    float fog = (isEyeInWater > 0) ? 1. - exp(-gl_FogFragCoord * gl_Fog.density) :
    clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0., 1.);

    //Apply the fog.
    if (isEyeInWater > 0) {
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
        // col.rgb = (1 - fog) * col.rgb + fog * gl_Fog.color.rgb;
    }

    //Output the result.
    gl_FragData[0] = col;
}
