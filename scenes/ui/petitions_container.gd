extends MarginContainer

@export var petitionEntryScene : PackedScene
var entries = {}


func _ready():
	Signals.populatePetitionsContainer.connect(populate)


func populate(sectioNames : Array):
	for node in $MarginContainer/VBoxContainer/VBoxContainer.get_children():
		node.queue_free()
	show()
	
	entries = {}
	for sectioName in sectioNames:
		var sectio = Decks.sectioNodes[sectioName]
		var petitionEntry = petitionEntryScene.instantiate()
		petitionEntry.populate(sectioName, str(sectio.souls))
		petitionEntry.reply.connect(_on_reply)
		$MarginContainer/VBoxContainer/VBoxContainer2/Label2.text = "You can occupy " + str(Data.player.favors - Data.player.disfavors) + " more Sectios"
		$MarginContainer/VBoxContainer/VBoxContainer.add_child(petitionEntry)
		entries[sectioName] = petitionEntry
	
	var hasFavor = Data.player.hasFavor()
	for entry in entries.values():
		entry.highlight(hasFavor)
	if not hasFavor:
		hide()
		print("petitions no favor")
		await get_tree().create_timer(0.3).timeout
		RpcCalls.petitionsDone.rpc_id(Connection.host)
		AudioSignals.playerTurnDone.emit()


func _on_reply(sectioName, boolean):
	entries[sectioName].queue_free()
	if boolean:
		var favors = Data.player.favors - 1
		Signals.changeFavors.emit(Data.id, favors)
		Signals.changeFavorsInUI.emit(favors)
		Data.sectiosToClaim.append([Data.id, sectioName])
		print("petitions to claim2 ",Data.sectiosToClaim)
	$MarginContainer/VBoxContainer/VBoxContainer2/Label2.text = "You can occupy " + str(Data.player.favors - Data.player.disfavors) + " more Sectios"
	entries.erase(sectioName)
	var hasFavor = Data.player.hasFavor()
	for entry in entries.values():
		if is_instance_valid(entry):
			entry.highlight(hasFavor)
	if entries.size() <= 0 or not hasFavor:
		hide()
		if not Data.id == Connection.host:
			sendSectiosToClaimToHost.rpc_id(Connection.host, Data.sectiosToClaim)
			print("petitions to claim1 ",Data.sectiosToClaim)
		RpcCalls.petitionsDone.rpc_id(Connection.host)
		for sectio in Decks.sectioNodes.values():
			sectio.changeClickable(false)
		AudioSignals.playerTurnDone.emit()


@rpc ("any_peer", "call_local")
func sendSectiosToClaimToHost(sectiosToClaim):
	print("petitions to claim0 ",sectiosToClaim)
	Data.sectiosToClaim = Data.sectiosToClaim + sectiosToClaim
