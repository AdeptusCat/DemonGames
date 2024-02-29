extends MarginContainer


@onready var default_font_size : int = %SoulsLabel.label_settings.font_size


func _ready():
	Signals.changeSoulsInUiContainer.connect(_on_changeSoulsInUiContainer)
	Signals.soulReachedPlayerStats.connect(_on_soulReachedPlayerStats)
	Signals.soulLeftPlayerStats.connect(_on_soulLeftPlayerStats)


func _on_changeSoulsInUiContainer(souls : int):
	%SoulsLabel.text = str(souls)


func _on_soulReachedPlayerStats():
	%SoulsLabel.text = str(%SoulsLabel.text.to_int() + 1)
	var tween = create_tween()
	tween.tween_property(%SoulsLabel.label_settings, "font_size", default_font_size + 50, 0.2)
	tween.tween_property(%SoulsLabel.label_settings, "font_size", default_font_size, 0.2)


func _on_soulLeftPlayerStats():
	%SoulsLabel.text = str(%SoulsLabel.text.to_int() - 1)
	var tween = create_tween()
	tween.tween_property(%SoulsLabel.label_settings, "font_size", default_font_size + 50, 0.2)
	tween.tween_property(%SoulsLabel.label_settings, "font_size", default_font_size, 0.2)

