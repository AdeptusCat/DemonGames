extends GoapAction

class_name RecruitLegionAction


#func get_class(): return "RecruitLegionAction"


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {
#		"sectiosWithoutEnemies": true
	}


func get_effects() -> Dictionary:
	return {
		"has_more_legions": true
	}


func perform(actor, delta) -> bool:
	print("recruited legion ")
	if not Data.currentAiPlayer.hasEnoughSouls(3):
		return false
	if Data.currentAiPlayer.sectiosWithoutEnemiesLeft.is_empty():
		Data.currentAiPlayer.sectiosWithoutEnemiesLeft = Data.currentAiPlayer.sectiosWithoutEnemies.duplicate()
	var sectioName = Data.currentAiPlayer.sectiosWithoutEnemiesLeft.pop_back()
	var sectio = Decks.sectioNodes[sectioName]
	
	Signals.placeUnit.emit(sectio, Data.currentAiPlayer.playerId, Data.UnitType.Legion)
	
	var souls = Data.currentAiPlayer.souls - 3
	Signals.changeSouls.emit(Data.currentAiPlayer.playerId, souls)
	
	return true
#	var closest_food = WorldState.get_closest_element("food", actor)
#
#	if closest_food == null:
#		return false
#
#	if closest_food.position.distance_to(actor.position) < 5:
#		WorldState.set_state("hunger", WorldState.get_state("hunger") - closest_food.nutrition)
#		closest_food.queue_free()
#		return true
#
#	actor.move_to(actor.position.direction_to(closest_food.position), delta)
	return false
