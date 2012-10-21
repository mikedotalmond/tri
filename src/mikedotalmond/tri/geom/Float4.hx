package mikedotalmond.tri.geom;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class Float4 {
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;

	public function new(x=.0,y=.0,z=.0,w=.0) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}	
	
	public inline function set(x,y,z,w) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public inline function setFrom(source:Float4) {
		this.x = source.x;
		this.y = source.y;
		this.z = source.z;
		this.w = source.w;
	}
	
	public inline function setInt(colour:Int) {
		Utils.rgbIntToFloat4(colour, this);
	}
}