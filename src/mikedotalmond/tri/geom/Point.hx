package mikedotalmond.tri.geom;

import flash.Lib;

/**
 * An Indexable x,y Point
 *
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class Point  {
	
	static private var Index:Int = 0;
	
	static private function nextIndex():Int {
		Point.Index++;
		if (Point.Index == 2147483647) { //2147483647 = 0x7FFFFFFF = max value of a signed 32-bit int
			Lib.trace("Point index wrapped around at 2147483647 - that's a lot of points.");
			Point.Index = 0;
		}
		return Point.Index;
	}
	
	/**
	 *
	 * @param	pt1
	 * @param	pt2
	 * @param	f
	 * @return	new Point
	*/
	public static inline function interpolate(pt1:Point, pt2:Point, f:Float) : Point {
		return new Point(pt2.x + f * (pt1.x - pt2.x), pt2.y + f * (pt1.y - pt2.y));
	}
	
	/**
	 * Similar to Point.interpolate, except you pass in the target for the interpolated point rather than create a new instance.
	 * @see Point.interpolate
	 * @param	pt1
	 * @param	pt2
	 * @param	target
	 * @param	f
	*/
	public static inline function interpolateTo(pt1:Point, pt2:Point, target:Point, f:Float):Void {
		target.x = pt2.x + f * (pt1.x - pt2.x);
		target.y = pt2.y + f * (pt1.y - pt2.y);
	}
	
	/**
	 *
	 * @param	pt1
	 * @param	pt2
	 * @return
	 */
	public static inline function distance(pt1:Point,pt2:Point):Float {
		return Math.sqrt(distanceSquared(pt1, pt2));
	}
	
	/**
	 * Use if you can make do with distance*distance, to avoid a sqrt calculation
	 * @param	pt1
	 * @param	pt2
	 * @return	
	 */
	public static inline function distanceSquared(pt1:Point,pt2:Point):Float {
		var dx = pt1.x - pt2.x;
		var dy = pt1.y - pt2.y;
		return dx * dx + dy * dy;
	}
	
	//
	
	private var _index:Int;
	public var index(get_index, never):Int;
	private function get_index():Int { return _index; }
	
	public var x:Float;
	public var y:Float;
	
	public function new(?x:Float=0, ?y:Float=0) {
		_index = Point.nextIndex();
		this.x = x;
		this.y = y;
	}
	
	/**
	 * 
	 * @param	compare		  - Point to compare against
	 * @param	?reallyEquals - if true the test is against the index value for the two points.
	 * @return
	 */
	public function equals(compare:Point, ?reallyEquals:Bool=true):Bool {
		return reallyEquals ? (_index == compare.index) : (this.x == compare.x && this.y == compare.y);
	}
	
	public function set(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}