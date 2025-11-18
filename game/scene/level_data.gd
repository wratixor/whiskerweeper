extends Node
class_name LevelData

var cat_count: int = 10
var cats: Array = []
var flags: Array = []
var paw: Array = []
var grass: Array = []

var wx: int = Global.WORLD_SIZE_X
var wy: int = Global.WORLD_SIZE_Y
#               0  1  2  3  4   5   6   7   8   9  10  11  12  13  14  15  
enum CELL_PAW {NA, U, D, L, R, UD, LR, UR, RD, DL, LU, NU, ND, NL, NR, A}

func _ready() -> void:
	SignalBus.l_click.connect(destroy)
	SignalBus.r_click.connect(mark)
	seed(floor(Time.get_unix_time_from_system()))
	for x in wx:
		cats.append([])
		flags.append([])
		paw.append([])
		grass.append([])
		for y in wy:
			cats[x].append([false])
			flags[x].append([false])
			paw[x].append(CELL_PAW.NA)
			grass[x].append([true])


func generate_new() -> void:
	print("Clean...")
	cat_count = Global.get_cat_count()
	for x in wx:
		for y in wy:
			cats[x][y] = false
			flags[x][y] = false
			paw[x][y] = CELL_PAW.NA
			grass[x][y] = true
	print("Gen cats...")
	generate_cats()
	print("Calc paws...")
	search_paw()
	SignalBus.redraw_lvl.emit()


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
			print(Vector2i(x, y))
			paw[x][y] = search_cat(x, y)
	print(paw)


func search_cat(x: int, y: int) -> int: #Global.CELL_PAW
	# Вычисляем расстояния во всех направлениях
	var u = search_in_direction(x, y, 0, -1, y)			# Вверх
	var d = search_in_direction(x, y, 0, 1, wy - y - 1)	# Вниз
	var l = search_in_direction(x, y, -1, 0, x)			# Влево
	var r = search_in_direction(x, y, 1, 0, wx - x - 1)	# Вправо
	var nu = calc_vector(u, d, l, r)
	print("udlr: ", u, d, l, r, "v: ", nu)
	return nu

# Вспомогательная функция для поиска в одном направлении
func search_in_direction(x: int, y: int, dx: int, dy: int, max_steps: int) -> int:
	if max_steps <= 0:
		return -1
	print("xy(", x, ",", y, ") dxy(", dx, ",", dy, ")")
	print(range(0, max_steps + 1))
	for i in range(0, max_steps + 1):
		var new_x = x + dx * i
		var new_y = y + dy * i
		# Добавляем проверку выхода за границы массива
		if new_x < 0 || new_x >= wx || new_y < 0 || new_y >= wy:
			break
		if cats[new_x][new_y]:
			print("nxy(", new_x, ",", new_y, ")")
			return i
	return -1


func calc_vector(u, d, l, r) -> int:
	# Создаем массив с направлениями и соответствующими значениями
	var directions = [
		[CELL_PAW.U, u],
		[CELL_PAW.D, d], 
		[CELL_PAW.L, l],
		[CELL_PAW.R, r]
	]
	
	# Фильтруем только положительные значения и находим минимальное
	var positive_dirs = []
	var min_val = INF
	
	for dir_data in directions:
		var value = dir_data[1]
		if value > 0:
			positive_dirs.append(dir_data[0])
			if value < min_val:
				min_val = value
	print("positive_dirs: ", positive_dirs)
	# Если нет положительных значений
	if positive_dirs.is_empty():
		return CELL_PAW.NA
	
	# Находим все направления с минимальным значением
	var min_dirs = []
	for i in range(4):
		if directions[i][1] == min_val and directions[i][1] > 0:
			min_dirs.append(directions[i][0])
	
	print("min_dirs: ", min_dirs)
	# Определяем результат на основе количества минимальных направлений
	match min_dirs:
		[CELL_PAW.U]:
			return CELL_PAW.U
		[CELL_PAW.D]:
			return CELL_PAW.D
		[CELL_PAW.L]:
			return CELL_PAW.L
		[CELL_PAW.R]:
			return CELL_PAW.R
		[CELL_PAW.U, CELL_PAW.D]:
			return CELL_PAW.UD
		[CELL_PAW.L, CELL_PAW.R]:
			return CELL_PAW.LR
		[CELL_PAW.U, CELL_PAW.R]:
			return CELL_PAW.UR
		[CELL_PAW.D, CELL_PAW.R]:
			return CELL_PAW.RD
		[CELL_PAW.D, CELL_PAW.L]:
			return CELL_PAW.DL
		[CELL_PAW.U, CELL_PAW.L]:
			return CELL_PAW.LU
		[CELL_PAW.D, CELL_PAW.L, CELL_PAW.R]:
			return CELL_PAW.NU
		[CELL_PAW.U, CELL_PAW.L, CELL_PAW.R]:
			return CELL_PAW.ND
		[CELL_PAW.U, CELL_PAW.D, CELL_PAW.R]:
			return CELL_PAW.NL
		[CELL_PAW.U, CELL_PAW.D, CELL_PAW.L]:
			return CELL_PAW.NR
		[CELL_PAW.U, CELL_PAW.D, CELL_PAW.L, CELL_PAW.R]:
			return CELL_PAW.A
	
	return CELL_PAW.NA


func destroy(x: int, y: int) -> void:
	if x < 0 || x >= wx || y < 0 || y >= wy:
		return
	if grass[x][y] && !flags[x][y]:
		grass[x][y] = false
		SignalBus.redraw_lvl.emit()
		check_win()
	if cats[x][y]:
		SignalBus.lvl_lose.emit()


func mark(x: int, y: int) -> void:
	if x < 0 || x >= wx || y < 0 || y >= wy:
		return
	if grass[x][y]:
		flags[x][y] = !flags[x][y]
		SignalBus.redraw_lvl.emit()
		check_win()

func get_flags_count() -> int:
	var flags_count: int = 0
	for x in wx:
		for y in wy:
			if (flags[x][y]):
				flags_count += 1
	return flags_count

func check_win() -> void:
	var founds_cats_count: int = 0
	var flags_count: int = 0
	var grass_count: int = 0
	for x in wx:
		for y in wy:
			if (cats[x][y] && flags[x][y] && grass[x][y]):
				founds_cats_count += 1
			if (flags[x][y]):
				flags_count += 1
			if (grass[x][y]):
				grass_count += 1
	if (founds_cats_count == flags_count && flags_count == grass_count):
		SignalBus.lvl_win.emit()
