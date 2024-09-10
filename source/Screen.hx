package;

import kha.Image;
import kha.Shaders;
import kha.System;
import kha.math.FastVector2;
import kha.graphics5_.VertexStructure;
import kha.graphics5_.Usage;
import kha.graphics4.*;
import haxe.io.Bytes;
import haxe.io.FPHelper;

class Screen {
    // private var observableWorld:World;
    private var textureHandler:TextureHandler;

    private var structure:VertexStructure;
    private var vertexBuffer:VertexBuffer;

    private var pipeline:PipelineState;
    private var time:ConstantLocation;
    private var resolution:ConstantLocation;
    private var cameraLocation:ConstantLocation;
    private var matrixLocation:ConstantLocation;
    // private var spheresAmount:ConstantLocation;
    // private var spheresUnit:TextureUnit; // TODO: Put this in the textureHandler
    // private var spheresBuffer:Image;
    private var resolutionVector:FastVector2;

    public var camera(default, null):Camera;
    public var width(default, null):Int;
    public var height(default, null):Int;

    public function new(width:Int, height:Int, camera:Camera) {
        this.width = width;
        this.height = height;
        this.camera = camera;

        resolutionVector = new FastVector2(width, height);
        setupPipeline();

        // observableWorld = new World();
        textureHandler = new TextureHandler(pipeline);

        vertexBuffer = new VertexBuffer(4, structure, Usage.StaticUsage);
        var vertices = vertexBuffer.lock();

        vertices.set(0, 0.0); // Bottom-left
        vertices.set(1, 0.0); // Bottom-left

        vertices.set(2, width); // Bottom-right
        vertices.set(3, 0.0); // Bottom-right

        vertices.set(4, width); // Top-right
        vertices.set(5, height); // Top-right

        vertices.set(6, 0.0); // Top-left
        vertices.set(7, height);  // Top-left

        vertexBuffer.unlock();

        // spheresBuffer = Image.create(1, 1, TextureFormat.RGBA32, Usage.DynamicUsage);
    }

    public function render(g:Graphics) {
        /*
        if(observableWorld.__dirtySphereChange) {
            writeToSphereBuffer();
            observableWorld.__dirtySphereChange = false;
        }
        */

        g.setPipeline(pipeline);
        g.setFloat(time, System.time);
        g.setVector2(resolution, resolutionVector);
        g.setVector3(cameraLocation, camera.position);
        g.setVertexBuffer(vertexBuffer);
        g.setMatrix3(matrixLocation, camera.matrix);
        g.drawIndexedVertices(0, 6);
        // g.setTexture(spheresUnit, spheresBuffer);
        // g.setInt(spheresAmount, observableWorld.length);

        textureHandler.render(g);
    }

    public function resize(width:Int, height:Int) {
        this.width = width;
        this.height = height;

        resolutionVector.x = width;
        resolutionVector.y = height;
    }

    /*
    private function writeToSphereBuffer():Void {
        final __width = observableWorld.length;

        if(width != spheresBuffer.width) {
            spheresBuffer = Image.create(__width, 1, TextureFormat.RGBA128, Usage.DynamicUsage);
        }

        var bytes = spheresBuffer.lock();
        var spheres = observableWorld.__spheres;

        for(j in 0...__width) {
            var x = spheres[j].position.get(0);
            var y = spheres[j].position.get(1);
            var z = spheres[j].position.get(2);
            var w = spheres[j].position.get(3);

            bytes.setFloat(j * 16 + 0, x);
            bytes.setFloat(j * 16 + 4, y);
            bytes.setFloat(j * 16 + 8, z);
            bytes.setFloat(j * 16 + 12, w);
        }

        spheresBuffer.unlock();
    }
    */

    private function setupPipeline():Void {
        structure = new VertexStructure();
        structure.add('pos', VertexData.Float32_2X);

        pipeline = new PipelineState();
        pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
        pipeline.inputLayout = [structure];

        pipeline.fragmentShader = Shaders.universe_frag;
        pipeline.vertexShader = Shaders.universe_vert;

        pipeline.colorAttachmentCount = 1;
        pipeline.colorAttachments[0] = TextureFormat.RGBA32;
        pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
        pipeline.cullMode = Clockwise;

        pipeline.compile();

        // spheresUnit = pipeline.getTextureUnit('iSpheres');
        // spheresAmount = pipeline.getConstantLocation('iSpheresAmount');
        time = pipeline.getConstantLocation('iTime');
        resolution = pipeline.getConstantLocation('iResolution');
        cameraLocation = pipeline.getConstantLocation('iCam');
        matrixLocation = pipeline.getConstantLocation('iMat');
    }
}
