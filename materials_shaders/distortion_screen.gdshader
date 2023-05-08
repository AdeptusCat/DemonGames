shader_type canvas_item;
uniform float speed = 1.0;

uniform float distortion_strength : hint_range(0.01, 1.0) = 0.1;
uniform sampler2D distortion_noise : repeat_enable;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	float distortion_noise_value = texture(distortion_noise, vec2(UV.x,UV.y + TIME * speed)).r;
	COLOR.rgb = texture(SCREEN_TEXTURE, SCREEN_UV - (distortion_strength / 2.0) + vec2(distortion_noise_value) * distortion_strength).rgb;
}
