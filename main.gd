extends Node2D



@onready var deck = $TtrBoard2/Deck
@onready var redPlayer = player.new()
@onready var bluePlayer = player.new()
@onready var playerArray := []
@onready var currentPlayer : player
@onready var pointsArray = [0, 1, 2, 4, 7, 10, 15]
@onready var colorArray = ["red", "blue", "green", "yellow", "black"]
@onready var cardTaken := false
@onready var ticketsDrawn := false
@onready var wildDrawnFromDisplay := false
var numberOfPlayers = 2
var scoreMarker = preload("res://scoreMarker.tscn")
signal initialTicketsSelected
	
func _ready():
	SignalBus.betweenTurns = false
	$"Start Turn".visible = false
	for route in $TtrBoard2/Routes2.get_children():
		SignalBus.route_selected.connect(_on_route_selected)
	_startup()
	
func _startup():
	for i in range(numberOfPlayers):
		var newPlayer = player.new()
		var randColor = randi_range(0, colorArray.size()-1)
		newPlayer.playerColor = colorArray.pop_at(randColor)
		var score = scoreMarker.instantiate()
		$TtrBoard2.add_child(score)
		newPlayer.scoreMarker = score
		newPlayer.scoreMarker._setup(newPlayer.playerColor)
		playerArray.push_back(newPlayer)
		newPlayer.playerNum = i
	currentPlayer = playerArray[randi_range(0, numberOfPlayers-1)]
	for newPlayer in playerArray:
		newPlayer._print()
	#for i in range(numberOfPlayers):
		#ticketsDrawn = true
		#await $tickets._on_deck_button_up(1)
		#await initialTicketsSelected
	#ticketsDrawn = false
		
		
		
	

func _on_deck_card_drawn(cardBase: Variant) -> void:
	if not SignalBus.betweenTurns:
		currentPlayer.trainHand.draw_card(cardBase)
		if wildDrawnFromDisplay == false and cardTaken == false:
			cardTaken = true
		#else:
			#await(_next_player())
			#cardTaken = false
			#wildDrawnFromDisplay = false
			
func _on_deck_wild_drawn_fron_display() -> void:
	wildDrawnFromDisplay = true
			

	
func discard():
	for card in currentPlayer.trainHand.selectedCards:
		$TtrBoard2/Deck.discard.push_back(card)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", $TtrBoard2/Deck/Discard.position, 0.5).from(card.position)
		currentPlayer.trainHand.cards.erase(card)
		print(currentPlayer.trainHand.cards)
	currentPlayer.trainHand.selectedCards.clear()
	currentPlayer.trainHand._reorganize_hand()
	
func _on_route_selected(route: Variant, trains: Variant):
	if not SignalBus.betweenTurns:
		if cardTaken:
			_display_error("Already drew a card!")
			return
		if ticketsDrawn:
			_display_error("Already drew tickets!")
			return
			$"Error Message".visible = false
		if _check_route_valid(route):
			await(discard())
			for train in route.get_children():
				var rect = ColorRect.new()
				rect.color = Color(currentPlayer.playerColor)
				rect.size = train.size - Vector2(3, 3)
				rect.scale *= train.scale
				rect.rotation = train.rotation
				rect.position = train.position
				rect.visible = true
				add_child(rect)
				var tween = get_tree().create_tween()
				tween.tween_property(rect, "position", train.position, 0.5).from(Vector2(500, 1000))
				train.disabled = true
				$TtrBoard2/TrainTimer.start()
				await $TtrBoard2/TrainTimer.timeout
			currentPlayer.trains -= r.routes[route.name][0]
			currentPlayer._add_route(route.name)
			var routeArray = r.splitRoute(route.name)
			var city1 = routeArray[0]
			var city2 = routeArray[1]
			currentPlayer._update_connections(city1, city2, city1, 0, {})
			currentPlayer._update_connections(city2, city1, city2, 0, {})
			print("longest route: ", currentPlayer.longestRoute)
			currentPlayer.scoreMarker._move_marker(pointsArray[route.get_children().size()], currentPlayer)
			if currentPlayer.trains <= 2:
				print("end game")
				_end_game()
			#await(_next_player())
		
		
		
func _check_route_valid(route: Variant) -> bool:
	if currentPlayer.trainHand.selectedCards.size() != route.get_children().size():
		_display_error("wrong number of cards selected!")
		return false
	if not _correct_cards_selected(route.name):
		return false
	if currentPlayer.trains < r.routes[route.name][0]:
		_display_error("not enough trains!")
		return false
	return true
	
func _correct_cards_selected(routeName) -> bool:
	var color = r.routes[routeName][1]
	if color == "grey":
		var matchColor = "none"
		for card in currentPlayer.trainHand.selectedCards:
			if card.cardColor != "wild":
				if matchColor == "none":
					matchColor = card.cardColor
			if (card.cardColor != matchColor) and (card.cardColor != "wild"):
				_display_error("wrong cards!")
				return false
	else:
		for card in currentPlayer.trainHand.selectedCards:
			if (card.cardColor != color) and (card.cardColor != "wild"):
				_display_error("wrong cards!")
				return false
	return true
	

		
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("ui_click"):
		#currentPlayer.scoreMarker._move_marker(30, currentPlayer)
		

func _on_tickets_tickets_selected(tickets: Array) -> void:
	if not SignalBus.betweenTurns:
		if cardTaken:
			_display_error("Already drew a card!")
			return
		ticketsDrawn = true
		await(currentPlayer._organize_tickets(tickets))
		#await(_next_player())
		#ticketsDrawn = false
		#emit_signal("initialTicketsSelected")

func _next_player():
	SignalBus.betweenTurns = true
	$"Start Turn/Timer".start()
	await $"Start Turn/Timer".timeout
	currentPlayer.trainHand._hide_cards()
	currentPlayer._hide_tickets()
	$"Start Turn".visible = true
	await $"Start Turn".button_up
	$"Start Turn".visible = false
	currentPlayer = playerArray[(currentPlayer.playerNum + 1) % numberOfPlayers]
	currentPlayer.trainHand._reveal_cards()
	currentPlayer._reveal_tickets()
	SignalBus.betweenTurns = false
	
func _display_error(message : String):
	$"Error Message".visible = true
	$"Error Message".text = str(message)
	$"Error Message/Error Timer".start()
	await $"Error Message/Error Timer".timeout
	$"Error Message".visible = false
	
func _end_game():
	var longestRoute = 0
	var longestRoutePlayer
	for plyr in playerArray:
		for route in plyr.completedRoutes:
			var routeArray = r.splitRoute(route)
			var city1 = routeArray[0]
			var city2 = routeArray[1]
			plyr._update_connections(city1, city2, city1, 0, {})
			plyr._update_connections(city2, city1, city2, 0, {})
			if plyr.longestRoute > longestRoute:
				longestRoutePlayer = plyr
				longestRoute = plyr.longestRoute
	print(longestRoutePlayer.playerColor, " player wins longest route with ", longestRoute, " trains!")
	longestRoutePlayer.scoreMarker._move_marker(10, longestRoutePlayer)

func calculate_ticket_points(plyr : player):
	for ticket in plyr.tickets:
		_display_error(ticket.name)
		var cities = r.splitRoute(ticket.name)
		var city1 = cities[0]
		var city2 = cities[1]
		if city2 in plyr.connections[city1]:
			await(plyr.scoreMarker._move_marker(r.ticketDict[ticket.name], plyr))
	
			
