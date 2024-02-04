extends GoapGoal

class_name HasMoreLegionsGoal

#func get_class(): return "HasMoreLegionsGoal"


func is_valid() -> bool:
	var mostUnits : int = 0
	for player in Data.players.values():
		if player == Data.currentAiPlayer:
			continue
		if player.troops.size() > mostUnits:
			mostUnits = player.troops.size()
	print("HasMoreLegionsGoal ", Data.currentAiPlayer.troops.size() < mostUnits + 1, Data.currentAiPlayer.troops.size(), mostUnits)
	return Data.currentAiPlayer.troops.size() < mostUnits + 1 and Data.currentAiPlayer.souls >= 3
#	return true


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
		"has_more_legions": true
	}
