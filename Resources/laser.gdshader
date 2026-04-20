shader_type spatial;
render_mode unshaded;

uniform vec4 color_1 : source_color;
uniform vec4 color_2 : source_color;
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
	
	vec4 mix_result = mix(color_1, color_2, val);
	ALBEDO = mix_result.rgb;
	
	if (mix_result.a < 0.5) {
		discard;
	}
}
