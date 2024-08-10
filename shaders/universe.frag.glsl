#version 450

// uniform float iTime;

out vec4 fragColor;

void main() {
    if (gl_FragCoord.x > 100.0) {
        fragColor = vec4(0.0, 1.0, 0.0, 1.0);
        return;
    }

    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
