shader_type canvas_item;

void fragment() {
	float t = fract(TIME);

	float xOffset = sin(t * 3.14159 * 2.0) * 0.004 * sin(UV.y*160.0);
	float yOffset = cos(t * 3.14159 * 2.0) * 0.002 * sin(UV.x*160.0);

	vec4 color = texture(TEXTURE, UV + vec2(xOffset, yOffset));

	vec4 color2 = texture(TEXTURE, UV - vec2(xOffset, yOffset));

	float brightness = length(color.rgb);

	color.rgb = vec3(0.9, 0.9, 1.0);

	color.a *= (1.0 - brightness);

	color.a *= (1.0 - length(color2.rgb));

	COLOR = color;

}
