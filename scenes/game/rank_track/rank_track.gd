extends Node

var rankTrack : Array = []


func _ready():
	Signals.addDemon.connect(addDemon)
	Signals.removeDemon.connect(_on_removeDemon)


func addDemon(demonRank : int):
	rankTrack.append(demonRank)
	rankTrack.sort()


func _on_removeDemon(demonRank : int):
	rankTrack.erase(demonRank)
	print("erasing demon ", rankTrack, demonRank)


func updateRankTrack(newRankTrack):
	rankTrack = newRankTrack


