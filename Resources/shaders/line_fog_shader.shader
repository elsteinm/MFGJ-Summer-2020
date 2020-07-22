shader_type canvas_item;

// Gonkee's smoke shader for Godot 3 - full tutorial https://youtu.be/ZkeRKXCoJNo
// If you use this shader, I would prefer it if you gave credit to me and my channel

uniform vec2 center = vec2(.0, .0);

uniform int OCTAVES = 6;
uniform float target_strech;
uniform bool need_strech = false;
void vertex()
{
	if (UV.y > 0.5)
	{
		//VERTEX.y += sin(TIME) * 20.0;
	}
}
float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

float egg_shape(vec2 coord, float radius){
	vec2 diff = abs(coord - center);

	if (coord.y < center.y){
		diff.y /= 2.0;
	} else {
		diff.y *= 2.0;
	}

	float dist = sqrt(diff.x * diff.x + diff.y * diff.y) / radius;
	float value = clamp(1.0 - dist, 0.0, 1.0);
	return clamp(value * value, 0.0, 1.0);
}
float line_shape(vec2 coord)
{
	float min_x = min(coord.x, 1.0 - coord.x);
	float min_y = min(coord.y, 1.0 - coord.y);
	float total_min = min(min_x,min_y);
	return smoothstep(0.0,0.5,total_min);
	float x_value = 1.0;
	if (coord.x > 0.5)
	{
		x_value =  smoothstep(1.0,0.6,coord.x);
	}
	else
	{
		x_value =  smoothstep(0.0,0.4,coord.x);
	}
	float y_value = 1.0;
	if (coord.y > 0.8)
	{
		y_value = smoothstep(0.95,0.8,coord.y);
	}
	if (coord.y < 0.2)
	{
		y_value = smoothstep(0.05,0.2,coord.y);
	}
	return min(x_value,y_value);
}
void fragment() {
	vec2 new_uv = UV.yx;
//	new_uv.y = 1.0 - new_uv.y;
	vec2 scaled_coord = new_uv * 20.0;
	

	float warp = new_uv.y;
	float dist_from_center = abs(new_uv.x - 0.5) * 4.0;
	if (new_uv.x > 0.5) {
		warp = 1.0 - warp;
	}
	
	vec2 warp_vec = vec2(warp, 0.0);
	float motion_fbm = fbm(scaled_coord + vec2(TIME * 0.4, TIME * 1.3)); // used for distorting the smoke_fbm texture
	float smoke_fbm = fbm(scaled_coord + vec2(0.0, TIME * 1.0) + motion_fbm + warp_vec * dist_from_center);
	
	float egg_s = line_shape(new_uv);
	float thres = 0.1;
	smoke_fbm *= egg_s;
	smoke_fbm = clamp(smoke_fbm - thres, 0.0, 1.0) / (1.0 - thres);
	if (smoke_fbm < 0.1) {
		smoke_fbm *= smoke_fbm/0.1;
	}
	smoke_fbm /= egg_s;
	smoke_fbm = sqrt(smoke_fbm);
	smoke_fbm = clamp(smoke_fbm, 0.0, 1.0);
//	COLOR = vec4(1.0);
	
	COLOR = vec4(vec3(smoke_fbm),line_shape(new_uv));
//	vec4 temp = vec4(vec3(egg_s),1.0);
//	COLOR = vec4(vec3(egg_s), line_shape(new_uv));
}
