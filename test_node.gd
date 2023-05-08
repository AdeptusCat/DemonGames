extends Node

var tw1
var tw2

# Called when the node enters the scene tree for the first time.
#func _ready():
#	highlight(true)
#	await get_tree().create_timer(0.5).timeout
#	highlight(true)
#	await get_tree().create_timer(0.5).timeout
#	highlight(true)
#	await get_tree().create_timer(0.5).timeout
#	highlight(true)
#	await get_tree().create_timer(0.5).timeout
#	highlight(true)
#	await get_tree().create_timer(0.5).timeout
#	highlight(false)
#	await get_tree().create_timer(0.5).timeout
#	highlight(true)
#	await get_tree().create_timer(0.5).timeout
#	highlight(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func highlight(boolean):
	if boolean:
		if tw1:
			tw1.kill()
			tw2.kill()
		tw1 = get_tree().create_tween()
		tw1.set_loops(10)
		tw1.set_trans(Tween.TRANS_CUBIC)
		tw1.set_ease(Tween.EASE_IN)
	#		tw1.tween_property(playerPolygon, "scale", Vector2(1.2, 1.2), 1.0)
		tw1.tween_property(self, "modulate:a", 0.8, 0.5)
		tw1.tween_interval(0.01)
		tw1.set_trans(Tween.TRANS_SINE)
		tw1.set_ease(Tween.EASE_OUT)
	#		tw1.tween_property(playerPolygon, "scale", Vector2(1.0, 1.0), 1.0)
		tw1.tween_property(self, "modulate:a", 0.4, 0.5)
	#		tw1.play()

		tw2 = get_tree().create_tween()
		tw2.set_loops(10)
		tw2.set_trans(Tween.TRANS_CUBIC)
		tw2.set_ease(Tween.EASE_IN)
		tw2.tween_property(self, "scale", Vector2(1.1, 1.1), 1.0)
	#		tw2.tween_property(playerPolygon, "modulate:a", 0.8, 1.0)
		tw2.tween_interval(0.01)
		tw2.set_trans(Tween.TRANS_SINE)
		tw2.set_ease(Tween.EASE_OUT)
		tw2.tween_property(self, "scale", Vector2(1.0, 1.0), 2.0)
	#		tw2.tween_property(playerPolygon, "modulate:a", 0.4, 1.0)
	#		tw2.play()
	else:
		if tw1:
			tw1.kill()
			tw2.kill()
			var tween1 = get_tree().create_tween()
			tween1.set_trans(Tween.TRANS_CUBIC)
			tween1.set_ease(Tween.EASE_IN)
	#			tween1.tween_property(playerPolygon, "scale", Vector2(1.0, 1.0), 1.0)
			tween1.tween_property(self, "modulate:a", 0.4, 1.0)
	#			tween1.play()
