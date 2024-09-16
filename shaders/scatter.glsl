#define PI 3.14159265
#define REFLECTIVE_INDEX 1.00029

// scatter const
const float R_INNER = 1.0;
const int NUM_SCATTER = 8;

struct atmosphere {
    vec3 wavelengthCoeff;
};

struct ray {
    vec3 origin;
    vec3 direction;
};

vec3 wavelength(atmosphere atm) {
    vec3 w = atm.wavelengthCoeff;
    w.x = pow(400.0 / w.x, 4.0);
    w.y = pow(400.0 / w.y, 4.0);
    w.z = pow(400.0 / w.z, 4.0);
    return w;
}

float densityRatio(vec3 p, float H) {
    float h = length(p) - R_INNER;
    return exp(-max(h, 0.0) / H);
}

float optic(ray r, float phase) {
    vec3 rayDelta = (r.direction - r.origin) / float(NUM_SCATTER);
    vec3 v = r.origin + rayDelta * 0.5;

    float sum = 0.0;
    for(int i = 0; i < NUM_SCATTER; i++) {
        sum += densityRatio(v, phase);
        v += rayDelta;
    }

    sum *= length(rayDelta);
    return sum;
}
/*
float transmittance(ray r, float phase) {
    float Beta = 
}
*/

float phase_ray(float angle) {
    float cc = cos(angle) * cos(angle);
    return (3.0 / 16.0 / PI) * (1.0 + cc);
}


