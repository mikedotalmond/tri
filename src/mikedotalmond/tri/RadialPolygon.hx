package mikedotalmond.tri;

import flash.utils.ByteArray;
import mikedotalmond.tri.geom.Float4;
import mikedotalmond.tri.geom.Utils;
import mikedotalmond.tri.geom.Vector;


/*
 * A polygon in which all triangles radiate from the centroid
 * 
 * */
@:final class RadialPolygon extends Polygon {
	
	
	public var innerColour(default, null):Float4;
	public var outerColour(default, null):Float4;
	
	public var scale(default, set_scale):Float = 1;
	
	public var position(get_position, never):Vector;
	public var centroid(default, null):Vector;
	
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	
	private var _rotation:Float = 0;
	public var rotation(default, set_rotation):Float;

	/**
	 * 
	 * @param	edgeVertices
	 * @param	centroid
	 * @param	innerRGB
	 * @param	outerRGB
	 * @param	manager
	 */
	public function new(edgeVertices:flash.Vector<Vector>, centroid:Vector, innerRGB:UInt, outerRGB:UInt, manager:PolygonManager) {
		
		edgeVertices.unshift(this.centroid = centroid);
		
		var idxStart:Int = manager.vCount;
		
		super(edgeVertices, manager);
		
		var idx:ByteArray = manager.idx;
		idx.position = ibufIndex;
		
		var n = points.length - 1;
		// build triangle indices - all triangles start at the centroid, radiating out along the edge points
		for (i in 0...n) {
			idx.writeShort(idxStart);
			idx.writeShort(idxStart + 1 + i);
			idx.writeShort(idxStart + 1 + ((i + 1) % n));
		}
		
		innerColour = Utils.rgbIntToFloat4(innerRGB);
		outerColour = Utils.rgbIntToFloat4(outerRGB);
		
		addVColours();
	}
	
	/**
	 * @inheritDoc
	 */
	override public function addVColours() {
		if (vertexColours == null) vertexColours = new flash.Vector<Float4>();
		vertexColours.length = 0;
		vertexColours[0] = innerColour;
		for(i in 1...points.length) vertexColours[i] = outerColour;
		vertexColours.fixed = true;
	}
	
	
	/**
	 * public property get/set
	 * @return
	 */
	
	private function get_position():Vector { return centroid; }
	public function setPosition(x:Float=0, y:Float=0):Void {
		var reference = centroid;
		var tx = x - reference.x;
		var ty = y - reference.y;
		inlineTranslate(tx, ty, 0);
	}
	
	
	private function get_x():Float { return  centroid.x; }
	private function set_x(value:Float):Float { 
		inlineTranslate(x - centroid.x, 0, 0);
		return centroid.x;
	}
	
	
	private function get_y():Float { return  centroid.y; }
	private function set_y(value:Float):Float { 
		inlineTranslate(y - centroid.y, 0, 0);
		return centroid.y;
	}
	
	
	private function set_scale(value:Float):Float {
		var ds = value / scale;
		var cX = centroid.x;
		var cY = centroid.y;
		for(i in 1...points.length){
			var v = points[i];
			v.x = Utils.lerp(v.x, cX, ds);
			v.y = Utils.lerp(v.y, cY, ds);
		}
		return scale = value;
	}
	
	
	private function set_rotation(angle:Float):Float {
		var dt = angle - _rotation;
		rotatePoints(dt);
		_rotation = angle;
		return angle;
	}
	
	/**
	 * 
	 * @param	angleDelta
	 */
	private inline function rotatePoints(angleDelta:Float) {
		var cX:Float = centroid.x;
		var cY:Float = centroid.y;
		var n = points.length;
		for (i in 1...n) {
			Utils.rotateVector2D(cX, cY, points[i], angleDelta);
		}
	}
	
	
	/**
	 * 
	 * @param	?edgeCount
	 * @param	?innerRGB
	 * @param	?outerRGB
	 * @return
	 */
	public static function regularPolygon(?edgeCount:Int = 6, ?innerRGB:UInt, ?outerRGB:UInt, manager:PolygonManager):RadialPolygon {
		if (edgeCount < 3) return null;
		
		var t	:Float = Const.TwoPi / edgeCount;
		var v	:flash.Vector<Vector> = new flash.Vector<Vector>();
		
		for (i in 0...edgeCount) v.unshift(new Vector(Math.sin(Math.PI + i * t), Math.cos(Math.PI + i * t)));
		
		return new RadialPolygon(v, new Vector(), innerRGB, outerRGB, manager);
	}
}