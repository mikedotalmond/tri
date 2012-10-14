package mikedotalmond.tri;

import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.Memory;

import flash.utils.ByteArray;
import flash.utils.Endian;

import mikedotalmond.tri.geom.Float4;
import mikedotalmond.tri.geom.Vector;
import mikedotalmond.tri.Polygon;


@:final class PolygonManager {
	
	public static inline var floatsPerVertex:Int = 7;
	
	public var ibuf 			:IndexBuffer3D;
	public var vbuf 			:VertexBuffer3D;
	public var vCount			:Int = 0;
	public var nextIBufferIndex	:Int = 0;
	public var nextVBufferIndex	:Int = 0;
	
	public var buf				:ByteArray;
	public var idx 				:ByteArray;
	public var polygons(default, null):flash.Vector<Polygon>;
	
	public var polyZero(get_polyZero, null):Polygon;
	private function get_polyZero() { return polygons[0]; }
	
	public function new() {
		
	}
	
	public function init() {
		disposePolygons();
		
		polygons 		= new flash.Vector<Polygon>();
		idx 			= new ByteArray();
		buf 			= new ByteArray();
		idx.endian 		= Endian.LITTLE_ENDIAN;
		buf.endian 		= Endian.LITTLE_ENDIAN;
	}
	
	public function add(poly:Polygon):Void {
		vCount 				+= poly.vertexCount;
		nextIBufferIndex 	+= (poly.vertexCount << 1) * 3;
		nextVBufferIndex 	+= (poly.vertexCount << 2) * floatsPerVertex;
		if (polygons.length > 0) polygons[polygons.length - 1].next = poly;
		
		poly.index = polygons.length;
		polygons.push(poly);
	}
	
	
	public function alloc( c : Context3D ) {
		disposeBuffers();
		
		polygons.fixed = true;
		
		ibuf = c.createIndexBuffer(idx.length >> 1);
		ibuf.uploadFromByteArray(idx, 0, 0, idx.length >> 1);
		
		vbuf = c.createVertexBuffer(vCount, floatsPerVertex);
		
		prepareAllbuffers(); //fill the vertex bytearray
		Memory.select(buf);  // select the vertex bytearray for fast memory access. All buffer updates are set using Memory.setFloat
	}
	
	public function prepareAllbuffers() {
		var poly = polygons[0];
		while (poly != null) {
			poly.prepareVertexBuffer();
			poly = poly.next;
		}
	}
	
	public function updateAllBuffers() {
		var poly = polygons[0];
		while (poly != null) {
			poly.updateVertexBuffer();
			poly = poly.next;
		}
	}
	
	public inline function uploadAll() {
		vbuf.uploadFromByteArray(buf, 0, 0, vCount);
	}
	
	public inline function uploadPoly(poly:Polygon) {
		vbuf.uploadFromByteArray(buf, poly.vbufIndex, poly.vIndex, poly.vertexCount);
	}
	
	public inline function triCount() {
		return Std.int((idx.length >> 1) / 3);
	}
	
	private function disposeBuffers() {
		if( ibuf != null ) { ibuf.dispose(); ibuf = null; }
		if( vbuf != null ) { vbuf.dispose(); vbuf = null; }
	}
	
	private function disposePolygons() {
		if ( polygons != null ) { 
			for (poly in polygons) {
				poly.dispose();
			}
			polygons.fixed  = false;
			polygons.length = 0;
			polygons = null;
		}
		
		nextVBufferIndex = nextIBufferIndex = vCount = 0;
	}
}