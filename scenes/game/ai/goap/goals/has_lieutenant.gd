extends GoapGoal

class_name RecruitLieutenantGoal

#func get_class(): return "RecruitLieutenantGoal"


func is_valid() -> bool:
	return WorldState.get_state("lieutenants", 0) < 1 and WorldState.get_elements("recruitLieutenantCards").size() > 0 # and WorldState.get_elements("lieutenantCards").size() > 0


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
		"has_lieutenant": true
	}
