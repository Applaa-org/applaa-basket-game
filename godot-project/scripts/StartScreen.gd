extends Control

@onready var high_score_label: Label = $VBoxContainer/StatsPanel/VBoxContainer/HighScoreLabel
@onready var last_player_label: Label = $VBoxContainer/StatsPanel/VBoxContainer/LastPlayerLabel
@onready var player_name_input: LineEdit = $VBoxContainer/PlayerNameInput
@onready var leaderboard_container: VBoxContainer = $VBoxContainer/LeaderboardPanel/VBoxContainer/ScoresList

func _ready():
	# Initialize high score display to 0
	high_score_label.text = "High Score: 0"
	high_score_label.visible = true
	
	# Connect buttons
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	
	# Load and display saved data
	update_display()

func update_display():
	high_score_label.text = "High Score: %d" % Global.high_score
	
	if Global.last_player_name != "":
		last_player_label.text = "Last Player: " + Global.last_player_name
		player_name_input.text = Global.last_player_name
	else:
		last_player_label.text = "Last Player: ---"
	
	# Display leaderboard
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	var top_scores = Global.scores.slice(0, 5)
	for i in range(top_scores.size()):
		var score_data = top_scores[i]
		var score_label = Label.new()
		score_label.text = "%d. %s - %d" % [i + 1, score_data["playerName"], score_data["score"]]
		score_label.add_theme_color_override("font_color", Color.WHITE)
		leaderboard_container.add_child(score_label)

func _on_start_pressed():
	var name = player_name_input.text.strip_edges()
	if name == "":
		name = "Player"
	Global.player_name = name
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed():
	get_tree().quit()