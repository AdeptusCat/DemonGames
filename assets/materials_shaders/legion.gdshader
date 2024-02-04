shader_type canvas_item;

uniform float dissolveState : hint_range(0,1) = 0.0;
uniform sampler2D dissolveNoise;

uniform float flashState : hint_range(1,10) = 1.0;

void fragment() {
	vec4 textureColor = texture(TEXTURE, UV);
	float brightness = texture(dissolveNoise, UV).r;
	//COLOR = textureColor;
	//COLOR.a = step(dissolveState, brightness);
	float tranparency = step(dissolveState, brightness);
//	float textureBrightness = (textureColor.r + textureColor.g + textureColor.b) / 3.0;
//	vec4 gradientColor = t
//	COLOR.a += textureColexture(gradient, vec2(textureBrightness - dissolveState));
//	COLOR = gradientColor;

	vec4 previous_color = texture(TEXTURE, UV);
	vec4 flash_color = vec4(textureColor.r * flashState, textureColor.g * flashState, textureColor.b * flashState, tranparency);
	COLOR = flash_color;
}

