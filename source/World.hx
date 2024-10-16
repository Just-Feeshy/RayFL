package;

import kha.math.FastVector3;

@:allow(Screen) class World {
    private static final FIELD_OFFSET = 160.0;

    public var length(default, null):Int = 0;

    @:noCompletion private var __spheres:Array<Sphere> = [];
    @:noCompletion private var __dirtySphereChange:Bool = false;

    public function new() {
        // This is where my code starts

        var sphere = new Sphere(0.0, 0.0, 0.0, 6400.0);
        add(sphere);
    }

    @:access(kha.math.FastVector3) public function collision(position:FastVector3):FastVector3 {
        for(sph in __spheres) {

            // While doing this, I just did it through tip to tail vector subtraction
            // I literally had a physics quiz on this exact same topic
            final sphereDist = position.sub(sph.getPositionVector());
            final deltaDist = sphereDist.length - (sph.radius + FIELD_OFFSET);

            if(deltaDist < 0.0) {
                sphereDist.set_length(sph.radius + FIELD_OFFSET); // Normalize our vector, then multiply it by our radius boundary

                // Now multiply our normalized vector by our radius boundary
                return sphereDist;
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
