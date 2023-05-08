extends GoapGoal

class_name LegionInCircleNextToOwnSectioGoal 

#func get_class(): return "LegionInCircleNextToOwnSectioGoal"


func is_valid() -> bool:
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
	else:
		return true


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
		"legion_in_target_circle_next_to_own_sectio": true
	}
