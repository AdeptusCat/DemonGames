extends Label

signal mouseEntered(demonRank)
signal mouseExited()

var active = false
var tw1
func _on_mouse_entered():
	print("hedfre")
	mouseEntered.emit(text)


func _on_gui_input(_event):
	if Input.is_action_just_pressed("click"):
		mouseEntered.emit(text)
		active = true

func _input(_event):
	if active:
		if Input.is_action_just_pressed("right_click"):
			mouseExited.emit()
			active = false

#func _process(delta):
#	if tw1:
#		print(self)

#func stopTween():
#	if tw1:
#		tw1.stop()

func startTween():
	tw1 = create_tween()
	tw1.set_loops(50) # value here or endless warnings get printed...
	tw1.set_trans(Tween.TRANS_CUBIC)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "scale", Vector2(1.2, 1.2), 1.0)
	#			tw1.tween_property(n, "modulate:a", 0.8, 1.0)
	tw1.tween_interval(0.01)
	tw1.set_trans(Tween.TRANS_SINE)
	tw1.set_ease(Tween.EASE_OUT)
	tw1.tween_property(self, "scale", Vector2(1.0, 1.0), 1.0)
	#			tw1.tween_property(n, "modulate:a", 0.4, 1.5)
	tw1.play()
