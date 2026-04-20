shader_type spatial;
render_mode blend_premul_alpha, unshaded;

uniform float noise_weight;
uniform float noise_bias;
uniform float noise_frequency;
uniform float vertex_adjust;
uniform vec4 color_at_0 : source_color;
uniform vec4 color_at_1 : source_color;

vec3 hash(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec3 p) {
	  vec3 i = floor(p);
  vec3 f = fract(p);
  vec3 u = f * f * (3.0 - 2.0 * f);

  return mix(mix(mix(dot(hash(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
                     dot(hash(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
                 mix(dot(hash(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
                     dot(hash(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y),
             mix(mix(dot(hash(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
                     dot(hash(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x),
                 mix(dot(hash(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
                     dot(hash(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z );
}

float get_noise_at_UV(vec2 uv) {
	float theta = uv.y * PI;
	float phi = uv.x * TAU;
	vec3 unit = vec3(0.0, 0.0, 0.0);
	
	unit.x = sin(phi) * sin(theta);
	unit.y = -cos(theta);
	unit.z = cos(phi) * sin(theta);
	unit = normalize(unit);
	
	return noise_weight * noise(unit * noise_frequency) + noise_bias;
}

void vertex() {
	float noise_val = get_noise_at_UV(UV);
	VERTEX += vertex_adjust * noise_val * NORMAL;
}

void fragment() {
	float noise_val = get_noise_at_UV(UV);
	vec4 color = mix(color_at_0, color_at_1, noise_val);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
