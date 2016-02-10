precision highp float;

varying vec2      outTex;	// texture coords of row/column to calculate
uniform sampler2D X;		// texture with data from padded X
uniform float     N;		// number of columns
uniform float     pad;		// additional columns to nearest multiple of four
uniform float     N_in;		// number of columns (input)
uniform float     pad_in;	// additional columns to nearest multiple of four (input)
uniform float     offset;


#pragma glslify: fix_pad = require(./fix_pad)


void main(void) {

	// get the implied row and column from .y and .x of passed (output)
	// texture coordinate. These map directly to input texture space when
	// the relevant dimensions are the same.
	float row_t = outTex.y;
	float col_t = outTex.x;
	float col = (col_t * (N + pad) - 2.0); // index of first element in pixel (output matrix space)

	vec4 x;
	float pixel_part = mod(offset, 4.0);
	// are we in the middle of an input pixel?
	if(offset == 0.0 || pixel_part == 0.0){
		// no, take the whole thing
		x = texture2D( X, vec2((col + 2.0 + offset - pixel_part) / (N_in + pad_in) , row_t));
	} else {
		// yes, straddle pixels
		vec4 x0, x1;
		x0 = texture2D( X, vec2((col + 2.0 + offset - pixel_part) / (N_in + pad_in) , row_t));
		x1 = texture2D( X, vec2((col + 6.0 + offset - pixel_part) / (N_in + pad_in) , row_t));

		if(pixel_part == 1.0){
			x.rgb = x0.gba;
			x.a = x1.r;
		} else if(pixel_part == 2.0){
			x.rg = x0.ba;
			x.ba = x1.rg;
		} else if(pixel_part == 3.0){
			x.r = x0.a;
			x.gba = x1.rgb;
		}
	}

	// fix padded region
	if(pad > 0.0 && col + 4.0 > N ) {
		fix_pad(x, int(pad));
	}

	gl_FragColor = x;
}
