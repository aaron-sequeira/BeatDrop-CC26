extends Node

const DEFAULT_SONG_PATH    := "res://assets/songs/doitforme.ogg"
const DEFAULT_BEATMAP_PATH := "res://data/doitforme.json"
const DEFAULT_SONG_ID      := "doitforme"
const USE_ONSETS    := true
const APPROACH_TIME := 0.8
const MIN_GAP       := 0.15

@onready var audio          : AudioStreamPlayer = $AudioStreamPlayer
@onready var note_container : Node2D            = $NoteContainer
@onready var grid           : GridContainer     = $Grid
@onready var score_label    : Label             = $UI/ScoreLabel
@onready var combo_label    : Label             = $UI/ComboLabel
@onready var end_screen     : Control           = $UI/EndScreen
@onready var end_title      : Label             = $UI/EndScreen/Panel/Margin/VBox/Title
@onready var end_score      : Label             = $UI/EndScreen/Panel/Margin/VBox/ScoreLabel
@onready var end_max_combo  : Label             = $UI/EndScreen/Panel/Margin/VBox/MaxCombo
@onready var end_perfect    : Label             = $UI/EndScreen/Panel/Margin/VBox/Stats/Perfect
@onready var end_good       : Label             = $UI/EndScreen/Panel/Margin/VBox/Stats/Good
@onready var end_miss       : Label             = $UI/EndScreen/Panel/Margin/VBox/Stats/Miss
@onready var end_accuracy   : Label             = $UI/EndScreen/Panel/Margin/VBox/Accuracy
@onready var end_grade      : Label             = $UI/EndScreen/Panel/Margin/VBox/Grade
@onready var end_new_best   : Label             = $UI/EndScreen/Panel/Margin/VBox/NewBest
@onready var retry_button   : Button            = $UI/EndScreen/Panel/Margin/VBox/Buttons/RetryButton
@onready var menu_button    : Button            = $UI/EndScreen/Panel/Margin/VBox/Buttons/MenuButton
@onready var cursor         : Node2D            = $Cursor

const NoteScene = preload("res://doitforme_full/Note.tscn")

var notes         : Array = []
var note_index    : int   = 0
var song_position : float = 0.0
var cell_positions: Array = []
var score         : int   = 0
var combo         : int   = 0
var max_combo     : int   = 0
var perfect_count : int   = 0
var good_count    : int   = 0
var miss_count    : int   = 0
var song_id       : String = DEFAULT_SONG_ID
var ended         : bool   = false

func _ready():
	randomize()
	var song_path: String = DEFAULT_SONG_PATH
	var beatmap_path: String = DEFAULT_BEATMAP_PATH
	if Globals.selected_song.has("song_path"):
		song_path = Globals.selected_song["song_path"]
	if Globals.selected_song.has("beatmap_path"):
		beatmap_path = Globals.selected_song["beatmap_path"]
	if Globals.selected_song.has("id"):
		song_id = Globals.selected_song["id"]
	notes = _load_beatmap(beatmap_path, USE_ONSETS)
	var stream = load(song_path)
	if stream:
		audio.stream = stream
	else:
		push_error("Cannot load song: " + song_path)
	await get_tree().process_frame
	for i in range(grid.get_child_count()):
		var cell = grid.get_child(i)
		cell_positions.append(cell.global_position + cell.size / 2.0)
	audio.finished.connect(_on_song_finished)
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_back_to_menu)
	end_screen.visible = false
	audio.play()
	_update_ui()

func _process(_delta):
	if ended:
		return
	song_position = audio.get_playback_position()
	while note_index < notes.size():
		var n = notes[note_index]
		if song_position >= n["time"] - APPROACH_TIME:
			_spawn_note(n)
			note_index += 1
		else:
			break

func _spawn_note(data: Dictionary):
	var note = NoteScene.instantiate()
	note_container.add_child(note)
	note.global_position = cell_positions[data["cell"]]
	note.hit_time      = data["time"]
	note.approach_time = APPROACH_TIME
	note.game_manager  = self

func register_hit(judgment: String):
	match judgment:
		"Perfect":
			combo += 1
			score += 300 * combo
			perfect_count += 1
		"Good":
			combo += 1
			score += 100 * combo
			good_count += 1
		"Miss":
			combo = 0
			miss_count += 1
	if combo > max_combo:
		max_combo = combo
	_update_ui()

func _update_ui():
	score_label.text = "Score: %d" % score
	combo_label.text = "%dx" % combo
	Globals.record_score(song_id, score)

func _load_beatmap(path: String, use_onsets: bool) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open beatmap: " + path)
		return []
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("JSON parse failed: " + path)
		return []
	file.close()
	var data = json.get_data()
	var timestamps: Array = []
	if use_onsets and data.has("onsets"):
		timestamps = data["onsets"]
	elif data.has("beats"):
		timestamps = data["beats"]
	else:
		push_error("Beatmap has no 'onsets' or 'beats' key")
		return []
	var filtered: Array = []
	var last_t: float = -999.0
	for t in timestamps:
		if float(t) - last_t >= MIN_GAP:
			filtered.append(float(t))
			last_t = float(t)
	var result: Array = []
	var last_cell := -1
	for t in filtered:
		var cell := randi() % 9
		var tries := 0
		while cell == last_cell and tries < 10:
			cell = randi() % 9
			tries += 1
		last_cell = cell
		result.append({ "time": t, "cell": cell })
	print("[doitforme] %d notes loaded" % result.size())
	return result

func _on_song_finished():
	if ended:
		return
	# Wait briefly so any final notes finish their judgment animation.
	await get_tree().create_timer(0.6).timeout
	_show_end_screen()

func _show_end_screen():
	if ended:
		return
	ended = true
	var total_judged: int = perfect_count + good_count + miss_count
	var accuracy: float = 0.0
	if total_judged > 0:
		accuracy = (float(perfect_count) + float(good_count) * 0.5) / float(total_judged) * 100.0
	var prev_best: int = int(Globals.high_scores.get(song_id, 0))
	var is_new_best: bool = score > prev_best
	Globals.record_score(song_id, score)

	end_title.text = "Track Complete!"
	end_score.text = "Score: %d" % score
	end_max_combo.text = "Max Combo: %dx" % max_combo
	end_perfect.text   = "Perfect: %d" % perfect_count
	end_good.text      = "Good: %d"    % good_count
	end_miss.text      = "Miss: %d"    % miss_count
	end_accuracy.text  = "Accuracy: %.1f%%" % accuracy
	end_grade.text = "Grade: %s" % _grade_for(accuracy)
	end_new_best.visible = is_new_best
	end_screen.visible = true
	cursor.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _grade_for(accuracy: float) -> String:
	if accuracy >= 95.0: return "S"
	elif accuracy >= 85.0: return "A"
	elif accuracy >= 70.0: return "B"
	elif accuracy >= 55.0: return "C"
	else: return "D"

func _on_retry():
	get_tree().reload_current_scene()

func _on_back_to_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://menu.tscn")

# ── Hit sound (generated in code, no file needed) ─────────────────
func play_hit_sound():
	var player = AudioStreamPlayer.new()
	add_child(player)

	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	gen.buffer_length = 0.1
	player.stream = gen
	player.play()

	var playback = player.get_stream_playback()
	var frames   = int(44100.0 * 0.08)   # 80ms beep
	var freq     = 880.0                  # A5 note — bright click sound

	for i in range(frames):
		var t_s  = float(i) / 44100.0
		var env  = 1.0 - (float(i) / float(frames))   # fade out
		var sample = sin(t_s * freq * TAU) * env * 0.4
		playback.push_frame(Vector2(sample, sample))

	# Clean up after it finishes
	await get_tree().create_timer(0.15).timeout
	player.queue_free()
