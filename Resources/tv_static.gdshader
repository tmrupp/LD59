shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_texture;

void fragment() {
	ALBEDO = texture(noise_texture, UV + 47.0 * TIME).rgb;
}
