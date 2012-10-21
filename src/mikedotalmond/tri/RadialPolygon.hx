package mikedotalmond.tri;

import flash.Memory;
import mikedotalmond.tri.geom.Point;
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
	
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	
	private var _scale:Float = 1.0;
	public var scale(default, set_scale):Float = 1.0;
	
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
	public function new(edgeVertices:flash.Vector<Point>, centroid:Point, innerRGB:UInt, outerRGB:UInt, manager:PolygonManager) {
		
		edgeVertices.fixed = false;
		edgeVertices.unshift(centroid);
		
		var idxStart:Int = manager.vCount;
		
		super(edgeVertices, manager);
		
		var idx:ByteArray = manager.idx;
		idx.position = ibufIndex;
		
		var n = vertexCount - 1;
		// build triangle indices - all triangles start at the centroid, radiating out along the edge points
		for (i in 0...n) {
			idx.writeShort(idxStart);
			idx.writeShort(idxStart + 1 + i);
			idx.writeShort(idxStart + 1 + ((i + 1) % n));
		}
		
		innerColour = new Float4(); 
		outerColour = new Float4();
		Utils.rgbIntToFloat4(innerRGB, innerColour);
		Utils.rgbIntToFloat4(outerRGB, outerColour);
		
		addVColours();
	}
	
	/**
	 * @inheritDoc
	 */
	override public function addVColours() {
		if (vertexColours == null) vertexColours = new flash.Vector<Float4>();
		vertexColours.length = 0;
		vertexColours[0] = innerColour;
		for(i in 1...vertexCount) vertexColours[i] = outerColour;
		vertexColours.fixed = true;
	}
	
	
	/**
	 * public property get/set
	 * @return
	 */
	
	//private function get_position():Point { return centroid; }
	public function setPosition(x:Float=0, y:Float=0):Void {
		var tx = x - centroidX();
		var ty = y - centroidY();
		inlineTranslate(tx, ty);
	}
	
	private function get_x():Float { return  centroidX(); }
	private function set_x(value:Float):Float { 
		var dx = value - centroidX();
		inlineTranslate(dx, 0);
		return value;
	}
	
	private function get_y():Float { return centroidY(); }
	private function set_y(value:Float):Float { 
		var dy = value - centroidY();
		inlineTranslate(0, dy);
		return value;
	}
	
	public inline function centroidX() {
		return Memory.getFloat(vbufIndex);
	}
	public inline function centroidY() {
		return Memory.getFloat(vbufIndex + 4);
	}
	
	private function set_scale(value:Float):Float {
		var change = value / _scale;
		_scaleBy(change);
		return _scale = value;
	}
	
	public function scaleAbout(value:Float, x:Float, y:Float) {
		var change = value / _scale;
		
		var tx, ty;
		var i = vbufIndex + 28; // skip vertex 0
		var pts = points;
		var p;
		for (j in 1...vertexCount) {
			p 	= pts[j];
			tx 	= Utils.lerp(p.x, x, value);
			ty 	= Utils.lerp(p.y, y, value);
			
			Memory.setFloat(i, tx); i += 4; //x
			Memory.setFloat(i, ty); i += 24; //y + skip z
		}
		
		_scale = value;
	}
	
	private inline function _scaleBy(value:Float) {
		
		var x = centroidX();
		var y = centroidY();
		var tx, ty;
		var i = vbufIndex + 28; // skip vertex 0
		
		for (j in 1...vertexCount) {
			tx = Memory.getFloat(i);
			ty = Memory.getFloat(i + 4);
			
			tx 	= Utils.lerp(tx, x, value);
			ty 	= Utils.lerp(ty, y, value);
			
			Memory.setFloat(i, tx); i += 4; //x
			Memory.setFloat(i, ty); i += 24; //y + skip z
		}
	}
	
	override public function updateVertexColours() {
		var tx, ty;
		
		var i = vbufIndex + 12; // skip vertex 0 xyz
		var c = innerColour;
		Memory.setFloat(i, c.x); i += 4; //x
		Memory.setFloat(i, c.y); i += 4; //y
		Memory.setFloat(i, c.z); i += 4; //z
		Memory.setFloat(i, c.w); i += 16; //w - + xyz
		c = outerColour;
		for (j in 1...vertexCount) {
			Memory.setFloat(i, c.x); i += 4; //x
			Memory.setFloat(i, c.y); i += 4; //y
			Memory.setFloat(i, c.z); i += 4; //z
			Memory.setFloat(i, c.w); i += 16; //w - + xyz
		}
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
		var j = vbufIndex + 28;
		var cX = centroidX();
		var cY = centroidY();
		var ct = Math.cos(angleDelta);
		var st = Math.sin(angleDelta);
		
		var n = vertexCount;
		for (i in 1...n) {
			
			var dX,dY;
			dX = Memory.getFloat(j);
			dY = Memory.getFloat(j + 4);
			
			var tx = dX - cX;
			var ty = dY - cY;
			dX = (tx * ct - ty * st) + cX;
			dY = (tx * st + ty * ct) + cY;
			
			Memory.setFloat(j, dX); j += 4; //x
			Memory.setFloat(j, dY); j += 24; //y - skip z + colours
		}
	}
	
	
	/**
	 * 
	 * @param	?edgeCount
	 * @param	?innerRGB
	 * @param	?outerRGB
	 * @return
	 */
	public static function regularPolygon(?edgeCount:Int = 6, ?innerRGB:UInt, ?outerRGB:UInt, manager:PolygonManager, ?x=.0, ?y=.0, ?size=1.0):RadialPolygon {
		if (edgeCount < 3) return null;
		
		var t	:Float = Const.TwoPi / edgeCount;
		var v	:flash.Vector<Point> = new flash.Vector<Point>();
		
		for (i in 0...edgeCount) v.unshift(new Point(x + Math.sin(Math.PI + i * t) * size, y + Math.cos(Math.PI + i * t) * size));
		
		return new RadialPolygon(v, new Point(x,y), innerRGB, outerRGB, manager);
	}
}