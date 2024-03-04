extends Control

@export var map : Node2D
var items : Array
# Called when the node enters the scene tree for the first time.
func _ready():
	map.on_change.connect(_on_map_change)
	_on_map_change()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_map_change():
	for item in items:
		item.queue_free()
	items.clear()
	sectios = map.get_sectios()
	for sectio in sectios:
		var item = sectioScene.instantiate()
		item.initialize(sectio)
		add_child(item)
		items.append(item)
		
