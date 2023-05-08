extends Node

var sectioIdsNodeDict : Dictionary = {}

class HyperAStar2D:
	extends AStar2D

	func _compute_cost(u : int, v : int):
		return 1.0

	func _estimate_cost(u : int, v : int):
		return 1.0


var astar : HyperAStar2D

var map_nodes_by_name : Dictionary
var map_nodes_by_id : Dictionary

func _ready():
	astar = HyperAStar2D.new()
