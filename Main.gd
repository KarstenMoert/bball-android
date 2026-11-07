extends Control

@export var tile_sheet: Texture2D

var level = []
var sel_tile = 0
var history = []
var history_pos = -1

var tile_size = 64
var pal_size = 64

func get_tile_pos(t:int) -> int:
	if t >= 1 and t <= 9: return t
	if t == 12: return 10
	return -1

func _ready():
	for i in 48: level.append(0)
	push_undo()
	get_viewport().connect("size_changed", Callable(self, "on_resize"))
	on_resize()

func on_resize():
	var vp = get_viewport_rect().size
	var grid_w = vp.x - 40
	var grid_h = vp.y - 250
	tile_size = clamp(min(grid_w / 8.0, grid_h / 6.0), 32, 120)
	pal_size = clamp((vp.x - 40 - 10*8) / 11.0, 28, 90)
	
	for c in $VBox/LevelGrid.get_children():
		c.custom_minimum_size = Vector2(tile_size, tile_size)
	for c in $VBox/Palette.get_children():
		c.custom_minimum_size = Vector2(pal_size, pal_size)
	
	$VBox/LabelStatus.add_theme_font_size_override("font_size", clamp(int(vp.x / 65.0), 10, 20))
	update_all()

func _process(_delta):
	if $VBox/LevelGrid.get_child_count() != 48:
		build_grids()

func build_grids():
	var grid = $VBox/LevelGrid
	var pal = $VBox/Palette
	if grid.get_child_count() == 0:
		for i in 48:
			var btn = TextureButton.new()
			btn.stretch_mode = TextureButton.STRETCH_SCALE
			var idx = i
			btn.pressed.connect(func(): paint_tile(idx))
			grid.add_child(btn)
	if pal.get_child_count() == 0:
		for i in 11:
			var btn = TextureButton.new()
			btn.stretch_mode = TextureButton.STRETCH_SCALE
			var t = i
			if i == 10: t = 12
			btn.pressed.connect(func(): sel_tile = t; update_all())
			pal.add_child(btn)
	on_resize()

func update_all():
	var grid = $VBox/LevelGrid
	var pal = $VBox/Palette
	if grid.get_child_count() < 48: return
	for i in 48:
		var btn = grid.get_child(i)
		var t = level[i]
		if t == 0:
			btn.modulate = Color(0.57, 0.51, 0.925)
			btn.texture_normal = null
		else:
			btn.modulate = Color.WHITE
			btn.texture_normal = get_tile_texture(t)
	for i in pal.get_child_count():
		var t = i
		if i == 10: t = 12
		var btn = pal.get_child(i)
		if t == 0:
			btn.modulate = Color(0.57, 0.51, 0.925)
			btn.texture_normal = null
		else:
			btn.modulate = Color.WHITE
			btn.texture_normal = get_tile_texture(t)
		if sel_tile == t:
			btn.modulate = Color.YELLOW
	$VBox/LabelStatus.text = "Aktuell: %d  |  S=Save  |  L=Load  |  C=Clear" % sel_tile

func get_tile_texture(t:int) -> AtlasTexture:
	var pos = get_tile_pos(t)
	if pos < 0 or tile_sheet == null: return null
	var at = AtlasTexture.new()
	at.atlas = tile_sheet
	at.region = Rect2(pos * 160, 0, 160, 160)
	return at

func paint_tile(idx):
	if history.size() == 0 or level != history[history_pos]:
		push_undo()
	level[idx] = sel_tile
	update_all()

func push_undo():
	history = history.slice(0, history_pos + 1)
	history.append(level.duplicate())
	history_pos += 1