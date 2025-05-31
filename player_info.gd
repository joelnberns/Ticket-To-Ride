extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_color(color : String):
	var styleBox: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	styleBox.set("bg_color", Color(color))
	styleBox.set("border_color", Color("white"))
	$Panel.add_theme_stylebox_override("panel", styleBox)
	
func _set_current_player():
	var styleBox: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	styleBox.set("border_color", Color("white"))
	$Panel.add_theme_stylebox_override("panel", styleBox)
	
func _unset_current_player(color):
	var styleBox: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	styleBox.set("border_color", Color(color))
	$Panel.add_theme_stylebox_override("panel", styleBox)
	
func _set_trains(trains):
	$Panel/trainPanel/trains.text = str(trains)
	
func _set_score(score):
	$Panel/trainPanel/points.text = str(score)
	
func _set_new_position(newPosition : Vector2):
	$Panel.position = newPosition
