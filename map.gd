extends Node2D

const legionScene = preload("res://units/legion.tscn")
const lieutenantScene = preload("res://units/lieutenant_unit.tscn")
const borderLineScene = preload("res://sectio_border_line_2d.tscn")

var possibleNeighbours = []
var _selectedUnit = null
var recruitLieutenant = false

var playerpolygons =  {}
var playerPolygonsLeft = []

signal unitPlacingDone
#signal demonDone(passAction)
signal fleeConfirmation(boolean)

signal unitFinishedFleeing
var fleeRequestId
#var sectioAttackedFrom

var tw1

var map_fx_path : String = "res://map_fx/map_fx.tscn"

var mouseLightScene = preload("res://mouse_light.tscn")
var mouseLights : Dictionary = {}

func _ready():
	Signals.confirmFlee.connect(_on_confirm_flee)
	Signals.sectiosClickable.connect(sectiosClickable)
	Signals.sectiosUnclickable.connect(sectiosUnclickable)
	Signals.demonActionDone.connect(_on_demonActionDone)
	Signals.sectioClicked.connect(_on_sectioClicked)
	Signals.neighbours.connect(on_neighbours)
	Signals.changeSectioBackground.connect(_on_changeSectioBackground)
	Signals.march.connect(_on_march)
	Signals.placeLegion.connect(_on_placeLegion)
	Signals.placeLieutenant.connect(_on_placeLieutenant)
	Signals.moveUnits.connect(moveUnits)
	Signals.summoningDone.connect(_on_summoningDone)
	Signals.buildCircles.connect(buildCircles)
	Signals.initSectios.connect(initSectios)
	Signals.initMouseLights.connect(_on_initMouseLights)
	Signals.spawnUnit.connect(_on_spawnUnit)
	Signals.potatoPc.connect(_on_potatoPc)
	
	# Engine.is_editor_hint()
	# only useful for tool scripts
#	while not ResourceLoader.load_threaded_get_status(map_fx_path) == 3:
#		print("loading")
#	var fxScene = ResourceLoader.load_threaded_get(map_fx_path)

	
	Settings.debug = false
	if OS.has_feature("editor"):
		if not Settings.debug:
			var fx = load("res://map_fx/map_fx.tscn")
			var f = fx.instantiate()
			$MapSprites2.add_child(f)
	else:
		var fx = load("res://map_fx/map_fx.tscn")
		var f = fx.instantiate()
		$MapSprites2.add_child(f)
		
#	call1()
	setupLightning()
	
#	ResourceLoader.load_threaded_request(map_fx_path)
	await get_tree().create_timer(4.01).timeout
	promtToFlee(Data.id, "Bad People")

var loaded = false
func _process(delta):
	if mouseLights.has(Data.id):
		mouseLights[Data.id].position = get_local_mouse_position()
#	print(ResourceLoader.load_threaded_get_status(map_fx_path))
#	if ResourceLoader.load_threaded_get_status(map_fx_path) == 3 and not loaded:
#		loaded = true
#		var fxScene = ResourceLoader.load_threaded_get(map_fx_path)
#		var f = fxScene.instantiate()
#		$MapSprites2.add_child(f)


@onready var startpos = %LightningPointLight2D.position
func setupLightning():
	var time : float = randf_range(1.0, 4.0)
	%LightningTimer.wait_time = time
	%LightningTimer.start()
	var pos_x : int = randi_range(-3000, 3000)
	var pos_y : int = randi_range(-2500, 2500)
	var pos : Vector2 = Vector2(pos_x, pos_y)
	%LightningPointLight2D.energy = 0.0
	%LightningPointLight2D.position = pos
	%LightningPointLight2D.height = randi_range(50,150)
	%LightningPointLight2D.scale.x = randf_range(2, 6)
	var tw1 : Tween = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	var tw2 : Tween = get_tree().create_tween()
	tw2.set_trans(Tween.TRANS_QUAD)
	tw2.set_ease(Tween.EASE_IN)
	var count : int = randi_range(2, 5)
	for i in count:
		var delay : float = randf_range(0.01, 0.05)
		var t1 : float = randf_range(0.001, 0.01)
		var t2 : float = randf_range(0.02, 0.2)
		var shift : Vector2 = Vector2(randf_range(-400.0, 400.0), randf_range(-400.0, 400.0))
		tw1.tween_property(%LightningPointLight2D, "energy", randf_range(1.0, 2.0), t1).set_delay(delay)
		tw1.tween_property(%LightningPointLight2D, "energy", 0, t2)
		tw2.tween_property(%LightningPointLight2D, "position", pos + shift, t1 + t2).set_delay(delay)
#	tw1.tween_property(%LightningPointLight2D, "energy", 2, 0.1)
#	tw1.tween_property(%LightningPointLight2D, "energy", 0, 0.2)


func call1():
#	tw1.stop()
	var tw1 = get_tree().create_tween()
	tw1.set_parallel(true)
	
	var i = randf_range(1.0, 1.5)
	var t = randf_range(1.2, 3.5)
	
	tw1.set_trans(Tween.TRANS_CUBIC)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(%PointLight2D, "energy", i, t)
	
	var h = randi_range(200, 300)
	tw1.tween_property(%PointLight2D, "height", h, t)
	
	tw1.tween_callback(call2).set_delay(t)


func call2():
#	print("2")
#	tw1.stop()
	
	var tw1 = get_tree().create_tween()
	tw1.set_parallel(true)
	
	var i = randf_range(0.5, 1.0)
	var t = randf_range(1.2, 3.5)
	
	tw1.set_trans(Tween.TRANS_CUBIC)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(%PointLight2D, "energy", i, t)
	
	var h = randi_range(200, 300)
	tw1.tween_property(%PointLight2D, "height", h, t)
	
	tw1.tween_callback(call1).set_delay(t)


func _on_placeLegion(sectio : Sectio, playerId : int):
	placeUnit(sectio, playerId, Data.UnitType.Legion)


func _on_placeLieutenant(sectio : Sectio, playerId : int, lieutenantName : String):
	placeUnit(sectio, playerId, Data.UnitType.Lieutenant, lieutenantName)


func _on_demonActionDone():
	pass
#	unselectUnit(_selectedUnit)

func buildCircles():
	var polygon_filenames : Array = [
		"res://map_fx/player_polygons/neutral_polygons.tscn",
		"res://map_fx/player_polygons/node_2d.tscn",
		"res://map_fx/player_polygons/player_1_polygons.tscn",
		"res://map_fx/player_polygons/player_1_polygons_2.tscn",
		"res://map_fx/player_polygons/player_1_polygons_3.tscn",
		"res://map_fx/player_polygons/player_1_polygons_4.tscn",
		"res://map_fx/player_polygons/player_1_polygons_5.tscn"
	]
	polygon_filenames.shuffle()
	var size : int = polygon_filenames.size()
	for player in size:
		var scene = load(polygon_filenames.pop_back()).instantiate()
		%Polygons.add_child(scene)
	
	for polygon in %Polygons.get_children():
		playerPolygonsLeft.append(polygon)
	
	var circleNr = 1
	var edges = [[],[],[],[],[]]
	for circles in $Sectios.get_children():
		var i = 0
		var circlePoints = []
		for sectio in circles.get_children():
			var _points = sectio.innerPoints.duplicate()
			edges[i].append(_points[0])
#			_points.remove_at(-1)
			_points.pop_back()
#			_points.remove_at(0)
			circlePoints += _points
			i += 1
			
		var circleline = borderLineScene.instantiate()
		if circlePoints.size() > 0:
			circlePoints.append(circlePoints[0])
		circleline.points = circlePoints
#		circleline.get_material().scroll1 =  circleline.get_material().scroll1 + Vector2(0.2, 0.1) * circleNr
#		circleline.get_material().scroll2 =  circleline.get_material().scroll2 + Vector2(0.1, 0.2) * circleNr
#		circleline.get_material().color2 = Data.player.color
		circleline.default_color = Data.player.color
		print(Vector2(0.1, 0.1) * circleNr)
		%BorderLinesNode2D.add_child(circleline)
		
		if circles.name == "Limbo":
			var ii = 0
			var outerCirclePoints = []
			for sectio in circles.get_children():
				print("sectio name ", sectio.name)
				var _points = sectio.outerPoints.duplicate()
				edges[ii].append(_points[-1])
#				_points.remove_at(-1)
				_points.pop_back()
				
#				_points.remove_at(0)
				outerCirclePoints = _points + outerCirclePoints
				ii += 1
		
			var outerCircleline = borderLineScene.instantiate()
			if outerCirclePoints.size() > 0:
				outerCirclePoints.append(outerCirclePoints[0])
			outerCircleline.points = outerCirclePoints
			outerCircleline.default_color = Data.player.color
#			outerCircleline.get_material().color2 = Data.player.color
			%BorderLinesNode2D.add_child(outerCircleline)
		
		circleNr += 1
	
	for edge in edges:
		var edgeline = borderLineScene.instantiate()
#		edgeline.get_material().color2 = Data.player.color
		edgeline.default_color = Data.player.color
		edgeline.points = edge
		%BorderLinesNode2D.add_child(edgeline)


func _on_initMouseLights():
	print("init lights ",Connection.peers)
	for id in Connection.peers:
		var mouseLight = mouseLightScene.instantiate()
		mouseLight.color = Data.players[id].color
		%MouseLights.add_child(mouseLight)
		mouseLights[id] = mouseLight


func initSectios():
	var sectiosArray = []
	var i = 0
	for circles in $Sectios.get_children():
		for sectio in circles.get_children():
			Decks.sectios[sectio.circle][sectio.quarter] = sectio
			sectiosArray.append(sectio.name)
			Decks.sectioNodes[sectio.name] = sectio
			
			sectio.id = i
			Astar.astar.add_point(i, sectio.global_position, 1.0)
			Astar.sectioIdsNodeDict[i] = sectio
			i += 1
			
#			var navigationNode
#			var navigationPolygon
#			var polygonPoints
#
#			navigationNode = NavigationRegion2D.new()
#			navigationPolygon = NavigationPolygon.new()
#			polygonPoints = sectio.polygonPoints
#			navigationPolygon.add_outline(polygonPoints)
#			navigationPolygon.make_polygons_from_outlines()
#			navigationNode.navpoly = navigationPolygon
#			navigationNode.position = sectio.startpoint
#			%NavigationNode2D.add_child(navigationNode)
#
#			navigationNode = NavigationRegion2D.new()
#			navigationPolygon = NavigationPolygon.new()
#			polygonPoints = sectio.polygonPoints
#			navigationPolygon.add_outline(polygonPoints)
#			navigationPolygon.make_polygons_from_outlines()
#			navigationNode.navpoly = navigationPolygon
#			navigationNode.position = sectio.startpoint
#			%NavigationNode2D.add_child(navigationNode)
	
	for sectioName in sectiosArray:
		var sectio = Decks.sectioNodes[sectioName]
		getPossibleNeighbours(sectio.circle, sectio.quarter)
#		var line = Line2D.new()
		for neighbour in possibleNeighbours:
#			line.add_point(sectio.position)
#			line.add_point(sectios[neighbour[0]][neighbour[1]].position)
			Astar.astar.connect_points(sectio.id, Decks.sectios[neighbour[0]][neighbour[1]].id, false)
#		add_child(line)
	
	sectiosArray.shuffle()
	Decks.sectioCards = sectiosArray


func first(baseAngle, angle, r):
	var angles = []
	var steps = 8
	var step = baseAngle / steps
	for a in range(steps/2, 0, -1):
		angles.append(angle + step * a)
	angles.append(angle)
	for a in range(1, steps/2+1):
		angles.append(angle - step * a)
	
	var points = []
	var outer = angles.duplicate()
	var inner = angles.duplicate()
	
	while outer.size() > 0:
		points.append(marker(r * 9 + r / 2, outer.pop_back()))
	while inner.size() > 0:
		points.append(marker(r * 9 - r / 2, inner.pop_front()))
	var marker = Polygon2D.new()
	marker.set_polygon(points)
	%Marker2D.add_child(marker)

func second(baseAngle, angle, r):
	var angles = []
	var steps = 8
	var step = baseAngle / steps
	for a in range(steps/2, 0, -1):
		angles.append(angle + step * a)
	angles.append(angle)
	for a in range(1, steps/2+1):
		angles.append(angle - step * a)
	
	var points = []
	var outer = angles.duplicate()
	var inner = angles.duplicate()
	
	while outer.size() > 0:
		points.append(marker(r * 9 + r / 2, outer.pop_back()))
	while inner.size() > 0:
		points.append(marker(r * 9 - r / 2, inner.pop_front()))
	var polygon = Polygon2D.new()
	polygon.set_polygon(points)
	%Marker2D.add_child(polygon)

func marker(radius, angle):
	var marker = %Marker.duplicate()
	%Marker.get_parent().add_child(marker)
	var x = radius*sin(angle) 
	var y = radius*cos(angle)
	marker.position = Vector2(x, y)
	return Vector2(x, y)

@rpc("any_peer", "call_local")
func addSpawner(id : int):
	if not has_node(str(id)):
		var folder = Node2D.new()
		folder.name = str(id)
		add_child(folder)
#	var node = $MultiplayerSpawner.duplicate()
##	var node = MultiplayerSpawner.new()
#	node.set_multiplayer_authority(id)
#	node.name = "MultiplayerSpawner"+str(id)
#	get_node(str(id)).add_child(node)
##	node.spawn_path = ".."#get_node("Legions"+str(id)).get_path()
##	node.add_spawnable_scene("res://legion.tscn")
##	print(get_node("Legions1/MultiplayerSpawner1").spawn_path)


func on_neighbours(node):
	possibleNeighbours = getPossibleNeighbours(node.circle, node.quarter)
	var isIsolated = true
#	print("new")
#	print(node)
	for neighbour in possibleNeighbours:
		#print(node.player, sectios[neighbour[0]][neighbour[1]].player)
#		print(sectios[neighbour[0]][neighbour[1]])
		if node.player == Decks.sectios[neighbour[0]][neighbour[1]].player:
			isIsolated = false
	node.isIsolated = isIsolated
	

func getPossibleNeighbours(occupiedCircle, occupiedQuarter):
	possibleNeighbours.clear()
	var circleDown = occupiedCircle - 1
	if not circleDown < 0:
		possibleNeighbours.append([circleDown, occupiedQuarter])
	
	var circleUp = occupiedCircle + 1
	if not circleUp > 8:
		possibleNeighbours.append([circleUp, occupiedQuarter])
	
#	var quarterClockwise = occupiedQuarter + 1
	var quarterClockwise = posmod((occupiedQuarter + 1), 5)
#	if quarterClockwise > 4:
#		quarterClockwise = 0
	possibleNeighbours.append([occupiedCircle, quarterClockwise])
	
#	var quarterCounterclockwise = occupiedQuarter - 1
#	if quarterCounterclockwise < 0:
#		quarterCounterclockwise = 4
	var quarterCounterclockwise = posmod((occupiedQuarter - 1), 5)
	possibleNeighbours.append([occupiedCircle, quarterCounterclockwise])
	return possibleNeighbours

func changeClickableNeighbours(possibleNeighbours):
	neightboursClickable(true)


func _on_changeSectioBackground(id , playerPolygon):
	if not playerpolygons.has(id):
		playerpolygons[id] = playerPolygonsLeft.pop_back()
		var c = playerpolygons[id].get_material().get_shader_parameter("colorTexture").get_gradient().get_colors()
		c[1] = Data.players[id].color
		playerpolygons[id].get_material().get_shader_parameter("colorTexture").get_gradient().set_colors(c) 
		
	for polygons in %Polygons.get_children():
		for polygon in polygons.get_children():
			if polygon == playerPolygon:
				polygons.remove_child(polygon)
	playerpolygons[id].add_child(playerPolygon)
	playerPolygon.set_light_mask(4) # this might be better at init


func sectiosUnclickable():
	for sectio in Decks.sectioNodes.values():
		sectio.changeClickable(false)

func sectiosClickable():
	for troop in Data.player.troops.values():
		var sectio = Decks.sectioNodes[troop.occupiedSectio]
		var enemyInSectio = false
		for unitName in sectio.troops:
			var unit = Data.troops[unitName]
			if not unit.triumphirate == Data.id:
				enemyInSectio = true
		if not enemyInSectio:
			sectio.changeClickable(true)


func _on_summoningDone():
	Signals.sectioClicked.emit(null)


func _unhandled_input(event):
	if Input.is_action_just_pressed("right_click"):
		if Data.state == Data.States.MARCHING:
			Signals.sectioClicked.emit(null)
		elif Data.state == Data.States.RECRUITING:
			Signals.sectioClicked.emit(null)
#		if not _selectedUnit == null:
#			if not _selectedUnit.fleeing:
#				unselectUnit(_selectedUnit)
#				if enoughSkullsToMoveAgain():
#					sectiosClickable()
	if Input.is_action_pressed("click"):
		pass
#		var destination = get_local_mouse_position()
#		legio.set_destination(destination)
		#print(destination)
	if event is InputEventMouseMotion:
		for peer in Connection.peers:
			moveMouse.rpc_id(peer, Data.id, get_local_mouse_position())


@rpc("any_peer", "call_local")
func moveMouse(id : int, pos : Vector2):
	if mouseLights.has(id):
		mouseLights[id].position = pos


func enoughSkullsToMoveAgain():
	if Data.currentDemon.skullsUsed < Data.currentDemon.skulls:
		return true
	else:
		return false


@rpc("any_peer", "call_local")
func placingDone():
	print("emitted")
	unitPlacingDone.emit()


@rpc("any_peer", "call_local")
func updateTroopInSectio(sectioName, troops):
	var sectio = Decks.sectioNodes[sectioName]
	sectio.troops = troops
	print(Data.id, " ",sectioName, " update sectio troops ", sectio.troops)


@rpc("any_peer", "call_local")
func promtToFlee(triumphirate : int, sectioName : String, sectioAttackedFromName : String = "", fleeFromCombat : bool = false):
	fleeRequestId = multiplayer.get_remote_sender_id()
	if Connection.peers.has(triumphirate):
		var sectioToFleeFrom = Decks.sectioNodes[sectioName]
		var sectioAttackedFrom
		if not sectioAttackedFromName == "":
			sectioAttackedFrom = Decks.sectioNodes[sectioAttackedFromName]

		Signals.fleeDialog.emit(sectioName, fleeFromCombat)
		AudioSignals.enemyEnteringSectio.emit()
		
		var fleeing = await Signals.confirmFlee
		if Tutorial.tutorial:
			if Tutorial.currentTopic == Tutorial.Topic.FleePromt:
				fleeing = true
		print("fleeing from 1 ", sectioName)
		if fleeing:
			Signals.hideFleeControl.emit()
			var result = await flee(sectioToFleeFrom, sectioAttackedFrom)
			print("fleeing from 2 ", sectioName)
			
			confirmToFlee.rpc_id(fleeRequestId, true)
		else:
			Signals.hideFleeControl.emit()
			confirmToFlee.rpc_id(fleeRequestId, false)
			print("fleeing from 3 ", sectioName)
	else:
		confirmToFlee.rpc_id(fleeRequestId, false)


@rpc("any_peer", "call_local")
func promtForceToFlee(triumphirate : int, sectioName : String, sectioAttackedFromName : String = ""):
	fleeRequestId = multiplayer.get_remote_sender_id()
#	if Connection.peers.has(triumphirate):
	var sectioToFleeFrom = Decks.sectioNodes[sectioName]
	var sectioAttackedFrom
	if not sectioAttackedFromName == "":
		sectioAttackedFrom = Decks.sectioNodes[sectioAttackedFromName]
#	Signals.forceFleeDialog.emit()
	await flee(sectioToFleeFrom, sectioAttackedFrom)
	confirmToFlee.rpc_id(fleeRequestId, true)
#	else:
#		confirmToFlee.rpc_id(fleeRequestId, true)


func fleeFromCombat(triumphirate : int, sectio):
	promtToFlee.rpc_id(triumphirate, triumphirate, sectio.sectioName, "", true)
	var fleeingConfirmed = await fleeConfirmation
	print("fleeFromCombat ", fleeingConfirmed)
	if fleeingConfirmed:
		Signals.endCombat.emit()
	return fleeingConfirmed
#	_on_confirm_flee_button_pressed()
#	return true


func forceFleeFromCombat(triumphirate : int, sectio):
	if triumphirate < 0:
		return true
	promtForceToFlee.rpc_id(triumphirate, triumphirate, sectio.sectioName)
	await fleeConfirmation
#	var fleeingConfirmed = await fleeConfirmation
#	return fleeingConfirmed
	return true




@rpc("any_peer", "call_local")
func confirmToFlee(boolean):
	fleeConfirmation.emit(boolean)

@rpc("any_peer", "call_local")
func removeUnit(unitName):
	var unit = Data.troops[unitName]
	Data.troops.erase(unitName)
	Data.players[unit.triumphirate].troops.erase(unitName)
	if not Connection.dedicatedServer:
		Data.player.troops.erase(unitName)
	unit.kill()


func moveUnits(troopsToMove, oldSectio : Sectio, sectio : Sectio):
	if troopsToMove.is_empty():
		return
	
	var playerId = troopsToMove[0].triumphirate
	
	var friendlyUnits : Array = []
	for unitName in sectio.troops:
		var unit = Data.troops[unitName]
		if unit.triumphirate == playerId:
			friendlyUnits.append(unit)
	
	for troop in troopsToMove:
		oldSectio.troops.erase(troop.unitNr)
	for peer in Connection.peers:
		updateTroopInSectio.rpc_id(peer, oldSectio.sectioName, oldSectio.troops)
	
	for troop in troopsToMove:
		sectio.troops.append(troop.unitNr)
		troop.occupiedSectio = sectio.sectioName
		for peer in Connection.peers:
			troop.changeSectio.rpc_id(peer, sectio.sectioName, sectio.circle, sectio.quarter)
	for peer in Connection.peers:
		updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)
	
	
	var i = sectio.slots.find(playerId)
	var destination : Vector2 = sectio.slotPositions[i]
	
	var zIndex : int = 1
	for unit in friendlyUnits:
		destination += Vector2(0, -32)
		unit.global_position = destination
		unit.z_index = zIndex
		zIndex += 1
	
	print("destination ", destination, " ",i ," ",sectio.slots, " ",sectio.slotPositions)
	
	for troop in troopsToMove:
		var destinations : Array
		if oldSectio.global_position.distance_to(destination) < troop.global_position.distance_to(destination):
			destinations.append(oldSectio.global_position)
		# clockwise
		if posmod((oldSectio.quarter + 1), 5) == sectio.quarter:
			destinations.append(oldSectio.clockwisePoint)
		# counterclockwise
		if posmod((oldSectio.quarter - 1), 5) == sectio.quarter:
			destinations.append(oldSectio.counterclockwisePoint)
		
		if troop.global_position.distance_to(sectio.global_position) < troop.global_position.distance_to(destination):
			destinations.append(sectio.global_position)
		
		destination += Vector2(0, -32)
		destinations.append(destination)
		troop.z_index = zIndex
		zIndex += 1
		
		troop.set_destinations(destinations)


@rpc("any_peer", "call_local")
func placeFirstLegion():
	Signals.help.emit(Data.HelpSubjects.PlaceFirstLegion)
	for sectioName in Data.player.sectios:
		Decks.sectioNodes[sectioName].changeClickable(true)
	var sectio = await Signals.sectioClicked
	placeUnit(sectio, Data.id, Data.UnitType.Legion)
	print("w2 ",Connection.host)
	placingDone.rpc_id(Connection.host)
	for sectioName in Data.player.sectios:
		Decks.sectioNodes[sectioName].changeClickable(false)


func _on_march():
	while Data.currentDemon.skullsUsed < Data.currentDemon.skulls:
		Signals.sectiosClickable.emit()
		Data.changeState(Data.States.IDLE)
		
		var sectio = await Signals.sectioClicked
		var selectedUnit
		if not sectio:
			sectiosUnclickable()
			Data.changeState(Data.States.IDLE)
			break
		elif sectio.troops.size() == 1:
			Data.changeState(Data.States.MARCHING)
			sectiosUnclickable()
			neightboursClickable(false)
			var unitName = sectio.troops[0]
			selectedUnit = Data.troops[unitName]
			selectedUnit.sectiosMoved = 0
			possibleNeighbours = getPossibleNeighbours(selectedUnit.occupiedCircle, selectedUnit.occupiedQuarter)
			changeClickableNeighbours(possibleNeighbours)
		else:
			sectiosUnclickable()
			neightboursClickable(false)
			Signals.pickUnit.emit(sectio)
			selectedUnit = await Signals.unitClicked
			if selectedUnit:
#				Signals.unitSelected.emit()
				Data.changeState(Data.States.MARCHING)
				sectiosUnclickable()
				neightboursClickable(false)
				selectedUnit.sectiosMoved = 0
				possibleNeighbours = getPossibleNeighbours(selectedUnit.occupiedCircle, selectedUnit.occupiedQuarter)
				changeClickableNeighbours(possibleNeighbours)
			else:
				continue
		# bug, wait shortly otherwise the sectio gets clicked, this should not happen
		await get_tree().create_timer(0.01).timeout
		#print(selectedUnit, " moved1 ", selectedUnit.sectiosMoved)
		var unitsAlreadyMovingWithLieutenant : Array = []
		while selectedUnit.sectiosMoved < selectedUnit.maxSectiosMoved:
			#print(selectedUnit, " moved2 ", selectedUnit.sectiosMoved)
			possibleNeighbours = getPossibleNeighbours(sectio.circle, sectio.quarter)
			changeClickableNeighbours(possibleNeighbours)
			selectedUnit.showMovesLeft(true, selectedUnit.maxSectiosMoved - selectedUnit.sectiosMoved)
			
			sectio = await Signals.sectioClicked
			if not sectio:
				neightboursClickable(false)
				break
			
			# move only as many troops as there are skulls on the demon
			# if the sectiosMoved is 1, then it doesnt count the second move
			if selectedUnit.sectiosMoved == 0:
				Data.currentDemon.skullsUsed += 1
				Signals.skullUsed.emit()
			
			selectedUnit.sectiosMoved += 1
			
			var unitsToMove = [selectedUnit]
			
			var oldSectio = Decks.sectioNodes[selectedUnit.occupiedSectio]
			
			if selectedUnit.unitType == Data.UnitType.Lieutenant:
				var legionsToMoveWithLieutenant = []
				for troopName in oldSectio.troops:
					var troop = Data.troops[troopName]
					if not troop.triumphirate == Data.id or troop.unitType == Data.UnitType.Lieutenant:
						continue
					legionsToMoveWithLieutenant.append(troop)
				if legionsToMoveWithLieutenant.size() > 0:
					unitsAlreadyMovingWithLieutenant = await pickLegions(legionsToMoveWithLieutenant.duplicate(), unitsAlreadyMovingWithLieutenant.duplicate(), selectedUnit.capacity)
					unitsToMove = unitsToMove + unitsAlreadyMovingWithLieutenant
			
			moveUnits(unitsToMove, oldSectio, sectio)
			
			neightboursClickable(false)
			
			%MarchAudio.play()
			
			var enemies = 0
			var enemiesFled = 0
			var fleeingConfirmed = false
			for unitNr in sectio.troops:
				var unit = Data.troops[unitNr]
				if unitNr == selectedUnit.unitNr:
					continue
				if not unit.triumphirate == selectedUnit.triumphirate:
					# solitary lieutenant would have to flee automatically
					print("enemy in sectio")
					enemies += 1
					if Connection.peers.has(unit.triumphirate):
						promtToFlee.rpc_id(unit.triumphirate, unit.triumphirate, sectio.sectioName, oldSectio.sectioName)
					else:
						promtToFlee.rpc_id(Connection.host, unit.triumphirate, sectio.sectioName, oldSectio.sectioName)
					%EventDialog.popup()
					%EventDialog.dialog_hide_on_ok = false
					%EventDialog.dialog_text = "Waiting for the other player to either flee or stay."
					if Connection.peers.has(unit.triumphirate):
						fleeingConfirmed = await fleeConfirmation
					%EventDialog.dialog_hide_on_ok = true
					if fleeingConfirmed:
						enemiesFled += 1
		#						%EventDialog.dialog_text = "The Enemy fled."
					else:
						%EventDialog.dialog_text = "The Enemy is choosing to stay and fight."
					AudioSignals.enemyEnteringSectioResult.emit(fleeingConfirmed)
					print("result of flee ", fleeingConfirmed)
					break
				else:
					print("friend in sectio")
			
			if enemies > 0 and not fleeingConfirmed:
				neightboursClickable(false)
				break
			
			var  troopsRemaining = false
			for troopName in sectio.troops:
				var troop = Data.troops[troopName]
				if not troop.triumphirate == Data.id:
					troopsRemaining = true
				
			if troopsRemaining and fleeingConfirmed:
				%EventDialog.dialog_text = "The Enemy tried to flee but failed, stopping."
#				_on_unitMovedMax(selectedUnit)
				break

			if not troopsRemaining:
				%EventDialog.dialog_text = "The Enemy fled."
#		Signals.unitDeselected.emit()
		selectedUnit.showMovesLeft(false)
	Data.changeState(Data.States.IDLE)
	if Data.currentDemon.skullsUsed <= 0:
		Signals.cancelMarch.emit()
	else:
		Signals.demonDone.emit(null)
	


func _on_sectioClicked(sectio):
	return
#	var selectedUnit = _selectedUnit
	match Data.phase:
		# place one legion at start of match
		null:
			placeUnit(sectio, Data.id, Data.UnitType.Legion)
			placingDone.rpc_id(Connection.host)



func neightboursClickable(boolean):
	for neighbour in possibleNeighbours:
		if not neighbour == null:
			if not neighbour[0] == 666:
				Decks.sectios[neighbour[0]][neighbour[1]].changeClickable(boolean)


func flee(sectioToFleeFrom, sectioAttackedFrom):
	print("player ", Data.id, " starts to flee")
	var sectio = sectioToFleeFrom
	# collect troops first, because using the the troops array from the sectio
	# while mutating it, is a bad idea
	var troopsToFlee = []
	var lieutenantsToFlee = []
	for troopName in sectio.troops:
		var troop = Data.troops[troopName]
		if not troop.triumphirate == Data.id:
			continue
		if troop.unitType == Data.UnitType.Lieutenant:
			lieutenantsToFlee.append(troop)
		else:
			troopsToFlee.append(troop)
	for lieutenant in lieutenantsToFlee:
		_selectedUnit = lieutenant
		lieutenant.fleeing = true
#		troopsToFlee = await fleeAction(sectio, troopsToFlee, lieutenant)
		troopsToFlee = await fleeingLieutenant(sectio, troopsToFlee, lieutenant, sectioAttackedFrom)
#	await fleeAction(sectio, troopsToFlee)
	# rest of the Legions try to flee
	var tutorialCounter : int = 0
	for fleeingUnit in troopsToFlee:
		var forceFailTofFlee : bool = false
		if tutorialCounter > 0:
			forceFailTofFlee = true
		await fleeingLegion(sectioToFleeFrom, fleeingUnit, sectioAttackedFrom, forceFailTofFlee)
		if Tutorial.tutorial:
			tutorialCounter += 1
	var allFled = true
	for troopName in sectio.troops:
		var troop = Data.troops[troopName]
		if not troop.triumphirate == Data.id:
			continue
		return false
	if allFled:
		return true

#var fleetime = 1
func getFleeDirection(sectio, sectioAttackedFrom):
	var possibleNeighbours = []
#	if fleetime <= 1:
	possibleNeighbours = getPossibleNeighbours(sectio.circle, sectio.quarter)
	if sectioAttackedFrom:
		possibleNeighbours.erase([sectioAttackedFrom.circle, sectioAttackedFrom.quarter])
	while possibleNeighbours.size() < 4:
		possibleNeighbours.append(null)
#		fleetime += 1
#	else:
	possibleNeighbours.append([666])
	possibleNeighbours.append([666])
	
	var neighbour
	while neighbour == null:
		var _possibleNeighbours = possibleNeighbours.duplicate()
		_possibleNeighbours.shuffle()
		neighbour = _possibleNeighbours.pop_back()
		_possibleNeighbours.append(neighbour)
	return neighbour


func fleeingLegion(sectioToFleeFrom : Sectio, fleeingLegion, sectioAttackedFrom, forceToFail : bool = false):
	if Tutorial.tutorial:
		Signals.tutorial.emit(Tutorial.Topic.FleeWithLegion, "Legions flee in a random direction. ")
	var tutorialCounter : int = 0
	
	while true:
		Signals.moveCamera.emit(sectioToFleeFrom.global_position)
		var neighbour = getFleeDirection(sectioToFleeFrom, sectioAttackedFrom)
		# force the second legion to fail to flee
		if forceToFail:
			neighbour[0] = 666
		if neighbour[0] == 666:
			if Tutorial.tutorial:
				if Tutorial.currentTopic == Tutorial.Topic.FleeWithLegion and not forceToFail:
					continue
				Signals.tutorial.emit(Tutorial.Topic.FailToFlee, "Beware that your Units can fail to flee from a Sectio.")
			print("legion failed to flee from ", sectioToFleeFrom.sectioName)
			
			await fleeMessage(str(fleeingLegion.unitName), sectioToFleeFrom.sectioName)
			Signals.tutorialRead.emit()
			break
		var sectioToFleeTo : Sectio = Decks.sectios[neighbour[0]][neighbour[1]]
		
		for peer in Connection.peers:
			spinFleeArrows.rpc_id(peer, sectioToFleeFrom.sectioName, sectioToFleeTo.sectioName)
		await Signals.spinFleeArrowsStopped
		
		tutorialCounter += 1
		moveUnits([fleeingLegion], sectioToFleeFrom, sectioToFleeTo)
		
		Signals.moveCamera.emit(sectioToFleeTo.global_position)
		await fleeingLegion.arrivedAtDestination
		for peer in Connection.peers:
			hideFleeArrow.rpc_id(peer)
		var enemyInSectio = false
		for unitName in sectioToFleeTo.troops:
			var unit = Data.troops[unitName]
			if not unit.triumphirate == Data.id:
				print(fleeingLegion, " continues to flee")
				sectioToFleeFrom = sectioToFleeTo
				enemyInSectio = true
		if not enemyInSectio:
			break


@rpc("any_peer", "call_local")
func spinFleeArrows(sectioToFleeFromName : String, sectioToFleeToName : String):
	Signals.spinFleeArrows.emit(sectioToFleeFromName, sectioToFleeToName)


@rpc("any_peer", "call_local")
func hideFleeArrow():
	Signals.hideFleeArrow.emit()


func fleeingLieutenant(sectioToFleeFrom, fleeingTroops, lieutenant, sectioAttackedFrom):
	var failedToFlee = false
	
	# pick Legions to flee with Lieutenant
	var legionsFleeingWithLieutenant = []
	var legionsToMoveWithLieutenant = []
	for unitName in sectioToFleeFrom.troops:
		var unit = Data.troops[unitName]
		if not unit.triumphirate == Data.id or unit.unitType == Data.UnitType.Lieutenant:
			continue
		legionsToMoveWithLieutenant.append(unit)
	if legionsToMoveWithLieutenant.size() > 0:
		var unitsAlreadyMovingWithLieutenant : Array = []
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.PickLegionsToFleeWith, "Lieutenants can carry other Legions with them while fleeing. \nThe amount of Legions is limited by the number to the right of the Lieutenants Name.")
		legionsFleeingWithLieutenant = await pickLegions(fleeingTroops, unitsAlreadyMovingWithLieutenant, lieutenant.capacity)
		Signals.tutorialRead.emit()
		lieutenant.solitary = false
		print("lieutenant is not solitary ",lieutenant)
	else:
		print("lieutenant is solitary ",lieutenant)
		lieutenant.solitary = true
	print("legions picked ", legionsFleeingWithLieutenant)
	
	for legion in legionsFleeingWithLieutenant:
		fleeingTroops.erase(legion)
	
	while true:
		Signals.moveCamera.emit(sectioToFleeFrom.global_position)
		var sectiosToFleeTo = []
		var neighbour1 = getFleeDirection(sectioToFleeFrom, sectioAttackedFrom)
		if not neighbour1[0] == 666:
			print("fleeoption 1")
			sectiosToFleeTo.append(Decks.sectios[neighbour1[0]][neighbour1[1]])
		
		var neighbour2 = getFleeDirection(sectioToFleeFrom, sectioAttackedFrom)
		if not neighbour2[0] == 666:
			print("fleeoption 2")
			sectiosToFleeTo.append(Decks.sectios[neighbour2[0]][neighbour2[1]])
		
		if neighbour1[0] == 666 and neighbour2[0] == 666:
			if Tutorial.tutorial:
				if Tutorial.currentTopic == Tutorial.Topic.PickLegionsToFleeWith:
					continue # always be able to flee
			print("lieutenant, ", lieutenant, " failed to flee from ", sectioToFleeFrom)
			await fleeMessage(str(lieutenant.unitName), sectioToFleeFrom.sectioName)
			lieutenant.fleeing = false
			if lieutenant.solitary:
				for peer in Connection.peers:
					removeUnit.rpc_id(peer, lieutenant.unitNr)
				sectioToFleeFrom.troops.erase(lieutenant.unitNr)
				for peer in Connection.peers:
					updateTroopInSectio.rpc_id(peer, sectioToFleeFrom.sectioName, sectioToFleeFrom.troops)
			break
		
		possibleNeighbours = []
		for sectioToFleeTo in sectiosToFleeTo:
			print("change clickable ",sectioToFleeTo)
			sectioToFleeTo.changeClickable(true)
			possibleNeighbours.append([sectioToFleeTo.circle, sectioToFleeTo.quarter])
		
		if Tutorial.tutorial:
			Signals.tutorial.emit(Tutorial.Topic.FleeWithLieutenant, "Unlike Legions, Lieutenants can choose where to flee to.")
		var unitsToMove = [lieutenant] + legionsFleeingWithLieutenant
		var sectioToFleeTo = await Signals.sectioClicked
		Signals.tutorialRead.emit()
		moveUnits(unitsToMove, sectioToFleeFrom, sectioToFleeTo)
		
		neightboursClickable(false)
		await lieutenant.arrivedAtDestination
		
		var enemyInSectio = false
		for unitName in sectioToFleeTo.troops:
			var unit = Data.troops[unitName]
			if not unit.triumphirate == Data.id:
				enemyInSectio = true
				print(lieutenant, " Lieutenant continues to flee with ", legionsFleeingWithLieutenant)
				sectioToFleeFrom = sectioToFleeTo
		if not enemyInSectio:
			print("lieutenant is done fleeing")
			lieutenant.fleeing = false
			break
	return fleeingTroops

func fleeMessage(unitName : String, sectioName : String):
	var message = "The Unit " + unitName + " failed to flee from " + sectioName + "."
	Signals.showMessage.emit(message)
	await Signals.proceed


func _on_unitClicked(legion):
	return
	neightboursClickable(false)
	_selectedUnit = legion
	possibleNeighbours = getPossibleNeighbours(legion.occupiedCircle, legion.occupiedQuarter)
	changeClickableNeighbours(possibleNeighbours)


func _on_spawnUnit(sectioName : String, playerId : int, unitType : Data.UnitType, unitName : String = ""):
	var sectio : Sectio = Decks.sectioNodes[sectioName]
	placeUnit(sectio, playerId, unitType, unitName)


func placeUnit(sectio, playerId : int = Data.id, unitType : Data.UnitType = Data.UnitType.Legion, lieutenantNameToSpawn : String = ""):
	var player = Data.players[playerId]
	if unitType == Data.UnitType.Lieutenant:
		if Decks.availableLieutenants.size() > 0:
			var nr = randi()
			# call it for the recruiting player first
			# otherwise the sectio isnt updated yet
			spawnUnit(sectio.sectioName, nr, playerId, Data.UnitType.Lieutenant, lieutenantNameToSpawn)
			updateTroopInSectio(sectio.sectioName, sectio.troops)
			Signals.incomeChanged.emit(playerId)
			for peer in Connection.peers:
				if not peer == playerId:
					# skip sending to host if its an AI player
					if not Connection.peers.has(playerId) and peer == Connection.host:
						continue
					spawnUnit.rpc_id(peer, sectio.sectioName, nr, playerId, Data.UnitType.Lieutenant, lieutenantNameToSpawn)
					updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)
			
			Data.players[Data.id].canAffordRecruitLieutenants()
			RpcCalls.recruitedLieutenant.rpc_id(Connection.host)
	
	if unitType == Data.UnitType.Legion:
		var nr = randi()
		spawnUnit(sectio.sectioName, nr, playerId, Data.UnitType.Legion)
		updateTroopInSectio(sectio.sectioName, sectio.troops)
		print("troops in sectio ", sectio.sectioName, sectio.troops)
		Signals.incomeChanged.emit(playerId)
		for peer in Connection.peers:
			if not peer == playerId:
				# skip sending to host if its an AI player
				if not Connection.peers.has(playerId) and peer == Connection.host:
					continue
				spawnUnit.rpc_id(peer, sectio.sectioName, nr, playerId, Data.UnitType.Legion)
				updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)


@rpc("any_peer", "call_local")
func spawnUnit(sectioName : String, nr : int, triumphirate : int, unitType : Data.UnitType, unitName : String = ""):
	var sectio = Decks.sectioNodes[sectioName]
	
	var unitScene
	match unitType:
		Data.UnitType.Legion:
			unitScene = legionScene.instantiate()
		Data.UnitType.Lieutenant:
			unitScene = lieutenantScene.instantiate()
			recruitLieutenant = false
			var lieutenantRef = Decks.lieutenantsReference[unitName]
			unitScene.unitName = unitName
			unitScene.combatBonus = lieutenantRef["combat bonus"]
			unitScene.capacity = lieutenantRef["capacity"]
			unitScene.lieutenantTextureDir = lieutenantRef["texture"]
			Signals.removeLieutenantFromAvailableLieutenantsBox.emit(unitName)
	
	unitScene.name = str(nr)
	unitScene.triumphirate = triumphirate
	
	unitScene.changeSectio(sectio.sectioName, sectio.circle, sectio.quarter)
	unitScene.position = sectio.position
	unitScene.unitClicked.connect(_on_unitClicked)
#	unitScene.unitMovedMax.connect(_on_unitMovedMax)
	
	get_node(str(triumphirate)).add_child(unitScene)
	sectio.troops = sectio.troops + [nr]
	
	if unitType == Data.UnitType.Legion:
		%SpawnLegionAudio.play()
	elif unitType == Data.UnitType.Lieutenant:
		%SpawnLieutenantAudio.play()
	
	if not Connection.peers.has(triumphirate) and Data.id == Connection.host:
		unitScene.set_process(true)
		var i = sectio.slots.find(triumphirate)
		var value = friendlyUnitsOfTheSameTypeInSectio(sectio, triumphirate, unitType)
		var destination = sectio.slotPositions[i]
		destination = stackedPosition(destination, value)
		unitScene.set_destination(destination)
		
			
	if triumphirate == Data.id:
		unitScene.set_process(true)
		var i = sectio.slots.find(triumphirate)
		var value = friendlyUnitsOfTheSameTypeInSectio(sectio, triumphirate, unitType)
		var destination = sectio.slotPositions[i]
		destination = stackedPosition(destination, value)
		unitScene.set_destination(destination)
	
	


func stackedPosition(destination : Vector2, stack : int):
	destination = destination - Vector2(0, 30 * stack)
	return destination


func friendlyUnitsOfTheSameTypeInSectio(sectio, triumphirate : int, unitType):
	var value : int = 0
	for unitNr in sectio.troops:
		var unit = Data.troops[unitNr]
		if unit.triumphirate == triumphirate and unit.unitType == unitType:
			value += 1
	return value


func friendlyUnitsInSectio(sectio, triumphirate : int):
	var value : int = 0
	for unitNr in sectio.troops:
		var unit = Data.troops[unitNr]
		if unit.triumphirate == triumphirate:
			value += 1
	return value


#func spawnUnit(unitType, sectio, playerId):
#	var player = Data.players[playerId]
#	match unitType:
#		"legion":
#			var legion = legionScene.instantiate()
#			legion.name = str(randi())
#
#			print(Data.id, " current legios in sectio ", sectio.sectioName, " ",sectio.troops)
#			sectio.troops.append(legion.unitNr)
#			print(Data.id, " after   legios in sectio ", sectio.sectioName, " ",sectio.troops)
#			for peer in Connection.peers:
#				updateTroopInSectio.rpc_id(peer, sectio.sectioName, sectio.troops)
#
#			for peer in Connection.peers:
#				legion.changeSectio.rpc_id(peer, sectio.sectioName, sectio.circle, sectio.quarter)
#			legion.global_position = sectio.global_position
#			legion.unitClicked.connect(_on_unitClicked)
#			legion.unitMovedMax.connect(_on_unitMovedMax)
#			get_node(str(Data.id)).add_child(legion)
#			player.troops[legion.unitNr] = legion
	

# still needed???
#func _on_confirmation_dialog_confirmed():
#	var result = await flee()
#	print("confirmed flee1")
#	confirmToFlee.rpc_id(fleeRequestId, true)

# still needed???
#func _on_confirmation_dialog_cancelled():
#	confirmToFlee.rpc_id(fleeRequestId, false)


func pickLegions(possibleLegionsToMoveWithLieutenant, unitsAlreadyMovingWithLieutenant : Array, capacity):
	Signals.pickLegions.emit(possibleLegionsToMoveWithLieutenant, unitsAlreadyMovingWithLieutenant, capacity)
	var legions = await Signals.pickedLegions
	return legions

# still needed???
#func _on_pick_move_unit_control_legion_clicked(unit):
#	if unit:
#		sectiosUnclickable()
#		neightboursClickable(false)
#		_selectedUnit = unit
#		_selectedUnit.sectiosMoved = 0
#		possibleNeighbours = getPossibleNeighbours(unit.occupiedCircle, unit.occupiedQuarter)
#		changeClickableNeighbours(possibleNeighbours)
#	print("clicked unit ", unit)
#	%PickMoveUnitControl._on_exit_button_pressed()


#func _on_unit_to_move_clicked(unitNode):
#	if unitNode:
#		sectiosUnclickable()
#		neightboursClickable(false)
#		_selectedUnit = unitNode
#		_selectedUnit.sectiosMoved = 0
#		possibleNeighbours = getPossibleNeighbours(unitNode.occupiedCircle, unitNode.occupiedQuarter)
#		changeClickableNeighbours(possibleNeighbours)
#	selfNode._on_exit_button_pressed()


func _on_confirm_flee(boolean : bool):
	return
#	if boolean:
#		Signals.hideFleeControl.emit()
#		var result = await flee()
#		confirmToFlee.rpc_id(fleeRequestId, true)
#	else:
#		Signals.hideFleeControl.emit()
#		confirmToFlee.rpc_id(fleeRequestId, false)





func _on_lightning_timer_timeout():
	setupLightning()


func _on_potatoPc(boolean : bool):
	if boolean:
		%PentagramSprite2D.use_parent_material = boolean
		for playerpolygon in playerpolygons.values():
			playerpolygon.get_material().set_shader_parameter("speed", 0.0)
	else:
		%PentagramSprite2D.use_parent_material = boolean
		for playerpolygon in playerpolygons.values():
			playerpolygon.get_material().set_shader_parameter("speed", 0.03)
