extends Node2D
var trains = [TextureButton]
signal route_selected(route, trains)

func _ready():
	for button in get_children():
		if button.get_class() == "TextureButton":
			button.button_up.connect(_on_button_up.bind(trains))
			trains.push_back(button)


func _on_button_up(trains) -> void:
	SignalBus.emit_signal("route_selected", self, trains)
		
func _disconnect_signal():
	for train in trains:
		train.button_up.disconnect(_on_button_up)
