package;

import kha.System;
import kha.Assets;
import kha.Framebuffer;

class Main {
    private function new() {
        trace("Hello, World!");
    }

    private function render(framebuffer:Framebuffer) {

    }

    public static function main() {
        System.start({
            title: "Project",
            width: 1280,
            height: 720,
            framebuffer: {samplesPerPixel: 4}
        }, function(_) {
            /*
            Assets.loadEverything(function() {
                var main = new Main();
                System.notifyOnFrames(function(framebuffers) {
                    main.render(framebuffers[0]);
                });
            });
            */
        }
        );
    }
}
