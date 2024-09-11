
#define EARTH_TILT 0.40840704496
#define CLOSEST_DIST 100000000.0
#define MAX_STEPS 80
#define MIN_DIST 0.00001
#define PI 3.14159265
#define TAU (2*PI)

// Raymarching with multiple planets

struct ray {
    vec3 origin;
    vec3 direction;
};

struct planet {
    vec3 position;
    float radius;
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

vec3 rotateX(vec3 p, float angle) {
    float cosT = cos(angle);
    float sinT = sin(angle);

    return vec3(
        p.y * sinT + p.x * cosT,
        p.y * cosT - p.x * sinT,
        p.z
    );
}

vec2 sphereUV(vec3 p, float t) {
    p = rotateX(p, EARTH_TILT);
    p = rotateY(p, t);

    float phi = atan2(p.z, p.x);
    return vec2(phi / TAU, acos(p.y) / PI);
}

float distancePlanet(vec3 p, float radius, sampler2D planetTexture, float rot) {
    vec2 coordinates = sphereUV(normalize(p), rot);
    coordinates.y = coordinates.y * 0.5 + 0.5;
    vec4 elevation = texture(planetTexture, coordinates);

    float f = length(p) - radius;

    float elevationScale = radius * 0.0;
    return f - length(elevation.rgb) * elevationScale;
}

void marchedSphere(ray r,
        planet pl,
        float rot,
        out vec3 hitPos,
        out vec3 nor,
        out bool hit,
        sampler2D text) {
    vec3 p = r.origin;
    float closestDist = CLOSEST_DIST;
    float minDist = MIN_DIST;
    int steps = 0;
    float dist = dot(p, p) + 1.0;

    while(closestDist > minDist && steps++ <= MAX_STEPS) {
        closestDist = distancePlanet(p, pl.radius, text, rot);
        float cameraDist = dot(r.origin - p, r.origin - p);
        minDist = MIN_DIST + clamp(cameraDist / 40, 0.0, 0.0075);

        if(closestDist <= 0.0) {
            break;
        }

        p += r.direction * closestDist;

        if(dot(p, p) > dist * 1.25) {
            hit = false;
            return;
        }
    }

    // Check if we hit the sphere
    if(closestDist <= minDist + MIN_DIST) {
        hitPos = p;
        nor = normalize(p);

        hit = true;
    }else {
        hit = false;
    }
}

vec2 raySphereIntersect(ray r, float radius, out bool hit) {
    float a = 2.0 * dot(r.origin, r.direction);
    float b = dot(r.origin, r.origin) - radius * radius;
    float disc = a * a - 4.0 * b;

    if(disc > 0.0) {
        float t = sqrt(disc);
        float near = (-a - t) * 0.5;
        float far = (-a + t) * 0.5;

        if(far >= 0.0) {
            hit = true;
            return vec2(near, far);
        }
    }

    hit = false;
    return vec2(0.0);
}

void drawPlanet(ray r, planet pl, sampler2D text, float rot, inout vec3 combinedColor) {
    vec3 worldPos = r.origin - pl.position;
    vec3 hitPos = vec3(0.0);
    vec3 nor = vec3(0.0);
    bool hit = false;
    float t = 0.0;

    marchedSphere(r, pl, rot, hitPos, nor, hit, text);

    if(hit) {
        // combinedColor = vec3(1.0);
        combinedColor = texture(text, sphereUV(nor, rot)).rgb;
    }
}
