package;

import kha.Image;
import kha.Shaders;
import kha.math.FastVector2;
import kha.graphics5_.VertexStructure;
import kha.graphics5_.Usage;
import kha.graphics4.*;
import haxe.io.Bytes;
import haxe.io.FPHelper;

class Screen {
    private var observableWorld:World;
    private var structure:VertexStructure;
    private var vertexBuffer:VertexBuffer;

    private var pipeline:PipelineState;
    private var time:ConstantLocation;
    private var resolution:ConstantLocation;
    private var cameraLocation:ConstantLocation;
    private var spheresAmount:ConstantLocation;
    private var spheresUnit:TextureUnit;
    private var spheresBuffer:Image;
    private var resolutionVector:FastVector2;

    public var camera(default, null):Camera;
    public var geometryBuffer(default, null):GeometryBuffer;

    public var width(default, null):Int;
    public var height(default, null):Int;

    public function new(width:Int, height:Int) {
        this.width = width;
        this.height = height;

        camera = new Camera();
        camera.aspectRatio = width / height;
        resolutionVector = new FastVector2(width, height);

        setupPipeline();

        var vertexBuffer = new VertexBuffer(4, structure, Usage.StaticUsage);
        var indexBuffer = new IndexBuffer(6, Usage.StaticUsage);
        var vertexBufferData = vertexBuffer.lock();

        var vertices = [
            // Positions
            -1.0, -1.0, 0.0,
             1.0, -1.0, 0.0,
             1.0,  1.0, 0.0,
            -1.0,  1.0, 0.0
        ];

        var indices = [
            0, 1, 2,
            2, 3, 0
        ];

        var vertexBufferData = vertexBuffer.lock();
        var indexBufferData = indexBuffer.lock();

        for(i in 0...vertices.length) {
            vertexBufferData.set(i, vertices[i]);
        }

        for(i in 0...indices.length) {
            indexBufferData.set(i, indices[i]);
        }

        vertexBuffer.unlock();
        indexBuffer.unlock();

        geometryBuffer = new GeometryBuffer(indexBuffer, vertexBuffer);
        spheresBuffer = Image.create(1, 1, TextureFormat.RGBA32, Usage.DynamicUsage);
        observableWorld = new World();
    }

    public function render(g:Graphics) {
        if(observableWorld.__dirtySphereChange) {
            writeToSphereBuffer();
            observableWorld.__dirtySphereChange = false;
        }

        g.setPipeline(pipeline);
        g.setVector2(resolution, resolutionVector);
        g.setMatrix(cameraLocation, camera.modelViewProj);
        g.setTexture(spheresUnit, spheresBuffer);
        g.setInt(spheresAmount, observableWorld.length);
        g.setVertexBuffer(geometryBuffer.vertexBuffer);
        g.setIndexBuffer(geometryBuffer.indexBuffer);
        g.drawIndexedVertices();
    }

    public function resize(width:Int, height:Int) {
        this.width = width;
        this.height = height;

        resolutionVector.x = width;
        resolutionVector.y = height;

        camera.aspectRatio = width / height;
    }

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

    private function setupPipeline():Void {
        structure = new VertexStructure();
        structure.add('pos', VertexData.Float32_3X);

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

        // time = pipeline.getConstantLocation('iTime');
        resolution = pipeline.getConstantLocation('iResolution');
        spheresUnit = pipeline.getTextureUnit('iSpheres');
        spheresAmount = pipeline.getConstantLocation('iSpheresAmount');
        cameraLocation = pipeline.getConstantLocation('iCamera');
    }
}
