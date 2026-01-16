shader_type canvas_item;

uniform float reveal : hint_range(0.0, 1.0) = 1.0;
uniform float softness : hint_range(0.0, 0.2) = 0.02;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float d = abs(UV.x - 0.5) * 2.0;
	float m = smoothstep(reveal + softness, reveal - softness, d);

	COLOR = tex;
	COLOR.a *= m;
}
