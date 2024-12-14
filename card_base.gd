extends MarginContainer

@onready var CardDataBase = preload("res://cardDB.gd")
var cardColor : String = "red"
@onready var cardImg = str("res://cards/train cards/", cardColor, ".png")
@onready var texture = $Card.texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var CardSize = size
	#$Card.scale *= CardSize/$Card.texture.get_size()

	
func _set_texture(color):
	cardColor = color
	cardImg = str("res://cards/train cards/", color, ".png")
	$Card.texture = load(cardImg)
