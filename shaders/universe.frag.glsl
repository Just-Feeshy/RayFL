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
    float texelSizeX = 1.0 / float(iSpheresAmount * 4);

    // Compute texture coordinates for each component of the vec4
    float baseCoordX = float(index * 4) * texelSizeX;
    vec2 baseCoord = vec2(baseCoordX, 0.5);

    // Sample 4 consecutive texels
    vec4 v1 = texture(iSpheres, baseCoord);
    vec4 v2 = texture(iSpheres, baseCoord + vec2(texelSizeX, 0.0));
    vec4 v3 = texture(iSpheres, baseCoord + vec2(texelSizeX * 2.0, 0.0));
    vec4 v4 = texture(iSpheres, baseCoord + vec2(texelSizeX * 3.0, 0.0));

    // Reconstruct the floats from the sampled bytes
    int x = int(v1.r * 255.0) << 24 | int(v1.g * 255.0) << 16 | int(v1.b * 255.0) << 8 | int(v1.a * 255.0);
    int y = int(v2.r * 255.0) << 24 | int(v2.g * 255.0) << 16 | int(v2.b * 255.0) << 8 | int(v2.a * 255.0);
    int z = int(v3.r * 255.0) << 24 | int(v3.g * 255.0) << 16 | int(v3.b * 255.0) << 8 | int(v3.a * 255.0);
    int w = int(v4.r * 255.0) << 24 | int(v4.g * 255.0) << 16 | int(v4.b * 255.0) << 8 | int(v4.a * 255.0);

    // Reinterpret the bytes as floats
    return vec4(intBitsToFloat(x), intBitsToFloat(y), intBitsToFloat(z), intBitsToFloat(w));
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
        return 0.5 * (rec.normal + color(1.0));
    }

    vec3 unit_direction = normalize(direction);
    float t = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - t) * color(1.0) + t * vec3(0.5, 0.7, 1.0);
}

void main() {
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = ((gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y) * vec2(aspectRatio, 1.0);

    vec3 ro = iCamera[3].xyz;
    vec3 rd = normalize((iCamera * vec4(uv, 0.0, 1.0)).xyz);

    vec3 col = ray_color(ro, rd);

    fragColor = vec4(col.xyz, 1.0);
}
