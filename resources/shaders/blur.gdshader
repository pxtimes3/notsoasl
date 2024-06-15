shader_type canvas_item;

// Radius that the shader was designed for.
const float DEFAULT_RADIUS = 15.000000000;

// Unit vector: (1, 0) or (0, 1)
uniform vec2 step;
// Desired blur radius.
uniform float radius = 15.000000000;

void fragment() {
	vec2 s = radius / DEFAULT_RADIUS * step / vec2(textureSize(TEXTURE, 0));
	COLOR.rgb =
		0.000035689 * texture(TEXTURE, UV - 15.000000000 * s).rgb +
		0.000361455 * texture(TEXTURE, UV - 13.276878195 * s).rgb +
		0.002076109 * texture(TEXTURE, UV - 11.306235579 * s).rgb +
		0.009011110 * texture(TEXTURE, UV - 9.337253977 * s).rgb +
		0.029562157 * texture(TEXTURE, UV - 7.369739777 * s).rgb +
		0.073317395 * texture(TEXTURE, UV - 5.403449852 * s).rgb +
		0.137485829 * texture(TEXTURE, UV - 3.438097000 * s).rgb +
		0.194956148 * texture(TEXTURE, UV - 1.473358589 * s).rgb +
		0.209060196 * texture(TEXTURE, UV + 0.491112047 * s).rgb +
		0.169537867 * texture(TEXTURE, UV + 2.455672242 * s).rgb +
		0.103969632 * texture(TEXTURE, UV + 4.420675748 * s).rgb +
		0.048211744 * texture(TEXTURE, UV + 6.386458784 * s).rgb +
		0.016902383 * texture(TEXTURE, UV + 8.353327534 * s).rgb +
		0.004479363 * texture(TEXTURE, UV + 10.321548051 * s).rgb +
		0.000897155 * texture(TEXTURE, UV + 12.291339175 * s).rgb +
		0.000135768 * texture(TEXTURE, UV + 14.262868749 * s).rgb;
	COLOR.a = 1.0;
}
