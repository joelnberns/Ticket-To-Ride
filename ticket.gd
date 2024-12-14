extends Sprite2D
signal ticket_clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()):
				emit_signal("ticket_clicked")
				

func _set_texture(route : String):
	print(route)
	var img = str("res://cards/tickets/", route, ".png")
	texture = load(img)
