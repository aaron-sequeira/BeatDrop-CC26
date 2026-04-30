extends Control

const GAME_SCENE := "res://doitforme_full/doitforme.tscn"

const SONGS: Array = [
	{
		"id": "doitforme",
		"title": "Do It For Me",
		"artist": "Glaive",
		"song_path": "res://assets/songs/doitforme.ogg",
		"beatmap_path": "res://data/doitforme.json",
		"icon_path": "res://doitforme.png",
	},
	{
		"id": "flashinglights",
		"title": "Flashing Lights",
		"artist": "Kanye West ft. Dwele",
		"song_path": "res://assets/songs/FlashingLights.ogg",
		"beatmap_path": "res://data/flashinglights.json",
		"icon_path": "res://Flashinglights.png",
	},
]

@onready var scroll: ScrollContainer = $RightPanel/ScrollContainer
@onready var song_list: VBoxContainer = $RightPanel/ScrollContainer/SongList
@onready var start_button: Button = $LeftPanel/StartButton
@onready var start_sprite: TextureRect = $LeftPanel/StartButton/StartGraphic
@onready var selected_icon: TextureRect = $LeftPanel/SelectedCard/Margin/HBox/Icon
@onready var selected_title: Label = $LeftPanel/SelectedCard/Margin/HBox/Text/Title
@onready var selected_artist: Label = $LeftPanel/SelectedCard/Margin/HBox/Text/Artist
@onready var selected_status: Label = $LeftPanel/SelectedCard/Margin/HBox/Text/Status
@onready var high_score_label: Label = $LeftPanel/HighScoreLabel
@onready var last_played_label: Label = $LeftPanel/LastPlayedLabel

var song_cards: Array = []
var selected_index: int = -1

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	await _populate_songs()
	var initial := 0
	if Globals.selected_song.has("id"):
		for i in range(SONGS.size()):
			if SONGS[i]["id"] == Globals.selected_song["id"]:
				initial = i
				break
	_select_song(initial, false)

func _populate_songs() -> void:
	for child in song_list.get_children():
		child.queue_free()
	song_cards.clear()
	# Wait one frame so scroll.size reflects the anchored layout.
	await get_tree().process_frame

	var pad: float = max(40.0, scroll.size.y * 0.5 - 80.0)

	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, pad)
	top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	song_list.add_child(top_spacer)

	for i in range(SONGS.size()):
		var card := _create_song_card(SONGS[i], i)
		song_list.add_child(card)
		song_cards.append(card)

	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, pad)
	bottom_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	song_list.add_child(bottom_spacer)

func _create_song_card(song: Dictionary, index: int) -> Panel:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0, 140)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 22)
	margin.add_child(hbox)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(112, 112)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(song["icon_path"]):
		icon.texture = load(song["icon_path"])
	hbox.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 4)
	hbox.add_child(text_box)

	var title := Label.new()
	title.text = song["title"]
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	text_box.add_child(title)

	var artist := Label.new()
	artist.text = song["artist"]
	artist.add_theme_font_size_override("font_size", 19)
	artist.add_theme_color_override("font_color", Color(0.78, 0.82, 0.95))
	text_box.add_child(artist)

	var hs := Label.new()
	hs.text = "Best: %d" % int(Globals.high_scores.get(song["id"], 0))
	hs.add_theme_font_size_override("font_size", 16)
	hs.add_theme_color_override("font_color", Color(1.0, 0.85, 0.32))
	text_box.add_child(hs)

	if not _song_available(song):
		var coming := Label.new()
		coming.text = "Coming soon"
		coming.add_theme_font_size_override("font_size", 14)
		coming.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
		text_box.add_child(coming)
		card.modulate = Color(1, 1, 1, 0.78)

	var click := Button.new()
	click.flat = true
	click.set_anchors_preset(Control.PRESET_FULL_RECT)
	click.focus_mode = Control.FOCUS_NONE
	click.pressed.connect(func(): _select_song(index, true))
	card.add_child(click)

	_apply_card_style(card, false)
	return card

func _song_available(song: Dictionary) -> bool:
	return ResourceLoader.exists(song["song_path"]) and ResourceLoader.exists(song["beatmap_path"])

func _make_style(selected: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.corner_radius_top_left = 14
	sb.corner_radius_top_right = 14
	sb.corner_radius_bottom_left = 14
	sb.corner_radius_bottom_right = 14
	if selected:
		sb.bg_color = Color(0.18, 0.10, 0.34, 1.0)
		sb.border_color = Color(1.0, 0.38, 0.95, 1.0)
		sb.border_width_left = 3
		sb.border_width_right = 3
		sb.border_width_top = 3
		sb.border_width_bottom = 3
		sb.shadow_color = Color(1.0, 0.45, 0.95, 0.6)
		sb.shadow_size = 18
		sb.shadow_offset = Vector2.ZERO
	else:
		sb.bg_color = Color(0.10, 0.11, 0.20, 0.92)
		sb.border_color = Color(0.32, 0.34, 0.58, 0.9)
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
	return sb

func _apply_card_style(card: Panel, selected: bool) -> void:
	card.add_theme_stylebox_override("panel", _make_style(selected))

func _select_song(index: int, animate: bool) -> void:
	if index < 0 or index >= song_cards.size():
		return
	selected_index = index
	for i in range(song_cards.size()):
		_apply_card_style(song_cards[i], i == index)
	_update_info_panel()
	_scroll_to_card(index, animate)

func _scroll_to_card(index: int, animate: bool) -> void:
	await get_tree().process_frame
	var card: Panel = song_cards[index]
	var view_h: float = scroll.size.y
	var target := int(card.position.y + card.size.y * 0.5 - view_h * 0.5)
	var max_scroll := int(max(0.0, song_list.size.y - view_h))
	target = clamp(target, 0, max_scroll)
	if animate:
		var tween := create_tween()
		tween.tween_property(scroll, "scroll_vertical", target, 0.32) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		scroll.scroll_vertical = target

func _update_info_panel() -> void:
	if selected_index < 0:
		return
	var song: Dictionary = SONGS[selected_index]
	selected_title.text = song["title"]
	selected_artist.text = song["artist"]
	if ResourceLoader.exists(song["icon_path"]):
		selected_icon.texture = load(song["icon_path"])
	var hs := int(Globals.high_scores.get(song["id"], 0))
	high_score_label.text = "Highest score: %d" % hs
	var last := Globals.last_played
	last_played_label.text = "Last played: %s" % (last if last != "" else "—")
	var available := _song_available(song)
	selected_status.text = "" if available else "Track unavailable"
	selected_status.modulate = Color(1.0, 0.45, 0.45)
	start_button.disabled = not available
	start_sprite.modulate = Color(1, 1, 1, 1.0 if available else 0.45)

func _on_start_pressed() -> void:
	if selected_index < 0:
		return
	var song: Dictionary = SONGS[selected_index]
	if not _song_available(song):
		return
	Globals.selected_song = song
	Globals.last_played = song["title"]
	get_tree().change_scene_to_file(GAME_SCENE)
