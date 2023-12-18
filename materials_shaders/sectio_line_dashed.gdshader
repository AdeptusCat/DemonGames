shader_type canvas_item;

uniform float scrolling_speed = 1.0;
uniform bool on = false;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (on)
	{
		vec2 moving_uv = vec2(UV.x-(TIME * scrolling_speed), UV.y);
		vec4 in_tex = texture(TEXTURE, moving_uv);
		COLOR = in_tex;
	}
	}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
