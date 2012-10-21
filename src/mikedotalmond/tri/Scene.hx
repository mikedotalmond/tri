package mikedotalmond.tri;

import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.geom.Matrix3D;
import flash.Lib;

import hxs.Signal;

import mikedotalmond.tri.geom.Vector;
import mikedotalmond.tri.shaders.VertexWaveShader;


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class Scene {

	private var stage 			:Stage;
	private var stage3D 		:Stage3D;
	private var context3D		:Context3D;
	private var shader 			:VertexWaveShader;
	private var time			:Float;
	
	private var stageWidth		:Int;
	private var stageHeight		:Int;
	private var halfStageWidth	:Int;
	private var halfStageHeight	:Int;

	public var polyManager(default, null):PolygonManager;
	
	public var ready(default, null):Signal;
	
	public var createPolygons(default, null):Signal;
	public var camera(default, null)		:Camera;
	public var positionMatrix(default, null):Matrix3D;
	
	
	public function new() {
		
		var current 	= flash.Lib.current;
		
		createPolygons 	= new Signal();
		ready 			= new Signal();
		
		time 			= 0;
		stage 			= current.stage;
		stage3D 		= stage.stage3Ds[0];
		
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextReady );
		stage3D.requestContext3D();
	}
	
	function onContextReady( _ ) {
	
		setup3D();
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.addEventListener(FullScreenEvent.FULL_SCREEN, onResize);
		
		onResize(null);
		
		createScene();
	}
	
	private function setup3D() {
		
		context3D 		= stage3D.context3D;
		shader 			= new VertexWaveShader(context3D);
		polyManager 	= new PolygonManager();
		positionMatrix 	= new Matrix3D();
		camera 			= new Camera(60, 1, 1, 0.02, 15);
		camera.up		= new Vector(0, 1, 0);
		camera.pos.z 	= 10;
	}
	
	private function initBackBuffer() {
		#if debug 
		context3D.enableErrorChecking = true;
		context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 0, false );
		#else 
		context3D.enableErrorChecking = false; 
		context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 4, false );//antialias=4
		#end
	}
	
	public function createScene() {
		
		polyManager.init();
		
		createPolygons.dispatch();
		
		polyManager.alloc(context3D);
		
		Lib.trace("vertices: " + polyManager.vCount);
		Lib.trace("triangles: " + polyManager.triCount());
		Lib.trace("polygons: " + polyManager.polygons.length);
		
		ready.dispatch();
	}
	
	private function onResize(e:Event):Void {
		var w:Int = stage.stageWidth;
		var h:Int = stage.stageHeight;
		
		stageWidth  	= w;
		stageHeight 	= h;
		halfStageWidth 	= w >> 1;
		halfStageHeight = h >> 1;
		
		// set the backbuffer size
		initBackBuffer();
		
		// update scene
		camera.ratio = w / h;
		camera.update();
	}

	/**
	 * Call every frame
	 * @param	?updateAllBuffers
	 */
	public function update(delta:Float) {
		if( context3D == null ) return;
		
		context3D.clear(0, 0, 0, 1);
		
		// allow alpha blending
		context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		
		// no depth test for now...
		context3D.setDepthTest(false, Context3DCompareMode.LESS_EQUAL );
		
		// don't draw back-faces
		context3D.setCulling(Context3DTriangleFace.BACK);
		
		var pm = polyManager;
		
		pm.uploadAll();
		
		//scene.positionMatrix.appendRotation(time * 10, flash.geom.Vector3D.Z_AXIS);
		
		var project = camera.m.toMatrix();
		
		var mouseX:Float = (stage.mouseX / stageWidth) - 0.5;
		var mouseY:Float = (stage.mouseY / stageHeight) - 0.5;
		
		time += delta + delta * mouseX;
		
		camera.zoom = 1.05 + mouseX * 0.1;
		camera.update();
		
		shader.init(
			{	mpos		: positionMatrix, 
				mproj		: project, 
				time		: time,
				fx			: mouseX*2, 
				fy			: mouseY*2, 
				amplitude	: 0.2+mouseY
			},
			{  }
		);
		
		shader.bind(pm.vbuf);
		context3D.drawTriangles(pm.ibuf);
		context3D.present();
	}
}