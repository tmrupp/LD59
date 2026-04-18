shader_type sky;

uniform float noise_weight;
uniform float noise_bias;
uniform float noise_frequency;
uniform sampler2D star_light_texture : repeat_enable;
uniform float star_density;

const int ARR_LEN = 4;

const float grad_1_marks[ARR_LEN] = float[](0.0, 0.4229249, 0.67193675, 1.0);
const vec4 grad_1_colors[ARR_LEN] = vec4[](
	vec4(0.0, 0.0, 0.0, 1.0), //black
	vec4(0.0, 0.0, 0.0, 1.0), //black
	vec4(0.090193845, 2.529271e-05, 0.3544664, 1.0), //purple
	vec4(0.0006394652, 0.0, 0.37308142, 1.0) //blue
);

const float grad_2_marks[ARR_LEN] = float[](0.0, 0.64426875, 0.85375494, 1.0);
const vec4 grad_2_colors[ARR_LEN] = vec4[](
	vec4(0.0, 0.0, 0.0, 0.0), //transparent
	vec4(0.12648222, 0.12648222, 0.0, 0.12648222), // mostly transparent slight yellow
	vec4(1.0, 0.49803922, 0.0, 0.78431374), // partially transparent orange
	vec4(1.0, 1.0, 1.0, 0.78431374) // partially transparent white
);

vec4 get_color(float[ARR_LEN] marks, vec4[ARR_LEN] colors, float n) {
	int found_index = ARR_LEN - 1;
	for (int i = 1; i < ARR_LEN; i++) {
		if (n <= marks[i]) {
			found_index = i;
			break;
		}
	}
	float mix_amount = (n - marks[found_index - 1]) / (marks[found_index] - marks[found_index - 1]);
	
	return mix(colors[found_index - 1], colors[found_index], mix_amount);
}

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

void sky() {
	float theta = SKY_COORDS.y * PI;
	float phi = SKY_COORDS.x * TAU;
	vec3 unit = vec3(0.0, 0.0, 0.0);
	
	unit.x = sin(phi) * sin(theta);
	unit.y = -cos(theta);
	unit.z = cos(phi) * sin(theta);
	unit = normalize(unit);
	
	float noise_val = noise_weight * noise(unit * noise_frequency) + noise_bias;
	noise_val += 0.25 * noise_weight * noise(unit * noise_frequency * 2.0);
	noise_val += 0.125 * noise_weight * noise(unit * noise_frequency * 4.0);
	noise_val += 0.0625 * noise_weight * noise(unit * noise_frequency * 8.0);
	
	vec3 undercolor = get_color(grad_1_marks, grad_1_colors, noise_val).rgb;
	vec4 overcolor = get_color(grad_2_marks, grad_2_colors, noise_val);
	
	vec3 base_space_color = mix(undercolor, overcolor.rgb, overcolor.a);
	vec3 star_light_layer = vec3(pow(texture(star_light_texture, SKY_COORDS).r, star_density));
	
	COLOR = mix(base_space_color, star_light_layer, star_light_layer.r);
}
