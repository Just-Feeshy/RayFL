package components;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;

enum Status {
    HOLD;
    RELEASED;
}

enum Device {
    KEYBOARD;
    GAMEPAD;
}

enum abstract Controls(Int) from Int to Int {
    var NONE = 0;

    // Camera Movement (Keyboard)
    var MOVE_FOWARD = 1;
    var MOVE_BACKWARDS = 2;
    var MOVE_RIGHT = 4;
    var MOVE_LEFT = 8;
    var MOVE_UP = 16;
    var MOVE_DOWN = 32;
    var LOOK_HORIZONTAL_RIGHT = 64;
    var LOOK_HORIZONTAL_LEFT = 128;
    var LOOK_VERTICAL_UP = 256;
    var LOOK_VERTICAL_DOWN = 512;
}

class Input {
    public var controlStatus(default, null):Int = 0;

    private var inputCallback:(control:Controls, status:Status)->Void;
    private var mappedInput:Map<Int, Controls> = [];

    public function new(device:Device) {
        switch(device) {
            case KEYBOARD:
                mappedInput.set(KeyCode.W, Controls.MOVE_FOWARD);
                mappedInput.set(KeyCode.S, Controls.MOVE_BACKWARDS);
                mappedInput.set(KeyCode.D, Controls.MOVE_RIGHT);
                mappedInput.set(KeyCode.A, Controls.MOVE_LEFT);
                mappedInput.set(KeyCode.Q, Controls.MOVE_UP);
                mappedInput.set(KeyCode.E, Controls.MOVE_DOWN);

            case GAMEPAD:
                trace("Gamepad support not implemented yet.");
        }
    }

    public function setupNotifications(
        onMouseMove:(x:Int, y:Int, dx:Int, dy:Int)->Void):Void {
            Keyboard.get().notify(__onKeyDown, __onKeyUp);
            Mouse.get().notify(onMouseMove);
    }

    @:noCompletion private function __onKeyDown(keyCode:Int):Void {
        if(mappedInput.exists(keyCode)) {
            controlStatus |= mappedInput.get(keyCode);
        }
    }

    @:noCompletion private function __onKeyUp(keyCode:Int):Void {
        if(mappedInput.exists(keyCode)) {
            controlStatus &= ~mappedInput.get(keyCode);
        }
    }
}
