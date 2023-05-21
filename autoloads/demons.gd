extends Node


func _ready():
	Signals.demonStatusChange.connect(_on_demon_status_change)
	Signals.pickedDemon.connect(_on_picked_demon)


func _on_demon_status_change(demonRank, status):
	for peer in Connection.peers:
		RpcCalls.demonStatusChange.rpc_id(peer, demonRank, status)
	Signals.incomeChanged.emit(Data.id)


func _on_picked_demon(demonRank : int):
	RpcCalls.pickedDemonForCombat.rpc_id(Connection.host, demonRank)
