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

    // General Controls
    var LOST_FOCUS = 64;
}

class Input {
    #if debug
    public var debugCallback:Void->String;
    #end

    public var controlStatus(default, null):Int = 0;
    public var focused(default, null):Bool = false;

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
                mappedInput.set(KeyCode.Escape, Controls.LOST_FOCUS);

            case GAMEPAD:
                trace("Gamepad support not implemented yet.");
        }
    }

    public function setupNotifications(
        onMouseMove:(x:Int, y:Int, dx:Int, dy:Int)->Void):Void {
            Keyboard.get().notify(__onKeyDown, __onKeyUp);
            Mouse.get().notify(__mouseDown, onMouseMove, __mouseLeave);
    }

    @:noCompletion private function __mouseLeave() {
        Mouse.get().unlock();
        focused = false;
    }

    @:noCompletion private function __mouseDown(button:Int, x:Int, y:Int) {
        Mouse.get().lock();
        focused = true;
    }

    @:noCompletion private function __onKeyDown(keyCode:Int):Void {
        #if debug
        if(keyCode == KeyCode.O) {
            trace(debugCallback());
        }
        #end

        if(!mappedInput.exists(keyCode)) {
            return;
        }

        controlStatus |= mappedInput.get(keyCode);
    }

    @:noCompletion private function __onKeyUp(keyCode:Int):Void {
        if(!mappedInput.exists(keyCode)) {
            return;
        }

        controlStatus &= ~mappedInput.get(keyCode);
    }
}
