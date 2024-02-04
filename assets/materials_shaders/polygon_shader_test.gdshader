shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform sampler2D noise3 : repeat_enable;

uniform sampler2D colorTexture;

uniform float speed = 1.0;
uniform vec2 scroll1 = vec2(0.1, 0.1);
uniform vec2 scroll2 = vec2(0.2, 0.2);
const float mid = 0.5;

uniform float distortion_strength : hint_range(0.05, 1.0) = 0.1;
uniform sampler2D distortion_noise : repeat_enable;

void fragment() {
//	float pct = 0.0;
//	pct = distance(UV,vec2(0.5));
//	float speed = pct;
	vec2 rotation_cw_uv = vec2(cos(TIME*speed) * (UV.x - mid) + sin(TIME*speed) * (UV.y - mid) + mid, cos(TIME*speed) * (UV.y - mid) - sin(TIME*speed) * (UV.x - mid) + mid);
	vec2 rotation_ccw_uv = vec2(cos(TIME*speed) * (UV.x - mid) - sin(TIME*speed) * (UV.y - mid) + mid, cos(TIME*speed) * (UV.y - mid) + sin(TIME*speed) * (UV.x - mid) + mid);
//	float new_color1 = texture(noise1, rotation_cw_uv + scroll1).r;
//	float new_color2 = texture(noise2, rotation_ccw_uv + scroll2).r;

	
	
//	vec3 new_color = vec3(noise_r, noise_g, noise_b);
	float new_color1 = texture(noise1, UV + scroll1 * speed * TIME).r;
	float new_color2 = texture(noise2, UV - scroll2 * speed * TIME).r;
	float new_color3 = texture(noise3, vec2(UV.x + scroll2.x * speed * TIME, UV.y - scroll2.y * speed * TIME)).r;
	
	float energy = new_color1 * new_color2 * new_color3;
	float distortion_noise_value =  texture(distortion_noise, rotation_ccw_uv).r;
	vec3 color = texture(colorTexture, vec2(energy) - (distortion_strength / 2.0) + vec2(distortion_noise_value) * distortion_strength).rgb;
	float alpha = texture(colorTexture, vec2(energy) - (distortion_strength / 2.0) + vec2(distortion_noise_value) * distortion_strength).a;
//		vec3 color = texture(colorTexture, vec2(energy)).rgb;
	COLOR.rgb = color.rgb;
	COLOR.a = alpha;
//	COLOR = texture(colorTexture, vec2(new_color1 * new_color2));
//	COLOR.rgb = texture(TEXTURE, UV).rgb;
//	COLOR.rgb = new_color1.rgb;
//	COLOR.a = clamp(new_alpha * 10.0 * texture(TEXTURE, UV).a, 0.0, 1.0);
}