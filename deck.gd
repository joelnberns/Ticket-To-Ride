extends Node
@onready var deck = []
@onready var top = 0
@onready var cards_per_color = 12
@onready var number_of_wilds = 14
@onready var markerArray = [$display1, $display2, $display3, $display4, $display5]
const cardBase = preload("res://CardBase.tscn")
const cardSize = Vector2(1000, 0)
var newCard = cardBase.instantiate()
@onready var discard = []
@onready var display = [0, 0, 0, 0, 0]
signal card_drawn(cardBase)
signal wild_drawn_fron_display


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DeckDraw.position += Vector2(230, 0)
	$DeckDraw.scale *= newCard.size/$DeckDraw.size
	var viewport_x : float = 1400 - $DeckDraw.position.x
	for i in range(0, cards_per_color):
		discard.push_back(_initialize_card("red"))
		discard.push_back(_initialize_card("blue"))
		discard.push_back(_initialize_card("green"))
		discard.push_back(_initialize_card("yellow"))
		discard.push_back(_initialize_card("orange"))
		discard.push_back(_initialize_card("pink"))
		discard.push_back(_initialize_card("white"))
		discard.push_back(_initialize_card("black"))
	for i in range(0, number_of_wilds):
		discard.push_back(_initialize_card("wild"))
	_shuffle()
	var farthestCard = 800
	$display1.position = Vector2($DeckDraw.position.x + 20 + 0.2*farthestCard, $DeckDraw.position.y)
	$display2.position = Vector2($DeckDraw.position.x + 20 + 0.4*farthestCard, $DeckDraw.position.y)
	$display3.position = Vector2($DeckDraw.position.x + 20 + 0.6*farthestCard, $DeckDraw.position.y)
	$display4.position = Vector2($DeckDraw.position.x + 20 + 0.8*farthestCard, $DeckDraw.position.y)
	$display5.position = Vector2($DeckDraw.position.x + 20 + farthestCard, $DeckDraw.position.y)
	for i in range(5):
		await _add_to_display(i)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _initialize_card(color):
	newCard = cardBase.instantiate()
	#newCard.scale *= $DeckDraw.size/newCard.size
	newCard._set_texture(color)
	newCard.visible = false
	add_child(newCard)
	return newCard
	
func _add_to_display(i):
		var tween = get_tree().create_tween()
		var cardTemp = deck.pop_front()
		cardTemp.visible = true
		display[i] = cardTemp
		tween.tween_property(display[i], "position", markerArray[i].position, 0.2).from(cardTemp.position)
		cardTemp.gui_input.connect(_on_gui_input.bind(cardTemp, i))
		$Timer.start()
		await $Timer.timeout
	

		
func _shuffle():
	while discard.size() > 0:
		var randnum = randi_range(0, discard.size()-1)
		var randCard = discard.pop_at(randnum)
		deck.push_back(randCard)
		randCard.visible = false
		randCard.position = $DeckDraw.position
		


func _on_deck_draw_button_up() -> void:
	if get_parent().get_parent().ticketsDrawn == true: # Cannot take if tickets have been drawn
		if get_parent().get_parent().has_method("_display_error"):
			get_parent().get_parent()._display_error("Already drew tickets!")
			return
	if not SignalBus.betweenTurns:
		if deck.size() == 0:
			_shuffle()
		var drawn_card = deck.pop_front()
		drawn_card.position = $DeckDraw.position
		drawn_card.visible = true
		emit_signal("card_drawn", drawn_card)
	
func _on_gui_input(event: InputEvent, card, i) -> void:
	if not SignalBus.betweenTurns:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if get_parent().get_parent().ticketsDrawn == true: # Cannot take if tickets have been drawn
					if get_parent().get_parent().has_method("_display_error"):
						get_parent().get_parent()._display_error("Already drew tickets!", "red")
						return
				if card.cardColor == "wild":
					if get_parent().get_parent().cardTaken == true: # Cannot take a wild if card has already been drawn
						if get_parent().get_parent().has_method("_display_error"):
							get_parent().get_parent()._display_error("Cannot take a wild!", "red")
							return
					await emit_signal("wild_drawn_fron_display") # end turn if a wild is drawn
				emit_signal("card_drawn", display[i])
				display[i].gui_input.disconnect(_on_gui_input.bind(display[i], i))
				_add_to_display(i)
				if deck.size() == 0:
					_shuffle()
			
			
			
