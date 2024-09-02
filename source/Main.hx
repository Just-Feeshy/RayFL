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
import kha.Macros;
#end

class Main {
    private static var FRAMERATE = 60;

    private var screen:Screen;
    private var camera:Camera;
    private var input:Input;

    private function new() {
        var w = Window.get(0).width;
        var h = Window.get(0).height;

        Window.get(0).notifyOnResize(function(width, height) {
            screen.resize(width, height);
        });

        camera = new Camera();
        screen = new Screen(w, h, camera);
        input = new Input(Device.KEYBOARD);

        input.setupNotifications(__onMouse);
    }

    private function clamp(value:Float, min:Float, max:Float):Float {
        return Math.min(Math.max(value, min), max);
    }

    // Update game logic here (Input)
    private function update():Void {

        // Every expensive operation done here
        camera.rotation.x = Math.PI * clamp(screen.mouseVector.x / screen.width, -0.5, 0.5);
        camera.rotation.y = Math.PI * clamp(screen.mouseVector.y / screen.height, -0.5, 0.5);

        if(input.controlStatus & Controls.MOVE_FOWARD != 0) {
            camera.position.z += 1 * Math.cos(camera.rotation.x) * Math.cos(camera.rotation.y);
            camera.position.x += 1 * Math.sin(camera.rotation.x) * Math.cos(camera.rotation.y);
            camera.position.y += 1 * Math.sin(camera.rotation.y);
        }

        if(input.controlStatus & Controls.MOVE_BACKWARDS != 0) {
            camera.position.z -= 1 * Math.cos(camera.rotation.x) * Math.cos(camera.rotation.y);
            camera.position.x -= 1 * Math.sin(camera.rotation.x) * Math.cos(camera.rotation.y);
            camera.position.y -= 1 * Math.sin(camera.rotation.y);
        }

        if(input.controlStatus & Controls.MOVE_RIGHT != 0) {
            camera.position.x += 1 * Math.cos(camera.rotation.x);
            camera.position.z += 1 * Math.sin(camera.rotation.x);
        }

        if(input.controlStatus & Controls.MOVE_LEFT != 0) {
            camera.position.x -= 1 * Math.cos(camera.rotation.x);
            camera.position.z -= 1 * Math.sin(camera.rotation.x);
        }

        if(input.controlStatus & Controls.MOVE_UP != 0) {
            camera.position.y += 1 * Math.cos(camera.rotation.y);
            camera.position.z += 1 * Math.sin(camera.rotation.y) * Math.sin(camera.rotation.y);
            camera.position.x += 1 * Math.cos(camera.rotation.y) * Math.sin(camera.rotation.y);
        }

        if(input.controlStatus & Controls.MOVE_DOWN != 0) {
            camera.position.y -= 1 * Math.cos(camera.rotation.y);
            camera.position.z -= 1 * Math.sin(camera.rotation.y) * Math.sin(camera.rotation.y);
            camera.position.x -= 1 * Math.cos(camera.rotation.y) * Math.sin(camera.rotation.y);
        }
    }

    private function render(framebuffer:Framebuffer) {
        var g4 = framebuffer.g4;

        g4.begin();
        screen.render(g4);
        g4.end();
    }

    @:noCompletion private function __onMouse(x:Int, y:Int, dx:Int, dy:Int) {
        screen.updateMouse(x - (screen.width >> 1), y - (screen.height >> 1));
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
