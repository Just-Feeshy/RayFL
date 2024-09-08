#define BORDER_WIDTH 0.1
#define CURSOR_RADIUS 64

vec3 cursor(vec2 uv, inout vec3 color) {
    vec3 col = vec3(1.0);

    float d1 = length(uv * CURSOR_RADIUS);
    float d2 = step(0.1, d1 - 0.5);
    float d = step(0.1, abs(d1 - 0.5));

    vec3 cursor = mix(vec3(d), col, (1.0 - d2) * d);
    return mix(color, cursor, 1.0 - d2);
}
