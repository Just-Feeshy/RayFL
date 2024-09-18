#version 450

#include "cursor.glsl"
#include "planet.glsl"
#include "map.glsl"

#define MAX_TEXTURES 4
#define EARTH_TILT 0.40840704496
#define CLOSEST_DIST 100000000.0
#define MAX_STEPS 80
#define MIN_DIST 0.00001

uniform float iTime;
uniform vec3 iCam;
uniform mat3 iMat;
uniform vec2 iResolution;
uniform sampler2D textures[MAX_TEXTURES];
uniform sampler2D iSpheres;
uniform int iSpheresAmount;

out vec4 fragColor;

const float FOV = 1.0;

vec4 unpackVec4FromTexture(int index) {
    float x = float(index) / float(iSpheresAmount);
    float offset = 1.0 / float(iSpheresAmount);
    return texture(iSpheres, vec2(x, x + offset));
}

void drawEarth(ray r, planet pl, float rot, inout vec3 combinedColor) {
    vec3 hitPos = vec3(0.0);
    vec3 nor = vec3(0.0);
    bool hit = false;

    march m = coneMarch(r, pl, rot, textures[0]);
    marchedSphere(r, pl, rot, m, hitPos, nor, hit, textures[0]);

    vec3 lightDir = normalize(vec3(3.0, 0.0, 0.0));
    float light = max(0.0, (dot(nor, lightDir) + 1.0) * 0.5);
    float terminatorLight = dot(normalize(hitPos), lightDir);
    terminatorLight = map(terminatorLight, -0.2, 0.3, 0.0, 1.0);
    terminatorLight = smoothstep(0.0, 1.0, terminatorLight);

    vec3 p = hitPos / pl.radius;

    vec2 earthUV = sphereUV(p, rot);
    vec4 earthColor = texture(textures[0], earthUV);

    vec2 atmosphereUV = sphereUV(p, rot * 1.5);
    vec4 atmosphereColor = texture(textures[2], atmosphereUV);
    vec4 nightColor = texture(textures[1], earthUV);

if(hit) {
        combinedColor = (earthColor.rgb + (atmosphereColor.rgb * 0.5 * atmosphereColor.a)) * sqrt(terminatorLight * light) + ((1.0 - sqrt(terminatorLight * light)) * nightColor.rgb) * earthColor.a;
    }

/*
    atmosphere atm = atmosphere(
        vec3(135, 208, 235),
        10000.0,
        100.0
    );

    bool hitAtm = false;
    vec2 atmRay = raySphereIntersect(r, pl.radius + atm.thinkness, hitAtm);

    if(hitAtm) {
        const float epsilon = 0.001;
        float minDist = atmRay.x + epsilon;
        float maxDist = atmRay.y - epsilon;

        vec3 atmPos = r.origin + r.direction * minDist;
        vec3 atmDir = r.origin + r.direction * maxDist;
        float atmDensity = 0.0;
        vec3 atmLight = lightPath(atmPos, atmDir, lightDir, atmDensity, pl.radius, atm);

        const vec3 ex = exp(-atmDensity * wavelength(atm));
        combinedColor = clamp(combinedColor * ex, 0.0, 1.0) + atmLight * 0.1;
    }
    */
}

vec3 render(vec2 uv) {
    vec3 ro = iCam - vec3(0.0, 0.0, 0.0);
    vec3 rd = normalize(normalize(vec3(uv, FOV)) * iMat);

    vec3 col = vec3(0.0);


    for(int i=0; i<iSpheresAmount; i++) {
        vec4 sphere = unpackVec4FromTexture(i);
        planet pl = planet(sphere.xyz, sphere.w);
        ray r = ray(ro - pl.position, rd);
        drawEarth(r, pl, iTime / 24, col);
    }

    return col;
}

vec2 getUV(vec2 rayOffset) {
    return (2.0 * (gl_FragCoord.xy + rayOffset) - iResolution.xy) / iResolution.y;
}

vec3 renderAAx4() {
    /*
    vec4 offsets = vec4(0.125, -0.125, 0.375, -0.375);
    vec3 colAA = render(getUV(offsets.xz)) + render(getUV(offsets.yw)) + render(getUV(offsets.wx)) + render(getUV(offsets.zy));
    return colAA * 0.25;
    */
    vec3 colAA = render(getUV(vec2(0.0)));
    return colAA;
}

void main() {
    vec3 col = renderAAx4();
    col = cursor(getUV(vec2(0.0)), col);

    fragColor = vec4(col, 1.0);
}
