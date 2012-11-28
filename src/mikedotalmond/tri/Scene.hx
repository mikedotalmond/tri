package mikedotalmond.tri;

import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.textures.Texture;
import hxs.Signal1;
import hxs.Signal2;


import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;

import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.geom.Matrix3D;
import flash.Lib;
import haxe.Log;

import hxs.Signal;

import mikedotalmond.tri.geom.Utils;
import mikedotalmond.tri.geom.Vector;
import mikedotalmond.tri.shaders.VertexWaveShader;


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class Scene {
	
	private var stage 				:Stage;
	private var stage3D 			:Stage3D;
	private var context3D			:Context3D;
	private var shader 				:VertexWaveShader;
	private var time				:Float;
	
	public var polyManager(default, null):PolygonManager;
	
	public var ready(default, null):Signal;
	
	public var createPolygons(default, null):Signal1<Scene>;
	public var camera(default, null)		:Camera;
	public var positionMatrix(default, null):Matrix3D;
	
	public var shaderX			:Float = .01;
	public var shaderY			:Float = .01;
	public var shaderAmplitude	:Float = 1;
	
	/**
	 *
	 * @param	stage3D - Stage3D instance with an initialised context3D
	 */
	public function new(sharedStage3D:SharedStage3DContext) {
		
		var current 	= flash.Lib.current;
		
		createPolygons 	= new Signal1<Scene>();
		ready 			= new Signal();
		
		time 			= 0;
		stage 			= current.stage;
		
		this.stage3D 	= sharedStage3D.stage3D;
		this.context3D 	= stage3D.context3D;
		
		shader 			= new VertexWaveShader(context3D);
		polyManager 	= new PolygonManager();
		positionMatrix 	= new Matrix3D();
		camera 			= new Camera(60, 1, 1, 0.02, 80);
		camera.up		= new Vector(0, 1, 0);
		camera.pos.z 	= 10;
		
		sharedStage3D.resize.add(onResize);
		sharedStage3D.requestDraw.add(update);
	}
	
	
	public function createScene() {
		
		polyManager.init();
		
		createPolygons.dispatch(this);
		
		polyManager.alloc(context3D);
		
		Lib.trace("vertices: " + polyManager.vCount);
		Lib.trace("triangles: " + polyManager.triCount());
		Lib.trace("polygons: " + polyManager.polygons.length);
		
		ready.dispatch();
	}
	
	private function onResize(w:Int,h:Int):Void {
		// update scene
		camera.ratio = w / h;
		camera.update();
	}

	/**
	 * Call every frame
	 * @param	?updateAllBuffers
	 */
	public function update(delta:Float, time:Float) {
		
		var pm = polyManager;
		
		pm.uploadAll();
		
		//positionMatrix.appendRotation(time * .10, flash.geom.Vector3D.Z_AXIS);
		var mouseX:Float = (stage.mouseX / stage.stageWidth) - 0.5;
		var mouseY:Float = (stage.mouseY / stage.stageHeight) - 0.5;
		
		time += delta + delta * mouseX;
		
		//camera.zoom = 1.05 + mouseX * 0.1;
		camera.update();
		
		var project = camera.m.toMatrix();
		
		shader.init(
			{	mpos		: positionMatrix,
				mproj		: project,
				time		: time,
				fx			: mouseX * 2,
				fy			: mouseY * 2,
				amplitude	: mouseY * 0.2
			},
			{  }
		);
		
		shader.draw(pm.vbuf, pm.ibuf); // bind->drawTriangles->unbind
	}
}