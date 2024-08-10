#version 450

// uniform float iTime;
uniform vec2 iResolution;
uniform mat4 iCamera;

out vec4 fragColor;

vec3 unit_vector(const vec3 v) {
    return v / length(v);
}

vec3 ray_color(const vec3 origin, const vec3 direction) {
    vec3 unit_direction = unit_vector(direction);
    float t = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - t) * vec3(1.0, 1.0, 1.0) + t * vec3(0.5, 0.7, 1.0);
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y;

    vec3 ro = inverse(iCamera)[3].xyz;
    vec3 rd = normalize((iCamera * vec4(uv, 0.0, 1.0)).xyz);

    vec3 col = ray_color(ro, rd);

    fragColor = vec4(col.xyz, 1.0);
}
