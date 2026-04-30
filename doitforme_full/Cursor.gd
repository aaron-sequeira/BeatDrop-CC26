extends Node2D

# ── Tweakable ─────────────────────────────────────────────────────
const RADIUS       := 18.0
const COLOR        := Color(1.0, 1.0, 1.0, 0.9)
const BORDER_WIDTH := 2.5
const DOT_RADIUS   := 2.5

func _ready():
	# Hide the system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	# Follow the mouse every frame
	global_position = get_global_mouse_position()
	queue_redraw()

func _draw():
	# Outer ring
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 64, COLOR, BORDER_WIDTH, true)
	# Centre dot
	draw_circle(Vector2.ZERO, DOT_RADIUS, COLOR)
