#version 450

#include "cursor.glsl"

#define PI 3.14159265
#define TAU (2*PI)
#define MAX_TEXTURES 3

uniform float iTime;
uniform vec3 iCam;
uniform mat3 iMat;
uniform vec2 iResolution;
uniform sampler2D textures[MAX_TEXTURES];
// uniform sampler2D iSpheres;
// uniform int iSpheresAmount;

out vec4 fragColor;

const float FOV = 1.0;

struct ray {
    vec3 origin;
    vec3 direction;
};

float atan2(in float y, in float x) {
    return y > 0.0 ? atan(y, x) + PI : -atan(y, -x);
}

vec3 rotateY(vec3 p, float angle) {
    float cosT = cos(angle);
    float sinT = sin(angle);

    return vec3(
        p.x * cosT + p.z * sinT,
        p.y,
        p.z * cosT - p.x * sinT
    );
}

vec2 sphereUV(vec3 p, float t) {
    p = rotateY(p, t);

    float phi = atan2(p.z, p.x);
    return vec2(phi / TAU, acos(p.y) / PI);
}

bool sphere(ray r, float radius, out float t) {
    float a = dot(r.direction, r.direction);
    float b = dot(r.origin, r.direction);
    float c = dot(r.origin, r.origin) - radius * radius;
    float disc = b * b - c * a;

    if (disc > 0.0) {
        t = (-b - sqrt(disc)) / a;
    }else {
        t = -b / a;
    }

    return disc > 0.0 && dot(r.direction, -r.origin) > 0.0;
}

void main() {
    vec2 uv = (2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.y;

    vec3 ro = iCam - vec3(0.0, 0.0, 100.0);
    vec3 rd = normalize(normalize(vec3(uv, FOV)) * iMat);

    vec3 col = vec3(0.0);
    float dist = 0.0;

    bool hit_sphere = sphere(ray(ro, rd), 20.0, dist);

    if (hit_sphere) {
        vec3 p = ro + rd * dist;
        vec3 nor = normalize(p);
        vec3 ligthDir = vec3(3.0, 1.0, 0.0);
        float light = dot(nor, normalize(ligthDir));
        float normlight = max(0.0, (light + 1.0) * 0.5);
        vec2 texCoord = sphereUV(nor, iTime * 0.1);
        vec2 atmosphereCoord = sphereUV(nor, iTime * 0.15);

        vec4 planet = texture(textures[0], texCoord.xy);
        vec4 dark = texture(textures[1], texCoord.xy);
        vec4 atmosphere = texture(textures[2], atmosphereCoord.xy);
        float darkAverage = (dark.r + dark.g + dark.b) / 3.0;

        col = (planet.rgb * normlight) + (atmosphere.rgb * atmosphere.a * 0.5 * min(1.0, normlight + darkAverage)) + ((1.0 - sqrt(normlight)) * dark.rgb);
    }

    col = cursor(uv, col);
    fragColor = vec4(col, 1.0);
}
