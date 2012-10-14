
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display.StageQuality;
import flash.display3D.Context3D;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;

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

	
	private var scene	:Scene;
	private var lastTime:Float = 0;

	function new() {
		
		scene = new Scene();
		scene.createPolygons.add(createPolygons);
		scene.ready.add(sceneReady);
		scene.init();
		
	}
	
	private function sceneReady() {
		var current = flash.Lib.current;
		current.stage.addEventListener(MouseEvent.DOUBLE_CLICK, rebuild);
		current.addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function rebuild(e:MouseEvent):Void {
		var current = flash.Lib.current;
		current.removeEventListener(Event.ENTER_FRAME, update);
		current.stage.removeEventListener(MouseEvent.DOUBLE_CLICK, rebuild);
		scene.createScene();
	}
	
	private function createPolygons() {
		var pm = scene.polyManager;
		for (i in 0...46) {
			for (j in 0...25) {
				var poly = RadialPolygon.regularPolygon(15 + (i * j % 12) % 15, 0, 0x8032fa, pm);
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

	function update(_) {
		
		var s 		= scene;
		var pm		= s.polyManager;
		var t 		= Timer.stamp();
		var dt 		= t - lastTime;
		lastTime 	= t;
		
		var poly:RadialPolygon 	= cast pm.polyZero; // get the first poly in the list
		
		while (poly != null) {
			var pid = 0.00021 * (poly.index % 7);
			//poly.rotation = Math.cos(t + poly.index % 13);
			poly.translate(Math.sin(t)*pid,Math.cos(t/2)*pid,0);// = Math.cos(t + poly.index % 13);
			poly.outerColour.x += (Math.random() * 0.6 - poly.outerColour.x) * 0.5;
			poly.outerColour.y += (Math.random() * 0.6 - poly.outerColour.y) * 0.5;
			//poly.outerColour.z += (Math.random() * 0.5 - poly.outerColour.z) * 0.5;
			//poly.innerColour.set(Math.random(), Math.random(), Math.random(), 0);
			poly.scale = 0.08 + Math.sin(t*(poly.x+poly.y)) * 0.01;// * Math.cos(t - 1 / t * t);

			poly.updateVertexBuffer();
			// if a poly is updated and you want to see that change (position, scale, rotation, colour) you have to update the vertex buffer
			
			poly = cast poly.next;
		}
		
		s.update(dt * 5);
	}

	
	
	static function main() {
		
		Lib.current.stage.quality = StageQuality.LOW;
		Lib.current.stage.showDefaultContextMenu = false;
		Lib.current.stage.doubleClickEnabled = true;
		
		haxe.Log.setColor(0xFF0000);
		
		var inst = new Test();
	}
}