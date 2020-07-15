shader_type canvas_item;
uniform vec4 color_of_border : hint_color;

void fragment(){
	vec4 current = texture(TEXTURE,UV); // read from texture
	if (current == color_of_border)
	{
	//	current = current * vec4(2.0,2.0,2.0,1.0);
	}
	COLOR = current;
}
