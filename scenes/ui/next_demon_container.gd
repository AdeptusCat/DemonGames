extends MarginContainer

var demonNode
var tw1

func _ready():
	Signals.nextDemon.connect(nextDemon)
	Signals.demonClicked.connect(_on_demonClicked)

@rpc("any_peer", "call_local")
func nextDemon(demonRank : int):
	if demonNode:
		demonNode.queue_free()
	demonNode = Data.demons[demonRank].duplicate()
	%DemonLabel.text = demonNode.demonName + " is next to perform hellish actions."
	%NextDemonVBoxContainer.add_child(demonNode)
#	show()
#	await Signals.demonClicked
#	hide()
	modulate.a = 1.0
	show()
	if tw1:
		tw1.kill()
	tw1 = create_tween()
	tw1.set_trans(Tween.TRANS_QUAD)
	tw1.set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "modulate", Color(1,1,1,0), 3.0).set_delay(0.2)
	tw1.tween_callback(hideDemon)


func hideDemon():
	hide()
	modulate.a = 1.0


func _on_demonClicked(demon):
	if tw1:
		hide()


func _on_timer_timeout():
	Signals.demonClicked.emit(null)
	
