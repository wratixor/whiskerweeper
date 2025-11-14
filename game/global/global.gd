extends Node

const CELL_SIZE: Vector2 = Vector2(16, 16)
const WORLD_SIZE_X: int = 15
const WORLD_SIZE_Y: int = 15

enum CELL_PAW {NA, U, D, L, R, UD, LR, UR, RD, DL, LU, NU, ND, NL, NR, A}


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
	
	# Если нет положительных значений
	if positive_dirs.is_empty():
		return CELL_PAW.NA
	
	# Находим все направления с минимальным значением
	var min_dirs = []
	for i in range(4):
		if directions[i][1] == min_val and directions[i][1] > 0:
			min_dirs.append(directions[i][0])
	
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
		[CELL_PAW.R, CELL_PAW.D]:
			return CELL_PAW.RD
		[CELL_PAW.D, CELL_PAW.L]:
			return CELL_PAW.DL
		[CELL_PAW.L, CELL_PAW.U]:
			return CELL_PAW.LU
		[CELL_PAW.R, CELL_PAW.D, CELL_PAW.L]:
			return CELL_PAW.NU
		[CELL_PAW.U, CELL_PAW.R, CELL_PAW.L]:
			return CELL_PAW.ND
		[CELL_PAW.U, CELL_PAW.D, CELL_PAW.R]:
			return CELL_PAW.NL
		[CELL_PAW.U, CELL_PAW.D, CELL_PAW.L]:
			return CELL_PAW.NR
		[CELL_PAW.U, CELL_PAW.D, CELL_PAW.L, CELL_PAW.R]:
			return CELL_PAW.A
	
	return CELL_PAW.NA
	
	
	
	
