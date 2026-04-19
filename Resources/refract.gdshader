shader_type spatial;
render_mode unshaded;

uniform float offset;
uniform vec4 mix_color: source_color;
uniform sampler2D screen_texture: hint_screen_texture;

void fragment() {
	vec2 displacement = vec2(offset);
	displacement.x *= -NORMAL.x * 2.0;
	displacement.y *= -NORMAL.y * 2.0;
	
	vec3 screen_sample = texture(screen_texture, SCREEN_UV + displacement).rgb;
	
	ALBEDO = mix(screen_sample, mix_color.rgb, mix_color.a);
}
