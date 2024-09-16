package;

import kha.math.FastVector3;

@:allow(Screen) class World {
    private static final FIELD_OFFSET = 1.0;

    public var length(default, null):Int = 0;

    @:noCompletion private var __spheres:Array<Sphere> = [];
    @:noCompletion private var __dirtySphereChange:Bool = false;

    public function new() {
        // This is where my code starts

        var sphere = new Sphere(0.0, 0.0, 0.0, 40.0);
        add(sphere);
    }

    @:access(kha.math.FastVector3) public function collision(position:FastVector3):FastVector3 {
        for(sph in __spheres) {
            final sphereDist = position.sub(sph.getPositionVector());
            final deltaDist = sphereDist.length - (sph.radius + FIELD_OFFSET);

            if(deltaDist < 0.0) {
                sphereDist.set_length(1.0);
                return sphereDist.mult(sph.radius + FIELD_OFFSET);
            }
        }

        return position;
    }

    public function add(sphere:Sphere) {
        __spheres.push(sphere);
        length = __spheres.length;
        __dirtySphereChange = true;
    }

    public function remove(sphere:Sphere) {
        var index = __spheres.indexOf(sphere);

        if (index != -1) {
            __spheres.splice(index, 1);
            length = __spheres.length;
            __dirtySphereChange = true;
        }
    }

    public function get(index:Int):Sphere {
        return __spheres[index];
    }

    public function clear() {
        __spheres = [];
        length = 0;
        __dirtySphereChange = true;
    }
}
