extends Node2D
class_name hand

const cardBase = preload("res://card_base.gd")
const deck = preload("res://deck.gd")
const main = preload("res://main.gd")
var number_of_cards
var cards = []
var viewport_size = Vector2(1600, 648)
var selectedCards = []
var handParent = Node2D.new()
var cardColors = ["red", "blue", "yellow", "green", "orange", "pink", "white", "black"]

var center_card_oval = viewport_size * Vector2(0.58, 2)
var hor_rad = viewport_size.x*0.7
var ver_rad = viewport_size.y*0.4
var angle
var rot
var oval_angle_vector = Vector2()
var new_position
var card
var increase
var switch 

func draw_card(card : cardBase):
	cards.push_back(card)
	_reorganize_hand()

	
	
func _on_gui_input(event: InputEvent, card: cardBase):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if card not in selectedCards:
				selectedCards.push_back(card)
				card.position.y -= 50
			else:
				selectedCards.erase(card)
				card.position.y += 50
	
func _reorganize_hand():
	selectedCards.clear()
	increase = 3
	switch = -1
	rot = deg_to_rad(90)
	angle = deg_to_rad(90)
	for card in cards:
		if switch == 1:
			card.get_parent().move_child(card, -1)
		else:
			card.get_parent().move_child(card, 0)
		#angle = PI/2 + cardSpread*(float(cards.size())/2 - cards.size())
		oval_angle_vector = Vector2(hor_rad*cos(angle), -ver_rad*sin(angle))
		new_position = center_card_oval + oval_angle_vector - card.size/2
		if switch == 1:
			new_position += Vector2(0, increase)
		var tween = card.get_tree().create_tween()
		tween.tween_property(card, "position", new_position, 0.3).from(card.position)
		#card.scale *= deck.cardSize/card.size
		card.rotation = -angle + deg_to_rad(90)
		card.gui_input.connect(_on_gui_input.bind(card))
		angle += deg_to_rad(increase)*switch
		card.z_index = increase * switch
		increase += 3
		switch *= -1
		rot -= 0.08

func _hide_cards():
	for card in cards:
		var tween = card.get_tree().create_tween()
		tween.parallel().tween_property(card, "position", card.position + Vector2(0, 200), 0.4)

func _reveal_cards():
	for card in cards:
		var tween = card.get_tree().create_tween()
		tween.parallel().tween_property(card, "position", card.position + Vector2(0, -200), 0.4)
		
func _CPU_draw_card(card : cardBase):
	var color = card.cardColor
	var oldScale = card.scale
	card._set_texture("back_card")
	card.scale *= Vector2(200, 220)/card.texture.get_size()
	cards.push_back(card)
	selectedCards.clear()
	var tween = card.get_tree().create_tween()
	tween.tween_property(card, "position", Vector2(928, 1500), 0.3)
	await tween.finished
	card._set_texture(color)
	card.scale = oldScale
	
	
	
func _CPU_cards_for_route(color : String, cardsNeeded : int):
	if color == "grey":
		for colorForGrey in cardColors:
			if(_CPU_cards_for_route(colorForGrey, cardsNeeded)):
				return true
		return false
	
	else:
		for card in cards:
			if card.cardColor == color or card.cardColor == "wild":
				selectedCards.push_back(card)
				if selectedCards.size() == cardsNeeded:
					return true
		selectedCards.clear()
		return false
	return true
		
