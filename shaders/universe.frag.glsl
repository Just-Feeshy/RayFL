#version 450

#include "cursor.glsl"

#define PI 3.14159265
#define TAU (2*PI)

uniform vec3 iCam;
uniform mat3 iMat;
uniform vec2 iResolution;
uniform sampler3D textures;
// uniform sampler2D iSpheres;
// uniform int iSpheresAmount;

out vec4 fragColor;

const float FOV = 1.0;

struct ray {
    vec3 origin;
    vec3 direction;
};

float atan2(in float y, in float x) {
    return x == 0.0 ? sign(y) * PI / 2.0 : atan(y, x);
}

bool sphere(ray r, float radius, out float t) {
    // float a = dot(r.direction, r.direction);
    float b = dot(r.origin, r.direction);
    float c = dot(r.origin, r.origin) - radius * radius;
    float disc = b * b - c;

    if (disc > 0.0) {
        t = (-b - sqrt(disc));
    }else {
        t = -b;
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
        float light = dot(nor, ligthDir);
        float normlight = max(0.1, (light + 1.0) * 0.5);
        col = vec3(1.0) * normlight;
    }

    col = cursor(uv, col);
    fragColor = vec4(col, 1.0);
}
