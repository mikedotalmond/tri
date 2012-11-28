package mikedotalmond.tri.geom;
import mikedotalmond.tri.geom.Point;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class Utils {

	
	public static inline function lerp(a:Float, b:Float, f:Float):Float {
		return b + (a - b) * f;
	}
	
	/**
	*   Get the next-highest power of two
	*   @param v Value to get the next-highest power of two from
	*   @return The next-highest power of two from the given value
	*/
	public static function nextPowerOfTwo(v:UInt): UInt {
		v--;
		v |= v >> 1;
		v |= v >> 2;
		v |= v >> 4;
		v |= v >> 8;
		v |= v >> 16;
		v++;
		return v;
	}
	
	/**
	 * rotate a 2d (x,y) position around another by a theta radians
	 * @param	cX
	 * @param	cY
	 * @param	v
	 * @param	theta
	 */
	public static inline function rotateVector2D(cX:Float, cY:Float, dX:Float, dY:Float, theta:Float) {
		var tx = dX - cX;
		var ty = dY - cY;
		var ct = Math.cos(theta);
		var st = Math.sin(theta);
		dX = (tx * ct - ty * st) + cX;
		dY = (tx * st + ty * ct) + cY;
	}
	
	/**
	 * Take an RGB Int and set xyz - w (alpha) is set to 1.0
	 * @param	rgb
	 * @param	target
	 */
	public static inline function rgbIntToFloat4(rgb:Int, target:Float4) {
		target.set(
			((rgb & 0xff0000) >> 16) / 0xff,
			((rgb & 0xff00) >> 8) / 0xff,
			(rgb & 0xff) / 0xff,
			1.0			
		);
	}
	
	/**
	 * Take an ARGB Int and set xyzw 
	 * @param	argb
	 * @param	target
	 */
	public static inline function argbIntToFloat4(argb:Int, target:Float4) {
		target.set(
			((argb & 0xff0000) >> 16) / 0xff, // R -> x
			((argb & 0xff00) >> 8) / 0xff, // G -> y
			(argb & 0xff) / 0xff, // B -> z
			((argb & 0xff000000) >> 24) / 0xff //A -> w		
		);
	}
	
	/**
	 * Take an RGBA Int and set xyzw 
	 * @param	argb
	 * @param	target
	 */
	public static inline function rgbaIntToFloat4(rgba:Int, target:Float4) {
		target.set(
			((rgba & 0xff000000) >> 24) / 0xff, //R -> x		
			((rgba & 0xff0000) >> 16) / 0xff, // G -> y
			((rgba & 0xff00) >> 8) / 0xff, // B -> w
			(rgba & 0xff) / 0xff // A -> z
		);
	}
}