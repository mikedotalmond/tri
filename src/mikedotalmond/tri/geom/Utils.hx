package mikedotalmond.tri.geom;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class Utils {

	
	public static inline function lerp(a:Float, b:Float, f:Float):Float {
		return b + (a - b) * f;
	}
	
	
	/**
	 * rotate a 2d (x,y) vector position around another by a theta radians
	 * @param	cX
	 * @param	cY
	 * @param	v
	 * @param	theta
	 */
	public static inline function rotateVector2D(cX:Float, cY:Float, position:Vector, theta:Float) {
		var tx = position.x - cX;
		var ty = position.y - cY;
		var ct = Math.cos(theta);
		var st = Math.sin(theta);
		position.x = (tx * ct - ty * st) + cX;
		position.y = (tx * st + ty * ct) + cY;
	}
	
	
	
	public static function rgbIntToFloat4(rgb:Int):Float4 {
		return new Float4(((rgb & 0xff0000) >> 16) / 0xff, ((rgb & 0xff00) >> 8) / 0xff, (rgb & 0xff) / 0xff, 1.0);
	}
}