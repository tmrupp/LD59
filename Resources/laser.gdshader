shader_type spatial;
render_mode unshaded;

uniform float low_threshold;
uniform float high_threshold;
uniform float noise_multiplier;
uniform float noise_vertex_multiplier;
uniform sampler2D noise_texture;

void vertex() {
	float noise_val = texture(noise_texture, UV + 0.3 * TIME).r;
	VERTEX += noise_vertex_multiplier * noise_val * NORMAL;
}

void fragment() {
	float val = dot(NORMAL, VIEW);
	val = pow(val, 2);
	val = clamp(val, 0.0, 1.0);
	
	if (val > low_threshold && val < high_threshold) {
		val += noise_multiplier * texture(noise_texture, UV + 0.75 * TIME).r;
	}
	
	float mid_threshold = (low_threshold + high_threshold) / 2.0;
	
	if (val < mid_threshold) {
		val = 0.0;
	}
	else {
		val = 1.0;
	}
	
	ALBEDO = mix(vec3(1.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0), val);
}
