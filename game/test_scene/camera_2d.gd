extends Camera2D

# Параметры перемещения
## Скорость перемещения камеры в пикселях/сек
@export var speed: float = 300.0
## Ускорение для плавного старта/остановки
@export var acceleration: float = 10.0

# Параметры зума
## Шаг изменения зума за одно прокручивание колеса
@export var zoom_step: float = 0.25
## Минимальное приближение (0.5 = в 2 раза ближе)
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)
## Максимальное отдаление (2.0 = в 2 раза дальше)
@export var max_zoom: Vector2 = Vector2(2.0, 2.0)

# Приватные переменные
var target_velocity: Vector2 = Vector2.ZERO
var current_velocity: Vector2 = Vector2.ZERO

## Обработка ввода (для мгновенных действий, таких как зум)
func _input(event: InputEvent) -> void:
	# Проверяем, является ли событие нажатием кнопки мыши
	if event is InputEventMouseButton:
		var new_zoom = zoom
		# Колесико вверх (Zoom In / Приближение)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Уменьшаем вектор zoom, чтобы приблизить (0.5 - ближе, 1.0 - стандарт)
			new_zoom -= Vector2(zoom_step, zoom_step)
		# Колесико вниз (Zoom Out / Отдаление)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Увеличиваем вектор zoom, чтобы отдалить
			new_zoom += Vector2(zoom_step, zoom_step)
		# Применяем новое значение и ограничиваем его границами
		zoom = new_zoom.clamp(min_zoom, max_zoom)

## Функция обработки физики (для плавного движения)
func _physics_process(delta: float):
	# 1. Получение данных ввода для движения
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	# 2. Нормализация
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()
	# 3. Вычисление целевой скорости
	target_velocity = input_dir * speed
	# 4. Сглаживание скорости
	current_velocity = current_velocity.lerp(target_velocity, delta * acceleration)
	# 5. Применение движения
	position += current_velocity * delta
	if position.x < 0:
		position.x = 0
		current_velocity = Vector2.ZERO
	if position.x > get_tree().root.content_scale_size.x:
		position.x = get_tree().root.content_scale_size.x
		current_velocity = Vector2.ZERO
	if position.y < 0:
		position.y = 0
		current_velocity = Vector2.ZERO
	if position.y > get_tree().root.content_scale_size.y:
		position.y = get_tree().root.content_scale_size.y
		current_velocity = Vector2.ZERO
