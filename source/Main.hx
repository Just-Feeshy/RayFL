package;

import kha.System;
import kha.Assets;
import kha.Window;
import kha.Framebuffer;
import kha.Scheduler;
import kha.graphics4.*;
import components.Input;

#if kha_html5
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.Element;
import kha.Macros;
#end

class Main {
    private static var FRAMERATE = 60;
    private static var TAU = 2 * Math.PI;
    private static var SPEED = 100.0;

    private var screen:Screen;
    private var camera:Camera;
    private var input:Input;

    @:noCompletion private var __dirtyMovement:Bool = false;

    private function new() {
        var w = Window.get(0).width;
        var h = Window.get(0).height;

        Window.get(0).notifyOnResize(function(width, height) {
            screen.resize(width, height);
        });

        camera = new Camera();
        screen = new Screen(w, h, camera);
        input = new Input(Device.KEYBOARD);

        #if debug
        input.debugCallback = camera.toString;
        #end

        input.setupNotifications(__onMouse);
    }

    private function clamp(value:Float, min:Float, max:Float):Float {
        return Math.min(Math.max(value, min), max);
    }

    // Update game logic here (Input)
    private function update():Void {
        if(input.controlStatus & Controls.MOVE_FOWARD != 0) {
            camera.position.x -= camera.front.x * SPEED;
            camera.position.y -= camera.front.y * SPEED;
            camera.position.z += camera.front.z * SPEED;

            __dirtyMovement = true;
        }

        if(input.controlStatus & Controls.MOVE_BACKWARDS != 0) {
            camera.position.x += camera.front.x * SPEED;
            camera.position.y += camera.front.y * SPEED;
            camera.position.z -= camera.front.z * SPEED;

            __dirtyMovement = true;
        }

        if(input.controlStatus & Controls.MOVE_RIGHT != 0) {
            var cross = camera.front.cross(camera.up).normalized();

            camera.position.x -= cross.x * SPEED;
            camera.position.z += cross.z * SPEED;

            __dirtyMovement = true;
        }

        if(input.controlStatus & Controls.MOVE_LEFT != 0) {
            var cross = camera.front.cross(camera.up).normalized();

            camera.position.x += cross.x * SPEED;
            camera.position.z -= cross.z * SPEED;

            __dirtyMovement = true;
        }

        if(__dirtyMovement) {
            camera.position = screen.observableWorld.collision(camera.position);
            __dirtyMovement = false;
        }
    }

    private function render(framebuffer:Framebuffer) {
        var g4 = framebuffer.g4;

        g4.begin();
        screen.render(g4);
        g4.end();
    }

    @:noCompletion private function __onMouse(x:Int, y:Int, dx:Int, dy:Int):Void {
        if(!input.focused) return;

        camera.rotation.x = (camera.rotation.x + dx / 512) % TAU;
        camera.rotation.y = clamp((camera.rotation.y + dy / 512), -Math.PI / 2, Math.PI / 2);
        camera.updateMatrix();
    }

    public static function main() {
        setFullWindowCanvas();

        System.start({
            title: "Project",
            width: 1280,
            height: 720,
            framebuffer: {samplesPerPixel: 4}
        }, function(_) {
            Assets.loadEverything(function() {
                var main = new Main();
                Scheduler.addTimeTask(function() {
					main.update();
				}, 0, 1 / FRAMERATE);
                System.notifyOnFrames(function(framebuffers) {
                    main.render(framebuffers[0]);
                });
            });
        });
    }

    private static function setFullWindowCanvas():Void {
		#if kha_html5
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		final canvas:CanvasElement = cast document.getElementById(Macros.canvasId());
		canvas.style.display = "block";
		final resize = function() {
			var w = document.documentElement.clientWidth;
			var h = document.documentElement.clientHeight;
			if (w == 0 || h == 0) {
				w = window.innerWidth;
				h = window.innerHeight;
			}
			canvas.width = Std.int(w * window.devicePixelRatio);
			canvas.height = Std.int(h * window.devicePixelRatio);
			if (canvas.style.width == "") {
				canvas.style.width = "100%";
				canvas.style.height = "100%";
			}
		}
		window.onresize = resize;
		resize();
		#end
	}
}
