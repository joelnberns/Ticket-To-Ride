extends Node
@onready var deck = []
@onready var discards = 0
const ticketBase = preload("res://ticket.tscn")
@onready var selectedCards = []
@onready var ticketArray = []
var ticketsTaken := false
signal ticketsSelected(tickets : Array)
@onready var discardPile = []




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Deck.position += Vector2(100, 20)
	$"Deck/Discard Button".visible = false
	for ticket in r.ticketDict:
		var card = ticketBase.instantiate()
		card.name = ticket
		card._set_texture(ticket)
		card.scale *= Vector2(0.9, 0.9)
		card.position = $Deck.position + Vector2(-58, 220)
		card.centered = false
		card.visible = false
		card.ticket_clicked.connect(_handle_click.bind(card))
		$Cards.add_child(card)
		deck.push_back(card)
	deck.shuffle()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_deck_button_up(discardLimit = 2) -> void:
	#for ticket in selectedCards:
		#selectedCards.erase(ticket)
		#ticket.modulate = Color(1, 1, 1)
	if not SignalBus.betweenTurns:
		if get_parent().cardTaken:
			get_parent()._display_error("Already drew a card!")
			return
		ticketArray.clear()
		for i in range(3):
			if deck.size() == 0:
				discardPile.shuffle()
				deck = discardPile.duplicate()
				#for card in deck:
					#card.ticket_clicked.connect(_handle_click)
				discardPile.clear()
			var card = deck.pop_front()
			card.inDeck = false
			ticketArray.push_back(card)
		var tween = create_tween()
		ticketArray[0].visible = true
		tween.tween_property(ticketArray[0], "position", ticketArray[0].position + Vector2(0, 200), 0.2)
		ticketArray[1].visible = true
		tween.tween_property(ticketArray[1], "position", ticketArray[1].position + Vector2(0, 350), 0.2)
		ticketArray[2].visible = true
		tween.tween_property(ticketArray[2], "position", ticketArray[2].position + Vector2(0, 500), 0.2)
		discards = discardLimit
		ticketsTaken = true
		$"Deck/Discard Button".visible = true
		
	
	
func _handle_click(ticket):
	if not ticket.inDeck and ticket not in selectedCards and discards > 0:
		selectedCards.push_back(ticket)
		ticketArray.erase(ticket)
		ticket.modulate = Color(0.616, 1, 1)
		discards -= 1
	elif not ticket.inDeck and ticket in selectedCards:
		selectedCards.erase(ticket)
		ticketArray.push_back(ticket)
		ticket.modulate = Color(1, 1, 1)
		discards += 1


func _on_discard_button_button_up() -> void:
	$"Deck/Discard Button".visible = false
	if ticketsTaken:
		print("Selected cards: ", selectedCards.size())
		for card in selectedCards:
			card.inDeck = true
			discardPile.push_back(card)
			var tween = create_tween()
			tween.tween_property(card, "position", $Deck.position + Vector2(-58, 220), 0.2)
			card.modulate = Color(1, 1, 1)
		for card in ticketArray:
			card.ticket_clicked.disconnect(_handle_click)
		ticketsTaken = false
		selectedCards.clear()
		emit_signal("ticketsSelected", ticketArray)
		
	
		
