extends Camera2D

@onready var world: Node2D = %World


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

var left: int = 0
var right: int = 256
var up: int = 0
var down: int = 256

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


func calc_border() -> void:
	var border: int = 64
	var screen_field: Vector2i = get_viewport_rect().size
	var world_field: Vector2i = Global.WORLD_SIZE_PX
	var center_cam: Vector2i = screen_field / 2
	left = floor(world.position.x) - border + center_cam.x
	right = floor(world.position.x) + world_field.x + border - center_cam.x
	up = floor(world.position.y) - border + center_cam.y
	down = floor(world.position.y) + world_field.y + border - center_cam.y
	
	if (up > down):
		up = floor(world.position.y + (world_field.y / 2.0))
		down = up
		self.position.y = up
	
	if (left > right):
		left = floor(world.position.x + (world_field.x / 2.0))
		right = left
		self.position.x = left


## Функция обработки физики (для плавного движения)
func _physics_process(delta: float):
	calc_border()
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
	if position.x < left:
		position.x = left
		current_velocity = Vector2.ZERO
	if position.x > right:
		position.x = right
		current_velocity = Vector2.ZERO
	if position.y < up:
		position.y = up
		current_velocity = Vector2.ZERO
	if position.y > down:
		position.y = down
		current_velocity = Vector2.ZERO
