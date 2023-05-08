extends GoapGoal

class_name EndPhaseGoal

#func get_class(): return "EndPhaseGoal"


# relax will always be available
func is_valid() -> bool:
	return true


# relax has lower priority compared to other goals
func priority() -> int:
	return 0


func get_desired_state() -> Dictionary:
	return {
		"end_phase": true
	}




