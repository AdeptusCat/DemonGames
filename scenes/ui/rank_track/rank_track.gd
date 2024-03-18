extends Control


@export var entryScene : PackedScene

var margin : Vector2 = Vector2(10, 10)
var marginBetweenEntries : int = 10
var moveTime : float = 0.5

var entries : Array = []
var entriesRank : Array = []
var rankTrack : Array = []

var _entries : Array = []
var _entriesRank : Array = []


func _ready():
	Signals.updateRankTrack.connect(_on_updateRankTrack)
	Signals.currentDemon.connect(_on_currentDemon)
	Signals.actionsDone.connect(_on_actionsDone)
	Signals.action.connect(_on_action)
	Signals.passOptionSelected.connect(_on_passOptionSelected)
	
	#await get_tree().create_timer(0.1).timeout
	#_on_updateRankTrack([1,2,3])
	#_on_action(0, "Reset")
	#await get_tree().create_timer(moveTime + 0.5).timeout
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
		tweenToPosition(entry, %MarginContainer.global_position + Vector2((entry.size.x + marginBetweenEntries) * i, 0))
		i += 1


func tweenToPosition(entry : RankTrackEntry, position : Vector2):
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(entry, "global_position", position, moveTime)
	tween.play()


func _on_updateRankTrack(_rankTrack : Array):
	rankTrack = _rankTrack
	Data.rankTrack = rankTrack


func _on_currentDemon(currentDemonRank : int):
	for rank in entriesRank.duplicate():
		if rank == currentDemonRank:
			break
		else:
			moveOut()
	for entry : RankTrackEntry in entries:
		entry.flashOff()
	if not entries.is_empty():
		if Data.players[Data.demons[currentDemonRank].player].playerId == Data.id:
			entries[0].flash()


func _on_action(_rank : int, action : String):
	if action == "Reset":
		show()
		var i : int = 0
		for rank in rankTrack:
			var entry : RankTrackEntry = entryScene.instantiate()
			add_child(entry)
			entry.rank = rank
			entry.playerId = Data.players[Data.demons[rank].player].playerId
			entry.colorRect.color = Data.players[Data.demons[rank].player].color
			entry.textureRect.texture = Data.demons[rank].image
			entry.global_position = %MarginContainer.global_position + Vector2(2000, 0) + Vector2(entry.size.x * i, 0)
			entries.append(entry)
			entriesRank.append(rank)
			i += 1
		moveIn()
	if action == "Pass":
		entries = _entries.duplicate()
		entriesRank = _entriesRank.duplicate()


func _on_actionsDone():
	moveOut()
	entries.clear()
	entriesRank.clear()
	hide()


@rpc("any_peer", "call_local")
func changeRankTrackPosition(newRankPosition : int):
	_entries = entries.duplicate()
	var insert : RankTrackEntry = _entries.pop_front()
	_entries.insert(newRankPosition, insert)
	_entriesRank.clear()
	var i : int = 0
	for entry : RankTrackEntry in _entries:
		tweenToPosition(entry, %MarginContainer.global_position + Vector2((entry.size.x + marginBetweenEntries) * i, 0))
		_entriesRank.append(entry.rank)
		i += 1


@rpc("any_peer", "call_local")
func resetRankTrackPosition():
	print("reset ranktrack ",Data.id)
	var i : int = 0
	for entry : RankTrackEntry in entries:
		tweenToPosition(entry, %MarginContainer.global_position + Vector2((entry.size.x + marginBetweenEntries) * i, 0))
		i += 1


func _on_passOptionSelected(passInterval : int):
	if passInterval == 0:
		for peer in Connection.peers:
			resetRankTrackPosition.rpc_id(peer)
	else:
		for peer in Connection.peers:
			changeRankTrackPosition.rpc_id(peer, passInterval)


func _on_label_mouse_entered():
	changeRankTrackPosition(1)


func _on_label_mouse_exited():
	resetRankTrackPosition()


func _on_label_gui_input(event):
	if Input.is_action_just_pressed("click"):
		pass
