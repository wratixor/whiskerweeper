extends Node2D

var wx: int = 10
var dcount: Dictionary = {}

func _ready() -> void:
	for i in 100000:
		var x: int = floor(randf() * wx)
		var c = dcount.get_or_add(x, 0)
		dcount[x] = c + 1
	print(dcount)
