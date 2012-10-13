
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import mikedotalmond.tri.Const;
import mikedotalmond.tri.PolygonManager;

import flash.display.StageQuality;
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DCompareMode;

import mikedotalmond.tri.Camera;
import mikedotalmond.tri.Polygon;
import mikedotalmond.tri.RadialPolygon;
import mikedotalmond.tri.geom.Vector;

import haxe.Log;
import net.hires.debug.Stats;


@:final class Shader extends format.hxsl.Shader {

	static var SRC = {
		
		var input : {
			pos 	: Float3, // xyz vertex position
			colour 	: Float4, // xyzw vertex colour
		};
		
		var tcolour : Float4; // vertex colour temporary register
		
		 /**
		  * 
		  * @param	mpos	position matrix
		  * @param	mproj	projection matrix
		  * @param 	t		time
		  * @param	fx		frequency x
		  * @param	fy		frequency y
		  * @param	amplitude
		  */
		function vertex( mpos : M44, mproj : M44, time:Float, fx:Float, fy:Float, amplitude:Float) {
			
			var p 		= pos.xyzw;
			var phase   = (p.x * fx + p.y * fy);
			
			p.z 		-= amplitude * sin(time + phase);
			
			out 		= p.xyzw * mpos * mproj;
			
			// read vertex colour so we can access it in the fragment
			tcolour 	= colour;
		}
		
		function fragment() {
			out = tcolour;
		}
	};

}


@:final class Test {

	var stage 		: Stage;
	var stage3D 	: Stage3D;
	var context3D	: Context3D;
	var shader 		: Shader;
	var t 			: Float;

	var camera 		: Camera;
	
	var positionMatrix:Matrix3D;
	var stats		:Stats;
	var polyManager	:PolygonManager;
	
	private var stageWidth:Int;
	private var stageHeight:Int;
	private var halfStageWidth:Int;
	private var halfStageHeight:Int;

	function new() {
		
		var current = flash.Lib.current;
		
		t 		= 0;
		stage 	= current.stage;
		stage3D = stage.stage3Ds[0];
		
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextReady );
		current.addEventListener(Event.ENTER_FRAME, update);
		
		stage3D.requestContext3D();
	}

	function onContextReady( _ ) {
		
		setup3D();
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.addChild(stats = new Stats());
		
		onResize(null);
	}
	
	private function setup3D() {
		
		context3D 		= stage3D.context3D;
		shader 			= new Shader(context3D);
		polyManager 	= new PolygonManager();
		positionMatrix 	= new Matrix3D();
		camera 			= new Camera(60, 1, 1, 0.02, 15);
		camera.up		= new Vector(0, 1, 0);
		camera.pos.z 	= 9;
		
		#if debug 
		context3D.enableErrorChecking = true;
		context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 0, false );
		#else 
		context3D.enableErrorChecking = false; 
		context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 4, false );//antialias=4
		#end
		
		polyManager.init();
		
		createPolygons();
		
		polyManager.alloc(context3D);
	}
	
	private function createPolygons() {
		var pm = polyManager;
		for (i in 0...46) {
			for (j in 0...25) {
				var poly = RadialPolygon.regularPolygon(16 + (i * j % 12) % 15, 0, 0x8032fa, pm);
				poly.setPosition( -5.625 + i/4, -3 + j/4);
				poly.scale = 0.1;
			}
		}
		
		Log.trace("polys: " + pm.polygons.length);
		Log.trace("tris: " + pm.triCount()); 
		
		// nexus7 - scaling and colouring 1150 regular polys...
		// 60fps, 12-13k triangles 
		// 60fps 18k tris after removing some XML GC in Stats.hx
		// 60fps ~26k tris after switching to domain memory for the vertex buffer
	}
	
	private function onResize(e:Event):Void {
		var w:Int = stage.stageWidth;
		var h:Int = stage.stageHeight;
		
		stageWidth  	= w;
		stageHeight 	= h;
		halfStageWidth 	= w >> 1;
		halfStageHeight = h >> 1;
		
		// update ui
		stats.x = w - stats.width;
		stats.y = h - stats.height;
		
		// update scene
		camera.ratio = w / h;
		camera.update();
	}

	function update(_) {
		if( context3D == null ) return;
		
		context3D.clear(0, 0, 0, 1);
		
		// allow alpha blending
		context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		// no depth test for now...
		context3D.setDepthTest( false, Context3DCompareMode.LESS_EQUAL );
		// don't draw back-faces
		context3D.setCulling(Context3DTriangleFace.BACK);
		
		
		var pm = polyManager;
		var poly = cast(pm.polyZero, RadialPolygon);
		while (poly != null) {
			//poly.rotation = Math.cos(t + poly.index % 13);
			//poly.translate(Math.sin(t)*0.0005*(poly.index%7),Math.cos(t/2)*0.0005*(poly.index%5),0);// = Math.cos(t + poly.index % 13);
			poly.outerColour.x += (Math.random() * 0.6 - poly.outerColour.x) * 0.5;
			poly.outerColour.y += (Math.random() * 0.6 - poly.outerColour.y) * 0.5;
			//poly.outerColour.z += (Math.random() * 0.5 - poly.outerColour.z) * 0.5;
			//poly.innerColour.set(Math.random(), Math.random(), Math.random(), 0);
			//poly.scale = 0.08 + Math.sin(t+poly.x*poly.y) * 0.01;// * Math.cos(t - 1 / t * t);
			poly.updateVertexBuffer();
			
			poly = cast poly.next;
		}
		
		//pm.updateAllBuffers();
		pm.uploadAll();
		
		//positionMatrix.identity();
		//positionMatrix.appendRotation(t * 10, flash.geom.Vector3D.Z_AXIS);
		
		var project = camera.m.toMatrix();
		
		var mouseX:Float = (stage.mouseX / stageWidth) - 0.5;
		var mouseY:Float = (stage.mouseY / stageHeight) - 0.5;
		
		t += 0.1 + 0.1 * mouseX;
		
		camera.zoom = 1.05 + mouseX * 0.1;
		camera.update();
		
		shader.init(
			{	mpos		: positionMatrix, 
				mproj		: project, 
				time		: t,
				fx			: mouseX * 2, 
				fy			: mouseY * 2, 
				amplitude	: 0.2 + mouseY
			},
			{  }
		);
		
		shader.bind(pm.vbuf);
		context3D.drawTriangles(pm.ibuf);
		context3D.present();
	}

	static function main() {
		
		Lib.current.stage.quality = StageQuality.LOW;
		Lib.current.stage.showDefaultContextMenu = false;
		
		haxe.Log.setColor(0xFF0000);
		
		var inst = new Test();
	}
}