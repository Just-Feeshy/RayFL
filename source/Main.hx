package;

import kha.System;

class Main {
    public static function main() {
            System.start({
                title: "Project",
                width: 1280,
                height: 720,
                framebuffer: {samplesPerPixel: 4}
            }, function(_) {
                trace("Hello, World!");
            }
        );
    }
}
