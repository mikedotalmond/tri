package mikedotalmond.tri;

import mikedotalmond.tri.geom.Point;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.Memory;

import mikedotalmond.tri.Polygon;

import flash.utils.ByteArray;
import flash.utils.Endian;

import mikedotalmond.tri.geom.Float4;
import mikedotalmond.tri.geom.Vector;


class Polygon {
	
	public var index(default, default):Int = -1;
	public var vertexCount(default, null):Int;
	public var ibufIndex(default, null):Int;
	public var vbufIndex(default, null):Int;
	public var vIndex(default, null):Int;
	
	public var next				:Polygon = null;
	
	private var vertexColours 	:flash.Vector<Float4>;
	private var points		 	:flash.Vector<Point>;
	
	private var manager			:PolygonManager;

	public function new(points:flash.Vector<Point>, manager:PolygonManager) {
		
		this.manager 	= manager;
		vIndex 			= manager.vCount;
		vbufIndex 		= manager.nextVBufferIndex;
		ibufIndex 		= manager.nextIBufferIndex;
		vertexCount		= points.length;
		
		prepareVertexBuffer(points);
		
		manager.add(this);
	}
	
	// allocate the vertex buffer bytearray and set initial positipon values
	private function prepareVertexBuffer(points:flash.Vector<Point>) {
		points.fixed 	= true;
		
		var tbuf:ByteArray = manager.buf;
		var i = vbufIndex;
		tbuf.position = i;
		var n = vertexCount;
		for ( k in 0...n) {
			var p = points[k];
			tbuf.writeFloat(p.x);
			tbuf.writeFloat(p.y);
			tbuf.writeFloat(.0); //z
			//
			tbuf.writeFloat(.5);//r
			tbuf.writeFloat(.5);//g
			tbuf.writeFloat(.5);//b
			tbuf.writeFloat(1);//a
		}
		
		this.points = points;
	}
	
	public function updateVertexColours() {
		throw "Not implemented for this polygon";
	}
	
	private inline function inlineTranslate( dx, dy ) {
		var i = vbufIndex;
		for ( j in 0...vertexCount ) {
			var x = Memory.getFloat(i) + dx;
			var y = Memory.getFloat(i + 4) + dy;
			Memory.setFloat(i, x); i += 4;
			Memory.setFloat(i, y); i += 24;
		}
	}
	
	public function translate( dx, dy) {
		inlineTranslate(dx, dy);
	}
	
	public function dispose():Void {
		
		if (vertexColours != null) {
			vertexColours.fixed = false;
			vertexColours.length = 0;
			vertexColours = null;
		}
		
		if (points != null) {
			points.fixed = false;
			points.length = 0;
			points = null;
		}
		
		manager = null;
	}
	
	
	public function addVColours() {
		throw "Not implemented for this polygon";
	}
}