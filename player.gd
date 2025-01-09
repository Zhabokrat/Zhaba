extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -275.0
const GRAVITY = 800.0
const JUMP_HOLD_TIME = 0.3

var jump_time = 0.0
var is_jumping = false
var wall_slide_gravity = 200.0  # Reduced gravity for wall sliding

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jumping logic
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		jump_time = 0.0

	if Input.is_action_pressed("ui_accept") and is_jumping:
		if jump_time < JUMP_HOLD_TIME:
			velocity.y += JUMP_VELOCITY * delta
			jump_time += delta

	if Input.is_action_just_released("ui_accept") and is_jumping:
		if velocity.y < 0:
			velocity.y = 0
		is_jumping = false

	# Wall cling logic
	var is_wall_clinging = false
	if is_on_wall_only() and Input.is_action_pressed("ui_cling"):  # Assume "ui_cling" is bound to the "C" key
		is_wall_clinging = true
		velocity.y = 0  # Stop vertical movement while clinging
		if !sprite.is_playing() or sprite.animation != "cling":
			sprite.play("cling")

	elif is_on_wall_only():  # Wall slide logic
		velocity.y = min(velocity.y, wall_slide_gravity)

	# Movement logic
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		if is_on_floor() and (!sprite.is_playing() or sprite.animation != "run"):
			sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			sprite.play("idle")

	if not is_wall_clinging:
		move_and_slide()
