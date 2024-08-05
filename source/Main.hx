package;

import kha.System;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.graphics4.*;

class Main {
    private static var FRAMERATE = 60;

    private var screen:Screen;

    private function new() {
        screen = new Screen();
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
        var width, height;

        #if (js && html5)
        width = untyped js.Syntax.code("window.innerWidth");
        height = untyped js.Syntax.code("window.innerHeight");
        #else
        width = System.windowWidth();
        height = System.windowHeight();
        #end

        System.start({
            title: "Project",
            width: width,
            height: height,
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
}
