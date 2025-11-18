extends Node2D

# Определите базовое разрешение
const BASE_WIDTH = 360
const BASE_HEIGHT = 360
const BASE_SIZE = Vector2i(BASE_WIDTH, BASE_HEIGHT)
var full: bool = false

func _ready():
	# Устанавливаем минимальный размер окна
	DisplayServer.window_set_min_size(BASE_SIZE)
	get_tree().root.content_scale_size = BASE_SIZE
	
	# Подключаем сигнал изменения размера окна
	get_tree().root.size_changed.connect(adjust_viewport_to_window)
	adjust_viewport_to_window()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		full = !full
		if full:
			# Рекомендую MODE_FULLSCREEN (borderless windowed), 
			# он лучше дружит с динамическим разрешением
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
		
		# После смены режима нужно пересчитать размер
		await get_tree().create_timer(0.01).timeout
		adjust_viewport_to_window()


func adjust_viewport_to_window():
	# Ждем кадр, чтобы размер окна стабилизировался
	await get_tree().process_frame
	#await get_tree().create_timer(0.01).timeout
	
	var window_size = DisplayServer.window_get_size()
	
	# Если окно свернуто, у него размер (0, 0). Игнорируем.
	if window_size.x == 0 or window_size.y == 0:
		return

	# 1. Рассчитываем потенциальные масштабы по X и Y
	var scale_x: float = float(window_size.x) / float(BASE_WIDTH)
	var scale_y: float = float(window_size.y) / float(BASE_HEIGHT)
	
	# 2. Находим МИНИМАЛЬНЫЙ из них и округляем ВНИЗ.
	#    Это и есть наш "честный" целочисленный масштаб (1x, 2x, 3x...)
	var integer_scale = max(1.0, floor(min(scale_x, scale_y)))
	
	# 3. Рассчитываем НОВЫЙ базовый размер (Overscan)
	var new_base_size = Vector2i(
		floor(window_size.x / integer_scale),
		floor(window_size.y / integer_scale)
	)
	
	# 4. Применяем этот новый размер
	get_tree().root.content_scale_size = new_base_size
	
	print("Window: %s | Scale: %sx | New Base Res: %s" % [window_size, integer_scale, new_base_size])
