extends Node

# Set by the menu when the player picks a song and presses start.
# Read by the game scene in _ready() to know what to load.
var selected_song: Dictionary = {}

# Display state shown back in the menu after returning from a run.
var last_played: String = ""
var high_scores: Dictionary = {}  # song id -> int

func record_score(song_id: String, score: int) -> void:
	var prev: int = int(high_scores.get(song_id, 0))
	if score > prev:
		high_scores[song_id] = score
