extends Area2D

var hit_time     : float = 0.0
var approach_time: float = 0.8
var game_manager          = null

const PERFECT_WINDOW := 0.08
const GOOD_WINDOW    := 0.18
const MISS_CUTOFF    := 0.22

var _judged := false

@onready var body : Node2D = $Body
@onready var ring : Node2D = $Ring

func _ready():
	input_pickable = false
	modulate.a = 0.0
	scale = Vector2(0.3, 0.3)

func _process(_delta):
	if _judged or game_manager == null:
		return

	var t    = game_manager.song_position
	var p    = 1.0 - clamp((hit_time - t) / approach_time, 0.0, 1.0)
	var diff = t - hit_time   # negative = early, positive = late

	scale           = Vector2(0.3 + p * 0.7, 0.3 + p * 0.7)
	modulate.a      = clamp(p * 3.0, 0.0, 1.0)
	ring.scale      = Vector2(2.5 - p * 1.5, 2.5 - p * 1.5)
	ring.modulate.a = clamp(p * 1.5, 0.0, 0.85)

	var hovering = global_position.distance_to(get_global_mouse_position()) <= 35.0 * scale.x

	# At perfect window: judge based on whether cursor is on note
	if diff >= -PERFECT_WINDOW and diff <= PERFECT_WINDOW:
		if hovering:
			_judge("Perfect")
		# don't judge yet if not hovering — wait for good/miss window

	# Past perfect but in good window: hovering = Good
	elif diff > PERFECT_WINDOW and diff <= GOOD_WINDOW:
		if hovering:
			_judge("Good")

	# Past good window entirely = Miss regardless
	elif diff > MISS_CUTOFF:
		_judge("Miss")

func _judge(result: String):
	if _judged:
		return
	_judged = true
	game_manager.register_hit(result)

	match result:
		"Perfect":
			body.set_color(Color(0.3, 0.8, 1.0))
			game_manager.play_hit_sound()
		"Good":
			body.set_color(Color(1.0, 0.95, 0.25))
		"Miss":
			body.set_color(Color(1.0, 0.25, 0.25))

	var tw = create_tween()
	if result == "Perfect":
		tw.tween_property(self, "scale", Vector2(1.6, 1.6), 0.07)
	tw.tween_property(self, "modulate:a", 0.0, 0.18)
	tw.tween_callback(queue_free)
