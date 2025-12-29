extends Node2D

@onready var basket: CharacterBody2D = $Basket
@onready var score_label: Label = $HUD/ScoreLabel
@onready var high_score_label: Label = $HUD/HighScoreLabel
@onready var target_label: Label = $HUD/TargetPanel/TargetLabel
@onready var progress_bar: ProgressBar = $HUD/ProgressBar
@onready var spawn_timer: Timer = $SpawnTimer

var falling_object_scene: PackedScene

func _ready():
	# Initialize HUD
	score_label.text = "Score: 0"
	high_score_label.text = "Best: %d" % Global.high_score
	high_score_label.visible = true
	
	target_label.text = "%s %s" % [Global.target_object.get("emoji", "🍎"), Global.target_object.get("name", "Apple")]
	
	progress_bar.value = 0
	progress_bar.max_value = 100
	
	# Connect spawn timer
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# Preload falling object scene
	falling_object_scene = preload("res://scenes/FallingObject.tscn")

func _process(_delta: float):
	# Update UI
	score_label.text = "Score: %d" % Global.score
	progress_bar.value = Global.get_fill_percentage()
	
	# Update high score if beaten during gameplay
	if Global.score > Global.high_score:
		high_score_label.text = "Best: %d" % Global.score
	
	# Check win condition
	if Global.is_basket_full():
		show_victory()

func _on_spawn_timer_timeout():
	spawn_falling_object()

func spawn_falling_object():
	var obj = falling_object_scene.instantiate()
	
	# 35% chance to spawn target object
	var is_target = randf() < 0.35
	var object_data: Dictionary
	
	if is_target:
		object_data = Global.target_object
	else:
		var non_target = Global.FALLING_OBJECTS.filter(func(o): return o["name"] != Global.target_object["name"])
		object_data = non_target[randi() % non_target.size()]
	
	obj.setup(object_data)
	obj.position.x = randf_range(50, get_viewport_rect().size.x - 50)
	obj.position.y = -50
	
	# Connect signals
	obj.caught_by_basket.connect(_on_object_caught)
	obj.missed.connect(_on_object_missed)
	
	add_child(obj)

func _on_object_caught(object_name: String):
	if object_name == Global.target_object["name"]:
		Global.catch_correct_object()
	else:
		Global.catch_wrong_object()

func _on_object_missed(object_name: String):
	if object_name == Global.target_object["name"]:
		Global.miss_target_object()

func show_victory():
	Global.save_game_data()
	get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")