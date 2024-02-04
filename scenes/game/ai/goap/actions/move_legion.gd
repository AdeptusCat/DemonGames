extends GoapAction

class_name MoveLegionAction


#func get_class(): return "MoveLegionAction"


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {
#		"sectiosWithoutEnemies": true
	}


func get_effects() -> Dictionary:
	return {
		"legion_in_target_circle_next_to_own_sectio": true
	}


func perform(actor, delta) -> bool:
	var playerId : int = WorldState.get_state("active_player")
	var circle : int = WorldState.get_state("circle_to_capture")
	var sectiosNextToFriendlySectioInSameCircle : Array = [] 
	for sectioName in Decks.sectioNodes:
		var sectio = Decks.sectioNodes[sectioName]
		if not circle == sectio.circle:
			continue
		if not sectio.player == playerId:
			var quarterClockwise = posmod((sectio.quarter + 1), 5)
			var sectioClockwise = Decks.sectios[sectio.circle][quarterClockwise]
			if not sectioClockwise.player == playerId and not sectiosNextToFriendlySectioInSameCircle.has(sectioClockwise):
				sectiosNextToFriendlySectioInSameCircle.append(sectioClockwise)
			var quarterCounterclockwise = posmod((sectio.quarter - 1), 5)
			var sectioCounterclockwise = Decks.sectios[sectio.circle][quarterCounterclockwise]
			if not sectioCounterclockwise.player == playerId and not sectiosNextToFriendlySectioInSameCircle.has(sectioCounterclockwise):
				sectiosNextToFriendlySectioInSameCircle.append(sectioCounterclockwise)
	
	if sectiosNextToFriendlySectioInSameCircle.is_empty():
		return false
	
	var shortestPhaseSize : int = 100
	var closestUnit
	var occupiedSectio
	var closestSectio
	for unitName in Data.players[playerId].troops:
		for sectioNextToFriendlySectioInSameCircle in sectiosNextToFriendlySectioInSameCircle:
			var unit = Data.troops[unitName]
			occupiedSectio = Decks.sectioNodes[unit.occupiedSectio]
			var path = Astar.astar.get_id_path(occupiedSectio.id, sectioNextToFriendlySectioInSameCircle.id)
			if path.size() < shortestPhaseSize:
				shortestPhaseSize = path.size()
				closestUnit = unit
				closestSectio = sectioNextToFriendlySectioInSameCircle
	
	var path : Array = Astar.astar.get_id_path(occupiedSectio.id, closestSectio.id)
	print("moving unit path size ", path.size())
	print("moving unit from1 ", occupiedSectio.sectioName, " to ", closestSectio.sectioName)
	if path.size() > 1:
		path.pop_front()
	if path.size() <= 1:
		Signals.phaseDone.emit()
		return false
	for sectioId in path:
		var nextSectio = Astar.sectioIdsNodeDict[sectioId]
		print("moving unit from2 ", occupiedSectio.sectioName, " to ", nextSectio.sectioName)
		Signals.moveUnits.emit([closestUnit], occupiedSectio, nextSectio)
		await closestUnit.arrivedAtDestination
		occupiedSectio = nextSectio
	print("moving unit done")
	Signals.phaseDone.emit()
	return true
