extends Node2D

# Определите базовое разрешение
const MIN_WIDTH = 360
const MIN_HEIGHT = 360
const MIN_SIZE = Vector2i(MIN_WIDTH, MIN_HEIGHT)

func _ready():
	SaveManager.load_settings()
	DisplayServer.window_set_min_size(MIN_SIZE)
	get_tree().root.content_scale_size = MIN_SIZE
	# Подключаем сигнал изменения размера окна
	get_tree().root.size_changed.connect(adjust_viewport_to_window)
	SignalBus.zoom_change.connect(adjust_viewport_to_window)
	SignalBus.toggle_fullscreen.connect(toggle_fullscreen)
	adjust_viewport_to_window()
	if Global.fullscreen:
		toggle_fullscreen()
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		Global.fullscreen = !Global.fullscreen
		toggle_fullscreen()

func toggle_fullscreen() -> void:
	if Global.fullscreen:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	# После смены режима нужно пересчитать размер
	await get_tree().process_frame
	adjust_viewport_to_window()

func adjust_viewport_to_window():
	# Ждем кадр, чтобы размер окна стабилизировался
	await get_tree().process_frame
	var window_size = DisplayServer.window_get_size()
	# Если окно свернуто, у него размер (0, 0). Игнорируем.
	if window_size.x == 0 or window_size.y == 0:
		return
	# 1. Рассчитываем потенциальные масштабы по X и Y
	var new_base_size = Vector2i(
		floor(window_size.x / Global.zoom),
		floor(window_size.y / Global.zoom)
	)
	
	#var scale_x: float = float(window_size.x) / float(MIN_WIDTH)
	#var scale_y: float = float(window_size.y) / float(MIN_HEIGHT)
	## 2. Находим МИНИМАЛЬНЫЙ из них и округляем ВНИЗ.
	##    Это и есть наш "честный" целочисленный масштаб (1x, 2x, 3x...)
	#var integer_scale = max(1.0, floor(min(scale_x, scale_y)))
	## 3. Рассчитываем НОВЫЙ базовый размер (Overscan)
	#var new_base_size = Vector2i(
		#floor(window_size.x / integer_scale),
		#floor(window_size.y / integer_scale)
	#)
	# 4. Применяем этот новый размер
	get_tree().root.content_scale_size = new_base_size
	#print("Window: %s | Scale: %sx | New Base Res: %s" % [window_size, integer_scale, new_base_size])
