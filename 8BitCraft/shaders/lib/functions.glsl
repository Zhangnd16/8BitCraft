float linearizeDepth(float depth, float near, float far) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}

float convolution(sampler2D texture, vec2 uv, mat3 kernel, int depth) {
    vec2 texOffset = 1.0 / textureSize(texture, 0);
    float result = 0.0;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (depth == 1) {
                result += linearizeDepth(texture(texture, uv + vec2(i, j) * texOffset).r, 0.05, 10) * kernel[i + 1][j + 1];
            } else {
                result += texture(texture, uv + vec2(i, j) * texOffset).r * kernel[i + 1][j + 1];
            }
        }
    }
    return result;
}

vec2 uniformUV(vec2 res) {
    vec2 screenResolution = res;
    vec2 textureResolution = vec2(1024.0, 576.0);
    float screenAspect = screenResolution.x / screenResolution.y;
    float textureAspect = textureResolution.x / textureResolution.y;
    vec2 scale = vec2(1.0);
    if (screenAspect > textureAspect) {
        scale.y = textureAspect / screenAspect;
    } else {
        scale.x = screenAspect / textureAspect;
    }
    vec2 uv = gl_FragCoord.xy / screenResolution;
    uv = uv * scale + (1.0 - scale) * 0.5;
    return uv;
}


float gaussianWeight(float x, float sigma) {
    return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159265) * sigma);
}

vec4 gaussianBlur(sampler2D texture, vec2 uv, vec2 resolution, float radius) {
    vec4 color = vec4(0.0);
    float sigma = radius / 2.0;
    float weightSum = 0.0;

    int numSamples = int(radius * 2.0 + 1.0);

    for (int x = -numSamples; x <= numSamples; x++) {
        for (int y = -numSamples; y <= numSamples; y++) {
            vec2 offset = vec2(float(x), float(y)) / resolution;
            float weight = gaussianWeight(length(offset * resolution), sigma);
            color += texture2D(texture, uv + offset) * weight;
            weightSum += weight;
        }
    }

    return color / weightSum;
}

vec3 rgbToHsv(vec3 c) {
    float maxC = max(c.r, max(c.g, c.b));
    float minC = min(c.r, min(c.g, c.b));
    float delta = maxC - minC;

    float h = 0.0;
    if (delta > 0.0) {
        if (maxC == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (maxC == c.g) {
            h = (c.b - c.r) / delta + 2.0;
        } else {
            h = (c.r - c.g) / delta + 4.0;
        }
        h *= 60.0;
    }
    float s = maxC == 0.0 ? 0.0 : delta / maxC;
    float v = maxC;

    return vec3(h, s, v);
}

vec3 hsvToRgb(vec3 c) {
    float h = c.x / 60.0;
    float s = c.y;
    float v = c.z;

    int i = int(floor(h)) % 6;
    float f = h - float(i);
    float p = v * (1.0 - s);
    float q = v * (1.0 - s * f);
    float t = v * (1.0 - s * (1.0 - f));
    //0-60
    if (i == 0) return vec3(v, t, p);
    //60-120
    if (i == 1) return vec3(q, v, p);
    //120-180
    if (i == 2) return vec3(p, v, t);
    //180-240
    if (i == 3) return vec3(p, q, v);
    //240-300
    if (i == 4) return vec3(t, p, v);
    //300-360
    return vec3(v, p, q);
}

vec4 adjustHueSaturation(vec4 color, float hueAdjust, float saturationAdjust) {
    vec3 hsv = rgbToHsv(color.rgb);        // Convert RGB to HSV
    hsv.x = mod(hsv.x + hueAdjust, 360.0); // Adjust hue and wrap around 360
    hsv.y = clamp(hsv.y * saturationAdjust, 0.0, 1.0); // Adjust saturation and clamp
    vec3 rgb = hsvToRgb(hsv);              // Convert back to RGB
    return vec4(rgb, color.a);             // Return adjusted color with original alpha
}