extends CharacterBody2D

const SPEED: float = 400.0

@onready var collision_area: Area2D = $CollisionArea

func _ready():
	collision_area.body_entered.connect(_on_body_entered)

func _physics_process(_delta: float):
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Also check A/D keys
	if Input.is_key_pressed(KEY_A):
		direction = -1
	elif Input.is_key_pressed(KEY_D):
		direction = 1
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
	
	move_and_slide()
	
	# Clamp position to screen bounds
	var viewport_width = get_viewport_rect().size.x
	position.x = clamp(position.x, 50, viewport_width - 50)

func _on_body_entered(body: Node2D):
	if body.has_method("catch"):
		body.catch()