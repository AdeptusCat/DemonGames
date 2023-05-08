extends Node

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()

func roll(dice : int) -> Array:
	var results = []
	for die in dice:
		var random_number = rng.randi_range(1, 6)
		results.append(random_number)
	return results

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func disfavorRoll(disfavors : int):
	var result = roll(1)
	if result[0] > disfavors:
		return true
	else:
		return false
