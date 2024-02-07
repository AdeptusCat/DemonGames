extends Node
class_name Demon

@export var stats : Resource
signal demonClicked(node)

const maleTexture = preload("res://assets/demons/genders/male.png")
const femaleTexture = preload("res://assets/demons/genders/female.png")
const hermaphroditeTexture = preload("res://assets/demons/genders/male_female.png")
const undefinedTexture = preload("res://assets/demons/genders/undefined.png")
const soulsGatherScene = preload("res://scenes/ui/soul_phase/souls_gather_container.tscn")



var demonName : String = "":
	set(_name):
		demonName = _name
		%DemonNameLabel.text = demonName
var rank : int = 2:
	set(_rank):
		rank = _rank
		%RankLabel.text = str(rank)
var skulls : int = 6:
	set(_skulls):
		skulls = _skulls
		var counter = 0
		for child in %SkullsVBoxContainer.get_children():
			child.hide()
#			print(counter, " ",skulls)
			if counter < skulls:
				child.show()
			else:
				child.hide()
			counter += 1
var stars : int = 6:
	set(_stars):
		stars = _stars
		var counter = 0
		for child in %StarsVBoxContainer.get_children():
			child.hide()
			if counter < stars:
				child.show()
			else:
				child.hide()
			counter += 1
var hearts : int = 6:
	set(_hearts):
		hearts = _hearts
		var counter = 0
		for child in %HeartsVBoxContainer.get_children():
			child.hide()
			if counter < hearts:
				child.show()
			else:
				child.hide()
			counter += 1
enum Sex {Male, Female, Hermaphrodite, Undefined}
var sex : Sex = Sex.Male:
	set(_sex):
		sex = _sex
		match sex:
			Sex.Male:
				%SexTextureRect.texture = maleTexture
				print("male demon ", %SexTextureRect.texture)
			Sex.Female:
				%SexTextureRect.texture = femaleTexture
			Sex.Hermaphrodite:
				%SexTextureRect.texture = hermaphroditeTexture
			Sex.Undefined:
				%SexTextureRect.texture = undefinedTexture
var player : int = 0:
	set(_player):
		player = _player
		if Data.players.has(player):
			var color : Color = Data.players[player].color
			%ColorRect.modulate = color
var incapacitated : bool = false:
	set(_incapacitated):
		incapacitated = _incapacitated
		if incapacitated:
			%StatusLabel.text = "Incapacitated"
		else:
			%StatusLabel.text = "In Hell"
var onEarth : bool = false:
	set(_onEarth):
		onEarth = _onEarth
		if not incapacitated:
			if onEarth:
				%StatusLabel.text = "On Earth"
			else:
				%StatusLabel.text = "In Hell"
var image : Texture:
	set(_image):
		%DemonTextureRect.texture = _image

var description : String:
	set(_description):
		description = _description
		%DemonDescriptionLabel.text = description
var skullsUsed = 0
var tw3
var inBattle := false


func _ready():
	Signals.combatOver.connect(_on_combatOver)
	Signals.combatPhaseStarted.connect(_on_combatPhaseStarted)
	demonClicked.connect(_on_demonClicked)


func _on_combatPhaseStarted():
	if onEarth:
		%NotBattleReadyLabel.text = "On Earth"
		%NotBattleReadyContainer.show()
	elif inBattle:
		%NotBattleReadyLabel.text = "In Battle"
		%NotBattleReadyContainer.show()
	elif incapacitated:
		%NotBattleReadyLabel.text = "Incapacitated"
		%NotBattleReadyContainer.show()
	

func _on_combatOver():
	%NotBattleReadyContainer.hide()
	inBattle = false

func chosenToBattle():
	%NotBattleReadyLabel.text = "In Battle"
	%NotBattleReadyContainer.show()
	inBattle = true

func loadStats():
	demonName = stats.name
	rank = stats.rank
	skulls = stats.skulls
	stars = stats.stars
	hearts = stats.hearts
	sex = stats.sex
	player = stats.player
	incapacitated = stats.incapacitated
	onEarth = stats.onEarth
	
	var demonImages : Array = []
	var dir = DirAccess.open("res://assets/demons/textures/" + demonName.to_lower())
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if not file_name.ends_with(".import"):
					print("Found file: " + file_name)
					demonImages.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	demonImages.shuffle()
	
	var image_path = "res://assets/demons/textures/" + demonName.to_lower() + "/" + demonImages.pop_back()
	var image1 = Image.new()
	image1.load(image_path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image1)
	
	image = image_texture
	
	description = stats.description


func loadGame(savegame : Dictionary):
	incapacitated = savegame.incapacitated
	onEarth = savegame.onEarth



func showSoulsGathered(souls : int, favors : int):
	var soulsGatherNode = soulsGatherScene.instantiate()
	soulsGatherNode.souls = souls
	soulsGatherNode.time = 1.5
	%SoulsGatherControl.add_child(soulsGatherNode)
	
	var favorGatherNode = soulsGatherScene.instantiate()
	favorGatherNode.souls = favors
	favorGatherNode.time = 1.5
	%FavorsGatherControl.add_child(favorGatherNode)


func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
		demonClicked.emit(self)
		Signals.demonClicked.emit(self)
		if Tutorial.tutorial:
			if Tutorial.currentTopic == Tutorial.Topic.DemonDetails:
				Signals.tutorialRead.emit()


func _on_demonClicked(demonNode):
	if Data.chooseDemon:
		if Data.player.hasFavor():
			Data.player.favors = Data.player.favors - 1
			RpcCalls.requestNewDemon.rpc_id(Connection.host, Data.id, demonNode.rank)
	if Data.phase == Data.phases.Combat and Data.pickDemon:
		if demonNode.incapacitated:
			return
		if demonNode.onEarth:
			return
		if demonNode.inBattle:
			return
		demonNode.chosenToBattle()
		Data.pickDemon = false
		RpcCalls.pickedDemonForCombat.rpc_id(Connection.host, demonNode.rank)
		Signals.pickedDemonForCombat.emit()
		Signals.collapseDemonCards.emit()


