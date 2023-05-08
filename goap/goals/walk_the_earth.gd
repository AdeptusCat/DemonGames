extends GoapGoal

class_name WalkTheEarthGoal

#func get_class(): return z"WalkTheEarthGoal"


func is_valid() -> bool:
	return true


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
		"walk_the_earth": true
	}
