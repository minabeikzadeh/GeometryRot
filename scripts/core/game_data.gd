extends Node
## Loads all JSON data in res://data at startup (autoload: GameData).
## Balance changes happen in the JSON files, not in code.

var shapes: Dictionary = {}  # id -> stats for towers (base and merged)
var merges: Array = []  # list of recipes
var zombies: Dictionary = {}  # id -> stats for zombies
var waves: Array = []  # list of wave definitions
var last_result: String = ""  # "won" or "lost"; read by the win/lose screen


func _ready() -> void:
	shapes = _load_json("res://data/shapes.json", {})
	merges = _load_json("res://data/merges.json", [])
	zombies = _load_json("res://data/zombies.json", {})
	waves = _load_json("res://data/waves.json", [])


func _load_json(path: String, fallback: Variant) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: %s" % path)
		return fallback
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null:
		push_error("Could not parse JSON: %s" % path)
		return fallback
	return parsed


## Returns the recipe result id for two shape ids (order does not matter), or "" if none.
func find_merge_result(id_a: String, id_b: String) -> String:
	for recipe in merges:
		var inputs: Array = recipe["inputs"]
		if (inputs[0] == id_a and inputs[1] == id_b) or (inputs[0] == id_b and inputs[1] == id_a):
			return recipe["result"]
	return ""
