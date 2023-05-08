extends Resource
class_name ArcanaResource

@export var cardName : String = "Sacred Music"
enum MinorSpell {WalkTheEarth, RecruitLieutenants, NonaryPass, Pass, DoublePass, TriplePass, QuadruplePass, QuinaryPass, SenaryPass, SeptenaryPass, OctonaryPass, PlayRightAway, WalkTheEarthSafely}
@export var minorSpell : MinorSpell = MinorSpell.Pass
@export var cost : int = 1
@export var player : int = 1
