extends Node
class_name LevelData

var cat_count: int = 10
var cats: Array = []
var flags: Array = []
var paw: Array = []
var grass: Array = []

var wx: int = Global.WORLD_SIZE_X
var wy: int = Global.WORLD_SIZE_Y


func _ready() -> void:
	seed(floor(Time.get_unix_time_from_system()))
	for x in wx:
		cats.append([])
		flags.append([])
		paw.append([])
		grass.append([])
		for y in wy:
			cats[x].append([false])
			flags[x].append([false])
			paw[x].append(Global.CELL_PAW.NA)
			grass[x].append([true])


func generate_new() -> void:
	for x in wx:
		for y in wy:
			cats[x][y] = false
			flags[x][y] = false
			paw[x][y] = Global.CELL_PAW.NA
			grass[x][y] = true
	self.generate_cats()
	self.search_paw()


func generate_cats() -> void:
	var count_regen: int = 0
	for i in cat_count:
		var x: int = min(floor(randf() * wx), wx - 1)
		var y: int = min(floor(randf() * wy), wy - 1)
		while cats[x][y]:
			x = floor(randf() * wx)
			y = floor(randf() * wy)
			count_regen += 1
		cats[x][y] = true
	print("Count regeneration: ", count_regen)


func search_paw() -> void:
	for x in wx:
		for y in wy:
			paw[x][y] = self.search_cat(x, y)

func search_cat(x: int, y: int) -> int: #Global.CELL_PAW
	# Вычисляем расстояния во всех направлениях
	var u = search_in_direction(x, y, 0, -1, y)			# Вверх
	var d = search_in_direction(x, y, 0, 1, wy - y - 1)	# Вниз
	var l = search_in_direction(x, y, -1, 0, x)			# Влево
	var r = search_in_direction(x, y, 1, 0, wx - x - 1)	# Вправо
	
	return Global.calc_vector(u, d, l, r)

# Вспомогательная функция для поиска в одном направлении
func search_in_direction(x: int, y: int, dx: int, dy: int, max_steps: int) -> int:
	if max_steps <= 0:
		return -1
	for i in range(1, max_steps + 1):
		var new_x = x + dx * i
		var new_y = y + dy * i
		# Добавляем проверку выхода за границы массива
		if new_x < 0 || new_x >= wx || new_y < 0 || new_y >= wy:
			break
		if cats[new_x][new_y]:
			return i
	return -1


# TODO

func destroy(x: int, y: int) -> void:
	pass


func mark(x: int, y: int) -> void:
	pass


func check_win() -> void:
	pass
