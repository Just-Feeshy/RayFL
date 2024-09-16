package;

import kha.FastFloat;
import kha.math.FastVector3;

@:allow(Screen) class Sphere {
    public var radius(get, set):FastFloat;

    private var position(default, null):Float32Array;

    public function new(x:FastFloat, y:FastFloat, z:FastFloat, radius:FastFloat) {
        position = new Float32Array(4);
        position.set(0, x);
        position.set(1, y);
        position.set(2, z);
        position.set(3, radius);
    }

    public function getPositionVector():FastVector3 {
        return new FastVector3(position[0], position[1], position[2]);
    }

    @:noCompletion private function set_radius(radius:FastFloat):FastFloat {
        position.set(3, radius);
        return radius;
    }

    @:noCompletion private function get_radius():FastFloat {
        return position[3];
    }
}
