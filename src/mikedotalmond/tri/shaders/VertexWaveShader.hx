package mikedotalmond.tri.shaders;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class VertexWaveShader extends format.hxsl.Shader {

	static var SRC = {
		
		var input : {
			pos 	: Float3, // xyz vertex position
			colour 	: Float4, // xyzw vertex colour
		};
		
		var tcolour : Float4; // vertex colour temporary register
		
		 /**
		  * 
		  * @param	mpos	position matrix
		  * @param	mproj	projection matrix
		  * @param 	t		time
		  * @param	fx		frequency x
		  * @param	fy		frequency y
		  * @param	amplitude
		  */
		function vertex( mpos : M44, mproj : M44, time:Float, fx:Float, fy:Float, amplitude:Float) {
			
			var p 		= pos.xyzw;
			
			var phase   = (p.x * fx + p.y * fy);			
			p.z 		+= amplitude * -sin(time + phase);
			p.x 		+= amplitude * cos(time + phase);
			p.y 		+= amplitude * sin(time + phase);
			
			out 		= p.xyzw * mpos * mproj;
			
			// read vertex colour so we can access it in the fragment
			tcolour 	= colour;
		}
		
		function fragment() {
			out = tcolour;
		}
		
	};
}