#version 450

#define color vec3

// uniform float iTime;
uniform vec2 iResolution;
uniform mat4 iCamera;
uniform sampler2D iSpheres;
uniform int iSpheresAmount;
uniform int iSamples;

out vec4 fragColor;

struct hit_record {
    float t;
    vec3 p;
    vec3 normal;
    bool front_face;
};

struct sphere {
    vec3 center;
    float radius;
};

// Helper functions for interval arithmetic

struct interval {
    float min;
    float max;
};

float size(interval ray_t, float x) {
    return ray_t.max - ray_t.min;
}

bool contains(interval ray_t, float x) {
    return ray_t.min <= x && x <= ray_t.max;
}

bool surrounds(interval ray_t, float x) {
    return x <= ray_t.max && x >= ray_t.min;
}


// Helper functions for the ray tracing
// TODO: Fix the `unpackVec4FromTexture` function, it seems broken

vec4 unpackVec4FromTexture(int index) {
    float x = float(index) / float(iSpheresAmount);
    float offset = 1.0 / float(iSpheresAmount);
    return texture(iSpheres, vec2(x, x + offset));
}

vec3 at(float t, const vec3 origin, const vec3 direction) {
    return origin + t * direction;
}

void set_face_front(inout hit_record rec, const vec3 direction, const vec3 outward_normal) {
    rec.front_face = dot(direction, outward_normal) < 0.0;
    rec.normal = rec.front_face ? outward_normal * vec3(1.0, 1.0, -1.0) : outward_normal * vec3(-1.0, -1.0, 1.0);
}

bool hit(const sphere s, const vec3 origin, const vec3 direction, interval ray_t, inout hit_record rec) {
    vec3 oc = s.center - origin;
    float h = dot(direction, oc);
    float c = dot(oc, oc) - s.radius * s.radius;

    float discriminant = h * h - c;

    if(discriminant < 0.0) {
        return false;
    }

    float sqrtd = sqrt(discriminant);
    float root = h - sqrtd;

    if(!surrounds(ray_t, root)) {
        root = h + sqrtd;

        if(!surrounds(ray_t, root)) {
            return false;
        }
    }

    rec.t = root;
    rec.p = at(rec.t, origin, direction);
    vec3 outward_normal = (rec.p - s.center) / s.radius;
    set_face_front(rec, direction, outward_normal);

    return true;
}

bool hit_world(vec3 origin, vec3 direction, interval ray_t, inout hit_record rec) {
    hit_record temp_rec;
    bool hit_anything = false;
    float closest_so_far = ray_t.max;
    sphere s;

    for(int i=0; i<iSpheresAmount; i++) {
        vec4 sphereData = unpackVec4FromTexture(i);
        s.center = sphereData.xyz;
        s.radius = sphereData.w;

        if(hit(s, origin, direction, interval(ray_t.min, closest_so_far), temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }

    return hit_anything;
}

color ray_color(const vec3 origin, const vec3 direction) {
    hit_record rec;

    if(hit_world(origin, direction, interval(0, 80), rec)) {
        return 0.5 * (rec.normal + color(1.0));
    }

    vec3 unit_direction = normalize(direction);
    float t = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - t) * color(1.0) + t * vec3(0.5, 0.7, 1.0);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy,
        vec2(12.9898, 78.233))) * 43758.5453123
    );
}

void render(vec3 ro, vec3 rd) {
    vec3 col = vec3(0.0);

    for(int i=0; i<iSamples; i++) {
        vec2 rnd = vec2(random(vec2(rd.x + float(i), rd.y + float(i))));
        vec3 rd_jittered = normalize(rd + vec3(rnd / iResolution.xy, 0.0));
        col += ray_color(ro, rd_jittered);
    }

    fragColor = vec4(col.xyz / iSamples, 1.0);
}

void main() {
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, 1.0));

    render(ro, rd);
}
