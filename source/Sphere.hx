package;

import kha.FastFloat;

@:allow(Screen) class Sphere {
    public var x(default, set):FastFloat;
    public var y(default, set):FastFloat;
    public var z(default, set):FastFloat;
    public var radius(default, set):FastFloat;

    private var position(default, null):Float32Array;

    public function new(x:FastFloat, y:FastFloat, z:FastFloat, radius:FastFloat) {
        position = new Float32Array(4);
        position.set(0, x);
        position.set(1, y);
        position.set(2, z);
        position.set(3, radius);
    }

    @:noCompletion private function set_x(x:FastFloat):FastFloat {
        this.x = x;
        position.set(0, x);
        return x;
    }

    @:noCompletion private function set_y(y:FastFloat):FastFloat {
        this.y = y;
        position.set(1, y);
        return y;
    }

    @:noCompletion private function set_z(z:FastFloat):FastFloat {
        this.z = z;
        position.set(2, z);
        return z;
    }

    @:noCompletion private function set_radius(radius:FastFloat):FastFloat {
        this.radius = radius;
        position.set(3, radius);
        return radius;
    }
}
