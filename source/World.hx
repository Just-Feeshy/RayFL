package;

@:allow(Screen) class World {
    public var length(default, null):Int = 0;

    @:noCompletion private var __spheres:Array<Sphere> = [];
    @:noCompletion private var __dirtySphereChange:Bool = false;

    public function new() {
        // This is where my code starts

        var sphere = new Sphere(0, 0, -1.0, 0.5);
        add(sphere);
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
