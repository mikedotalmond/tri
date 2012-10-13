
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
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
		 */
		function vertex( mpos : M44, mproj : M44, t:Float ) {
			
			var p 			= pos.xyzw;	
			
			var xMix		= 1;
			var yMix		= 0.667;
			var phase   	= (p.x * xMix + p.y * yMix);
			var amplitude 	= 0.33;
			
			p.z 	-= amplitude * sin(t + phase);
			
			out 	= p.xyzw * mpos * mproj;
			
			tcolour = colour;
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
		
		context3D = stage3D.context3D;
		
		#if debug 
		context3D.enableErrorChecking = true;
		context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 0, false );
		#else 
		context3D.enableErrorChecking = false; 
		context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 4, false );//antialias=4
		#end
		
		polyManager = new PolygonManager();
		shader 		= new Shader(context3D);
		camera 		= new Camera(60, 1, 1, 0.02, 20);
		camera.up	= new Vector(0, 1, 0);
		positionMatrix = new Matrix3D();
		
		polyManager.init();
		
		createPolygons();
		
		polyManager.alloc(context3D);
		
		stage.showDefaultContextMenu = false;
		stage.addEventListener(Event.RESIZE, onResize);
		stage.quality = StageQuality.LOW;
		stats = new Stats();
		stage.addChild(stats);
		
		onResize(null);
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
		
		camera.ratio = w / h;
		camera.update();
		
		//polyManager.setStageSize(w,h);
		
		stats.x = w - stats.width;
		stats.y = h - stats.height;
	}

	function update(_) {
		if( context3D == null ) return;
		
		t += 0.05;
		
		context3D.clear(0, 0, 0, 1);
		
		context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		context3D.setDepthTest( false, Context3DCompareMode.LESS_EQUAL );
		context3D.setCulling(Context3DTriangleFace.NONE);
		
		//camera.update();
		
		var project = camera.m.toMatrix();
		var pm = polyManager;
		var poly = cast(pm.polyZero, RadialPolygon);
		while (poly != null) {
			//poly.rotation = Math.cos(t + poly.index % 13);
			//poly.translate(Math.sin(t)*0.0005*(poly.index%7),Math.cos(t/2)*0.0005*(poly.index%5),0);// = Math.cos(t + poly.index % 13);
			poly.outerColour.x += (Math.random() * 0.5 - poly.outerColour.x) * 0.5;
			poly.outerColour.y += (Math.random() * 0.5 - poly.outerColour.y) * 0.5;
			//poly.outerColour.z += (Math.random() * 0.5 - poly.outerColour.z) * 0.5;
			//poly.innerColour.set(Math.random(), Math.random(), Math.random(), 0);
			poly.scale = 0.08 + Math.sin(t+poly.index) * 0.01;// * Math.cos(t - 1 / t * t);
			poly.updateVertexBuffer();
			
			poly = cast poly.next;
		}
		
		//pm.updateAllBuffers();
		pm.uploadAll();
		
		//positionMatrix.identity();
		//positionMatrix.appendRotation(t * 10, flash.geom.Vector3D.Z_AXIS);
		
		
		shader.init(
			{ mpos : positionMatrix, mproj : project, t:t },
			{  }
		);
		
		shader.bind(pm.vbuf);
		context3D.drawTriangles(pm.ibuf);
		context3D.present();
	}

	static function main() {
		haxe.Log.setColor(0xFF0000);
		var inst = new Test();
	}
}