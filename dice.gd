extends Sprite2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer
signal dice_has_rolled(roll)

func _ready() -> void:
	randomize()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		animation_player.play("Roll")
		timer.start()
	


func _on_timer_timeout() -> void:
	var dice_roll : int = randi_range(1, 6)
	animation_player.play(str(dice_roll))
	emit_signal("dice_has_rolled", dice_roll)
