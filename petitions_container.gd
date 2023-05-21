extends MarginContainer

const petitionEntryScene = preload("res://petition_entry.tscn")
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
		await get_tree().create_timer(0.3).timeout
		RpcCalls.petitionsDone.rpc_id(Connection.host)


func _on_reply(sectioName, boolean):
	entries[sectioName].queue_free()
	if boolean:
		var favors = Data.player.favors - 1
		Signals.changeFavors.emit(Data.id, favors)
		for peer in Connection.peers:
			RpcCalls.occupySectio.rpc_id(peer, Data.id, sectioName)
	$MarginContainer/VBoxContainer/VBoxContainer2/Label2.text = "You can occupy " + str(Data.player.favors - Data.player.disfavors) + " more Sectios"
	entries.erase(sectioName)
	var hasFavor = Data.player.hasFavor()
	for entry in entries.values():
		if is_instance_valid(entry):
			entry.highlight(hasFavor)
	if entries.size() <= 0 or not hasFavor:
		hide()
		RpcCalls.petitionsDone.rpc_id(Connection.host)
