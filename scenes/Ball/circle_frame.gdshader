shader_type canvas_item;

uniform vec3 color: source_color;

void fragment() {
	vec2 uv = (UV - 0.5) * 2.0;
	float dist = distance(vec2(0.0), uv);
	float mask = 1.0 - step(1.0, dist);
	
	float frame = smoothstep(0.93, 0.99, dist);
	
	vec3 finalColor = ((1.0 - frame) * COLOR.rgb) + (frame * color);

	COLOR = vec4(finalColor, mask);
}
