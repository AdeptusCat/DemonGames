extends HBoxContainer

var defaultFontSize = 16
var highlightedFontSize = 40


func _ready():
	Signals.phaseDescription.connect(_on_phaseDescription)


func _on_phaseDescription(phase : int, phaseText : String):
	
	$SoulPhaseLabel.add_theme_font_size_override("font_size", defaultFontSize)
	$SoulPhaseLabel.modulate = Color8(255,255,255)
	$SummoningPhaseLabel.add_theme_font_size_override("font_size", defaultFontSize)
	$SummoningPhaseLabel.modulate = Color8(255,255,255)
	$ActionPhaseLabel.add_theme_font_size_override("font_size", defaultFontSize)
	$ActionPhaseLabel.modulate = Color8(255,255,255)
	$CombatPhaseLabel.add_theme_font_size_override("font_size", defaultFontSize)
	$CombatPhaseLabel.modulate = Color8(255,255,255)
	$PetitionPhaseLabel.add_theme_font_size_override("font_size", defaultFontSize)
	$PetitionPhaseLabel.modulate = Color8(255,255,255)

	match phase:
		Data.phases.Hell:
			pass
		Data.phases.Soul:
			$SoulPhaseLabel.add_theme_font_size_override("font_size", highlightedFontSize)
			$SoulPhaseLabel.modulate = Color8(255,10,10)
			#%PhaseSummaryLabel.text = ""
		Data.phases.Summoning:
			$SummoningPhaseLabel.add_theme_font_size_override("font_size", highlightedFontSize)
			$SummoningPhaseLabel.modulate = Color8(255,10,10)
			#%PhaseSummaryLabel.text = "Click on Sectios to buy Legions for 3 Souls.\nBuy Arcana Cards for 5 Souls.\nBuy Lieutenants by using the appropiate Arcana Card."
		Data.phases.Action:
			$ActionPhaseLabel.add_theme_font_size_override("font_size", highlightedFontSize)
			$ActionPhaseLabel.modulate = Color8(255,10,10)
			#%PhaseSummaryLabel.text = "Use your Demons to take Actions in turn."
		Data.phases.Combat:
			$CombatPhaseLabel.add_theme_font_size_override("font_size", highlightedFontSize)
			$CombatPhaseLabel.modulate = Color8(255,10,10)
		Data.phases.Petitions:
			$PetitionPhaseLabel.add_theme_font_size_override("font_size", highlightedFontSize)
			$PetitionPhaseLabel.modulate = Color8(255,10,10)
			#%PhaseSummaryLabel.text = "Occupy Sectios with your Legions in them by paying one Favor.\nOccupy Sectios by winning a Fight in them."

