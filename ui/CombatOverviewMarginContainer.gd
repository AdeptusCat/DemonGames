extends MarginContainer

const combatEntryScene = preload("res://combat_entry.tscn")
var entries = {}


func _ready():
	Signals.showCombatSectios.connect(_on_showCombatSectios)
	hide()


func _on_showCombatSectios(sectioNames : Array):
	for node in $MarginContainer/VBoxContainer/VBoxContainer.get_children():
		node.queue_free()
	show()
	
	entries = {}
	var combatRankNr : int = 0
	for sectioName in sectioNames:
		combatRankNr += 1
		var sectio = Decks.sectioNodes[sectioName]
		var combatEntry = combatEntryScene.instantiate()
		combatEntry.populate(sectioName, combatRankNr)
		#$MarginContainer/VBoxContainer/VBoxContainer2/Label2.text = "You can occupy " + str(Data.player.favors - Data.player.disfavors) + " more Sectios"
		$MarginContainer/VBoxContainer/VBoxContainer.add_child(combatEntry)
		entries[sectioName] = combatEntry
		
		#RpcCalls.petitionsDone.rpc_id(Connection.host)


func _on_button_pressed():
	hide()
