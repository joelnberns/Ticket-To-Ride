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
@onready var discardZ = 10
var numberOfPlayers = 1
var numberOfCPUPlayers = 2
var totalPlayers
var lastTurn = false
var turnsLeft
var scoreMarker = preload("res://scoreMarker.tscn")
var playerInfo = preload("res://playerInfo.tscn")
signal initialTicketsSelected



func _on_game_start_game_started(humanPlayers: Variant, computerPlayers: Variant) -> void:
	print(numberOfPlayers, " and ", numberOfCPUPlayers)
	numberOfPlayers = humanPlayers
	numberOfCPUPlayers = computerPlayers
	$gameStart.visible = false
	_setup()
	
	
func _setup():
	totalPlayers = numberOfCPUPlayers + numberOfPlayers
	turnsLeft = totalPlayers
	SignalBus.betweenTurns = false
	$"Start Turn".visible = false
	for route in $TtrBoard2/Routes2.get_children():
		SignalBus.route_selected.connect(_on_route_selected)
	_startup()
	
func _startup():
	for i in range(numberOfPlayers): #initialize human players
		var newPlayer = player.new()
		var randColor = randi_range(0, colorArray.size()-1)
		newPlayer.playerColor = colorArray.pop_at(randColor)
		var score = scoreMarker.instantiate()
		$TtrBoard2.add_child(score)
		newPlayer.scoreMarker = score
		newPlayer.scoreMarker._setup(newPlayer.playerColor)
		playerArray.push_back(newPlayer)
		newPlayer.playerNum = i
	#for newPlayer in playerArray:
		#only for testing:
		#await newPlayer.scoreMarker._move_marker(10, newPlayer, 1)
		
	for i in range(numberOfCPUPlayers):
		var newPlayer = player.new()
		newPlayer.CPU = true
		var randColor = randi_range(0, colorArray.size()-1)
		newPlayer.playerColor = colorArray.pop_at(randColor)
		var score = scoreMarker.instantiate()
		$TtrBoard2.add_child(score)
		newPlayer.scoreMarker = score
		newPlayer.scoreMarker._setup(newPlayer.playerColor)
		playerArray.push_back(newPlayer)
		newPlayer.playerNum = i + numberOfPlayers
	
	var guiPosition = Vector2(1300, 0)	
	for newPlayer in playerArray:
		newPlayer.gui = playerInfo.instantiate()
		add_child(newPlayer.gui)
		newPlayer.gui._set_new_position(guiPosition)
		newPlayer.gui._set_color(newPlayer.playerColor)
		newPlayer.gui._unset_current_player(newPlayer.playerColor)
		guiPosition += Vector2(120, 0)
	
	currentPlayer = playerArray[0]
	currentPlayer.gui._set_current_player()
	
	#testing
	
	for i in range(numberOfPlayers):
		ticketsDrawn = true
		await $tickets._on_deck_button_up(1)
		await initialTicketsSelected
	ticketsDrawn = false
		
		
		
	

func _on_deck_card_drawn(cardBase: Variant) -> void:
	if not SignalBus.betweenTurns:
		if currentPlayer.CPU:
			currentPlayer.trainHand._CPU_draw_card(cardBase)
		else:
			currentPlayer.trainHand.draw_card(cardBase)
			if wildDrawnFromDisplay == false and cardTaken == false:
				cardTaken = true
			else:
				cardTaken = false
				wildDrawnFromDisplay = false
				await(_next_player())
			
func _on_deck_wild_drawn_fron_display() -> void:
	wildDrawnFromDisplay = true
			

	
func discard():
	for card in currentPlayer.trainHand.selectedCards:
		card.z_index = discardZ
		discardZ += 1
		$TtrBoard2/Deck.discard.push_back(card)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", $TtrBoard2/Deck/Discard.position, 0.5).from(card.position)
		currentPlayer.trainHand.cards.erase(card)
	currentPlayer.trainHand.selectedCards.clear()
	if not currentPlayer.CPU:
		currentPlayer.trainHand._reorganize_hand()
	
func _on_route_selected(route: Variant, trains: Variant):
	if not SignalBus.betweenTurns:
		if cardTaken:
			_display_error("Already drew a card!", "red")
			return
		if ticketsDrawn:
			_display_error("Already drew tickets!", "red")
			return
			$"Error Message".visible = false
		#if _check_route_valid(route):
		if true:
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
			r.completedRoutes.push_back(route.name)
			currentPlayer._update_connections(city1, city2, city1, 0, {})
			currentPlayer._update_connections(city2, city1, city2, 0, {})
			currentPlayer.gui._set_trains(currentPlayer.trains)
			currentPlayer.gui._set_score(currentPlayer.score + pointsArray[route.get_children().size()])
			currentPlayer.scoreMarker._move_marker(pointsArray[route.get_children().size()], currentPlayer, 1)
			if turnsLeft <= 1:
				await(currentPlayer.scoreMarker.marker_moved)
			if currentPlayer.trains <= 2:
				_display_error("Final Turn!", "red")
				lastTurn = true
			await(_next_player())
		
		
		
func _check_route_valid(route: Variant) -> bool:
	if currentPlayer.trainHand.selectedCards.size() != route.get_children().size():
		_display_error("wrong number of cards selected!", "red")
		return false
	if not _correct_cards_selected(route.name):
		return false
	if currentPlayer.trains < r.routes[route.name][0]:
		_display_error("not enough trains!", "red")
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
				_display_error("wrong cards!", "red")
				return false
	else:
		for card in currentPlayer.trainHand.selectedCards:
			if (card.cardColor != color) and (card.cardColor != "wild"):
				_display_error("wrong cards!", "red")
				return false
	return true
		

func _on_tickets_tickets_selected(tickets: Array) -> void:
	if not SignalBus.betweenTurns:
		if cardTaken:
			_display_error("Already drew a card!", "red")
			return
		ticketsDrawn = true
		await currentPlayer._organize_tickets(tickets)
		await(_next_player())
		ticketsDrawn = false
		emit_signal("initialTicketsSelected")

func _next_player():
	ticketsDrawn = false
	if lastTurn:
		turnsLeft -= 1
	SignalBus.betweenTurns = true
	$"Start Turn/Timer".start()
	await $"Start Turn/Timer".timeout
	currentPlayer.trainHand._hide_cards()
	currentPlayer.gui._unset_current_player(currentPlayer.playerColor)
	await(currentPlayer._hide_tickets())
	if turnsLeft == 0:
		get_tree().create_timer(1)
		_end_game()
		return
		
	if playerArray[(currentPlayer.playerNum + 1) % totalPlayers].CPU:
		$"Start Turn/Timer".start()
		await $"Start Turn/Timer".timeout
		currentPlayer = playerArray[(currentPlayer.playerNum + 1) % totalPlayers]
		currentPlayer.gui._set_current_player()
		SignalBus.betweenTurns = false
		_CPU_turn()
		return
	
	$"Start Turn".text = str("Begin ", playerArray[(currentPlayer.playerNum + 1) % totalPlayers].playerColor, " player's turn")
	$"Start Turn".visible = true
	await $"Start Turn".button_up
	$"Start Turn".visible = false
	currentPlayer = playerArray[(currentPlayer.playerNum + 1) % totalPlayers]
	currentPlayer.gui._set_current_player()
	currentPlayer.trainHand._reveal_cards()
	currentPlayer._reveal_tickets()
	SignalBus.betweenTurns = false
	
func _display_error(message : String, color : String):
	$"Error Message".visible = true
	$"Error Message".modulate = Color(color)
	$"Error Message".text = str(message)
	$"Error Message/Error Timer".start()
	await $"Error Message/Error Timer".timeout
	$"Error Message".visible = false
	
func _end_game():
	$"Start Turn".visible = false
	$"Error Message".position += Vector2(0, 100)
	_display_error("game over!", "red")
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
	
	_display_error(str(longestRoutePlayer.playerColor, " player wins longest route with ", longestRoute, " trains!"), longestRoutePlayer.playerColor)
	await longestRoutePlayer.scoreMarker._move_marker(10, longestRoutePlayer, 1)
	var endTimer = get_tree().create_timer(0.5)
	await endTimer.timeout
	var winner : player
	var highestScore = -100
	for plyr in playerArray:
		if not plyr.CPU:
			await _calculate_ticket_points(plyr)
			if plyr.score > highestScore:
				highestScore = plyr.score
				winner = plyr
		else:
			_display_error(str(plyr.playerColor, " player scores 10 points from routes!"), plyr.playerColor)
			await(plyr.scoreMarker._move_marker(10, plyr, 1))
			if plyr.score > highestScore:
				highestScore = plyr.score
				winner = plyr
	await _display_error(str(winner.playerColor, " wins!"), winner.playerColor)
	while(true):
		pass

func _calculate_ticket_points(plyr : player):
	$"Error Message".modulate = Color(plyr.playerColor)
	for ticket in plyr.tickets:
		var cities = r.splitRoute(ticket.name)
		var city1 = cities[0]
		var city2 = cities[1]
		_display_error(ticket.name, plyr.playerColor)
		if city2 in plyr.connections[city1]:
			await(plyr.scoreMarker._move_marker(r.ticketDict[ticket.name], plyr, 1))
		else:
			await(plyr.scoreMarker._move_marker(r.ticketDict[ticket.name], plyr, -1))
			var endTimer = get_tree().create_timer(0.5)
			await endTimer.timeout
			 
			
			
func _CPU_turn():
	var randNum = randf_range(0, 1)
	if randNum <= 0.55:
		await(_CPU_draw_card())
	else:
		var CPURoute = currentPlayer._CPU_select_route()
		if CPURoute:
			await(_on_route_selected(_CPU_find_route(CPURoute), null))
		else:
			await(_CPU_draw_card())
	
func _CPU_draw_card():
	for i in range(2):
		var displaySpot = currentPlayer._CPU_draw_card($TtrBoard2/Deck.display)
		if displaySpot:
			await($TtrBoard2/Deck._CPU_draw_card(displaySpot))
		else:
			await($TtrBoard2/Deck._on_deck_draw_button_up())
		await(get_tree().create_timer(0.5).timeout)
	await(_next_player())
		
func _CPU_find_route(route : String):
	for routeNode in $TtrBoard2/Routes2.get_children():
		if route == routeNode.name:
			return routeNode
