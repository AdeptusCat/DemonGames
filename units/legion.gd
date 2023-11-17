extends Unit

var lieutenant = null
var tw3

const soulsGatherScene = preload("res://ui/souls_gather_container.tscn")

func _ready():
	marginContainer = $LegionMarginContainer
	setup()
	unitType = Data.UnitType.Legion
	maxSectiosMoved = 2
	
	var canvasTexture : CanvasTexture = CanvasTexture.new()
	texture = Data.icons[Data.players[triumphirate].colorName]
	canvasTexture.texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	normalMap = Data.normalMaps[Data.players[triumphirate].colorName]
	canvasTexture.diffuse_texture = texture
	canvasTexture.normal_texture = normalMap
	%TextureRect.texture = canvasTexture
#	%TextureRect.normal_texture = texture
#	%TextureRect.texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
#	%TextureRect.diffuse_texture = texture
#	normaleMap = Data.normalMaps[Data.players[triumphirate].colorName]
#	%TextureRect.normal_texture = texture
#	%TextureRect.texture = texture
	set_process(false)
	
	# to avoid trying to get navigation path before navigation is initalized
	set_physics_process(false)
	await get_tree().process_frame
	set_physics_process(true)


func saveGame():
	var save_dict = {"legions" : {unitNr : {
		"previousSectio" : previousSectio,
		"occupiedSectio" : occupiedSectio,
		"occupiedCircle" : occupiedCircle,
		"occupiedQuarter" : occupiedQuarter,
		"unitName" : unitName,
		"clickable" : clickable,
		"sectiosMoved" : sectiosMoved,
		"maxSectiosMoved" : maxSectiosMoved,
		"fleeing" : fleeing,
		"arrived" : arrived,
		"unitType" : unitType,
		"unitNr" : unitNr,
		"triumphirate" : triumphirate,
		"lieutenant" : lieutenant,
		"playerName" : Data.players[triumphirate].playerName
	}}}
	return save_dict


@rpc("any_peer", "call_local")
func changeSectio(sectioName, circle, quarter):
	occupiedSectio = sectioName
	occupiedCircle = circle
	occupiedQuarter = quarter


func _process(delta):
	if not lastPositionSent == position:
		for peer in Connection.peers:
			if not peer == Data.id:
				lastPositionSent = position
				sendPosition.rpc_id(peer, lastPositionSent)


@rpc("any_peer", "unreliable")
func sendPosition(pos : Vector2):
	position = pos


func canMove():
	return
	sectiosMoved += 1
	if sectiosMoved >= maxSectiosMoved:
#		changeClickable(false)
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


# if is_target_reachable() is false, check the NavigationRegion2D size on the map
func _physics_process(delta: float) -> void:
	if not arrived:
		if $NavigationAgent2D.is_target_reachable():
			var next_location = $NavigationAgent2D.get_next_path_position()
			var v = (next_location - global_position).normalized() * speed
			$NavigationAgent2D.set_velocity(v)
			position += v
		else:
			print("target not rechable, check NavigationRegion size!")
			$NavigationAgent2D.set_velocity(Vector2.ZERO)
	if global_position.distance_to(destination) < 10 and not arrived:
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
	destinations.clear()
	arrived = false
	destination = newDestination
	$NavigationAgent2D.set_target_position(destination)

@rpc("any_peer", "call_local")
func set_destinations(newDestinations : Array):
	destinations += newDestinations
	if arrived:
		destination = destinations.pop_front()
		$NavigationAgent2D.set_target_position(destination)
	arrived = false
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
