extends Panel

signal gameStarted(humanPlayers, computerPlayers)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

	


func _on_human_players_select_item_selected(index: int) -> void:
	for i in range(0, 6):
		if i <= 5 - index:
			$computerPlayersSelect.set_item_disabled(i, false)
		else:
			$computerPlayersSelect.set_item_disabled(i, true)


func _on_computer_players_select_item_selected(index: int) -> void:
	for i in range(0, 6):
		if i <= 5 - index:
			$humanPlayersSelect.set_item_disabled(i, false)
		else:
			$humanPlayersSelect.set_item_disabled(i, true)
			



func _on_button_button_up() -> void:
	emit_signal("gameStarted", $humanPlayersSelect.selected, $computerPlayersSelect.selected)
	
