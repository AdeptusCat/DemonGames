extends GoapAction

class_name EndPhaseAction


#func get_class(): return "EndPhaseAction"


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"end_phase": true
	}


func perform(actor, delta) -> bool:
	#var playerId : int = WorldState.get_state("active_player")
	Signals.phaseDone.emit()
	return true
