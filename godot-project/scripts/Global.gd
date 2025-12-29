extends Node

# Game State
var score: int = 0
var high_score: int = 0
var basket_fill: int = 0
var objects_caught: int = 0
var player_name: String = "Player"
var target_object: Dictionary = {}
var last_player_name: String = ""
var scores: Array = []

# Constants
const BASKET_CAPACITY: int = 10
const CORRECT_OBJECT_SCORE: int = 100
const WRONG_OBJECT_PENALTY: int = 10
const MISSED_TARGET_PENALTY: int = 25

# Falling Objects Data
const FALLING_OBJECTS: Array = [
	{ "emoji": "🍎", "name": "Apple", "color": Color("#ff6b6b") },
	{ "emoji": "🍊", "name": "Orange", "color": Color("#ffa502") },
	{ "emoji": "🍋", "name": "Lemon", "color": Color("#ffd93d") },
	{ "emoji": "🍇", "name": "Grapes", "color": Color("#a855f7") },
	{ "emoji": "🍓", "name": "Strawberry", "color": Color("#ef4444") },
	{ "emoji": "🍌", "name": "Banana", "color": Color("#facc15") },
	{ "emoji": "🍉", "name": "Watermelon", "color": Color("#22c55e") },
	{ "emoji": "🥝", "name": "Kiwi", "color": Color("#84cc16") },
	{ "emoji": "🍑", "name": "Peach", "color": Color("#fb923c") },
	{ "emoji": "🫐", "name": "Blueberry", "color": Color("#6366f1") }
]

func _ready():
	load_game_data()

func reset_game():
	score = 0
	basket_fill = 0
	objects_caught = 0
	select_random_target()

func select_random_target():
	target_object = FALLING_OBJECTS[randi() % FALLING_OBJECTS.size()]

func add_score(points: int):
	score += points
	if score < 0:
		score = 0

func catch_correct_object():
	add_score(CORRECT_OBJECT_SCORE)
	basket_fill += 1
	objects_caught += 1

func catch_wrong_object():
	add_score(-WRONG_OBJECT_PENALTY)

func miss_target_object():
	add_score(-MISSED_TARGET_PENALTY)

func is_basket_full() -> bool:
	return basket_fill >= BASKET_CAPACITY

func get_fill_percentage() -> float:
	return float(basket_fill) / float(BASKET_CAPACITY) * 100.0

func save_game_data():
	# Save score
	var new_score = {
		"playerName": player_name,
		"score": score,
		"timestamp": Time.get_datetime_string_from_system()
	}
	scores.append(new_score)
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if scores.size() > 10:
		scores.resize(10)
	
	if score > high_score:
		high_score = score
	
	last_player_name = player_name
	
	# Save to file
	var save_data = {
		"high_score": high_score,
		"last_player_name": last_player_name,
		"scores": scores
	}
	
	var file = FileAccess.open("user://basket_game_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
	
	# Also try to save via JavaScript for web export
	if OS.has_feature("web"):
		var js_code = """
		window.parent.postMessage({
			type: 'applaa-game-save-score',
			gameId: 'basket-game',
			playerName: '%s',
			score: %d
		}, '*');
		""" % [player_name, score]
		JavaScriptBridge.eval(js_code)

func load_game_data():
	var file = FileAccess.open("user://basket_game_save.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			high_score = data.get("high_score", 0)
			last_player_name = data.get("last_player_name", "")
			scores = data.get("scores", [])