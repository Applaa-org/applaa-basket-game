extends RigidBody2D

signal caught_by_basket(object_name: String)
signal missed(object_name: String)

var object_data: Dictionary = {}
var fall_speed: float = 200.0
var is_caught: bool = false

@onready var label: Label = $Label
@onready var highlight: Node2D = $Highlight

func _ready():
	gravity_scale = 0
	
func setup(data: Dictionary):
	object_data = data
	fall_speed = randf_range(150, 250)
	
	if label:
		label.text = data.get("emoji", "🍎")
	
	# Show highlight if this is target object
	if highlight and data.get("name", "") == Global.target_object.get("name", ""):
		highlight.visible = true
	else:
		highlight.visible = false

func _physics_process(delta: float):
	if is_caught:
		return
	
	position.y += fall_speed * delta
	
	# Check if fallen off screen
	if position.y > get_viewport_rect().size.y + 50:
		missed.emit(object_data.get("name", ""))
		queue_free()

func catch():
	if is_caught:
		return
	is_caught = true
	caught_by_basket.emit(object_data.get("name", ""))
	queue_free()