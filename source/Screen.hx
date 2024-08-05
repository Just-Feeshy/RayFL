package;

import kha.graphics5_.VertexStructure;
import kha.graphics5_.Usage;
import kha.graphics4.*;
import kha.Shaders;

class Screen {
    private static inline final VERTICES = 0x5C;

    private var pipeline:PipelineState;
    private var time:ConstantLocation;

    public var geometryBuffer(default, null):GeometryBuffer;

    public function new() {
        var vertexStructure = new VertexStructure();
        vertexStructure.add('pos', VertexData.Float32_3X);

        pipeline = new PipelineState();
        pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
        pipeline.inputLayout = [vertexStructure];

        pipeline.fragmentShader = Shaders.universe_frag;
        pipeline.vertexShader = Shaders.universe_vert;

        pipeline.colorAttachmentCount = 1;
        pipeline.colorAttachments[0] = TextureFormat.RGBA32;
        pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
        pipeline.cullMode = Clockwise;

        pipeline.compile();

        // time = pipeline.getConstantLocation('iTime');

        var vertexBuffer = new VertexBuffer(4, vertexStructure, Usage.StaticUsage);
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
    }

    public function render(g:Graphics) {
        g.setPipeline(pipeline);
        g.setVertexBuffer(geometryBuffer.vertexBuffer);
        g.setIndexBuffer(geometryBuffer.indexBuffer);
        g.drawIndexedVertices();
    }
}
