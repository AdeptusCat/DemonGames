shader_type canvas_item;

uniform float speed = 1.0;
const float mid = 0.5;

uniform float blue = 1.0; // you can assign a default value to uniforms

uniform sampler2D x : hint_normal;


void fragment(){
  NORMAL_MAP = texture(x, UV).rgb;
  //COLOR.b = blue;
}

void vertex() {
//  VERTEX += vec2(cos(TIME)*500.0, sin(TIME)*500.0);
}