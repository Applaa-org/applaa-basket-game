extends Control

@onready var final_score_label: Label = $VBoxContainer/FinalScoreLabel
@onready var objects_caught_label: Label = $VBoxContainer/ObjectsCaughtLabel
@onready var new_high_score_label: Label = $VBoxContainer/NewHighScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel

func _ready():
	final_score_label.text = "Final Score: %d" % Global.score
	objects_caught_label.text = "%s Caught: %d" % [Global.target_object.get("emoji", "🍎"), Global.objects_caught]
	high_score_label.text = "High Score: %d" % Global.high_score
	high_score_label.visible = true
	
	# Check for new high score
	if Global.score >= Global.high_score:
		new_high_score_label.visible = true
	else:
		new_high_score_label.visible = false
	
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()