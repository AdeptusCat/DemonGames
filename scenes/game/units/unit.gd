extends Node2D

class_name Unit

const movesLeftContainerScene = preload("res://scenes/ui/moves_left_container.tscn")
var movesLeftContainer

var marginContainer

var destination : Vector2
var destinations : Array
const speed : int = 5
var previousSectio : String = ""
var occupiedSectio : String = "Court Of Corruption":
	set(_occupiedSectio):
		previousSectio = occupiedSectio
		occupiedSectio = _occupiedSectio
var occupiedCircle : int = 1
var occupiedQuarter : int = 4
var unitName : String = ""
var clickable : bool = false
var sectiosMoved : int = 0
var maxSectiosMoved : int = 2
var fleeing : bool = false
var arrived : bool = true

var unitType : Data.UnitType
var unitNr : int = 0
var triumphirate : int = 0
var texture : Texture
var normalMap : Texture
var lastPositionSent : Vector2 = Vector2.ZERO

signal unitMovedMax(node)
signal unitClicked(node)
signal arrivedAtDestination(node)

#func _ready():
#	unitNr = str(name).to_int()
#	triumphirate = str(get_parent().name).to_int()
#	Data.troops[unitNr] = self
#	print("data.troops set ", unitNr)
#	Data.players[triumphirate].troops[unitNr] = self
#	set_process(false)



func setup():
	unitNr = str(name).to_int()
	triumphirate = str(get_parent().name).to_int()
	Data.troops[unitNr] = self
	Data.players[triumphirate].troops[unitNr] = self
	set_process(false)


func showMovesLeft(boolean : bool, value : int = 0):
	if boolean:
		if is_instance_valid(movesLeftContainer):
			movesLeftContainer.movesLeft(value)
		else:
			movesLeftContainer = movesLeftContainerScene.instantiate()
			movesLeftContainer.movesLeft(value)
			add_child(movesLeftContainer)
			movesLeftContainer.position.x += marginContainer.size.x
	else:
		if is_instance_valid(movesLeftContainer):
			movesLeftContainer.queue_free()
