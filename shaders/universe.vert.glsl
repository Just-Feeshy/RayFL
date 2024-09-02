#version 450

in vec2 pos;

uniform vec2 iResolution;

void main() {
    vec2 resolution = (pos / iResolution) * 2.0 - vec2(1.0, 1.0);
    gl_Position = vec4(resolution.xy, 0.0, 1.0);
}
