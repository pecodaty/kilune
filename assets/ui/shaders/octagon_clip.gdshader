shader_type canvas_item;

// Clips the texture to a clipped-corner (octagonal) frame.
uniform float cut = 0.22;

void fragment() {
	vec2 q = abs(UV - 0.5);
	float inside = step(max(q.x, q.y), 0.5) * step(q.x + q.y, 1.0 - cut);
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= inside;
}
