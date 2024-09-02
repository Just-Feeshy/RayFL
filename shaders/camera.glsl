mat3 getCam(vec3 ro, vec3 lookAt) {
    vec3 ww = normalize(lookAt - ro);
    vec3 uu = normalize(cross(vec3(0, 1, 0), ww));
    vec3 vv = cross(ww, uu);
    return mat3(uu, vv, ww);
}
