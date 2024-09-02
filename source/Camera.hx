package;

import kha.math.FastVector3;
import kha.math.FastVector2;

class Camera {
    public var position(default, null):FastVector3;
    public var rotation(default, null):FastVector2;

    public function new() {
        position = new FastVector3(0, 0, 100);
        rotation = new FastVector2(0, 0);
    }
}
