shader_type spatial;
render_mode unshaded, cull_disabled;

// SpaceX Crew Dragon / Astro UXDS Studio Coordinate Grid Shader
// Procedural infinite-look grid with primary major axes, sub-divisions, and distance fade

uniform vec4 bg_color : source_color = vec4(0.031, 0.043, 0.063, 1.0); // #080B10 Deep Space Obsidian
uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.035);    // 5 cm grid lines
uniform vec4 axis_color : source_color = vec4(0.0, 0.824, 1.0, 0.12);   // SpaceX Cyan Primary Axis
uniform float grid_spacing = 0.05; // 5 cm physical grid spacing
uniform float grid_thickness = 0.0015;
uniform float fade_distance = 18.0;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 coord = world_pos.xz;
	vec2 grid = abs(fract(coord / grid_spacing - 0.5) - 0.5) / fwidth(coord / grid_spacing);
	float line = min(grid.x, grid.y);
	float c_grid = 1.0 - min(line, 1.0);

	// Major axes (X=0 and Z=0)
	vec2 axes = abs(coord) / fwidth(coord);
	float axis_line = min(axes.x, axes.y);
	float c_axis = 1.0 - min(axis_line, 1.0);

	// Distance circular fade out
	float dist = length(world_pos.xz);
	float fade = clamp(1.0 - (dist / fade_distance), 0.0, 1.0);
	fade = fade * fade; // smooth quad fade

	vec4 col = bg_color;
	col = mix(col, grid_color, c_grid * grid_color.a * fade);
	col = mix(col, axis_color, c_axis * axis_color.a * fade);

	ALBEDO = col.rgb;
	ROUGHNESS = 0.95;
	SPECULAR = 0.0;
}
