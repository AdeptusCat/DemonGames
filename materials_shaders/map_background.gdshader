shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform sampler2D noise3 : repeat_enable;

uniform vec4 smoke_color : source_color; 

uniform float speed = 1.0;
const float mid = 0.5;

void fragment() {
	
	vec2 rotation_cw_uv = vec2(cos(TIME*speed) * (UV.x - mid) + sin(TIME*speed) * (UV.y - mid) + mid, cos(TIME*speed) * (UV.y - mid) - sin(TIME*speed) * (UV.x - mid) + mid);
	vec2 rotation_ccw_uv = vec2(cos(TIME*speed) * (UV.x - mid) - sin(TIME*speed) * (UV.y - mid) + mid, cos(TIME*speed) * (UV.y - mid) + sin(TIME*speed) * (UV.x - mid) + mid);
	
	vec2 uv1 = vec2(UV.x + TIME*speed, UV.y);
	vec2 uv2 = vec2(UV.x - TIME*speed, UV.y);
	vec2 uv3 = vec2(UV.x, UV.y + TIME*speed);
	
	float noise_r = texture(noise1, rotation_ccw_uv).r;
	float noise_g = texture(noise2, rotation_cw_uv).g;
	float noise_b = texture(noise3, rotation_ccw_uv).b;
	
	vec3 new_color = vec3(noise_r, noise_g, noise_b);
	
	float new_alpha = noise_r * noise_r * noise_g * noise_g * noise_b * noise_b;
	
//	COLOR.rgb = texture(TEXTURE, UV).rgb;
	COLOR.rgb = smoke_color.rgb;
	COLOR.a = clamp(new_alpha * 5.0 * texture(TEXTURE, UV).a, 0.0, 1.0);
}