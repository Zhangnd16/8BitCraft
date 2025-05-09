#version 150 compatibility

#include "lib/functions.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex4;

uniform float viewWidth;
uniform float viewHeight;


const int CHAR_COUNT = 10;
const float CHAR_W = 48.0;
const float CHAR_H = 64.0;
const float CELL_W = 12.0;
const float CELL_H = 16.0;
const vec2 CHAR_SIZE = vec2(CHAR_W, CHAR_H);
const vec2 CELL_SIZE = vec2(CELL_W, CELL_H);
const vec2 ATLAS_SIZE = vec2(CHAR_W * CHAR_COUNT, CHAR_H);

in vec2 texCoord;  

layout (location = 0) out vec4 fragColor;

float absDist(vec3 a, vec3 b) {
    return abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b);
}

vec3 to8BitHsv(vec3 color) {
    vec3 hsv = rgbToHsv(color);

    hsv.x = floor(hsv.x / 16.0 + 0.5) * 16.0;
    hsv.y = floor(hsv.y * 8.0 + 0.5) / 8.0;
    hsv.z = floor(hsv.z * 4.0 + 0.5) / 4.0;

    hsv.z *= 1.5;

    return hsvToRgb(hsv);
}

vec3 to8Bit(vec3 color) {

    color.x = floor(color.x * 8.0 + 0.5) / 8.0;
    color.y = floor(color.y * 8.0 + 0.5) / 8.0;
    color.z = floor(color.z * 4.0 + 0.5) / 3.0;

    return color;
}


float luminance(vec3 color) {
    return sqrt(dot(color, vec3(0.299, 0.587, 0.114)));
}

void main() {
    vec2 fragCoord = gl_FragCoord.xy;
    vec2 resolution = vec2(viewWidth, viewHeight);
    vec2 cellOrigin = floor(texCoord * resolution / CELL_SIZE) * CELL_SIZE / resolution;
    vec3 sceneColor = texture(colortex0, cellOrigin).rgb;
    float gray = luminance(sceneColor);
    int index = int(floor((1.0 - gray) * 2 * float(CHAR_COUNT)));
    index = clamp(index, 0, CHAR_COUNT - 2);
    float glyphX = float(index) * CHAR_W;
    vec2 glyphUV = mod(fragCoord, CELL_SIZE) / CELL_SIZE;
    vec2 atlasUV = (vec2(glyphX, 0.0) + glyphUV * CHAR_SIZE) / ATLAS_SIZE;
    vec4 ascii = texture(colortex4, atlasUV);
    vec3 textureColor = ascii.rgb;
    fragColor = vec4(textureColor * to8BitHsv(texture(colortex0, cellOrigin).rgb), 1.0);
}
