extends Control

const COLS := 10
const ROWS := 20
const BLOCK := 28
const BOARD_ORIGIN := Vector2(410, 76)
const HISTORY_PATH := "user://scores.json"
const MAX_HISTORY := 10

enum Screen { MENU, PLAYING, PAUSED, GAME_OVER }
enum Mode { MARATHON, SPRINT, VERSUS }

const MODE_NAMES := {
	Mode.MARATHON: "Marathon",
	Mode.SPRINT: "Garbage Sprint",
	Mode.VERSUS: "Versus Bot"
}

const PALETTE := {
	"I": Color("#00d5ff"),
	"J": Color("#3177ff"),
	"L": Color("#ff9f1c"),
	"O": Color("#ffde59"),
	"S": Color("#66f07a"),
	"T": Color("#a66cff"),
	"Z": Color("#ff4f8b"),
	"G": Color("#53627d")
}

const PIECES := {
	"I": [[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]],
	"J": [[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]],
	"L": [[Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]],
	"O": [[Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0)]],
	"S": [[Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0)]],
	"T": [[Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]],
	"Z": [[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)]]
}

var screen := Screen.MENU
var mode := Mode.MARATHON
var selected_mode := 0
var board: Array = []
var bot_board: Array = []
var active := ""
var active_pos := Vector2i(5, 1)
var active_rot := 0
var hold_piece := ""
var hold_locked := false
var next_queue: Array[String] = []
var bag: Array[String] = []
var score := 0
var lines := 0
var level := 1
var combo := -1
var drop_delay := 0.8
var drop_clock := 0.0
var soft_clock := 0.0
var move_clock := 0.0
var bot_clock := 0.0
var bot_lines := 0
var bot_alive := true
var winner_text := ""
var history: Array = []
var rng := RandomNumberGenerator.new()

var title_label: Label
var stats_label: Label
var hint_label: Label
var history_box: VBoxContainer
var menu_buttons: Array[Button] = []


func _ready() -> void:
	rng.randomize()
	_setup_input()
	_build_ui()
	_load_history()
	_show_menu()
	set_process(true)


func _setup_input() -> void:
	_add_action_key("move_left", KEY_LEFT)
	_add_action_key("move_left", KEY_A)
	_add_action_key("move_right", KEY_RIGHT)
	_add_action_key("move_right", KEY_D)
	_add_action_key("soft_drop", KEY_DOWN)
	_add_action_key("soft_drop", KEY_S)
	_add_action_key("hard_drop", KEY_SPACE)
	_add_action_key("rotate_cw", KEY_UP)
	_add_action_key("rotate_cw", KEY_X)
	_add_action_key("rotate_ccw", KEY_Z)
	_add_action_key("hold", KEY_C)
	_add_action_key("pause", KEY_ESCAPE)
	_add_action_key("pause", KEY_P)
	_add_action_key("ui_accept", KEY_ENTER)
	_add_action_key("ui_accept", KEY_SPACE)
	_add_action_joy_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_add_action_joy_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_action_joy_button("soft_drop", JOY_BUTTON_DPAD_DOWN)
	_add_action_joy_button("hard_drop", JOY_BUTTON_A)
	_add_action_joy_button("rotate_cw", JOY_BUTTON_X)
	_add_action_joy_button("rotate_ccw", JOY_BUTTON_B)
	_add_action_joy_button("hold", JOY_BUTTON_Y)
	_add_action_joy_button("pause", JOY_BUTTON_START)


func _add_action_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func _add_action_joy_button(action: StringName, button_index: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action, event)


func _build_ui() -> void:
	title_label = Label.new()
	title_label.text = "DROP"
	title_label.add_theme_font_size_override("font_size", 52)
	title_label.position = Vector2(56, 32)
	add_child(title_label)

	stats_label = Label.new()
	stats_label.add_theme_font_size_override("font_size", 22)
	stats_label.position = Vector2(56, 130)
	add_child(stats_label)

	hint_label = Label.new()
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.position = Vector2(56, 636)
	hint_label.size = Vector2(1100, 48)
	add_child(hint_label)

	history_box = VBoxContainer.new()
	history_box.position = Vector2(910, 126)
	history_box.size = Vector2(270, 390)
	add_child(history_box)

	var labels := ["Marathon", "Garbage Sprint", "Versus Bot"]
	for i in labels.size():
		var button := Button.new()
		button.text = labels[i]
		button.position = Vector2(56, 220 + i * 64)
		button.size = Vector2(260, 48)
		button.pressed.connect(func() -> void:
			start_game(i)
		)
		add_child(button)
		menu_buttons.append(button)


func _show_menu() -> void:
	screen = Screen.MENU
	title_label.text = "DROP"
	stats_label.text = "Pick a mode"
	hint_label.text = "Keyboard: arrows / Z X / space / C / P. Gamepad: D-pad / face buttons / Start."
	history_box.visible = true
	history_box.position = Vector2(910, 126)
	for button in menu_buttons:
		button.visible = true
	_update_history_ui()
	queue_redraw()


func start_game(new_mode: int) -> void:
	mode = new_mode as Mode
	screen = Screen.PLAYING
	board = _make_empty_board()
	bot_board = _make_empty_board()
	if mode == Mode.SPRINT:
		_add_garbage(board, 8)
	if mode == Mode.VERSUS:
		_add_garbage(bot_board, 3)
		bot_lines = 0
		bot_alive = true
	bag.clear()
	next_queue.clear()
	hold_piece = ""
	hold_locked = false
	score = 0
	lines = 0
	level = 1
	combo = -1
	drop_delay = 0.8
	drop_clock = 0.0
	soft_clock = 0.0
	move_clock = 0.0
	bot_clock = 0.0
	winner_text = ""
	for i in 5:
		next_queue.append(_draw_piece())
	_spawn_piece()
	for button in menu_buttons:
		button.visible = false
	history_box.visible = false
	_update_labels()
	queue_redraw()


func _make_empty_board() -> Array:
	var fresh := []
	for y in ROWS:
		var row := []
		for x in COLS:
			row.append("")
		fresh.append(row)
	return fresh


func _draw_piece() -> String:
	if bag.is_empty():
		bag = ["I", "J", "L", "O", "S", "T", "Z"]
		bag.shuffle()
	return bag.pop_back()


func _spawn_piece() -> void:
	active = next_queue.pop_front()
	next_queue.append(_draw_piece())
	active_pos = Vector2i(5, 1)
	active_rot = 0
	hold_locked = false
	if not _can_place(active, active_pos, active_rot, board):
		_finish_game("Game Over")


func _process(delta: float) -> void:
	if screen != Screen.PLAYING:
		return
	drop_clock += delta
	move_clock += delta
	if Input.is_action_pressed("soft_drop"):
		soft_clock += delta
		if soft_clock >= 0.045:
			soft_clock = 0.0
			if _try_move(Vector2i(0, 1)):
				score += 1
	else:
		soft_clock = 0.0
	if Input.is_action_pressed("move_left") and move_clock >= 0.12:
		move_clock = 0.0
		_try_move(Vector2i(-1, 0))
	if Input.is_action_pressed("move_right") and move_clock >= 0.12:
		move_clock = 0.0
		_try_move(Vector2i(1, 0))
	if drop_clock >= drop_delay:
		drop_clock = 0.0
		_gravity_step()
	if mode == Mode.VERSUS:
		_process_bot(delta)
	_update_labels()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if screen == Screen.PLAYING:
			screen = Screen.PAUSED
			hint_label.text = "Paused. Press P / Esc / Start to resume."
		elif screen == Screen.PAUSED:
			screen = Screen.PLAYING
		elif screen == Screen.GAME_OVER:
			_show_menu()
		queue_redraw()
		return
	if screen == Screen.MENU:
		if event.is_action_pressed("soft_drop"):
			selected_mode = (selected_mode + 1) % 3
			menu_buttons[selected_mode].grab_focus()
		elif event.is_action_pressed("rotate_cw"):
			selected_mode = (selected_mode + 2) % 3
			menu_buttons[selected_mode].grab_focus()
		elif event.is_action_pressed("ui_accept"):
			start_game(selected_mode)
		return
	if screen != Screen.PLAYING:
		return
	if event.is_action_pressed("move_left"):
		_try_move(Vector2i(-1, 0))
	elif event.is_action_pressed("move_right"):
		_try_move(Vector2i(1, 0))
	elif event.is_action_pressed("rotate_cw"):
		_try_rotate(1)
	elif event.is_action_pressed("rotate_ccw"):
		_try_rotate(-1)
	elif event.is_action_pressed("hard_drop"):
		_hard_drop()
	elif event.is_action_pressed("hold"):
		_hold()
	queue_redraw()


func _gravity_step() -> void:
	if not _try_move(Vector2i(0, 1)):
		_lock_piece()


func _try_move(delta: Vector2i) -> bool:
	var target := active_pos + delta
	if _can_place(active, target, active_rot, board):
		active_pos = target
		return true
	return false


func _try_rotate(direction: int) -> void:
	var next_rot := (active_rot + direction + 4) % 4
	for kick in [Vector2i.ZERO, Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-2, 0), Vector2i(2, 0)]:
		if _can_place(active, active_pos + kick, next_rot, board):
			active_pos += kick
			active_rot = next_rot
			return


func _hard_drop() -> void:
	var dropped := 0
	while _can_place(active, active_pos + Vector2i(0, 1), active_rot, board):
		active_pos.y += 1
		dropped += 1
	score += dropped * 2
	_lock_piece()


func _hold() -> void:
	if hold_locked:
		return
	if hold_piece.is_empty():
		hold_piece = active
		_spawn_piece()
	else:
		var swap := hold_piece
		hold_piece = active
		active = swap
		active_pos = Vector2i(5, 1)
		active_rot = 0
		if not _can_place(active, active_pos, active_rot, board):
			_finish_game("Game Over")
	hold_locked = true


func _lock_piece() -> void:
	for cell in _piece_cells(active, active_pos, active_rot):
		if cell.y >= 0 and cell.y < ROWS and cell.x >= 0 and cell.x < COLS:
			board[cell.y][cell.x] = active
	var cleared := _clear_lines(board)
	_award(cleared)
	if mode == Mode.SPRINT and _count_filled(board) == 0:
		_finish_game("Board Cleared!")
		return
	if mode == Mode.VERSUS and cleared > 1:
		_add_garbage(bot_board, cleared - 1)
	_spawn_piece()


func _award(cleared: int) -> void:
	if cleared == 0:
		combo = -1
		return
	combo += 1
	lines += cleared
	level = 1 + lines / 10
	drop_delay = max(0.09, 0.8 - float(level - 1) * 0.055)
	var base: int = [0, 100, 300, 500, 800][cleared]
	score += base * level + max(combo, 0) * 50


func _clear_lines(target_board: Array) -> int:
	var cleared := 0
	for y in range(ROWS - 1, -1, -1):
		var full := true
		for x in COLS:
			if target_board[y][x] == "":
				full = false
				break
		if full:
			target_board.remove_at(y)
			var row := []
			for x in COLS:
				row.append("")
			target_board.push_front(row)
			cleared += 1
	return cleared


func _add_garbage(target_board: Array, amount: int) -> void:
	for i in amount:
		target_board.pop_front()
		var hole := rng.randi_range(0, COLS - 1)
		var row := []
		for x in COLS:
			row.append("" if x == hole else "G")
		target_board.append(row)


func _process_bot(delta: float) -> void:
	if not bot_alive:
		return
	bot_clock += delta
	var speed: float = max(0.38, 1.15 - float(level) * 0.05)
	if bot_clock < speed:
		return
	bot_clock = 0.0
	var clears := 0
	if rng.randf() < 0.58:
		clears = rng.randi_range(0, 2)
		for i in clears:
			_remove_random_bot_line()
	bot_lines += clears
	if clears > 1:
		_add_garbage(board, clears - 1)
	if _board_too_high(bot_board):
		bot_alive = false
		_finish_game("You Win!")
	elif _board_too_high(board):
		_finish_game("Bot Wins")


func _remove_random_bot_line() -> void:
	for y in range(ROWS - 1, 4, -1):
		var occupied := false
		for x in COLS:
			if bot_board[y][x] != "":
				occupied = true
				break
		if occupied:
			bot_board.remove_at(y)
			var row := []
			for x in COLS:
				row.append("")
			bot_board.push_front(row)
			return


func _board_too_high(target_board: Array) -> bool:
	for y in 4:
		for x in COLS:
			if target_board[y][x] != "":
				return true
	return false


func _count_filled(target_board: Array) -> int:
	var count := 0
	for y in ROWS:
		for x in COLS:
			if target_board[y][x] != "":
				count += 1
	return count


func _can_place(piece: String, pos: Vector2i, rot: int, target_board: Array) -> bool:
	for cell in _piece_cells(piece, pos, rot):
		if cell.x < 0 or cell.x >= COLS or cell.y >= ROWS:
			return false
		if cell.y >= 0 and target_board[cell.y][cell.x] != "":
			return false
	return true


func _piece_cells(piece: String, pos: Vector2i, rot: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for base in PIECES[piece][0]:
		var p: Vector2i = base
		for i in rot % 4:
			p = Vector2i(-p.y, p.x)
		if piece == "O":
			p = base
		cells.append(pos + p)
	return cells


func _ghost_pos() -> Vector2i:
	var ghost := active_pos
	while _can_place(active, ghost + Vector2i(0, 1), active_rot, board):
		ghost.y += 1
	return ghost


func _finish_game(message: String) -> void:
	winner_text = message
	screen = Screen.GAME_OVER
	_save_score()
	_update_history_ui()
	history_box.visible = true
	history_box.position = Vector2(910, 126)
	hint_label.text = "Press Esc / Start to return to the mode menu."


func _save_score() -> void:
	var entry := {
		"mode": MODE_NAMES[mode],
		"score": score,
		"lines": lines,
		"level": level,
		"date": Time.get_datetime_string_from_system(false, true)
	}
	history.append(entry)
	history.sort_custom(func(a, b): return int(a.score) > int(b.score))
	if history.size() > MAX_HISTORY:
		history.resize(MAX_HISTORY)
	var file := FileAccess.open(HISTORY_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(history, "\t"))


func _load_history() -> void:
	if not FileAccess.file_exists(HISTORY_PATH):
		history = []
		return
	var file := FileAccess.open(HISTORY_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		history = parsed


func _update_history_ui() -> void:
	for child in history_box.get_children():
		child.queue_free()
	var header := Label.new()
	header.text = "Best Drops"
	header.add_theme_font_size_override("font_size", 24)
	history_box.add_child(header)
	if history.is_empty():
		var empty := Label.new()
		empty.text = "No scores yet"
		history_box.add_child(empty)
		return
	for i in min(history.size(), 8):
		var entry = history[i]
		var label := Label.new()
		label.text = "%d. %s  %d" % [i + 1, entry.get("mode", "Mode"), int(entry.get("score", 0))]
		label.add_theme_font_size_override("font_size", 16)
		history_box.add_child(label)


func _update_labels() -> void:
	title_label.text = "DROP"
	stats_label.text = "%s\nScore %d\nLines %d\nLevel %d\nHold %s" % [
		MODE_NAMES[mode],
		score,
		lines,
		level,
		hold_piece if not hold_piece.is_empty() else "-"
	]
	if mode == Mode.VERSUS:
		stats_label.text += "\nBot lines %d" % bot_lines
	hint_label.text = "Clear lines, build combos, use Hold, and watch the next queue."


func _draw() -> void:
	_draw_background()
	if screen == Screen.MENU:
		_draw_menu()
		return
	_draw_board(board, BOARD_ORIGIN, true)
	_draw_side_panel()
	if mode == Mode.VERSUS:
		_draw_board(bot_board, Vector2(950, 112), false, 16)
	if screen == Screen.PAUSED:
		_draw_overlay("PAUSED")
	elif screen == Screen.GAME_OVER:
		_draw_overlay(winner_text)


func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#10131f"))
	for y in range(0, int(size.y), 36):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("#1b2135"), 1.0)
	for x in range(0, int(size.x), 36):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("#171d30"), 1.0)
	draw_circle(Vector2(1060, 80), 92, Color("#ff4f8b", 0.16))
	draw_circle(Vector2(180, 560), 122, Color("#00d5ff", 0.12))


func _draw_menu() -> void:
	draw_string(get_theme_default_font(), Vector2(56, 180), "Fast, colorful block-clearing for couch and controller.", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#dce7ff"))
	draw_string(get_theme_default_font(), Vector2(56, 470), "Modes: speed survival, messy board cleanup, and bot battle.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#93a3c6"))


func _draw_board(target_board: Array, origin: Vector2, include_active: bool, block_size: int = BLOCK) -> void:
	var board_rect := Rect2(origin, Vector2(COLS * block_size, ROWS * block_size))
	draw_rect(board_rect.grow(14), Color("#090b13"))
	draw_rect(board_rect.grow(8), Color("#252d46"), false, 2.0)
	for y in ROWS:
		for x in COLS:
			var cell_rect := Rect2(origin + Vector2(x * block_size, y * block_size), Vector2(block_size, block_size))
			draw_rect(cell_rect, Color("#151b2c"))
			draw_rect(cell_rect, Color("#26304b"), false, 1.0)
			var value: String = target_board[y][x]
			if value != "":
				_draw_block(cell_rect, PALETTE[value], value == "G")
	if include_active and screen in [Screen.PLAYING, Screen.PAUSED, Screen.GAME_OVER]:
		for cell in _piece_cells(active, _ghost_pos(), active_rot):
			if cell.y >= 0:
				var ghost_rect := Rect2(origin + Vector2(cell.x * block_size, cell.y * block_size), Vector2(block_size, block_size))
				draw_rect(ghost_rect.grow(-3), Color(PALETTE[active], 0.18), false, 2.0)
		for cell in _piece_cells(active, active_pos, active_rot):
			if cell.y >= 0:
				var piece_rect := Rect2(origin + Vector2(cell.x * block_size, cell.y * block_size), Vector2(block_size, block_size))
				_draw_block(piece_rect, PALETTE[active])


func _draw_block(rect: Rect2, color: Color, muted: bool = false) -> void:
	var fill := color.darkened(0.25) if muted else color
	draw_rect(rect.grow(-2), fill)
	draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8, 5)), Color.WHITE if not muted else Color("#9aa5ba"), true)
	draw_rect(rect.grow(-2), Color("#ffffff", 0.25), false, 1.0)


func _draw_side_panel() -> void:
	var font := get_theme_default_font()
	var next_x := 720 if mode == Mode.VERSUS else 760
	draw_string(font, Vector2(next_x, 72), "Next", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#ffffff"))
	for i in min(5, next_queue.size()):
		_draw_mini_piece(next_queue[i], Vector2(next_x + 20, 112 + i * 76), 16)
	if mode == Mode.VERSUS:
		draw_string(font, Vector2(950, 72), "Bot", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#ffffff"))


func _draw_mini_piece(piece: String, origin: Vector2, mini: int) -> void:
	for cell in _piece_cells(piece, Vector2i.ZERO, 0):
		var rect := Rect2(origin + Vector2((cell.x + 2) * mini, (cell.y + 2) * mini), Vector2(mini, mini))
		_draw_block(rect, PALETTE[piece])


func _draw_overlay(text: String) -> void:
	var rect := Rect2(Vector2(360, 250), Vector2(560, 160))
	draw_rect(rect, Color("#090b13", 0.92))
	draw_rect(rect, Color("#ffde59"), false, 3.0)
	draw_string(get_theme_default_font(), rect.position + Vector2(44, 70), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color("#ffffff"))
	draw_string(get_theme_default_font(), rect.position + Vector2(44, 112), "Score %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#dce7ff"))
