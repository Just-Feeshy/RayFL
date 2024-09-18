#define PI 3.14159265
#define REFLECTIVE_INDEX 1.00029

// scatter const
const float R_INNER = 1.0;
const int NUM_SCATTER = 8;
const int NUM_SAMPLES = 16;

struct atmosphere {
    vec3 wavelengthCoeff;
    float density;
    float thinkness;
};

struct ray {
    vec3 origin;
    vec3 direction;
};

float densityAtPos(vec3 p, float radius, atmosphere atm) {
    float h = length(p) - radius;
    float normH = min(1.0, h / atm.thinkness);
    return exp(-normH) * (1.0 - normH) * atm.density;
}

float opticalDepth(vec3 origin, vec3 lightDir, float radius, atmosphere atm) {
    float rayMag = length(lightDir - origin);
    float rayDelta = rayMag / float(NUM_SCATTER);

    float prevDensity = densityAtPos(origin, radius, atm);
    float sum = 0.0;

    for(int i = 0; i < NUM_SCATTER; i++) {
        vec3 p = mix(origin, lightDir, float(i) / float(NUM_SCATTER));
        float density = densityAtPos(p, radius, atm);
        sum += (density + prevDensity) * 0.5 * rayDelta;
        prevDensity = density;
    }

    return sum;
}

vec3 wavelength(atmosphere atm) {
    vec3 w = atm.wavelengthCoeff;
    w.x = pow(1.0 / w.x, 4.0);
    w.y = pow(1.0 / w.y, 4.0);
    w.z = pow(1.0 / w.z, 4.0);
    return w;
}

float densityRatio(vec3 p, float H) {
    float h = length(p) - R_INNER;
    return exp(-max(h, 0.0) / H);
}

float phase_ray(float angle) {
    float cc = cos(angle) * cos(angle);
    return (3.0 / (16.0 * PI)) * (1.0 + cc);
}

vec4 scatter(vec3 p, float delta, ray r, vec3 lightDir, float density, float radius, atmosphere atm) {
    bool hit = false;
    float lightOpticalDepth = opticalDepth(p, lightDir * (radius + atm.thinkness) * 2.0, radius, atm);
    float d = densityAtPos(p, radius, atm);
    float totalDensityDiff = d * delta;

    vec3 transmittance = exp(-(lightOpticalDepth + density + totalDensityDiff) * wavelength(atm));

    vec3 color = d * transmittance * wavelength(atm) * phase_ray(acos(dot(r.direction, lightDir)));
    return vec4(color, totalDensityDiff);
}

vec3 lightPath(vec3 origin, vec3 dir, vec3 lightDir, inout float density, float radius, atmosphere atm) {
    vec3 rayDir = normalize(dir - origin);
    ray r = ray(origin, rayDir);
    float rayMag = length(rayDir - origin);
    float rayDelta = rayMag / float(NUM_SAMPLES);

    vec3 wavelengthCoeff = wavelength(atm);
    vec4 prevLightRes = scatter(origin, rayDelta, r, lightDir, 0.0, radius, atm);
    vec3 prevLight = prevLightRes.rgb;
    float totalDensity = prevLightRes.a;
    vec3 totalLight = vec3(0.0);

    for(int i = 0; i < NUM_SAMPLES; i++) {
        vec3 p = mix(origin, dir, float(i) / float(NUM_SAMPLES));

        vec4 lightRes = scatter(p, rayDelta, r, lightDir, totalDensity, radius, atm);
        prevLight += lightRes.rgb;
        totalDensity += lightRes.a;

        totalLight += (lightRes.rgb + prevLight) * 0.5 * rayDelta;
        prevLight = lightRes.rgb;
    }

    density = totalDensity;
    return totalLight;
}
