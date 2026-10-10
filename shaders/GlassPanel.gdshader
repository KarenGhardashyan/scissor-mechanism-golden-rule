shader_type canvas_item;

// Apple VisionOS Liquid Glass / Frosted Glass Shader for Godot 4
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec4 glass_tint : source_color = vec4(1.0, 1.0, 1.0, 0.32);
uniform float blur_strength : hint_range(0.0, 6.0) = 2.2;
uniform float specular_sheen : hint_range(0.0, 1.0) = 0.12;
uniform float edge_glow : hint_range(0.0, 1.0) = 0.45;
uniform float corner_radius : hint_range(0.0, 40.0) = 22.0;

// Signed distance field for rounded rectangle
float rounded_rect_sdf(vec2 p, vec2 b, float r) {
	vec2 q = abs(p) - b + vec2(r);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	// Sample background with soft multi-tap blur
	vec2 uv = SCREEN_UV;
	vec2 ps = SCREEN_PIXEL_SIZE * blur_strength;

	vec4 bg = textureLod(screen_texture, uv, 1.5) * 0.32;
	bg += textureLod(screen_texture, uv + vec2(ps.x, ps.y), 1.2) * 0.17;
	bg += textureLod(screen_texture, uv - vec2(ps.x, ps.y), 1.2) * 0.17;
	bg += textureLod(screen_texture, uv + vec2(-ps.x, ps.y), 1.2) * 0.17;
	bg += textureLod(screen_texture, uv + vec2(ps.x, -ps.y), 1.2) * 0.17;

	// Liquid glass tint & subtle top-lit Fresnel sheen
	vec3 result = mix(bg.rgb, glass_tint.rgb, glass_tint.a);

	// Light liquid specular gradient from top edge
	float top_sheen = (1.0 - smoothstep(0.0, 0.45, UV.y)) * specular_sheen;
	result += vec3(top_sheen);

	// Hairline edge highlight
	float edge_dist_x = min(UV.x, 1.0 - UV.x);
	float edge_dist_y = min(UV.y, 1.0 - UV.y);
	float edge = min(edge_dist_x, edge_dist_y);
	float edge_val = (1.0 - smoothstep(0.0, 0.03, edge)) * edge_glow;
	result += vec3(edge_val * 0.35);

	COLOR = vec4(result, 1.0);
}
