package mikedotalmond.tri.shaders;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

@:final class DefaultShader extends format.hxsl.Shader {

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
		  */
		function vertex( mpos : M44, mproj : M44) {
			out 		= pos.xyzw * mpos * mproj;
			// read vertex colour so we can access it in the fragment
			tcolour 	= colour;
		}
		
		function fragment() {
			out = tcolour;
		}
	};

}