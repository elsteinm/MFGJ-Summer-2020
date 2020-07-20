shader_type canvas_item;

uniform vec4 line_color : hint_color = vec4(1);
uniform bool activated = false;

void fragment() {
	vec4 color = texture(TEXTURE,UV);
	if (color.a != 0.0 && activated)
	{
		color = line_color;
	}
	COLOR = color;
	
}
