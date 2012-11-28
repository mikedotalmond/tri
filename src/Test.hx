
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display.StageQuality;
import flash.display3D.Context3D;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import mikedotalmond.tri.SharedStage3DContext;

import flash.Lib;
import haxe.Log;
import haxe.Timer;

import mikedotalmond.tri.Camera;
import mikedotalmond.tri.PolygonManager;
import mikedotalmond.tri.RadialPolygon;
import mikedotalmond.tri.Scene;
import mikedotalmond.tri.shaders.VertexWaveShader;

import net.hires.debug.Stats;



@:final class Test {

	
	private var scene			:Scene;
	private var lastTime		:Float = 0;
	private var sharedContext	:SharedStage3DContext;

	function new() {
		sharedContext = new SharedStage3DContext(Lib.current.stage);
		sharedContext.ready.addOnce(onContextReady);
	}
	
	function onContextReady() {
		scene = new Scene(sharedContext);
		scene.createPolygons.add(createPolygons);
		scene.ready.add(sceneReady);
		scene.createScene();
	}
	
	private function sceneReady() {
		var current = flash.Lib.current;
		current.stage.addEventListener(MouseEvent.DOUBLE_CLICK, rebuild);
		current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function rebuild(e:MouseEvent):Void {
		var current = flash.Lib.current;
		current.stage.removeEventListener(Event.ENTER_FRAME, update);
		current.stage.removeEventListener(MouseEvent.DOUBLE_CLICK, rebuild);
		scene.createScene();
	}
	
	private function createPolygons(scene:Scene) {
		var pm = scene.polyManager;
		for (i in 0...46) {
			for (j in 0...25) {
				var x, y;
				x 		= -5.625 + i / 4;
				y 		= -3 + j / 4;
				RadialPolygon.regularPolygon(14 + (i * j % 12) % 15, 0, 0x0082ff, pm, x, y, 0.1);
			}
		}
		
		Log.trace("polys: " + pm.polygons.length);
		Log.trace("tris: " + pm.triCount());
		
		// nexus7 - scaling and colouring 1150 regular polys...
		// 60fps, 12-13k triangles
		// 60fps 18k tris after removing some XML GC in Stats.hx
		// 60fps ~26k tris after switching to domain memory for the vertex buffer
	}

	private function update(_) {
		
		var pm		= scene.polyManager;
		var t 		= Timer.stamp();
		var dt 		= t - lastTime;
		lastTime 	= t;
		
		var poly:RadialPolygon 	= cast pm.polyZero; // get the first poly in the list
		
		while (poly != null) {
			var pid = 0.00022 * (poly.index % 7);
			
			poly.outerColour.z += (Math.random() - poly.outerColour.z) * 0.5;
			//poly.innerColour.set(Math.random(), Math.random(), Math.random(), 0.5);
			poly.updateVertexColours();
			
			//poly.rotation = Math.cos(t + poly.index % 13);
			poly.translate(Math.sin(t)*pid,Math.cos(t/2)*pid);// = Math.cos(t + poly.index % 13);
			poly.scale = 0.7 + Math.sin(t*poly.index%6 + 2 * pid % (poly.x + poly.y)) * 0.25;// * Math.cos(t - 1 / t * t);
			
			poly = cast poly.next;
		}
		
		sharedContext.update(dt*5, t);
	}

	
	
	static function main() {
		
		Lib.current.stage.quality = StageQuality.LOW;
		Lib.current.stage.showDefaultContextMenu = false;
		Lib.current.stage.doubleClickEnabled = true;
		
		haxe.Log.setColor(0xFF0000);
		
		var inst = new Test();
	}
}