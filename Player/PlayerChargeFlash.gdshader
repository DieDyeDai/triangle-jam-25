shader_type canvas_item;

uniform float strength;
uniform float start_time;

void fragment() {
	// Called for every pixel the material is visible on.
	if (texture(TEXTURE, UV).a > 0.0) {
		// COLOR = texture(TEXTURE, UV) + vec4(1.0, 1.0, 0.0, 1.0) * (strength) * ((-2.0 * TIME) - floor(-2.0 * TIME));
		COLOR = texture(TEXTURE, UV) + vec4(1.0, 1.0, 0.0, 1.0) * (strength) * (fract(-2.0 * (TIME - start_time) + 0.05));
	} else {
		COLOR = COLOR;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
