extends Control


@export var combatEntryScene : PackedScene


func _ready():
	addCombatEntrys(["lul", "whaaat"])


func addCombatEntrys(sectioNames : Array):
	for sectioName in sectioNames:
		var combatEntry : CombatEntry = combatEntryScene.instantiate()
		add_child(combatEntry)
		combatEntry.addColors([Color.BLACK, Color.DARK_BLUE])
		combatEntry.setSectio(sectioName)
	
