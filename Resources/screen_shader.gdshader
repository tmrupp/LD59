shader_type spatial;

uniform sampler2D display_texture;

void fragment() {
    vec4 tex = texture(display_texture, UV);
    ALBEDO = tex.rgb;
    EMISSION = tex.rgb * 0.5;  // make it glow like a screen
}