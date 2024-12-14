extends Node
class_name player

var playerNum
var playerColor = "blue"
var trains = 3
var trainHand := hand.new()
var connections = {"Vancouver": {}, "Seattle": {}, "Portland": {}, "San Francisco": {}, "Los Angeles": {}, "Calcary": {}, "Helena": {}, "Salt Lake City": {}, "Las Vegas": {}, "Phoenix": {}, "Winnipeg": {}, "Duluth": {}, "Denver": {}, "Santa Fe": {}, "El Paso": {}, "Omaha": {}, "Kansas City": {}, "Oklahoma City": {}, "Dallas": {}, "Houston": {}, "Sault St Marie": {}, "Toronto": {}, "Chicago": {}, "Saint Louis": {}, "Little Rock": {}, "New Orleans": {}, "Pittsburgh": {}, "Nashville": {}, "Atlanta": {}, "Miami": {}, "Montreal": {}, "Boston": {}, "New York": {}, "Washington": {}, "Raleigh": {}, "Charleston": {}}
var completedRoutes = {}
var longestRoute := 0
var score := 0
var scoreMarker
var updatedCities = {}
var tickets = []                                                         

func _add_route(route : String):
	if route[-1] == "2":
		route = route.get_slice("2", 0)
	completedRoutes[route] = null

func _update_connections(city1: String, city2: String, newCity: String, trains: int, visitedRoutes: Dictionary):
	# new city = city now connected to, city1 = city2 in last recursive call, city2 = new city in current recursive call
	var route
	if newCity not in connections[city2].keys(): # add connection to player connections dictionary
		connections[city2][newCity] = 0 
		connections[newCity][city2] = 0
	if r.routes.has(city1 + "-" + city2): # find route name
		route = city1 + "-" + city2
	else:
		route = city2 + "-" + city1
	#print("route = ", route)
	var routeDistance = trains + r.routes[route][0] # trains in current route plus trains in all routes leading to recursive call
	if  routeDistance > connections[city2][newCity]: # check if connection between cities is longer than previous longest connection
		connections[city2][newCity] = routeDistance
		connections[newCity][city2] = routeDistance
		if routeDistance > longestRoute: # check for longest route
			longestRoute = routeDistance
	print(city2, "-", newCity, ": ", routeDistance)
	visitedRoutes[route] = null
	for nextCity in connections[city2].keys():
		if ((_check_route_completed(city2, nextCity) and _check_route_not_visited(city2, nextCity, visitedRoutes)) or (_check_route_completed(nextCity, city2) and _check_route_not_visited(nextCity, city2, visitedRoutes))): # make sure route exists and has not been visited
				_update_connections(city2, nextCity, newCity, routeDistance, visitedRoutes)
	if city2 == newCity: # circle detected
		print("Circle")
		var circleCities = {}
		for circleRoute in visitedRoutes: # get all cities in circle
			var circleCityArray = r.splitRoute(circleRoute)
			var circleCity1 = circleCityArray[0]
			var circleCity2 = circleCityArray[1]
			circleCities[circleCity1] = null
			circleCities[circleCity2] = null
			connections[circleCity1][circleCity1] = routeDistance
			connections[circleCity2][circleCity2] = routeDistance
		for completedRoute in completedRoutes:
			var completedRouteArray = r.splitRoute(completedRoute)
			var completedRouteCity1 = completedRouteArray[0]
			var completedRouteCity2 = completedRouteArray[1]
			if completedRouteCity1 in circleCities and completedRouteCity2 not in circleCities:
				_update_connections(completedRouteCity1, completedRouteCity2, completedRouteCity1, routeDistance, visitedRoutes)
			if completedRouteCity2 in circleCities and completedRouteCity1 not in circleCities:
				_update_connections(completedRouteCity2, completedRouteCity1, completedRouteCity2, routeDistance, visitedRoutes)
				
				
			
			
	#print(connections)
	visitedRoutes.erase(route)
	
func _check_route_not_visited(city1 : String, city2 : String, visitedRoutes : Dictionary) -> bool:
	if ((city1 + "-" + city2) not in visitedRoutes):
		return true
	return false
	
func _check_route_completed(city1 : String, city2 : String) -> bool:
	if (city1 + "-" + city2) in completedRoutes:
		return true
	return false
	
func _organize_tickets(newCards : Array):
	for card in newCards:
		tickets.push_back(card)
	var viewport_size = Vector2(1600, 1000)
	var position = viewport_size*Vector2(0.925, 0.9999)
	var column = 0
	for card in tickets:
		print(column)
		var tween = card.get_tree().create_tween()
		tween.tween_property(card, "position", position, 0.3)
		column = (column + 1) % 3
		if column == 2:
			position += Vector2(-220, -150)
			column = 0
		else:
			position += Vector2(220, 0)
			
func _print():
	print("number: ", playerNum)
	print("color: ", playerColor)
	print("trains: ", trains)
		
		
func _hide_tickets(): # move tickets down at end of turn
	for card in tickets:
		var tween = card.get_tree().create_tween()
		tween.parallel().tween_property(card, "position", card.position + Vector2(0, 1000), 0.7)

func _reveal_tickets(): # move tickets back up at beginning of turn
	for card in tickets:
		var tween = card.get_tree().create_tween()
		tween.parallel().tween_property(card, "position", card.position + Vector2(0, -1000), 0.7)
