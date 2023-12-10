extends MarginContainer

const PickMoveUnitVBoxContainerScene = preload("res://pick_move_unit_v_box_container.tscn")

var unitsHit = []
var hits = 0
var unitNames = []
var unitsDict = {}
var fleeingTriumphirates = []
var playerIsFighting : bool = false


func _ready():
	Signals.unitsHit.connect(hit)
	Signals.unitsKilled.connect(killed)
	Signals.showCombat.connect(_on_showCombat)
	Signals.hideCombat.connect(_on_hideCombat)
	Signals.endCombat.connect(endCombat)
	Signals.hightlightCombat.connect(highlight)
	Signals.unitsAttack.connect(attack)


func _on_showCombat():
	if playerIsFighting:
		%FleeButton.show()
		%FleeButton.disabled = false
	%CombatParticipantsControl.show()


func _on_hideCombat():
	%CombatParticipantsControl.hide()


#func _process(delta):
#	position


func highlight(_unitsDict : Dictionary, sectioName : String):
	%FleeButton.hide()
	%FleeButton.disabled = true
	playerIsFighting = false
	for triumphirate in _unitsDict:
		unitsDict[triumphirate] = {}
		for troopName in _unitsDict[triumphirate]:
			var troop = Data.troops[troopName]
			var scene = PickMoveUnitVBoxContainerScene.instantiate()
			scene.populate(troop)
			unitsDict[triumphirate][troopName] = scene
			if Data.id == troop.triumphirate:
				playerIsFighting = true
				%FriendlyUnitsHBoxContainer.add_child(scene)
			else:
				%EnemyUnitsHBoxContainer.add_child(scene)
	show()


func endCombat():
	for child in %FriendlyUnitsHBoxContainer.get_children():
		child.queue_free()
	for child in %EnemyUnitsHBoxContainer.get_children():
		child.queue_free()
	fleeingTriumphirates.clear()
	hide()


func attack():
	for child in %FriendlyUnitsHBoxContainer.get_children():
		child.attack(true)
	for child in %EnemyUnitsHBoxContainer.get_children():
		child.attack(false)


func hit(_unitsDict : Dictionary):
	for triumphirate in _unitsDict:
		for troopName in _unitsDict[triumphirate]:
#			print("triumphirate ", triumphirate, " got hit. unit name: ", troopName)
			unitsDict[triumphirate][troopName].hit()


func killed(_unitsDict : Dictionary):
	for triumphirate in _unitsDict:
		for troopName in _unitsDict[triumphirate]:
#			unitsDict[triumphirate][troopName].kill()
			unitsDict[triumphirate].erase(troopName)
	for child in %FriendlyUnitsHBoxContainer.get_children():
		child.unHit()
	for child in %EnemyUnitsHBoxContainer.get_children():
		child.unHit()


@rpc("any_peer", "call_local")
func wantsToFlee():
	var fleeRequestId = multiplayer.get_remote_sender_id()
#	fleeingTriumphirates.append(fleeRequestId)
	Signals.triumphiratWantsToFlee.emit(fleeRequestId)


func getFleeingTriumphirates():
	return fleeingTriumphirates


func _on_flee_button_pressed():
	wantsToFlee.rpc_id(Connection.host)
