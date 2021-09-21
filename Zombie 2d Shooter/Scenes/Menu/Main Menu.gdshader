shader_type canvas_item;

uniform vec2 tiled_factor = vec2(1.0, 1.0);
uniform float aspect_ratio = 1.0;

void fragment() {
	vec2 tilted_uvs = UV * tiled_factor;
	tilted_uvs.y *= aspect_ratio;
	
	vec2 waves_uv_offset;
	
	waves_uv_offset.x = cos(TIME / 55.0) * 20.50;
	waves_uv_offset.y = cos(TIME / 40.0) * -15.50;
	
	
	COLOR = texture( TEXTURE, tilted_uvs + waves_uv_offset);
}

void light() {
// Output:0

}

void vertex() {
// Output:0

}