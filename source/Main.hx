package;

import kha.System;
import kha.Assets;
import kha.Window;
import kha.Framebuffer;
import kha.Scheduler;
import kha.graphics4.*;

#if kha_html5
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import kha.Macros;
#end

class Main {
    private static var FRAMERATE = 60;

    private var screen:Screen;

    private function new() {
        var w = Window.get(0).width;
        var h = Window.get(0).height;

        Window.get(0).notifyOnResize(function(width, height) {
            screen.resize(width, height);
        });

        screen = new Screen(w, h);
    }

    private function render(framebuffer:Framebuffer) {
        var g4 = framebuffer.g4;

        g4.begin();
        screen.render(g4);
        g4.end();
    }

    private function update():Void {

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
