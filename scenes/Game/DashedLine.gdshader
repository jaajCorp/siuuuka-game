shader_type canvas_item;

uniform vec4 color: source_color;
uniform int dash_count = 64;

void fragment() {
	float aaa = floor(UV.x * float(dash_count));

	if (mod(aaa, 2) == 0.0) {
		COLOR = color;
	} else {
		COLOR = vec4(0.0);
	}
}
