shader_type canvas_item;

uniform sampler2D NOISE_PATTERN1 : repeat_enable;
uniform sampler2D NOISE_PATTERN2 : repeat_enable;
uniform vec2 scroll1 = vec2(0.0, 0.5);
uniform vec2 scroll2 = vec2(0.0, 0.3);

uniform sampler2D TONE_MAPPING;

uniform vec2 noiseScale1 = vec2(1, 1);
uniform vec2 noiseScale2 = vec2(1, 1);
uniform float blur : hint_range(0, 7) = 3.0;
uniform float base_intensity : hint_range(0, 0.5) = 0.1;
uniform float intensity_factor : hint_range(0, 5.0) = 1.5;

uniform float speed = 1.0;
uniform float distortion_strength : hint_range(0.01, 1.0) = 0.1;
uniform sampler2D distortion_noise : repeat_enable;

void fragment() {
	float distortion_noise_value = texture(distortion_noise, vec2(UV.x, UV.y + TIME * speed)).r;	
	COLOR.a = texture(TEXTURE, UV - (distortion_strength / 2.0) + distortion_noise_value * distortion_strength).a;
	
	
//	float tex_alpha = textureLod(TEXTURE, UV, blur).a;
	float tex_alpha = texture(TEXTURE, UV - (distortion_strength / 2.0) + vec2(distortion_noise_value) * distortion_strength, blur).a;
//	float tex_alpha = texture(TEXTURE, UV).a;
	float pattern_intensity = texture(NOISE_PATTERN1, UV * noiseScale1 + TIME * scroll1).r;
	float pattern_intensity2 = texture(NOISE_PATTERN1, UV * noiseScale1 + TIME * scroll2).r;
	float intensity = tex_alpha * intensity_factor * (pattern_intensity * pattern_intensity2 + base_intensity) ;
	COLOR = texture(TONE_MAPPING, vec2(intensity));

//	float intensity = tex_alpha * intensity_factor * (pattern_intensity * pattern_intensity2 + base_intensity);
//	COLOR = texture(TONE_MAPPING, vec2(intensity)); //UV - (distortion_strength / 2.0) + vec2(distortion_noise_value) * distortion_strength
//	COLOR.rgb = color.rgb;

	

//	float tex_alpha = texture(TEXTURE, UV).a;
//	float pattern_intensity = texture(NOISE_PATTERN1, UV * noiseScale1 + TIME * scroll1).r;
//	float pattern_intensity2 = texture(NOISE_PATTERN1, UV * noiseScale1 + TIME * scroll2).r;
//	float intensity = tex_alpha * pattern_intensity * pattern_intensity2;
//	COLOR = texture(TONE_MAPPING, vec2(intensity));

//	float tex_alpha = texture(TEXTURE, UV).a;
//	float pattern_intensity = texture(NOISE_PATTERN1, UV + TIME * scroll1).r;
//	float intensity = tex_alpha * pattern_intensity;
//	COLOR = texture(TONE_MAPPING, vec2(intensity));

//	float tex_alpha = texture(TEXTURE, UV).a;
//	float pattern_intensity = texture(NOISE_PATTERN1, UV + TIME * scroll1).r;
//	float intensity = tex_alpha * pattern_intensity;
//	COLOR = vec4(intensity);
//
//	vec2 stretched_UV = UV;
//	stretched_UV.x *= xStretch;
//	stretched_UV.y *= yStretch;
//
//	float intensity1 = textureLod(NOISE_PATTERN1, stretched_UV + TIME * scroll1 * speed, 0.0).r;
//	float intensity2 = textureLod(NOISE_PATTERN2, stretched_UV + TIME * scroll2 * speed, 0.0).r;
//	float intensity = intensity1 * intensity2;
//
//	float centrality = (1.0 - abs(UV.y - 0.5)) * 0.5;
//
//	if (wobbliness * intensity + (1.0 - wobbliness) * centrality > 1.0 - laserSize)
//	{
//		intensity *= centrality;
//		COLOR = mix(color1, color2, clamp(intensity * colorMixFactor, 0.0, 1.0)) * glowFactor;
//
//		float alpha = textureLod(TRANSPARENCY_VARIATION, stretched_UV + TIME * scroll1 * speed, 0.0).r;
//		COLOR.a = minAlpha + alpha * (1.0 - minAlpha);
//	}
}