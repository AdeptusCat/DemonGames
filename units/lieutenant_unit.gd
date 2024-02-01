extends Unit



var solitary : bool = false
var combatBonus : int = 9
var capacity : int = 9
var accompaniedLegions : Array = []
var legionsFleeingWithLieutenant : Array = []
var lieutenantTextureDir
var tw3

const soulsGatherScene = preload("res://ui/souls_gather_container.tscn")

func _ready():
	marginContainer = %LieutenantMarginContainer
	setup()
	unitType = Data.UnitType.Lieutenant
	maxSectiosMoved = 3
	marginContainer.populate(unitName, lieutenantTextureDir, str(combatBonus), str(capacity), triumphirate)
	
	# to avoid trying to get navigation path before navigation is initalized
	set_physics_process(false)
	await get_tree().process_frame
	set_physics_process(true)

func saveGame():
	var save_dict = {"lieutenants" : {unitNr : {
		"occupiedSectio" : occupiedSectio,
		"solitary" : solitary,
		"unitName" : unitName,
		"unitNr" : unitNr,
		"triumphirate" : triumphirate,
		"playerName" : Data.players[triumphirate].playerName
	}}}
	return save_dict


@rpc("any_peer", "call_local")
func changeSectio(sectioName, circle, quarter):
	occupiedSectio = sectioName
	occupiedCircle = circle
	occupiedQuarter = quarter


func canMove():
	return
	sectiosMoved += 1
	if sectiosMoved >= maxSectiosMoved:
		changeClickable(false)
		sectiosMoved = 0
		unitMovedMax.emit(self)
		return false
	else:
		return true




func showSoulsPaid(souls : int):
	var soulsGatherNode = soulsGatherScene.instantiate()
	soulsGatherNode.souls = 0 - souls
	add_child(soulsGatherNode)



#func _input(event):
#	if Input.is_action_pressed("space"):
#		if tw3:
#			tw3.kill()
#			hideSoulsPaid()


func _process(delta):
	if not lastPositionSent == position:
		for peer in Connection.peers:
			if not peer == Data.id:
				lastPositionSent = position
				sendPosition.rpc_id(peer, lastPositionSent)


@rpc("any_peer", "unreliable")
func sendPosition(pos : Vector2):
	position = pos


func _physics_process(delta: float) -> void:
	if not arrived:
		if $NavigationAgent2D.is_target_reachable():
			var next_location = $NavigationAgent2D.get_next_path_position()
			var v = (next_location - global_position).normalized() * speed
			$NavigationAgent2D.set_velocity(v)
			position += v
		else:
			$NavigationAgent2D.set_velocity(Vector2.ZERO)
	if global_position.distance_to(destination) < 5 and not arrived:
		if destinations.size() > 0:
			destination = destinations.pop_front()
			$NavigationAgent2D.set_target_position(destination)
		else:
			arrived = true
			arrivedAtDestination.emit()
			global_position = destination
			for peer in Connection.peers:
				RpcCalls.stopFollowingUnit.rpc_id(peer, unitNr)


func kill():
	marginContainer.kill()
	await get_tree().create_timer(2.1).timeout
	queue_free()

@rpc("any_peer", "call_local")
func set_destination(newDestination : Vector2):
	arrived = false
	destination = newDestination
	$NavigationAgent2D.set_target_position(destination)

@rpc("any_peer", "call_local")
func set_destinations(newDestinations : Array):
	arrived = false
	destinations = newDestinations
	destination = destinations.pop_front()
	$NavigationAgent2D.set_target_position(destination)
	for peer in Connection.peers:
		RpcCalls.followUnit.rpc_id(peer, unitNr)
#func _integrate_forces(_state):
#	if $NavigationAgent2D.is_target_reachable():
#		var target = $NavigationAgent2D.get_next_path_position()
#		var velocity = global_transform.origin.direction_to(target).normalized() * speed
#		print(target)
#		$NavigationAgent2D.set_velocity(velocity)
#	else:
#		$NavigationAgent2D.set_linear_velocity(Vector2.ZERO)


func changeClickable(boolean):
	clickable = boolean
	#$Area2D.input_pickable = boolean


func _on_navigation_agend_2d_velocity_computed(safe_velocity):
	$NavigationAgent2D.set_velocity(safe_velocity)
	position += safe_velocity


func on_velocity_computed(safe_velocity: Vector2) -> void:
	position += safe_velocity


func _on_navigation_agend_2d_target_reached():
	pass
#	print("reached goal")


func _on_navigation_agend_2d_path_changed():
	pass
#	print("aaaaa",$NavigationAgent2D.get_nav_path())


func _on_area_2d_input_event(viewport, event, shape_idx):
	return
	if Input.is_action_pressed("click"):
		if clickable:
			unitClicked.emit(self)
