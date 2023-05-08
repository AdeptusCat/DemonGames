shader_type canvas_item;

uniform float dissolveState : hint_range(0,1) = 0.5;
uniform sampler2D dissolveNoise;
//uniform sampler2D gradient;

void fragment() {
	vec4 textureColor = texture(TEXTURE, UV) * 0.0; // 0.0 makes it black
	float brightness = texture(dissolveNoise, UV).r;
	COLOR = textureColor;
	COLOR.a = step(dissolveState, brightness);
//	float textureBrightness = (textureColor.r + textureColor.g + textureColor.b) / 3.0;
//	vec4 gradientColor = t
//	COLOR.a += textureColexture(gradient, vec2(textureBrightness - dissolveState));
//	COLOR = gradientColor;
}
