extends Node2D

func _draw():
	draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 64, Color(1, 1, 1, 0.9), 3.0, true)

func _process(_delta):
	queue_redraw()
