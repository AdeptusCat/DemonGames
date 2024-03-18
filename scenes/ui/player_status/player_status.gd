extends Tree

var root
var entries : Dictionary = {}

var titleSize : int = 45
var entrySize : int = 28

func _ready():
	Signals.changePlayerStatus.connect(_on_changePlayerStatus)
	Signals.addPlayerStatus.connect(_on_addPlayerStatus)
	root = create_item()
	set_column_title(0, "Player")
	set_column_title(1, "Status")
	custom_minimum_size = Vector2(370,  entrySize + titleSize)


func _on_addPlayerStatus(playerId):
	var line : TreeItem
	line = create_item(root)
	line.set_text(0, Data.players[playerId].playerName)
	line.set_custom_color(0, Data.players[playerId].color)
	line.set_tooltip_text(0, "The Player's Name and Color.")
	line.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(0, false)
	line.set_text(1, "0")
	line.set_tooltip_text(1, "Status of the Player.")
	line.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(1, false)
	entries[playerId] = line
	
	if playerId == Data.id:
		line.visible = false
	else:
		custom_minimum_size = Vector2(370,  entries.size() * entrySize + titleSize)


func _on_changePlayerStatus(playerId : int, status : String):
	var line = entries[playerId]
	line.set_text(1, status)
	hideIfAllPlayersDone()


func hideIfAllPlayersDone():
	var doneEntries : int = 0
	for entry in entries.values():
		if entry.get_text(1) == "Done":
			doneEntries += 1
	
	if doneEntries == entries.size():
		hide()
	else:
		show()