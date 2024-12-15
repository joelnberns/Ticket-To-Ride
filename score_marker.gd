extends Sprite2D
var player = preload("res://player.gd")
var grad = load("res://scoreMarkerGradient.tres")
signal marker_moved()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _setup(color : String):
	texture = grad.duplicate(true)
	texture.gradient.set_color(0, color)
	position = Vector2(24.245, 745.576)
	scale = Vector2(0.401, 0.411)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _move_marker(points : int, currentPlayer : player, direction : int):
	for i in range(points):
		currentPlayer.score += 1*direction
		print(currentPlayer.score)
		var tween = create_tween()
		if ((currentPlayer.score %100) > 0) and ((currentPlayer.score % 100) <= 20):
			if (((currentPlayer.score - 20) % 100) == 0) and (direction == -1):
				tween.tween_property(self, "position", position + Vector2(-37, 0), 0.1)
			else:
				tween.tween_property(self, "position", position + Vector2(0, -36.5*direction), 0.1)
				
		if ((currentPlayer.score % 100) > 20) and ((currentPlayer.score % 100) <= 50):
			if (((currentPlayer.score - 50) % 100) == 0) and (direction == -1):
				tween.tween_property(self, "position", position + Vector2(0, -36.5), 0.1)
			else:
				tween.tween_property(self, "position", position + Vector2(37*direction, 0), 0.1)
				
		if ((currentPlayer.score % 100) > 50) and ((currentPlayer.score % 100) <= 70):
			if (((currentPlayer.score - 70) % 100) == 0) and (direction == -1):
				tween.tween_property(self, "position", position + Vector2(37, 0), 0.1)
			else:
				tween.tween_property(self, "position", position + Vector2(0, 36.5*direction), 0.1)
				
		if ((currentPlayer.score % 100) > 70) or ((currentPlayer.score % 100) == 0):
			if (((currentPlayer.score - 100) % 100) == 0) and (direction == -1):
				tween.tween_property(self, "position", position + Vector2(0, 36.5), 0.1)
			else:
				tween.tween_property(self, "position", position + Vector2(-37*direction, 0), 0.1)
		$Timer.wait_time = 0.2
		$Timer.start()
		await $Timer.timeout
	emit_signal("marker_moved")
	
