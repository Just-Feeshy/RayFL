#version 450

#include "cursor.glsl"
#include "planet.glsl"

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
// uniform sampler2D iSpheres;
// uniform int iSpheresAmount;

out vec4 fragColor;

const float FOV = 1.0;

void drawEarth(ray r, planet pl, float rot, inout vec3 combinedColor) {
    vec3 worldPos = r.origin - pl.position;
    vec3 hitPos = vec3(0.0);
    vec3 nor = vec3(0.0);
    bool hit = false;

    march m = coneMarch(r, pl, rot, textures[0]);
    marchedSphere(r, pl, rot, m, hitPos, nor, hit, textures[0]);

    vec3 lightDir = vec3(0.0, 0.0, 1.0);
    float light = max(0.0, dot(nor, (normalize(lightDir) + 1.0) * 0.5));
    vec3 p = hitPos / pl.radius;

    vec2 earthUV = sphereUV(p, rot);
    //cearthUV.y *= 0.5;
    vec4 earthColor = texture(textures[0], earthUV);

    vec2 atmosphereUV = sphereUV(p, rot * 1.5);
    vec4 atmosphereColor = texture(textures[2], atmosphereUV);
    vec4 nightColor = texture(textures[1], earthUV);

    if(hit) {
        combinedColor = (earthColor.rgb + (atmosphereColor.rgb * 0.5 * atmosphereColor.a)) * light + ((1.0 - light) * nightColor.rgb) * earthColor.a;
    }
}

vec3 render(vec2 uv) {
    vec3 ro = iCam - vec3(0.0, 0.0, 100.0);
    vec3 rd = normalize(normalize(vec3(uv, FOV)) * iMat);

    vec3 col = vec3(0.0);

    drawEarth(ray(ro, rd), planet(vec3(0.0), 40.0), iTime * 0.2, col);

    return col;
}

vec2 getUV(vec2 rayOffset) {
    return (2.0 * (gl_FragCoord.xy + rayOffset) - iResolution.xy) / iResolution.y;
}

vec3 renderAAx4() {
    vec4 offsets = vec4(0.125, -0.125, 0.375, -0.375);
    vec3 colAA = render(getUV(offsets.xz)) + render(getUV(offsets.yw)) + render(getUV(offsets.wx)) + render(getUV(offsets.zy));
    return colAA * 0.25;
    // vec3 colAA = render(getUV(vec2(0.0)));
    // return colAA;
}

void main() {
    vec3 col = renderAAx4();
    col = cursor(getUV(vec2(0.0)), col);

    fragColor = vec4(col, 1.0);
}
