#version 450

// uniform float iTime;
uniform vec2 iResolution;
uniform mat4 iCamera;

out vec4 fragColor;

vec3 at(float t, const vec3 origin, const vec3 direction) {
    return origin + t * direction;
}

float hit_sphere(const vec3 center, const vec3 origin, const vec3 direction, float radius) {
    vec3 oc = origin - center;
    float a = dot(direction, direction);
    float b = -2.0 * dot(direction, oc);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b * b - 4.0 * a * c;

    float T = 0.0;

    if (discriminant < 0.0) {
        T = -1.0;
    } else {
        T = (b - sqrt(discriminant)) / (2.0 * a);
        // T = 1.0;
    }

    return T;
}

vec3 ray_color(const vec3 origin, const vec3 direction) {
    float T = hit_sphere(vec3(0.0, 0.0, -1.0), origin, direction, 0.5);

    if (T > 0.0) {
        vec3 N = normalize(at(T, origin, direction) - vec3(0,0,-1));
        return 0.5*(N + 1.0);
    }

    vec3 unit_direction = normalize(direction);
    float a = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0);
}

void main() {
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = ((gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y) * vec2(aspectRatio, 1.0);

    vec3 ro = iCamera[3].xyz;
    vec3 rd = normalize((iCamera * vec4(uv, 0.0, 1.0)).xyz);

    vec3 col = ray_color(ro, rd);

    fragColor = vec4(col.xyz, 1.0);
}
