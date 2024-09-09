package;

import kha.Image;
import kha.Assets;
import kha.graphics4.*;
import haxe.io.Bytes;

class TextureHandler {
    public var textures(default, null):TextureUnit; // Soon to be an array of TextureUnits
    public var images3D(default, null):Image; // Soon to be an array of Images

    @:noCompletion private var __requiredImagesByName:Array<String> = [
        "2k_earth_daymap.png",
        "2k_earth_nightmap.png",
    ];

    @:noCompletion private var __images:Array<Image> = [];

    public function new(pipeline:PipelineState) {
        textures = pipeline.getTextureUnit('textures');

        for(imageName in __requiredImagesByName) {
            Assets.loadImageFromPath(imageName, true, loadAllImages, function(error) {
                trace('Error loading image: ' + error);
            });
        }
    }

    private function loadAllImages(image:Image):Void {
        __requiredImagesByName.shift();
        __images.push(image);

        if (__requiredImagesByName.length > 0) {
            return;
        }


        // Load all images

        var width:Int = __images[0].width;
        var height:Int = __images[0].height;
        var capacity:Int = 0;

        for(image in __images) {
            capacity += width * height * imageFormatSize(image);
        }

        var bytes = Bytes.alloc(capacity);
        var depth:Int = __images.length;
        var offset:Int = 0;

        while(__images[0] != null) {
            var image = __images.pop();
            var capacity = width * height * imageFormatSize(image);

            var memory = image.lock();
            bytes.blit(offset, memory, 0, capacity);
            image.unlock();

            offset += image.width * image.height * imageFormatSize(image);
        }

        images3D = Image.fromBytes3D(bytes, width, height, depth, TextureFormat.RGBA32, Usage.StaticUsage);
        __images = [];
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
        g.setTexture(textures, images3D);
    }
}
