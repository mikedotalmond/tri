
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display3D.Context3D;
import flash.events.ErrorEvent;
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



@:final class Main {
	
	private var scene			:Scene;
	private var lastTime		:Float = 0;
	private var sharedContext	:SharedStage3DContext;

	function new() {
		sharedContext = new SharedStage3DContext(Lib.current.stage);
		sharedContext.ready.addOnce(onContextReady);
		sharedContext.contextLost.add(onContextLost);
		sharedContext.contextError.add(onContextError);
		
		// Test context loss... causes context loss - 
		// the entire scene is then disposed and restarted with a new Context3D
		Lib.current.stage.doubleClickEnabled = true;
		Lib.current.stage.addEventListener(MouseEvent.DOUBLE_CLICK, function(_) {
			sharedContext.context3D.dispose();
		});
	}
	
	
	function onContextReady() {
		scene = new Scene(sharedContext);
		scene.createPolygons.add(createPolygons);
		scene.ready.add(sceneReady);
		scene.createScene();
	}
	
	
	private function onContextLost():Void {
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
		scene.dispose();
		scene = null;
		sharedContext.ready.addOnce(onContextReady);
	}
	
	
	/**
	 * There was an error creating a context3D - check wmode is set to 'direct'
	 * @param	e
	 */
	private function onContextError(e:ErrorEvent) {
		trace("onContextError");
		trace(e.toString());
	}
	
	
	/**
	 * triggered by the scene.ready signal when a scene has been created, buffers filled, and it's ready to render
	 */
	private function sceneReady() {
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	
	/**
	 * trigger scene rebuild
	 * @param	e
	 */
	private function rebuild(e:MouseEvent):Void {
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
		scene.createScene();
	}
	
	
	/**
	 * Called from the scene.createPolygons signal when the scene is ready to build the buffers
	 * @param	scene - The calling scene
	 */
	private function createPolygons(scene:Scene):Void {
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

	
	/**
	 * frame-tick
	 * @param	_
	 */
	private function update(_) {
		
		// do other processing....
		
		// ....
		
		
		// update all the polygons
		
		var pm		= scene.polyManager;
		var t 		= Timer.stamp();
		var dt 		= t - lastTime;
		lastTime 	= t;
		
		var poly:RadialPolygon 	= cast pm.polyZero; // get the first poly in the list
		
		while (poly != null) {
			
			var pid = 0.00022 * (poly.index % 7);
			
			// update colour, position, and scale on each poly...
			
			poly.outerColour.z += (Math.random() - poly.outerColour.z) * 0.5;
			//poly.innerColour.set(Math.random(), Math.random(), Math.random(), 0.5);
			poly.updateVertexColours();
			
			//poly.rotation = Math.cos(t + poly.index % 13);
			poly.translate(Math.sin(t)*pid,Math.cos(t/2)*pid);// = Math.cos(t + poly.index % 13);
			poly.scale = 0.7 + Math.sin(t*poly.index%6 + 2 * pid % (poly.x + poly.y)) * 0.25;// * Math.cos(t - 1 / t * t);
			
			poly = cast poly.next;
		}
		
		// call sharedContext.update(frameDelta, time) in your main enterframe function, it will...
		// > clear the context
		// > trigger the render for all observers of the sharedContext.requestDraw signal (the scene registers to this signal when created)
		// > and present the new scene
		sharedContext.update(dt * 5, t);
	}

	
	
	static function main() {
		
		var stage 		= Lib.current.stage;
		stage.align 	= StageAlign.TOP_LEFT;
		stage.scaleMode	= StageScaleMode.NO_SCALE;
		stage.quality 	= StageQuality.LOW;
		
		stage.showDefaultContextMenu = false;
		stage.doubleClickEnabled = true;
		
		haxe.Log.setColor(0xFF0000);
		
		var inst = new Main();
	}
}