package mikedotalmond.tri;

@:final class Const {

	public static inline var EPSILON			:Float = 1e-10;
	
	public static inline var FourPi				:Float = Math.PI * 4;
	public static inline var TwoPi				:Float = Math.PI * 2;
	public static inline var HalfPi				:Float = Math.PI / 2;
	
	public static inline var Sqrt2				:Float = 1.4142135623731;
	public static inline var Sqrt1_2			:Float = 0.707106781186548;
	
	public static inline var Log2e				:Float = 1.44269504088896;
	public static inline var Log10e				:Float = 0.434294481903252;
	
	public static inline var e					:Float = 2.71828182845905;
	public static inline var Ln2				:Float = 0.693147180559945;
	public static inline var Ln10				:Float = 2.30258509299405;
	
	public static inline var DegToRad			:Float = 0.01745329251; // Pi / 180;
	public static inline var RadToDeg			:Float = 57.2957795131; // 180 / Pi;
	
	public static inline var MinValue			:Float = 4.94065645841247e-324; // 
	public static inline var MaxValue			:Float = 1.79769313486231e+308;
	
	public static inline function toRadians(deg:Float):Float { return deg * DegToRad; }
	public static inline function toDegrees(rad:Float):Float { return rad * RadToDeg; }

	// round to 4 significant digits, eliminates <1e-10
	public static function f( v : Float ) {
		var neg;
		if( v < 0 ) {
			neg = -1.0;
			v = -v;
		} else
			neg = 1.0;
		var digits = Std.int(4 - Math.log(v) / Math.log(10));
		if( digits < 1 )
			digits = 1;
		else if( digits >= 10 )
			return 0.;
		var exp = Math.pow(10,digits);
		return Math.floor(v * exp + .49999) * neg / exp;
	}

}