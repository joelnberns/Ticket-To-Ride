extends Sprite2D
var player = preload("res://player.gd")
var grad = load("res://scoreMarkerGradient.tres")

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
	
	
func _move_marker(points : int, currentPlayer : player):
	for i in range(points):
		currentPlayer.score += 1
		var tween = create_tween()
		if ((currentPlayer.score %100) > 0) and ((currentPlayer.score % 100) <= 20):
			tween.tween_property(self, "position", position + Vector2(0, -36.5), 0.5)
		if ((currentPlayer.score % 100) > 20) and ((currentPlayer.score % 100) <= 50):
			tween.tween_property(self, "position", position + Vector2(37, 0), 0.5)
		if ((currentPlayer.score % 100) > 50) and ((currentPlayer.score % 100) <= 70):
			tween.tween_property(self, "position", position + Vector2(0, 36.5), 0.5)
		if ((currentPlayer.score % 100) > 70) or ((currentPlayer.score % 100) == 0):
			tween.tween_property(self, "position", position + Vector2(-37, 0), 0.5)
		$Timer.start()
		await $Timer.timeout
	
