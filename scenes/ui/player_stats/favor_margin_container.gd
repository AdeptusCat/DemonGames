extends MarginContainer


@onready var default_font_size : int = %FavorLabel.label_settings.font_size

func _ready():
	Signals.changeFavorsInUiContainer.connect(_on_changeFavorsInUiContainer)
	Signals.favorReachedPlayerStats.connect(_on_favorReachedPlayerStats)
	Signals.favorLeftPlayerStats.connect(_on_favorLeftPlayerStats)


func _on_changeFavorsInUiContainer(favors : int):
	%FavorLabel.text = str(favors)


func _on_favorReachedPlayerStats():
	%FavorLabel.text = str(%FavorLabel.text.to_int() + 1)
	var tween = create_tween()
	tween.tween_property(%FavorLabel.label_settings, "font_size", default_font_size + 50, 0.2)
	tween.tween_property(%FavorLabel.label_settings, "font_size", default_font_size, 0.2)


func _on_favorLeftPlayerStats():
	%FavorLabel.text = str(%FavorLabel.text.to_int() - 1)
	var tween = create_tween()
	tween.tween_property(%FavorLabel.label_settings, "font_size", default_font_size + 50, 0.2)
	tween.tween_property(%FavorLabel.label_settings, "font_size", default_font_size, 0.2)
