shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.3, 1.0);
uniform float outline_size = 1.0;
uniform bool enabled = true;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 out_col = tex;

	if (enabled) {
		if (tex.a <= 0.0) {
			vec2 size = TEXTURE_PIXEL_SIZE * outline_size;

			float a = 0.0;
			a += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
			a += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
			a += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
			a += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;

			if (a > 0.0) {
				out_col = outline_color;
			} else {
				out_col = vec4(0.0);
			}
		}
	}

	COLOR = out_col;
}
