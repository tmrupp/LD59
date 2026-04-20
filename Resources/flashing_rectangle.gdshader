shader_type spatial;
render_mode unshaded, depth_prepass_alpha;

void fragment() {
	if (sin(3.0 * TIME) > 0.0) {
		discard;
	}
	
	if (UV.x < 0.96 && UV.x > 0.04 && UV.y < 0.9 && UV.y > 0.1) {
		discard;
	}
	
	ALBEDO = vec3(0.0, 1.0, 0.0);
	ALPHA = 0.7;
}
