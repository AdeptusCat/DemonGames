extends GoapAction

class_name WalkTheEarthAction


#func get_class(): return "WalkTheEarthAction"


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"walk_the_earth": true
	}


func perform(actor, delta) -> bool:
	Signals.phaseDone.emit()
	return true
