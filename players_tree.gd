extends Tree

var root
var entries : Dictionary = {}

var titleSize : int = 45
var entrySize : int = 28

func _ready():
	Signals.changePlayerDisplayValue.connect(_on_changeValue)
	Signals.createPlayerDisplayLine.connect(_on_addLine)
	root = create_item()
	set_column_title(0, "Name")
	set_column_title(1, "Souls")
	set_column_title(2, "Income")
	set_column_title(3, "Favors")
	set_column_title(4, "Disfavors")
	custom_minimum_size = Vector2(370,  entrySize + titleSize)
#	_on_addLine(1)
	

func _on_addLine(playerId):
	
	var line : TreeItem
	if playerId == Data.id:
		line = create_item(root, 0)
	else:
		line = create_item(root)
	line.set_text(0, "Name")
	line.set_tooltip_text(0, "The Player's Name.")
	line.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(0, false)
	line.set_text(1, "0")
	line.set_tooltip_text(1, "Souls are the currency that can buy you: Legions, Lieutenants, Arcana Cards. They can also be used to bribe units.")
	line.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(1, false)
	line.set_text(2, "0")
	line.set_tooltip_text(2, "Souls that will be collected in the next Soul Phase.")
	line.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(2, false)
	line.set_text(3, "0")
	line.set_tooltip_text(3, "Favors are needed to occupy Sectios that are not won in battle.")
	line.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(3, false)
	line.set_text(4, "0")
	line.set_tooltip_text(4, "Every Disfavor will block one of your Favors.")
	line.set_text_alignment(4, HORIZONTAL_ALIGNMENT_CENTER)
	line.set_selectable(4, false)
	entries[playerId] = line
#	custom_minimum_size = Vector2(custom_minimum_size.x, custom_minimum_size.y + 36)




func _on_changeValue(playerId, column, value):
	var line = entries[playerId]
	match column:
		"name":
			line.set_text(0, str(value))
			line.set_custom_bg_color(0, Data.players[playerId].color, true)
		"souls":
			line.set_text(1, str(value))
		"income":
			print("changed income ", value)
			line.set_text(2, value)
		"favors":
			line.set_text(3, str(value))
		"disfavors":
			line.set_text(4, str(value))


func _on_mouse_entered():
	var y : int = entries.size() * entrySize + titleSize
	var tw1 = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "custom_minimum_size", Vector2(370, y), 0.3)


func _on_mouse_exited():
	var tw1 = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "custom_minimum_size", Vector2(370,  entrySize + titleSize), 0.3)
