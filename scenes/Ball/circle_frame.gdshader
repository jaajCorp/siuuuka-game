shader_type canvas_item;

void fragment() {
	vec2 uv = (UV - 0.5) * 2.0;
	float dist = distance(vec2(0.0), uv);
	float mask = 1.0 - smoothstep(0.99, 1.0, dist);

	COLOR = vec4(COLOR.rgb, mask);
}
