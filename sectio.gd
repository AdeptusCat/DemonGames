extends Node2D
class_name Sectio
#@icon("res://editor/skull3.svg")

const PickMoveUnitVBoxContainerScene = preload("res://pick_move_unit_v_box_container.tscn")
const soulsGatherScene = preload("res://ui/souls_gather_container.tscn")

@export var Treachery : Color
@export var Fraud : Color
@export var TheViolent : Color
@export var Heretics : Color
@export var TheWrathful : Color
@export var TheGreedy : Color
@export var TheGluttonous : Color
@export var TheLustful : Color
@export var Limbo : Color
@onready var colors = [Treachery, Fraud, TheViolent, Heretics, TheWrathful, TheGreedy, TheGluttonous, TheLustful, Limbo]

@onready var playerPolygon = $Polygon2D2
@onready var sectioPolygon = $Polygon2D
@onready var collisionPolygon = $Area2D/CollisionPolygon2D

@export var sectioName : String = "Spies"
enum Circles {Treachery, Fraud, TheViolent, Heretics, TheWrathful, TheGreedy, TheGluttonous, TheLustful, Limbo, Antehell}
@export var circle : Circles = Circles.Treachery
var circleNames : Dictionary = {Circles.Treachery : "Treachery", Circles.Fraud : "Fraud", Circles.TheViolent  : "The Violent", Circles.Heretics : "Heretics", Circles.TheWrathful : "The Wrathful", Circles.TheGreedy : "The Greedy", Circles.TheGluttonous : "The Gluttonous", Circles.TheLustful : "The Lustful", Circles.Limbo : "Limbo", Circles.Antehell : "Antehell"}
@export_enum("One", "Two", "Three", "Four", "Five") var quarter: int
@export var souls : int = 2
@export var player : int = 0:
	set(playerNr):
		player = playerNr
		$PlayerLabel.text = str(playerNr)
var slots = []
var slotPositions = []
@export var troops : Array = []:
	set(_troops):
		troops = _troops
		slots = []
		var playerId = null
		for unitName in troops:
			var unit = Data.troops[unitName]
			playerId = unit.triumphirate
			if not slots.has(playerId):
				slots.append(playerId)
@export var sectioTexture : Texture
var id : int = 0


var isIsolated = true
var clickable = false
var originalColor
var tw1
var tw2
var tw3
var buttonDown = false

var corners = {"ul" : null, "ur" : null, "dl" : null, "dr" : null}
var clockwisePoint
var counterclockwisePoint
var polygonPoints = []
var startpoint
var outerPoints = []
var innerPoints = []

var startTime = Time.get_ticks_msec()
var arrows : Array[Sprite2D] = []
var activeArrow : Sprite2D
var intervalDefault : float = 0.1
var interval : float = intervalDefault
var startArrows : bool = false
var fleeToPosition : Vector2
var spinCounter : int = 0
var shortestDistance : float = INF
var goalArrow : Sprite2D

func _ready():
	Signals.potatoPc.connect(_on_potatoPc)
	%SoulsRing.self_modulate = colors[circle]
	%SoulsRingLabel.text = str(souls)
	remove_child(sectioPolygon)
#	playerPolygon.modulate.a = 0.0
	%NameLabel.text = sectioName
	%SoulsLabel.text = str(souls)
#	var pol = collisionPolygon.polygon.duplicate()
#	playerPolygon.polygon = pol
#	originalColor = playerPolygon.modulate
#	if not sectioName == "Orgastica":
#		return 
#	position = Vector2(500,500)
#	showSoulsGathered(3)
#	return
	var angleOffset = 0.02
	var middleDistance = 250 # 250 50
	var multiplier = 9
	multiplier = circle + 1
	var r = 165 # 165 45
	var baseAngle = 1.256
	var angle = (baseAngle * quarter) * -1
	startpoint = marker(r * multiplier + middleDistance, angle)
	var angles = []
	var steps = 16
	var step = baseAngle / steps
	for a in range(steps/2, 0, -1):
		# angles.append(angle + step * a - angleOffset)
		angles.append(angle + step * a)
	angles.append(angle)
	for a in range(1, steps/2+1):
		# angles.append(angle - step * a + angleOffset)
		angles.append(angle - step * a)
	

	
	var points = []
	var outer = angles.duplicate()
	var inner = angles.duplicate()
	
	var startIndex = outer.size()
	while outer.size() > 0:
		# var point = marker(r * multiplier + r / 2 - 2 + middleDistance, outer.pop_back())
		var point = marker(r * multiplier + r / 2 + middleDistance, outer.pop_back())
		if outer.size() == angles.size():
			corners.ul = point
		if outer.size() == 1:
			corners.ur = point
		points.append(point)
		outerPoints.append(point)
	while inner.size() > 0:
		# var point = marker(r * multiplier - r / 2 + 2 + middleDistance, inner.pop_front())
		var point = marker(r * multiplier - r / 2 + middleDistance, inner.pop_front())
		if inner.size() == angles.size():
			corners.dl = point
		if inner.size() == 1:
			corners.dr = point
		points.append(point)
		innerPoints.append(point)
	
	position = startpoint
#	print("before ", points)
	
	clockwisePoint = marker(r * multiplier + middleDistance, angle - baseAngle / 2) - startpoint + global_position
#	$Sprite2D.global_position = marker(r * multiplier + middleDistance, angle - baseAngle / 2) - startpoint + global_position
	counterclockwisePoint = marker(r * multiplier + middleDistance, angle + baseAngle / 2) - startpoint + global_position
	
	for i in points.size():
		points[i] = points[i] - startpoint
	polygonPoints = points
	%Line2D.points = points
#	print("after  ", points)
	
#	var marker = Polygon2D.new()
	playerPolygon.set_polygon(points)
	sectioPolygon.set_polygon(points)
#	playerPolygon.modulate = Color8(60, 60, 60, 0)
#	%CollisionPolygon2D.position = startpoint
	%CollisionPolygon2D.set_polygon(points)
#		marker.global_position = get_parent().global_position
#	playerPolygon = marker
#	%PolygonContainer.add_child(marker)
	
	var radius = r * multiplier + middleDistance
	
	addMarker(marker(radius, angle + baseAngle / 5 * 1), startpoint)
	addMarker(marker(radius, angle - baseAngle / 5 * 1), startpoint)
	addMarker(marker(radius, angle + baseAngle / 5 * 2), startpoint)
	addMarker(marker(radius, angle - baseAngle / 5 * 2), startpoint)
	addMarker(marker(radius, angle + baseAngle / 5 * 0.5), startpoint)
	addMarker(marker(radius, angle - baseAngle / 5 * 0.5), startpoint)
	addMarker(marker(radius, angle), startpoint)
	
#	if sectioName == "Spies":
#		var navigationNode = NavigationRegion2D.new()
#		var navigationPolygon = NavigationPolygon.new()
#		navigationPolygon.add_outline(polygonPoints)
#		navigationPolygon.make_polygons_from_outlines()
#		navigationNode.navpoly = navigationPolygon
#		add_child(navigationNode)
	
#	for markers in range(1, 3):
#		var pos = marker(radius, angle + baseAngle / 5 * markers)
#		var unitMarker = Label.new()
#		%UnitsNode2D.add_child(unitMarker)
#		unitMarker.position = pos - startpoint
#		slotPositions.append(unitMarker.global_position)
#
#	for markers in range(1, 3):
#		var pos = marker(radius, angle - baseAngle / 5 * markers)
#		var unitMarker = Label.new()
#		%UnitsNode2D.add_child(unitMarker)
#		unitMarker.position = pos - startpoint
#		slotPositions.append(unitMarker.global_position)
#
#	for markers in range(1, 2):
#		var pos = marker(radius, angle)
#		var unitMarker = Label.new()
#		%UnitsNode2D.add_child(unitMarker)
#		unitMarker.position = pos - startpoint
#		slotPositions.append(unitMarker.global_position)
#		%UnitsMarginContainer.global_position = unitMarker.global_position + Vector2(0, 50)
	
	#var a_right = points[outerPoints.size() - 1]
	#var b_right = points[outerPoints.size()]
	#var angle_right_arrow = a_right.angle_to(b_right)
	var a_right = Vector2(50,0)
	var b_right = points[outerPoints.size()] - %SoulsRingLabel.position
	var angle_right_arrow = a_right.angle_to(b_right)
	%ArrowRightSprite2D.position = points[outerPoints.size()-1] - ((points[outerPoints.size()-1] - points[outerPoints.size()])/2)
	%ArrowRightSprite2D.rotation = angle_right_arrow
	
	var a_left = Vector2(-50,0)
	var b_left = points[points.size()-1] - %SoulsRingLabel.position
	var angle_left_arrow = a_left.angle_to(b_left)
	%ArrowLeftSprite2D.position = points[0] - ((points[0] - points[points.size()-1])/2)
	%ArrowLeftSprite2D.rotation = angle_left_arrow
	
	var a_up = Vector2(50,0)
	var b_up = points[outerPoints.size() + innerPoints.size()/2] - %SoulsRingLabel.position
	var angle_up_arrow = a_up.angle_to(b_up)
	%ArrowUpSprite2D.position = points[outerPoints.size() + innerPoints.size()/2]
	%ArrowUpSprite2D.rotation = angle_up_arrow
	
	var a_down = Vector2(50,0)
	var b_down = points[outerPoints.size()/2] - %SoulsRingLabel.position
	var angle_down_arrow = a_down.angle_to(b_down)
	%ArrowDownSprite2D.position = points[outerPoints.size()/2]
	%ArrowDownSprite2D.rotation = angle_down_arrow
	
	#%ArrowUpSprite2D.position = points[outerPoints.size() + innerPoints.size()/2]
	#%ArrowUpSprite2D.rotation = rotation
	#
	#%ArrowDownSprite2D.position = points[outerPoints.size()/2]
	#%ArrowDownSprite2D.rotation = rotation
	add_arrows()
	#startArrowSpin()
	Signals.spinFleeArrows.connect(_on_spinFleeArrows)
	Signals.hideFleeArrow.connect(_on_hideFleeArrow)


func _on_spinFleeArrows(sectioToFleeFromName, sectioToFleeToName):
	if sectioToFleeFromName != sectioName:
		return
	var sectioToFleeFrom : Sectio = Decks.sectioNodes[sectioToFleeFromName]
	var sectioToFleeTo : Sectio = Decks.sectioNodes[sectioToFleeToName]
	add_arrows()
	startArrowSpin(sectioToFleeToName)


func _on_hideFleeArrow():
	if activeArrow:
		activeArrow.hide()


func add_arrows():
	arrows.append(%ArrowRightSprite2D)
	arrows.append(%ArrowUpSprite2D)
	arrows.append(%ArrowLeftSprite2D)
	arrows.append(%ArrowDownSprite2D)


func startArrowSpin(sectioToFleeToName : String = ""):
	var sectioToFleeTo : Sectio = Decks.sectioNodes[sectioToFleeToName]
	fleeToPosition = sectioToFleeTo.global_position
	startArrows = true
	startTime = Time.get_ticks_msec()
	spinCounter = 0
	shortestDistance = INF
	interval = intervalDefault

func stopArrowSpin():
	startArrows = false


func _process(elta):
	if startArrows:
		if activeArrow == null:
			activeArrow = arrows.pop_front()
			activeArrow.show()
			spinCounter += 1
			if activeArrow.global_position.distance_to(fleeToPosition) < shortestDistance:
				goalArrow = activeArrow
				shortestDistance = activeArrow.global_position.distance_to(fleeToPosition)
		else:
			if Time.get_ticks_msec() > startTime + interval:
				if spinCounter > 10 and activeArrow == goalArrow:
					stopArrowSpin()
					for peer in Connection.peers:
						spinFleeArrowsStopped.rpc_id(peer)
				else:
					startTime = Time.get_ticks_msec()
					activeArrow.hide()
					arrows.append(activeArrow)
					activeArrow = null
					interval += pow(interval, 1.01)
			# if it takes too long, skip
			if Time.get_ticks_msec() > startTime + 5000:
					if activeArrow:
						activeArrow.hide()
					goalArrow.show()
					stopArrowSpin()
					for peer in Connection.peers:
						spinFleeArrowsStopped.rpc_id(peer)


@rpc("any_peer", "call_local")
func spinFleeArrowsStopped():
	Signals.spinFleeArrowsStopped.emit()


func addMarker(pos, _startpoint):
	var unitMarker = Label.new()
	%UnitsNode2D.add_child(unitMarker)
	unitMarker.position = pos - _startpoint
	slotPositions.append(unitMarker.global_position)
	%UnitsMarginContainer.global_position = unitMarker.global_position + Vector2(0, 50)

func marker(radius, angle):
	var x = radius*sin(angle) 
	var y = radius*cos(angle)
	return Vector2(x, y)



func highlightTroops():
	%UnitsMarginContainer.show()
	var troopsDict = {}
	for troopName in troops:
		var troop = Data.troops[troopName]
		if troopsDict.has(troop.triumphirate):
			troopsDict[troop.triumphirate].append(troop)
		else:
			troopsDict[troop.triumphirate] = [troop]
	for triumphirate in troopsDict:
		var units = troopsDict[triumphirate]
		for unit in units:
			if triumphirate == Data.id:
				%YourUnitsLabel.show()
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				scene.populate(unit)
				%YourUnitsHBoxContainer.add_child(scene)
			else:
				%EnemyUnitsLabel.show()
				var scene = PickMoveUnitVBoxContainerScene.instantiate()
				scene.populate(unit)
				%EnemyUnitsHBoxContainer.add_child(scene)
	
func hideTroops():
	%UnitsMarginContainer.hide()
	for child in %YourUnitsHBoxContainer.get_children():
		child.queue_free()
	for child in %EnemyUnitsHBoxContainer.get_children():
		child.queue_free()
	%YourUnitsLabel.hide()
	%EnemyUnitsLabel.hide()


func changeColor(id : int):
	playerPolygon.modulate = Data.players[id].color
	playerPolygon.modulate.a = 0.0
#	var c = playerPolygon.get_material().colorTexture.get_gradient().get_colors()
#	c[1] = Data.players[id].color
#	playerPolygon.get_material().colorTexture.get_gradient().set_colors(c) 
#	playerPolygon.texture_offset = position# - get_parent().get_parent().get_parent().position
#	playerPolygon.position = position
	sectioPolygon.texture_offset = position# - get_parent().get_parent().get_parent().position
	sectioPolygon.position = position
	Signals.changeSectioBackground.emit(id, sectioPolygon)
#	get_parent().get_parent().get_parent().changePolygon(id, sectioPolygon)
#	print("modulate", playerPolygon.modulate.a)


func isolated():
	Signals.neighbours.emit(self)
	return isIsolated

@rpc("any_peer", "call_local")
func changeClickable(boolean):
	clickable = boolean
	highlight(clickable)

func highlight(boolean):
	if boolean:
		if tw1:
			tw1.kill()
#			tw2.kill()
		tw1 = get_tree().create_tween()
		tw1.set_loops()
		tw1.set_trans(Tween.TRANS_CUBIC)
		tw1.set_ease(Tween.EASE_IN)
		tw1.tween_property(playerPolygon, "modulate:a", 0.0, 0.5)
		tw1.tween_interval(0.01)
		tw1.set_trans(Tween.TRANS_SINE)
		tw1.set_ease(Tween.EASE_OUT)
		tw1.tween_property(playerPolygon, "modulate:a", 0.6, 0.5)
		
#		tw2 = get_tree().create_tween()
#		tw2.set_loops()
#		tw2.set_trans(Tween.TRANS_CUBIC)
#		tw2.set_ease(Tween.EASE_IN)
#		tw2.tween_property(playerPolygon, "scale", Vector2(1.1, 1.1), 1.0)
#		tw2.tween_interval(0.01)
#		tw2.set_trans(Tween.TRANS_SINE)
#		tw2.set_ease(Tween.EASE_OUT)
#		tw2.tween_property(playerPolygon, "scale", Vector2(1.0, 1.0), 2.0)
	else:
		if tw1:
			tw1.kill()
#			tw2.kill()
		var tween1 = get_tree().create_tween()
		tween1.set_trans(Tween.TRANS_CUBIC)
		tween1.set_ease(Tween.EASE_IN)
#		if player == 0:
#			tween1.tween_property(playerPolygon, "modulate:a", 0.0, 1.0)
#		else:
		tween1.tween_property(playerPolygon, "modulate:a", 0.0, 1.0)			
		tween1.set_trans(Tween.TRANS_SINE)
		tween1.set_ease(Tween.EASE_OUT)
		tween1.tween_property(playerPolygon, "scale", Vector2(1.0, 1.0), 2.0)



#func _input(event):
#	if Input.is_action_pressed("space"):
#		if tw3:
#			tw3.kill()
#			hideSoulsGathered()

#func hideSoulsGathered():
#	soulsGathered.emit()
#	%SoulsGatherContainer.hide()
#	%SoulsGatherContainer.position = prevPosition
#	%SoulsGatherContainer.modulate.a = 1


func showSoulsGathered(souls : int):
	var soulsGatherNode = soulsGatherScene.instantiate()
	soulsGatherNode.souls = souls
	add_child(soulsGatherNode)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		if buttonDown:
			return
		buttonDown = true
		if clickable:
			print("clicked")
			Signals.sectioClicked.emit(self)
	if Input.is_action_just_released("click"):
		buttonDown = false


func _on_area_2d_mouse_entered():
	Signals.showSectioPreview.emit(self)


func _on_area_2d_mouse_exited():
	Signals.hideSectioPreview.emit(sectioName)


func _on_potatoPc(boolean : bool):
	pass
