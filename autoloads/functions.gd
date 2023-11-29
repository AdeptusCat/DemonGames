extends Node


func findByClass(node: Node, className : String, result : Array) -> Array:
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)
	return result
