extends Control

var tw3
var souls : int = 0
var time : float = 0.5

var prevPosition
func _ready():
	showSoulsPaid(souls)

func showSoulsPaid(souls : int):
	%SoulsGatherLabel.text = str(souls)
	prevPosition = %MarginContainer.position
	%MarginContainer.show()
	tw3 = create_tween()
	tw3.set_trans(Tween.TRANS_QUAD)
	tw3.set_ease(Tween.EASE_IN)
	tw3.parallel().tween_property(%MarginContainer, "position", %MarginContainer.position + Vector2(0, -150), time)
	tw3.parallel().tween_property(%MarginContainer, "modulate:a", 0, time)
	tw3.tween_callback(hideSoulsPaid)

func hideSoulsPaid():
	Signals.animationDone.emit()
	%MarginContainer.hide()
	%MarginContainer.position = prevPosition
	%MarginContainer.modulate.a = 1
	queue_free()

func _input(event):
	if Input.is_action_pressed("space"):
		if tw3:
			tw3.kill()
			hideSoulsPaid()
