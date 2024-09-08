package;

import kha.math.FastVector3;
import kha.math.FastVector2;
import kha.math.FastMatrix3;

class Camera {
    @:noCompletion private var __matrix_rot_x(default, null):FastMatrix3;
    @:noCompletion private var __matrix_rot_y(default, null):FastMatrix3;

    public var front(default, null):FastVector3;
    public var position(default, null):FastVector3;
    public var rotation(default, null):FastVector2;
    public var direction(default, null):FastVector3;
    public var up(default, null):FastVector3;
    public var matrix(default, null):FastMatrix3;

    public function new() {
        front = new FastVector3(0, 0, 1);
        position = new FastVector3(0, 0, 0);
        rotation = new FastVector2(0, 0);
        direction = new FastVector3(0, 0, 0);
        up = new FastVector3(0, 1, 0);

        __matrix_rot_x = new FastMatrix3(
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0
        );

        __matrix_rot_y = new FastMatrix3(
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0
        );

        matrix = null;
        updateMatrix();
    }

    public function updateMatrix():Void {
        var cos_x = Math.cos(rotation.y);
        var sin_x = Math.sin(rotation.y);

        var cos_y = Math.cos(rotation.x);
        var sin_y = Math.sin(rotation.x);

        // Rotation matrix for X
        __matrix_rot_x._00 = 1.0;
        __matrix_rot_x._01 = 0.0;
        __matrix_rot_x._02 = 0.0;

        __matrix_rot_x._10 = 0.0;
        __matrix_rot_x._11 = cos_x;
        __matrix_rot_x._12 = -sin_x;

        __matrix_rot_x._20 = 0.0;
        __matrix_rot_x._21 = sin_x;
        __matrix_rot_x._22 = cos_x;

        // Rotation matrix for Y
        __matrix_rot_y._00 = cos_y;
        __matrix_rot_y._01 = 0.0;
        __matrix_rot_y._02 = sin_y;

        __matrix_rot_y._10 = 0.0;
        __matrix_rot_y._11 = 1.0;
        __matrix_rot_y._12 = 0.0;

        __matrix_rot_y._20 = -sin_y;
        __matrix_rot_y._21 = 0.0;
        __matrix_rot_y._22 = cos_y;

        // Combine rotation matrices
        matrix = __matrix_rot_x.multmat(__matrix_rot_y);

        // Update camera front
        front.z = cos_y;
        front.y = 0.0;
        front.x = -sin_y;
        front = front.normalized();
    }

    #if debug
    public function toString():String {
        return "Camera: { position: " + position + ", rotation: " + rotation + " }";
    }
    #end
}
