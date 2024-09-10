package;

import kha.Image;
import kha.Assets;
import kha.graphics4.*;
import haxe.io.Bytes;

class TextureHandler {
    private var pipeline:PipelineState;

    @:noCompletion private var __textures(default, null):Array<TextureUnit> = [];

    @:noCompletion private var __requiredImagesByName:Array<String> = [
        "2k_earth_daymap.png",
        "2k_earth_nightmap.png",
        "2k_earth_clouds.png",
    ];

    @:noCompletion private var __images:Array<Image> = [];

    public function new(pipeline:PipelineState) {
        this.pipeline = pipeline;

        for(imageName in __requiredImagesByName) {
            Assets.loadImageFromPath(imageName, true, loadAllImages, function(error) {
                trace('Error loading image: ' + error);
            });
        }
    }

    private function loadAllImages(image:Image):Void {
        __requiredImagesByName.shift();
        __images.push(image);
        __textures.push(pipeline.getTextureUnit('textures[${__images.length - 1}]'));

        if (__requiredImagesByName.length != 0) {
            return;
        }
    }

    private function imageFormatSize(image:Image):Int {
        switch(image.format){
            case TextureFormat.RGBA32:
                return 4;
            case TextureFormat.RGBA64:
                return 8;
            case TextureFormat.RGBA128:
                return 16;
            case TextureFormat.DEPTH16:
                return 2;
            case TextureFormat.L8:
                return 1;
            case TextureFormat.A32:
                return 4;
            case TextureFormat.A16:
                return 2;
        }

        return 0;
    }

    public function render(g:Graphics):Void {
        for(i in 0...__textures.length) {
            g.setTexture(__textures[i], __images[i]);
        }
    }
}
