#version 450

#define color vec3

// uniform float iTime;
uniform vec2 iResolution;
uniform mat4 iCamera;
uniform sampler2D iSpheres;
uniform int iSpheresAmount;

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
    rec.normal = rec.front_face ? outward_normal : -outward_normal;
}

bool hit(const sphere s, const vec3 origin, const vec3 direction, float t_min, float t_max, inout hit_record rec) {
    vec3 oc = s.center - origin;
    float a = dot(direction, direction);
    float h = dot(direction, oc);
    float c = dot(oc, oc) - s.radius * s.radius;

    float discriminant = h * h - a * c;

    if(discriminant < 0.0) {
        return false;
    }

    float sqrtd = sqrt(discriminant);
    float root = (h - sqrtd) / a;

    if(root < t_min || t_max < root) {
        root = (h + sqrtd) / a;
        if(root <= t_min || t_max <= root) {
            return false;
        }
    }

    rec.t = root;
    rec.p = at(rec.t, origin, direction);
    vec3 outward_normal = (rec.p - s.center) / s.radius;
    set_face_front(rec, direction, outward_normal);

    return true;
}

bool hit_world(vec3 origin, vec3 direction, float t_min, float t_max, inout hit_record rec) {
    hit_record temp_rec;
    bool hit_anything = false;
    float closest_so_far = t_max;
    sphere s;

    for(int i=0; i<iSpheresAmount; i++) {
        vec4 sphereData = unpackVec4FromTexture(i);
        s.center = sphereData.xyz;
        s.radius = sphereData.w;

        if(hit(s, origin, direction, t_min, closest_so_far, temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }

    return hit_anything;
}

color ray_color(const vec3 origin, const vec3 direction) {
    hit_record rec;

    if(hit_world(origin, direction, 0, 80.0, rec)) {
        return 0.5 * (rec.normal + vec3(1.0));
    }

    vec3 unit_direction = normalize(direction);
    float t = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - t) * color(1.0) + t * vec3(0.5, 0.7, 1.0);
}

void main() {
    vec2 uv = ((gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y);

    // Camera Setup
    float fov = 90.0;
    vec3 ray_o = vec3(0.0, 0.0, -3.0);
    vec3 ray_d = normalize(vec3(uv, 1.0));

    vec3 col = ray_color(ray_o, ray_d);
    fragColor = vec4(col.xyz, 1.0);
}
