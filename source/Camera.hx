package;

import kha.math.FastMatrix4;
import kha.math.Vector3;
import kha.math.FastVector3;

class Camera {
    public var aspectRatio:Float;

    public var position(default, set):Vector3;
    public var fov = 80 * Math.PI / 180;
    public var samplesPerPixel:Int = 100;
    public var projection:FastMatrix4;
    public var view:FastMatrix4;

    public var horizontalAngle(default, set):Float = Math.PI;
    public var verticalAngle(default, set):Float = 0;
    public var modelViewProj(get, default):FastMatrix4;

    private var upVector:FastVector3;
    private var lookVector:Vector3;

    public function new() {
        upVector = new FastVector3(0, 1, 0);
        lookVector = new Vector3(0, 0, 0);
        position = new Vector3(0, 0, 0);
    }

    public function getLookVector():Vector3 {
        lookVector.x = Math.cos(verticalAngle) * Math.sin(horizontalAngle);
        lookVector.y = Math.sin(verticalAngle);
        lookVector.z = Math.cos(verticalAngle) * Math.cos(horizontalAngle);
        return lookVector;
    }

    @:noCompletion private function set_position(value:Vector3):Vector3 {
        return position = value;
    }

    @:noCompletion private function get_modelViewProj():FastMatrix4 {
        projection = FastMatrix4.perspectiveProjection(fov, aspectRatio, .15, 160);
        view = FastMatrix4.lookAt(position.fast(), position.add(getLookVector()).fast(), upVector);
        modelViewProj = projection.multmat(view);

        return modelViewProj;
    }

    @:noCompletion private function set_horizontalAngle(value:Float):Float {
        return horizontalAngle = value;
    }

    @:noCompletion private function set_verticalAngle(value:Float):Float {
        return verticalAngle = value;
    }
}
