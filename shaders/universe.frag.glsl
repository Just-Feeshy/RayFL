#version 450

#define PI 3.14159265
#define TAU (2*PI)

uniform vec3 iCam;
uniform vec2 iMouse;
uniform vec2 iResolution;
uniform sampler2D iSpheres;
uniform int iSpheresAmount;

out vec4 fragColor;

const float FOV = 1.0;

struct ray {
    vec3 origin;
    vec3 direction;
};

void pR(inout vec2 p, float a) {
	p = cos(a) * p + sin(a) * vec2(p.y, -p.x);
}

mat3 getCamera(vec3 ro, vec3 lookAt) {
    vec3 ww = normalize(lookAt - ro);
    vec3 uu = normalize(cross(vec3(0.0, 1.0, 0.0), ww));
    vec3 vv = cross(uu, ww);
    return mat3(uu, vv, ww);
}

void mouseControl(inout vec3 ro) {
    vec2 mouse = iMouse.xy / iResolution.xy;
    pR(ro.yz, -mouse.y * PI);
    pR(ro.xz, mouse.x * PI);
}

bool sphere(ray r, float radius, out float t) {
    float a = dot(r.direction, r.direction);
    float b = dot(r.origin, r.direction);
    float c = dot(r.origin, r.origin) - radius * radius;
    float disc = b * b - a * c;

    if (disc > 0.0) {
        t = (-b + sqrt(disc)) / a;
    }else {
        t = -b / a;
    }

    return disc > 0.0 && dot(r.direction, -r.origin) > 0.0;
}

void main() {
    vec2 uv = (2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.y;

    vec3 ro = iCam;
    mouseControl(ro);

    vec3 lookAt = vec3(0.0, 1.0, 0.0);
    vec3 rd = normalize(vec3(uv, FOV));

    vec3 col = vec3(0.0);
    float dist = 0.0;

    bool hit_sphere = sphere(ray(ro, rd), 20.0, dist);

    if (hit_sphere) {
        vec3 nor = normalize(ro + rd * dist);
        col = (nor + 1.0) / 2.0;
    }

    fragColor = vec4(col, 1.0);
}
