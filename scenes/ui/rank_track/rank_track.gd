extends Control


@export var entryScene : PackedScene

var margin : Vector2 = Vector2(10, 10)
var marginBetweenEntries : int = 10
var moveTime : float = 2.0

var entries : Array = []
var entriesRank : Array = []
var rankTrack : Array = []


func _ready():
	Signals.updateRankTrack.connect(_on_updateRankTrack)
	Signals.currentDemon.connect(_on_currentDemon)
	
	#await get_tree().create_timer(0.1).timeout
	#_on_updateRankTrack([1,2,3])
	#await get_tree().create_timer(3).timeout
	#_on_currentDemon(3)
	
	#await get_tree().create_timer(0.1).timeout
	#for i in range(4):
		#var entry : RankTrackEntry = entryScene.instantiate()
		#add_child(entry)
		#entry.global_position = %MarginContainer.global_position + Vector2(2000, 0) + Vector2(entry.size.x * i, 0)
		#entries.append(entry)
	#
	#moveIn()
	#
	#await get_tree().create_timer(3).timeout
	#moveOut()
	#await get_tree().create_timer(3).timeout
	#moveOut()
	#await get_tree().create_timer(3).timeout
	#moveOut()


func moveOut():
	entriesRank.pop_front()
	var entry = entries.pop_front()
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(entry, "global_position", %MarginContainer.global_position - Vector2(400, 0) , moveTime)
	tween.tween_callback(entry.queue_free)
	tween.play()
	moveIn()


func moveIn():
	var i : int = 0
	for entry in entries:
		var tween : Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(entry, "global_position", %MarginContainer.global_position + Vector2((entry.size.x + marginBetweenEntries) * i, 0) , moveTime)
		tween.play()
		i += 1


func _on_updateRankTrack(_rankTrack : Array):
	if _rankTrack == rankTrack:
		return
	rankTrack = _rankTrack
	var i : int = 0
	for rank in rankTrack:
		var entry : RankTrackEntry = entryScene.instantiate()
		add_child(entry)
		entry.global_position = %MarginContainer.global_position + Vector2(2000, 0) + Vector2(entry.size.x * i, 0)
		entries.append(entry)
		entriesRank.append(rank)
		i += 1
	moveIn()


func _on_currentDemon(currentDemonRank : int):
	for rank in entriesRank.duplicate():
		print(rank)
		if rank == currentDemonRank:
			break
		else:
			moveOut()
		
