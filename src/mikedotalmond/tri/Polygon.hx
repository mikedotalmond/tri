package mikedotalmond.tri;

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
	
	private var points 			:flash.Vector<Vector>;
	private var vertexColours 	:flash.Vector<Float4>;
	
	public var next				:Polygon = null;
	
	private var manager			:PolygonManager;
	
	public function new( points:flash.Vector<Vector>, manager:PolygonManager) {
		this.points 	= points;
		this.manager 	= manager;
		points.fixed 	= true;
		vIndex 			= manager.vCount;
		vbufIndex 		= manager.nextVBufferIndex;
		ibufIndex 		= manager.nextIBufferIndex;
		vertexCount		= points.length;
		
		manager.add(this);
	}
	
	public function prepareVertexBuffer() {
		var tbuf:ByteArray = manager.buf;
		var i = vbufIndex;
		tbuf.position = i;
		var n = vertexCount;
		for ( k in 0...n) {
			tbuf.writeFloat(.0);
			tbuf.writeFloat(.0);
			tbuf.writeFloat(.0);
			tbuf.writeFloat(.0);
			tbuf.writeFloat(.0);
			tbuf.writeFloat(.0);
			tbuf.writeFloat(.0);
		}
	}
	
	public function updateVertexBuffer() {
		var i = vbufIndex;
		var n = vertexCount;
		for ( k in 0...n ) {
			var p = points[k];
			Memory.setFloat(i, p.x); i += 4;
			Memory.setFloat(i, p.y); i += 4;
			Memory.setFloat(i, p.z); i += 4;
			var c = vertexColours[k];
			Memory.setFloat(i, c.x); i += 4;
			Memory.setFloat(i, c.y); i += 4;
			Memory.setFloat(i, c.z); i += 4;
			Memory.setFloat(i, c.w); i += 4;
		}
	}

	private inline function inlineTranslate( dx, dy, dz ) {
		for( p in points ) {
			p.x += dx;
			p.y += dy;
			p.z += dz;
		}
	}
	
	public function translate( dx, dy, dz ) {
		inlineTranslate(dx,dy,dz);
	}
	
	public function dispose():Void {
		if (points != null) {
			points.length = 0;
			points = null;
		}
		if (vertexColours != null) {
			vertexColours.length = 0;
			vertexColours = null;
		}
		manager = null;
	}
	
	
	public function addVColours() {
		throw "Not implemented for this polygon";
	}

}