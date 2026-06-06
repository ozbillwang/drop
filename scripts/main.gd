extends Control

const COLS := 10
const ROWS := 20
const BLOCK := 28
const BOARD_ORIGIN := Vector2(410, 76)
const HISTORY_PATH := "user://scores.json"
const SETTINGS_PATH := "user://settings.cfg"
const MAX_HISTORY := 10
const MOVE_REPEAT_DELAY := 0.18
const MOVE_REPEAT_INTERVAL := 0.06
const LOCK_DELAY := 0.45
const LOCK_RESET_LIMIT := 15
const EASY_SCORE_THRESHOLD := 100000
const EASY_POST_THRESHOLD_MIN_DELAY := 0.32
const EASY_POST_THRESHOLD_ACCELERATION := 0.008

enum Screen { MENU, PLAYING, PAUSED, GAME_OVER }
enum Mode { MARATHON, SPRINT, VERSUS, SIX_PACK }
enum Language { EN, ZH }
enum Difficulty { EASY, NORMAL }

const MODE_NAMES := {
	Mode.MARATHON: "Marathon",
	Mode.SPRINT: "Garbage Sprint",
	Mode.VERSUS: "Versus Bot",
	Mode.SIX_PACK: "Six Pack"
}

const MODE_KEYS := {
	Mode.MARATHON: "mode_marathon",
	Mode.SPRINT: "mode_sprint",
	Mode.VERSUS: "mode_versus",
	Mode.SIX_PACK: "mode_six_pack"
}

const THEME_KEYS := ["green", "blue", "orange", "black", "red", "cyan"]
const BACKGROUND_PATHS := {
	"green": "res://assets/backgrounds/vital-green.png",
	"blue": "res://assets/backgrounds/ocean-blue.png",
	"orange": "res://assets/backgrounds/sunrise-orange.png",
	"black": "res://assets/backgrounds/sport-black.png",
	"red": "res://assets/backgrounds/pulse-red.png",
	"cyan": "res://assets/backgrounds/glacier-cyan.png"
}
const SFX_PATHS := {
	"move": "res://assets/sfx/move.wav",
	"rotate": "res://assets/sfx/rotate.wav",
	"soft_drop": "res://assets/sfx/soft_drop.wav",
	"hard_drop": "res://assets/sfx/hard_drop.wav",
	"lock": "res://assets/sfx/lock.wav",
	"clear": "res://assets/sfx/clear.wav",
	"combo": "res://assets/sfx/combo.wav",
	"hold": "res://assets/sfx/hold.wav",
	"menu": "res://assets/sfx/menu.wav",
	"select": "res://assets/sfx/select.wav",
	"pause": "res://assets/sfx/pause.wav",
	"resume": "res://assets/sfx/resume.wav",
	"garbage": "res://assets/sfx/garbage.wav",
	"win": "res://assets/sfx/win.wav",
	"game_over": "res://assets/sfx/game_over.wav"
}
const THEME_DATA := {
	"green": {
		"name_en": "Vital Green",
		"name_zh": "活力绿",
		"bg": Color("#07170f"),
		"grid": Color("#153726"),
		"grid_alt": Color("#102b20"),
		"glow_a": Color("#38ff84", 0.20),
		"glow_b": Color("#00d5ff", 0.12),
		"text": Color("#e8fff0"),
		"muted": Color("#9fd8b8")
	},
	"blue": {
		"name_en": "Ocean Blue",
		"name_zh": "海洋蓝",
		"bg": Color("#071424"),
		"grid": Color("#14314d"),
		"grid_alt": Color("#102842"),
		"glow_a": Color("#00d5ff", 0.22),
		"glow_b": Color("#66f07a", 0.10),
		"text": Color("#e8f7ff"),
		"muted": Color("#9fc6df")
	},
	"orange": {
		"name_en": "Sunrise Orange",
		"name_zh": "晨光橙",
		"bg": Color("#211007"),
		"grid": Color("#4c2a14"),
		"grid_alt": Color("#3a2111"),
		"glow_a": Color("#ff9f1c", 0.24),
		"glow_b": Color("#ffde59", 0.12),
		"text": Color("#fff3e1"),
		"muted": Color("#e7b98c")
	},
	"black": {
		"name_en": "Sport Black",
		"name_zh": "运动黑",
		"bg": Color("#07090d"),
		"grid": Color("#252a34"),
		"grid_alt": Color("#1a1f2a"),
		"glow_a": Color("#ffffff", 0.10),
		"glow_b": Color("#00d5ff", 0.14),
		"text": Color("#f5f7fb"),
		"muted": Color("#a8b0c4")
	},
	"red": {
		"name_en": "Pulse Red",
		"name_zh": "脉冲红",
		"bg": Color("#20070d"),
		"grid": Color("#4a1622"),
		"grid_alt": Color("#36101b"),
		"glow_a": Color("#ff4f8b", 0.24),
		"glow_b": Color("#ffde59", 0.10),
		"text": Color("#ffeaf0"),
		"muted": Color("#e5a2b5")
	},
	"cyan": {
		"name_en": "Glacier Cyan",
		"name_zh": "冰川青",
		"bg": Color("#06191b"),
		"grid": Color("#154044"),
		"grid_alt": Color("#103237"),
		"glow_a": Color("#7dfff2", 0.22),
		"glow_b": Color("#a66cff", 0.12),
		"text": Color("#e7fffd"),
		"muted": Color("#9bd8d3")
	}
}

const I18N := {
	"en": {
		"pick_mode": "Pick a mode",
		"controls_hint": "Keyboard: arrows / Z X / space / C / P / Q. Controller: D-pad, A confirm/drop, X/B rotate, LB/RB hold. Menu: up/down selects, A changes selected settings.",
		"play_hint": "Clear lines, build combos, use Hold, and watch the next queue. Start/Esc pause, Q/Back quit.",
		"paused_hint": "Paused. Press P / A to resume. Press Esc / Start / Back / Q to confirm quitting.",
		"quit_confirm_hint": "Quit to menu? Press Esc / Start / Back / Q again to quit, or P / A to keep playing.",
		"game_over_hint": "Press A / Esc / Start to return to the mode menu.",
		"tagline": "Fast, colorful block-clearing for couch and controller.",
		"mode_summary": "Modes: speed survival, messy board cleanup, and bot battle.",
		"mode_marathon": "Marathon",
		"mode_sprint": "Garbage Sprint",
		"mode_versus": "Versus Bot",
		"mode_six_pack": "Six Pack",
		"score": "Score",
		"lines": "Lines",
		"level": "Level",
		"hold": "Hold",
		"bot_lines": "Bot lines",
		"next": "Next",
		"bot": "Bot",
		"history": "Best Drops",
		"no_scores": "No scores yet",
		"difficulty": "Marathon difficulty",
		"easy": "Easy",
		"normal": "Normal",
		"theme": "Theme",
		"language": "Language",
		"sound_on": "Sound On",
		"sound_off": "Sound Off",
		"english": "English",
		"chinese": "中文",
		"paused": "Paused",
		"quit": "Quit",
		"play": "Play",
		"quit_prompt": "Quit or keep playing?",
		"game_over": "Game Over",
		"board_cleared": "Board Cleared!",
		"you_win": "You Win!",
		"bot_wins": "Bot Wins"
	},
	"zh": {
		"pick_mode": "选择玩法",
		"controls_hint": "键盘：方向键 / Z X / 空格 / C / P / Q。手柄：十字键，A 确认/硬降，X/B 旋转，LB/RB 暂存。菜单上下选择，A 切换设置。",
		"play_hint": "消行、连击、使用暂存，并留意下一个方块队列。Start/Esc 暂停，Q/Back 放弃。",
		"paused_hint": "已暂停。按 P / A 继续。按 Esc / Start / Back / Q 确认放弃。",
		"quit_confirm_hint": "确认返回菜单？再按 Esc / Start / Back / Q 退出，按 P / A 继续。",
		"game_over_hint": "按 A / Esc / Start 返回玩法菜单。",
		"tagline": "快节奏、色彩鲜活，适合沙发和手柄的落块消除。",
		"mode_summary": "玩法：加速生存、残局清理、Bot 对战。",
		"mode_marathon": "单人挑战",
		"mode_sprint": "残局速清",
		"mode_versus": "Bot 对战",
		"mode_six_pack": "六格挑战",
		"score": "分数",
		"lines": "消行",
		"level": "等级",
		"hold": "暂存",
		"bot_lines": "Bot 消行",
		"next": "下一个",
		"bot": "Bot",
		"history": "历史高分",
		"no_scores": "暂无分数",
		"difficulty": "单人难度",
		"easy": "容易",
		"normal": "普通",
		"theme": "背景",
		"language": "语言",
		"sound_on": "音效开",
		"sound_off": "音效关",
		"english": "English",
		"chinese": "中文",
		"paused": "已暂停",
		"quit": "退出",
		"play": "继续",
		"quit_prompt": "退出还是继续？",
		"game_over": "游戏结束",
		"board_cleared": "清理完成！",
		"you_win": "你赢了！",
		"bot_wins": "Bot 获胜"
	}
}

const TOUCH_BUTTONS := [
	{"id": "left", "label": "<", "side": "left", "x": 0, "y": 1, "w": 1, "h": 1},
	{"id": "right", "label": ">", "side": "left", "x": 2, "y": 1, "w": 1, "h": 1},
	{"id": "soft", "label": "v", "side": "left", "x": 1, "y": 1, "w": 1, "h": 1},
	{"id": "hold", "label": "HOLD", "side": "right", "x": 0, "y": 1, "w": 1, "h": 1},
	{"id": "rotate_ccw", "label": "Z", "side": "right", "x": 1, "y": 1, "w": 1, "h": 1},
	{"id": "rotate_cw", "label": "X", "side": "right", "x": 2, "y": 1, "w": 1, "h": 1},
	{"id": "hard", "label": "DROP", "side": "right", "x": 1, "y": 0, "w": 2, "h": 1},
	{"id": "pause", "label": "MENU", "side": "top", "x": 0, "y": 0, "w": 1, "h": 1}
]

const BACKDROP_BLOCKS := [
	{"piece": "T", "pos": Vector2(0.12, 0.16), "size": 34.0, "rot": 0, "alpha": 0.08},
	{"piece": "S", "pos": Vector2(0.78, 0.15), "size": 30.0, "rot": 1, "alpha": 0.07},
	{"piece": "L", "pos": Vector2(0.15, 0.77), "size": 42.0, "rot": 2, "alpha": 0.08},
	{"piece": "I", "pos": Vector2(0.86, 0.70), "size": 28.0, "rot": 1, "alpha": 0.06},
	{"piece": "O", "pos": Vector2(0.56, 0.88), "size": 25.0, "rot": 0, "alpha": 0.05}
]

const PALETTE := {
	"I": Color("#00d5ff"),
	"J": Color("#3177ff"),
	"L": Color("#ff9f1c"),
	"O": Color("#ffde59"),
	"S": Color("#66f07a"),
	"T": Color("#a66cff"),
	"Z": Color("#ff4f8b"),
	"A": Color("#00e5a8"),
	"B": Color("#ffca3a"),
	"D": Color("#ff6f59"),
	"E": Color("#9b5de5"),
	"F": Color("#00bbf9"),
	"H": Color("#f15bb5"),
	"N": Color("#8ac926"),
	"P": Color("#ff924c"),
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

const SIX_PACK_PIECES := {
	# Six Pack uses simpler 4-6 block connected shapes so the mode stays playable.
	"A": [[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]],
	"B": [[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]],
	"D": [[Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]],
	"E": [[Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 0), Vector2i(0, -1)]],
	"F": [[Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, -1)]],
	"H": [[Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, -1), Vector2i(-2, -2)]],
	"N": [[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]],
	"P": [[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, -2)]]
}

var screen := Screen.MENU
var mode := Mode.MARATHON
var selected_mode := 0
var selected_menu_item := 0
var language := Language.EN
var difficulty := Difficulty.NORMAL
var theme_index := 0
var sound_enabled := true
var board: Array = []
var bot_board: Array = []
var active := ""
var active_pos := Vector2i(5, 1)
var active_rot := 0
var hold_piece := ""
var hold_locked := false
var next_queue: Array[String] = []
var bag: Array[String] = []
var versus_sequence: Array[String] = []
var player_piece_index := 0
var bot_piece_index := 0
var score := 0
var lines := 0
var level := 1
var combo := -1
var drop_delay := 0.8
var drop_clock := 0.0
var soft_clock := 0.0
var lock_clock := 0.0
var lock_resets := 0
var easy_slowdown_start_level := 0
var easy_slowdown_start_delay := 0.8
var move_repeat_dir := 0
var move_repeat_clock := 0.0
var move_repeat_started := false
var touch_left_pressed := false
var touch_right_pressed := false
var touch_soft_pressed := false
var touch_controls_visible := false
var bot_clock := 0.0
var bot_piece := ""
var bot_pos := Vector2i(5, 1)
var bot_rot := 0
var bot_target_x := 5
var bot_target_rot := 0
var bot_lines := 0
var bot_alive := true
var result_key := ""
var pause_quit_prompt := false
var pause_quit_choice := 1
var history: Array = []
var rng := RandomNumberGenerator.new()
var background_textures := {}

var title_label: Label
var stats_label: Label
var hint_label: Label
var history_box: VBoxContainer
var menu_buttons: Array[Button] = []
var difficulty_button: Button
var theme_button: Button
var language_button: Button
var sound_button: Button
var touch_root: Control
var touch_buttons := {}
var sfx_players := {}


func _ready() -> void:
	rng.randomize()
	_load_background_textures()
	_load_settings()
	_setup_input()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_build_ui()
	_setup_audio()
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
	_add_action_key("quit_to_menu", KEY_Q)
	_add_action_key("cycle_theme", KEY_T)
	_add_action_key("toggle_language", KEY_L)
	_add_action_key("ui_accept", KEY_ENTER)
	_add_action_key("ui_accept", KEY_SPACE)
	_add_action_key("menu_up", KEY_UP)
	_add_action_key("menu_down", KEY_DOWN)
	_add_action_key("menu_left", KEY_LEFT)
	_add_action_key("menu_right", KEY_RIGHT)
	_add_action_joy_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_add_action_joy_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_action_joy_button("soft_drop", JOY_BUTTON_DPAD_DOWN)
	_add_action_joy_button("menu_up", JOY_BUTTON_DPAD_UP)
	_add_action_joy_button("menu_down", JOY_BUTTON_DPAD_DOWN)
	_add_action_joy_button("menu_left", JOY_BUTTON_DPAD_LEFT)
	_add_action_joy_button("menu_right", JOY_BUTTON_DPAD_RIGHT)
	_add_action_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_action_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_action_joy_axis("soft_drop", JOY_AXIS_LEFT_Y, 1.0)
	_add_action_joy_axis("menu_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_action_joy_axis("menu_down", JOY_AXIS_LEFT_Y, 1.0)
	_add_action_joy_axis("menu_left", JOY_AXIS_LEFT_X, -1.0)
	_add_action_joy_axis("menu_right", JOY_AXIS_LEFT_X, 1.0)
	_add_action_joy_button("hard_drop", JOY_BUTTON_A)
	_add_action_joy_button("ui_accept", JOY_BUTTON_A)
	_add_action_joy_button("ui_accept", JOY_BUTTON_START)
	_add_action_joy_button("rotate_cw", JOY_BUTTON_X)
	_add_action_joy_button("rotate_ccw", JOY_BUTTON_B)
	_add_action_joy_button("hold", JOY_BUTTON_LEFT_SHOULDER)
	_add_action_joy_button("hold", JOY_BUTTON_RIGHT_SHOULDER)
	_add_action_joy_button("pause", JOY_BUTTON_START)
	_add_action_joy_button("quit_to_menu", JOY_BUTTON_BACK)
	_add_action_joy_button("quit_to_menu", JOY_BUTTON_GUIDE)


func _load_background_textures() -> void:
	for key in BACKGROUND_PATHS:
		background_textures[key] = load(BACKGROUND_PATHS[key])


func _add_action_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func _add_action_joy_button(action: StringName, button_index: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action, event)


func _add_action_joy_axis(action: StringName, axis: int, axis_value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_set_deadzone(action, 0.35)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(action, event)


func _build_ui() -> void:
	title_label = Label.new()
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

	for i in MODE_KEYS.size():
		var button := Button.new()
		button.position = Vector2(56, 210 + i * 56)
		button.size = Vector2(260, 48)
		button.pressed.connect(func() -> void:
			_play_sfx("select")
			start_game(i)
		)
		add_child(button)
		menu_buttons.append(button)

	difficulty_button = Button.new()
	difficulty_button.position = Vector2(56, 448)
	difficulty_button.size = Vector2(260, 42)
	difficulty_button.pressed.connect(_cycle_difficulty)
	add_child(difficulty_button)

	theme_button = Button.new()
	theme_button.position = Vector2(56, 500)
	theme_button.size = Vector2(260, 42)
	theme_button.pressed.connect(_cycle_theme)
	add_child(theme_button)

	language_button = Button.new()
	language_button.position = Vector2(56, 552)
	language_button.size = Vector2(260, 42)
	language_button.pressed.connect(_toggle_language)
	add_child(language_button)

	sound_button = Button.new()
	sound_button.position = Vector2(1112, 32)
	sound_button.size = Vector2(112, 40)
	sound_button.focus_mode = Control.FOCUS_NONE
	sound_button.pressed.connect(_toggle_sound)
	add_child(sound_button)

	touch_root = Control.new()
	touch_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_root.visible = false
	add_child(touch_root)
	for spec in TOUCH_BUTTONS:
		var button := Button.new()
		button.text = spec["label"]
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 18)
		button.button_down.connect(func() -> void:
			_touch_button_down(spec["id"])
		)
		button.button_up.connect(func() -> void:
			_touch_button_up(spec["id"])
		)
		touch_root.add_child(button)
		touch_buttons[spec["id"]] = button
	_layout_touch_controls()


func _setup_audio() -> void:
	for key in SFX_PATHS:
		var stream: AudioStream = load(SFX_PATHS[key])
		if not stream:
			continue
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = -5.0
		add_child(player)
		sfx_players[key] = player


func _play_sfx(key: String) -> void:
	if not sound_enabled:
		return
	var player := sfx_players.get(key) as AudioStreamPlayer
	if not player:
		return
	player.stop()
	player.play()


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	sound_enabled = bool(config.get_value("audio", "sound_enabled", true))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "sound_enabled", sound_enabled)
	config.save(SETTINGS_PATH)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and touch_root:
		_layout_touch_controls()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_reset_controller_state()


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_reset_controller_state()


func _reset_controller_state() -> void:
	touch_left_pressed = false
	touch_right_pressed = false
	touch_soft_pressed = false
	move_repeat_dir = 0
	move_repeat_clock = 0.0
	move_repeat_started = false
	soft_clock = 0.0


func _language_code() -> String:
	return "zh" if language == Language.ZH else "en"


func _text(key: String) -> String:
	return I18N[_language_code()].get(key, key)


func _mode_name(value: int) -> String:
	return _text(MODE_KEYS[value])


func _theme_data() -> Dictionary:
	return THEME_DATA[THEME_KEYS[theme_index]]


func _theme_name() -> String:
	var data := _theme_data()
	return data["name_zh"] if language == Language.ZH else data["name_en"]


func _difficulty_name() -> String:
	return _difficulty_name_for(difficulty)


func _difficulty_name_for(value: int) -> String:
	return _text("easy") if value == Difficulty.EASY else _text("normal")


func _legacy_mode_name(raw: Variant) -> String:
	if raw is int or raw is float:
		var mode_value := int(raw)
		if mode_value >= 0 and mode_value < MODE_KEYS.size():
			return _mode_name(mode_value)
	match str(raw):
		"Marathon":
			return _mode_name(Mode.MARATHON)
		"Garbage Sprint":
			return _mode_name(Mode.SPRINT)
		"Versus Bot":
			return _mode_name(Mode.VERSUS)
		"Six Pack":
			return _mode_name(Mode.SIX_PACK)
	return str(raw)


func _history_entry_name(entry: Dictionary) -> String:
	var raw_mode: Variant = entry.get("mode", Mode.MARATHON)
	var label := _legacy_mode_name(raw_mode)
	var mode_value := -1
	if raw_mode is int or raw_mode is float:
		mode_value = int(raw_mode)
	elif str(raw_mode) == "Marathon":
		mode_value = Mode.MARATHON
	if mode_value == Mode.MARATHON and entry.has("difficulty"):
		label += " " + _difficulty_name_for(int(entry.get("difficulty", Difficulty.NORMAL)))
	return label


func _refresh_static_text() -> void:
	title_label.text = "DROP"
	for i in menu_buttons.size():
		menu_buttons[i].text = _mode_name(i)
	difficulty_button.text = "%s: %s" % [_text("difficulty"), _difficulty_name()]
	theme_button.text = "%s: %s" % [_text("theme"), _theme_name()]
	language_button.text = "%s: %s" % [_text("language"), _text("chinese") if language == Language.ZH else _text("english")]
	sound_button.text = _text("sound_on") if sound_enabled else _text("sound_off")
	if screen == Screen.MENU:
		stats_label.text = _text("pick_mode")
		hint_label.text = _text("controls_hint")
	elif screen == Screen.PAUSED:
		hint_label.text = _pause_hint()
	elif screen == Screen.GAME_OVER:
		hint_label.text = _text("game_over_hint")
	else:
		_update_labels()
	_update_history_ui()


func _cycle_theme() -> void:
	_play_sfx("menu")
	theme_index = (theme_index + 1) % THEME_KEYS.size()
	_refresh_static_text()
	queue_redraw()


func _cycle_difficulty() -> void:
	_play_sfx("menu")
	difficulty = Difficulty.NORMAL if difficulty == Difficulty.EASY else Difficulty.EASY
	_refresh_static_text()
	queue_redraw()


func _toggle_language() -> void:
	_play_sfx("menu")
	language = Language.ZH if language == Language.EN else Language.EN
	_refresh_static_text()
	queue_redraw()


func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	_save_settings()
	_refresh_static_text()
	if sound_enabled:
		_play_sfx("select")
	queue_redraw()


func _pause_hint() -> String:
	return _text("quit_confirm_hint") if pause_quit_prompt else _text("paused_hint")


func _menu_item_count() -> int:
	return menu_buttons.size() + 3


func _focus_menu_item(index: int) -> void:
	if _menu_item_count() == 0:
		return
	selected_menu_item = wrapi(index, 0, _menu_item_count())
	if selected_menu_item < menu_buttons.size():
		selected_mode = selected_menu_item
		menu_buttons[selected_mode].grab_focus()
	elif selected_menu_item == menu_buttons.size():
		difficulty_button.grab_focus()
	elif selected_menu_item == menu_buttons.size() + 1:
		theme_button.grab_focus()
	else:
		language_button.grab_focus()


func _activate_menu_item() -> void:
	if selected_menu_item < menu_buttons.size():
		_play_sfx("select")
		selected_mode = selected_menu_item
		start_game(selected_mode)
	elif selected_menu_item == menu_buttons.size():
		_cycle_difficulty()
	elif selected_menu_item == menu_buttons.size() + 1:
		_cycle_theme()
	else:
		_toggle_language()


func _should_show_touch_controls() -> bool:
	return OS.get_name() in ["Android", "iOS"] or DisplayServer.is_touchscreen_available()


func _set_touch_controls(visible: bool) -> void:
	touch_controls_visible = visible
	if touch_root:
		touch_root.visible = visible
	if not visible:
		touch_left_pressed = false
		touch_right_pressed = false
		touch_soft_pressed = false
		move_repeat_dir = 0
		move_repeat_clock = 0.0
		move_repeat_started = false


func _layout_touch_controls() -> void:
	if not touch_root:
		return
	var button_size: float = clamp(size.y * 0.105, 56.0, 86.0)
	var gap: float = button_size * 0.16
	var margin: float = max(18.0, size.x * 0.025)
	var bottom: float = size.y - button_size * 2.0 - gap - max(18.0, size.y * 0.035)
	var left_origin := Vector2(margin, bottom)
	var right_origin := Vector2(size.x - margin - button_size * 3.0 - gap * 2.0, bottom)
	var top_origin := Vector2(size.x - margin - button_size, margin)
	for spec in TOUCH_BUTTONS:
		var button: Button = touch_buttons[spec["id"]]
		var origin := left_origin
		if spec["side"] == "right":
			origin = right_origin
		elif spec["side"] == "top":
			origin = top_origin
		button.position = origin + Vector2(float(spec["x"]) * (button_size + gap), float(spec["y"]) * (button_size + gap))
		button.size = Vector2(float(spec["w"]) * button_size + float(spec["w"] - 1) * gap, float(spec["h"]) * button_size + float(spec["h"] - 1) * gap)


func _touch_button_down(id: String) -> void:
	if not touch_controls_visible:
		return
	match id:
		"left":
			if screen == Screen.PLAYING:
				touch_left_pressed = true
				if _try_move(Vector2i(-1, 0)):
					_play_sfx("move")
				_start_horizontal_repeat(-1)
		"right":
			if screen == Screen.PLAYING:
				touch_right_pressed = true
				if _try_move(Vector2i(1, 0)):
					_play_sfx("move")
				_start_horizontal_repeat(1)
		"soft":
			touch_soft_pressed = true
		"hard":
			if screen == Screen.PLAYING:
				_hard_drop()
		"rotate_cw":
			if screen == Screen.PLAYING:
				_try_rotate(1)
		"rotate_ccw":
			if screen == Screen.PLAYING:
				_try_rotate(-1)
		"hold":
			if screen == Screen.PLAYING:
				_hold()
		"pause":
			_handle_touch_menu()
	queue_redraw()


func _touch_button_up(id: String) -> void:
	match id:
		"left":
			touch_left_pressed = false
		"right":
			touch_right_pressed = false
		"soft":
			touch_soft_pressed = false


func _handle_touch_menu() -> void:
	if screen == Screen.PLAYING:
		_pause_game()
	elif screen == Screen.PAUSED:
		_show_pause_quit_prompt()
	elif screen == Screen.GAME_OVER:
		_show_menu()


func _pause_game() -> void:
	screen = Screen.PAUSED
	pause_quit_prompt = false
	pause_quit_choice = 1
	hint_label.text = _pause_hint()
	_play_sfx("pause")


func _resume_game() -> void:
	screen = Screen.PLAYING
	pause_quit_prompt = false
	pause_quit_choice = 1
	_play_sfx("resume")
	queue_redraw()


func _request_quit_to_menu() -> void:
	if screen == Screen.PLAYING:
		_pause_game()
		_show_pause_quit_prompt()
	elif screen == Screen.PAUSED:
		_show_pause_quit_prompt()


func _show_pause_quit_prompt() -> void:
	pause_quit_prompt = true
	pause_quit_choice = 1
	hint_label.text = _pause_hint()
	_play_sfx("pause")


func _toggle_pause_quit_choice() -> void:
	pause_quit_choice = 1 - pause_quit_choice
	_play_sfx("menu")


func _confirm_pause_quit_choice() -> void:
	if pause_quit_choice == 0:
		_show_menu()
	else:
		_resume_game()


func _show_menu() -> void:
	screen = Screen.MENU
	pause_quit_prompt = false
	pause_quit_choice = 1
	history_box.visible = true
	history_box.position = Vector2(910, 126)
	_set_touch_controls(false)
	for button in menu_buttons:
		button.visible = true
	difficulty_button.visible = true
	theme_button.visible = true
	language_button.visible = true
	_refresh_static_text()
	_update_history_ui()
	_focus_menu_item(selected_menu_item)
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
	versus_sequence.clear()
	player_piece_index = 0
	bot_piece_index = 0
	next_queue.clear()
	bot_piece = ""
	hold_piece = ""
	hold_locked = false
	score = 0
	lines = 0
	level = 1
	combo = -1
	drop_delay = 0.8
	easy_slowdown_start_level = 0
	easy_slowdown_start_delay = 0.8
	drop_clock = 0.0
	soft_clock = 0.0
	lock_clock = 0.0
	lock_resets = 0
	move_repeat_dir = 0
	move_repeat_clock = 0.0
	move_repeat_started = false
	touch_left_pressed = false
	touch_right_pressed = false
	touch_soft_pressed = false
	bot_clock = 0.0
	result_key = ""
	pause_quit_prompt = false
	pause_quit_choice = 1
	if mode == Mode.VERSUS:
		for i in 16:
			versus_sequence.append(_draw_piece())
		for i in 5:
			next_queue.append(_peek_versus_piece(player_piece_index + i))
	else:
		for i in 5:
			next_queue.append(_draw_piece())
	_spawn_piece()
	if mode == Mode.VERSUS:
		_spawn_bot_piece()
	for button in menu_buttons:
		button.visible = false
	difficulty_button.visible = false
	theme_button.visible = false
	language_button.visible = false
	history_box.visible = false
	_set_touch_controls(_should_show_touch_controls())
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
		bag = _piece_bag()
		bag.shuffle()
	return bag.pop_back()


func _piece_bag() -> Array[String]:
	if mode == Mode.SIX_PACK:
		return ["A", "B", "D", "E", "F", "H", "N", "P"]
	return ["I", "J", "L", "O", "S", "T", "Z"]


func _peek_versus_piece(index: int) -> String:
	while index >= versus_sequence.size():
		versus_sequence.append(_draw_piece())
	return versus_sequence[index]


func _spawn_piece() -> void:
	if mode == Mode.VERSUS:
		active = _peek_versus_piece(player_piece_index)
		player_piece_index += 1
		next_queue.clear()
		for i in 5:
			next_queue.append(_peek_versus_piece(player_piece_index + i))
	else:
		active = next_queue.pop_front()
		next_queue.append(_draw_piece())
	active_pos = Vector2i(5, 1)
	active_rot = 0
	lock_clock = 0.0
	lock_resets = 0
	hold_locked = false
	if not _can_place(active, active_pos, active_rot, board):
		_finish_game("bot_wins" if mode == Mode.VERSUS else "game_over")


func _process(delta: float) -> void:
	if screen != Screen.PLAYING:
		return
	drop_clock += delta
	_process_horizontal_repeat(delta)
	if Input.is_action_pressed("soft_drop") or touch_soft_pressed:
		soft_clock += delta
		if soft_clock >= 0.045:
			soft_clock = 0.0
			if _try_move(Vector2i(0, 1)):
				score += 1
				_play_sfx("soft_drop")
	else:
		soft_clock = 0.0
	if drop_clock >= drop_delay:
		drop_clock = 0.0
		_gravity_step()
	_process_lock_delay(delta)
	if screen != Screen.PLAYING:
		return
	if mode == Mode.VERSUS:
		_process_bot(delta)
	_update_labels()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_theme"):
		_cycle_theme()
		accept_event()
		return
	if event.is_action_pressed("toggle_language"):
		_toggle_language()
		accept_event()
		return
	if _handle_raw_controller_ui_input(event):
		accept_event()
		return
	if screen == Screen.PAUSED:
		if _handle_paused_input(event):
			accept_event()
		return
	if event.is_action_pressed("quit_to_menu"):
		if screen == Screen.PLAYING:
			_request_quit_to_menu()
		elif screen == Screen.GAME_OVER:
			_show_menu()
		accept_event()
		return
	if screen == Screen.MENU:
		if event.is_action_pressed("menu_down") or event.is_action_pressed("soft_drop"):
			_play_sfx("menu")
			_focus_menu_item(selected_menu_item + 1)
		elif event.is_action_pressed("menu_up"):
			_play_sfx("menu")
			_focus_menu_item(selected_menu_item - 1)
		elif (event.is_action_pressed("menu_left") or event.is_action_pressed("menu_right")) and selected_menu_item == menu_buttons.size():
			_cycle_difficulty()
		elif event.is_action_pressed("ui_accept"):
			_activate_menu_item()
		else:
			return
		accept_event()
		return
	if event.is_action_pressed("pause"):
		if screen == Screen.PLAYING:
			_pause_game()
		elif screen == Screen.GAME_OVER:
			_show_menu()
		else:
			return
		queue_redraw()
		accept_event()
		return
	if screen == Screen.GAME_OVER and event.is_action_pressed("ui_accept"):
		_show_menu()
		accept_event()
		return
	if screen != Screen.PLAYING:
		return
	var handled := true
	if event.is_action_pressed("move_left"):
		if _try_move(Vector2i(-1, 0)):
			_play_sfx("move")
		_start_horizontal_repeat(-1)
	elif event.is_action_pressed("move_right"):
		if _try_move(Vector2i(1, 0)):
			_play_sfx("move")
		_start_horizontal_repeat(1)
	elif event.is_action_pressed("rotate_cw"):
		_try_rotate(1)
	elif event.is_action_pressed("rotate_ccw"):
		_try_rotate(-1)
	elif event.is_action_pressed("hard_drop"):
		_hard_drop()
	elif event.is_action_pressed("hold"):
		_hold()
	else:
		handled = false
	if not handled:
		return
	queue_redraw()
	accept_event()


func _handle_raw_controller_ui_input(event: InputEvent) -> bool:
	if not event is InputEventJoypadButton:
		return false
	var joy_event := event as InputEventJoypadButton
	if not joy_event.pressed:
		return false
	var button := joy_event.button_index
	if screen == Screen.PLAYING:
		if button == JOY_BUTTON_START:
			_pause_game()
			queue_redraw()
			return true
		if button == JOY_BUTTON_BACK or button == JOY_BUTTON_GUIDE:
			_request_quit_to_menu()
			queue_redraw()
			return true
		return false
	if screen == Screen.PAUSED:
		if pause_quit_prompt:
			if _is_controller_dpad(button):
				_toggle_pause_quit_choice()
			elif button == JOY_BUTTON_BACK or button == JOY_BUTTON_GUIDE:
				pause_quit_choice = 0
			elif button == JOY_BUTTON_A or button == JOY_BUTTON_START:
				_confirm_pause_quit_choice()
			else:
				return true
		elif button == JOY_BUTTON_START or button == JOY_BUTTON_BACK or button == JOY_BUTTON_GUIDE:
			_show_pause_quit_prompt()
		elif button == JOY_BUTTON_A:
			_resume_game()
		else:
			return true
		queue_redraw()
		return true
	if screen == Screen.MENU:
		if button == JOY_BUTTON_DPAD_DOWN:
			_play_sfx("menu")
			_focus_menu_item(selected_menu_item + 1)
		elif button == JOY_BUTTON_DPAD_UP:
			_play_sfx("menu")
			_focus_menu_item(selected_menu_item - 1)
		elif (button == JOY_BUTTON_DPAD_LEFT or button == JOY_BUTTON_DPAD_RIGHT) and selected_menu_item == menu_buttons.size():
			_cycle_difficulty()
		elif button == JOY_BUTTON_A or button == JOY_BUTTON_START:
			_activate_menu_item()
		else:
			return true
		queue_redraw()
		return true
	if screen == Screen.GAME_OVER:
		if button == JOY_BUTTON_A or button == JOY_BUTTON_START or button == JOY_BUTTON_BACK or button == JOY_BUTTON_GUIDE:
			_show_menu()
			queue_redraw()
		return true
	return false


func _is_controller_dpad(button: int) -> bool:
	return button == JOY_BUTTON_DPAD_LEFT or button == JOY_BUTTON_DPAD_RIGHT or button == JOY_BUTTON_DPAD_UP or button == JOY_BUTTON_DPAD_DOWN


func _handle_paused_input(event: InputEvent) -> bool:
	if pause_quit_prompt:
		if event.is_action_pressed("menu_left") or event.is_action_pressed("menu_right") or event.is_action_pressed("menu_up") or event.is_action_pressed("menu_down") or event.is_action_pressed("soft_drop"):
			_toggle_pause_quit_choice()
		elif event.is_action_pressed("quit_to_menu"):
			pause_quit_choice = 0
		elif event.is_action_pressed("ui_accept") or event.is_action_pressed("pause"):
			_confirm_pause_quit_choice()
		else:
			return false
		queue_redraw()
		return true
	if event.is_action_pressed("pause") or event.is_action_pressed("quit_to_menu"):
		_show_pause_quit_prompt()
	elif event.is_action_pressed("ui_accept") or _is_resume_event(event):
		_resume_game()
	else:
		return false
	queue_redraw()
	return true


func _is_resume_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.physical_keycode == KEY_P
	if event is InputEventJoypadButton:
		return event.button_index == JOY_BUTTON_A
	return false


func _start_horizontal_repeat(direction: int) -> void:
	move_repeat_dir = direction
	move_repeat_clock = 0.0
	move_repeat_started = false


func _process_horizontal_repeat(delta: float) -> void:
	var direction := 0
	var left_pressed := Input.is_action_pressed("move_left") or touch_left_pressed
	var right_pressed := Input.is_action_pressed("move_right") or touch_right_pressed
	if left_pressed and not right_pressed:
		direction = -1
	elif right_pressed and not left_pressed:
		direction = 1
	if direction == 0:
		move_repeat_dir = 0
		move_repeat_clock = 0.0
		move_repeat_started = false
		return
	if direction != move_repeat_dir:
		_start_horizontal_repeat(direction)
		return
	move_repeat_clock += delta
	var threshold := MOVE_REPEAT_INTERVAL if move_repeat_started else MOVE_REPEAT_DELAY
	if move_repeat_clock >= threshold:
		move_repeat_clock = 0.0
		move_repeat_started = true
		if _try_move(Vector2i(direction, 0)):
			_play_sfx("move")


func _gravity_step() -> void:
	_try_move(Vector2i(0, 1))


func _process_lock_delay(delta: float) -> void:
	if not _is_grounded():
		lock_clock = 0.0
		return
	lock_clock += delta
	if lock_clock >= LOCK_DELAY:
		_lock_piece()


func _try_move(delta: Vector2i) -> bool:
	var target := active_pos + delta
	if _can_place(active, target, active_rot, board):
		active_pos = target
		if delta.y > 0:
			lock_clock = 0.0
		elif delta.y == 0:
			_try_extend_lock_delay()
		return true
	return false


func _try_rotate(direction: int) -> void:
	var next_rot := (active_rot + direction + 4) % 4
	for kick in [Vector2i.ZERO, Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-2, 0), Vector2i(2, 0)]:
		if _can_place(active, active_pos + kick, next_rot, board):
			active_pos += kick
			active_rot = next_rot
			_try_extend_lock_delay()
			_play_sfx("rotate")
			return


func _try_extend_lock_delay() -> void:
	if not _is_grounded() or lock_resets >= LOCK_RESET_LIMIT:
		return
	lock_resets += 1
	lock_clock = 0.0


func _is_grounded() -> bool:
	return not _can_place(active, active_pos + Vector2i(0, 1), active_rot, board)


func _hard_drop() -> void:
	var dropped := 0
	while _can_place(active, active_pos + Vector2i(0, 1), active_rot, board):
		active_pos.y += 1
		dropped += 1
	score += dropped * 2
	_play_sfx("hard_drop")
	_lock_piece()


func _hold() -> void:
	if hold_locked:
		return
	_play_sfx("hold")
	if hold_piece.is_empty():
		hold_piece = active
		_spawn_piece()
	else:
		var swap := hold_piece
		hold_piece = active
		active = swap
		active_pos = Vector2i(5, 1)
		active_rot = 0
		lock_clock = 0.0
		lock_resets = 0
		if not _can_place(active, active_pos, active_rot, board):
			_finish_game("game_over")
	hold_locked = true


func _lock_piece() -> void:
	for cell in _piece_cells(active, active_pos, active_rot):
		if cell.y >= 0 and cell.y < ROWS and cell.x >= 0 and cell.x < COLS:
			board[cell.y][cell.x] = active
	_play_sfx("lock")
	var cleared := _clear_lines(board)
	_award(cleared)
	if mode == Mode.SPRINT and _count_garbage(board) == 0:
		_finish_game("board_cleared")
		return
	if mode == Mode.VERSUS and cleared > 0:
		_attack_bot(cleared)
		if screen != Screen.PLAYING:
			return
	_spawn_piece()


func _award(cleared: int) -> void:
	if cleared == 0:
		combo = -1
		return
	combo += 1
	lines += cleared
	level = 1 + lines / 10
	var base := _line_clear_score(cleared)
	score += base * level + max(combo, 0) * 50
	_play_sfx("combo" if cleared >= 4 or combo > 0 else "clear")
	_update_drop_delay()


func _line_clear_score(cleared: int) -> int:
	if cleared <= 0:
		return 0
	var table := [0, 100, 300, 500, 800]
	if cleared < table.size():
		return table[cleared]
	return 800 + (cleared - 4) * 400


func _update_drop_delay() -> void:
	if mode == Mode.SIX_PACK:
		drop_delay = 0.8
		return
	var normal_delay := _normal_drop_delay(level)
	if mode != Mode.MARATHON or difficulty != Difficulty.EASY:
		drop_delay = normal_delay
		return
	if score < EASY_SCORE_THRESHOLD:
		easy_slowdown_start_level = 0
		easy_slowdown_start_delay = normal_delay
		drop_delay = normal_delay
		return
	if easy_slowdown_start_level == 0:
		easy_slowdown_start_level = level
		easy_slowdown_start_delay = max(normal_delay, EASY_POST_THRESHOLD_MIN_DELAY)
	var extra_levels: int = max(0, level - easy_slowdown_start_level)
	drop_delay = max(0.26, easy_slowdown_start_delay - float(extra_levels) * EASY_POST_THRESHOLD_ACCELERATION)


func _normal_drop_delay(for_level: int) -> float:
	return max(0.09, 0.8 - float(for_level - 1) * 0.055)


func _clear_lines(target_board: Array) -> int:
	var cleared := 0
	var kept_rows := []
	for y in ROWS:
		var full := true
		for x in COLS:
			if target_board[y][x] == "":
				full = false
				break
		if full:
			cleared += 1
		else:
			kept_rows.append(target_board[y])
	target_board.clear()
	for i in cleared:
		target_board.append(_make_empty_row())
	for row in kept_rows:
		target_board.append(row)
	return cleared


func _make_empty_row() -> Array:
	var row := []
	for x in COLS:
		row.append("")
	return row


func _add_garbage(target_board: Array, amount: int) -> void:
	for i in amount:
		target_board.pop_front()
		var hole := rng.randi_range(0, COLS - 1)
		var row := []
		for x in COLS:
			row.append("" if x == hole else "G")
		target_board.append(row)


func _attack_bot(amount: int) -> void:
	_add_garbage(bot_board, amount)
	_play_sfx("garbage")
	if not bot_piece.is_empty():
		_lift_bot_piece_until_valid(amount)
		if not _can_place(bot_piece, bot_pos, bot_rot, bot_board):
			bot_alive = false
			_finish_game("you_win")


func _attack_player(amount: int) -> void:
	_add_garbage(board, amount)
	_play_sfx("garbage")
	if not active.is_empty():
		_lift_player_piece_until_valid(amount)
		if not _can_place(active, active_pos, active_rot, board):
			_finish_game("bot_wins")


func _lift_player_piece_until_valid(max_steps: int) -> void:
	for i in max_steps:
		if _can_place(active, active_pos, active_rot, board):
			return
		active_pos.y -= 1


func _lift_bot_piece_until_valid(max_steps: int) -> void:
	for i in max_steps:
		if _can_place(bot_piece, bot_pos, bot_rot, bot_board):
			return
		bot_pos.y -= 1


func _process_bot(delta: float) -> void:
	if not bot_alive or bot_piece.is_empty():
		return
	bot_clock += delta
	var speed: float = max(0.10, 0.34 - float(level) * 0.012)
	if bot_clock < speed:
		return
	bot_clock = 0.0
	if bot_rot != bot_target_rot:
		var next_rot := (bot_rot + 1) % 4
		if _can_place(bot_piece, bot_pos, next_rot, bot_board):
			bot_rot = next_rot
			return
	if bot_pos.x < bot_target_x and _can_place(bot_piece, bot_pos + Vector2i(1, 0), bot_rot, bot_board):
		bot_pos.x += 1
		return
	if bot_pos.x > bot_target_x and _can_place(bot_piece, bot_pos + Vector2i(-1, 0), bot_rot, bot_board):
		bot_pos.x -= 1
		return
	if _can_place(bot_piece, bot_pos + Vector2i(0, 1), bot_rot, bot_board):
		bot_pos.y += 1
	else:
		_lock_bot_piece()
	if _board_too_high(bot_board):
		bot_alive = false
		_finish_game("you_win")


func _spawn_bot_piece() -> void:
	bot_piece = _peek_versus_piece(bot_piece_index)
	bot_piece_index += 1
	bot_pos = Vector2i(5, 1)
	bot_rot = 0
	_choose_bot_target()
	if not _can_place(bot_piece, bot_pos, bot_rot, bot_board):
		bot_alive = false
		_finish_game("you_win")


func _choose_bot_target() -> void:
	var best_score := -999999
	var best_x := 5
	var best_rot := 0
	for rot in 4:
		for x in range(-2, COLS + 2):
			var pos := Vector2i(x, 1)
			if not _can_place(bot_piece, pos, rot, bot_board):
				continue
			while _can_place(bot_piece, pos + Vector2i(0, 1), rot, bot_board):
				pos.y += 1
			var score_value := _score_bot_landing(bot_piece, pos, rot)
			if score_value > best_score:
				best_score = score_value
				best_x = x
				best_rot = rot
	bot_target_x = best_x
	bot_target_rot = best_rot


func _score_bot_landing(piece: String, pos: Vector2i, rot: int) -> int:
	var test_board := _copy_board(bot_board)
	for cell in _piece_cells(piece, pos, rot):
		if cell.y >= 0 and cell.y < ROWS and cell.x >= 0 and cell.x < COLS:
			test_board[cell.y][cell.x] = piece
	var cleared := _count_full_lines(test_board)
	return cleared * 700 - _aggregate_height(test_board) * 6 - _count_holes(test_board) * 42 - _bumpiness(test_board) * 7 + rng.randi_range(0, 12)


func _lock_bot_piece() -> void:
	for cell in _piece_cells(bot_piece, bot_pos, bot_rot):
		if cell.y >= 0 and cell.y < ROWS and cell.x >= 0 and cell.x < COLS:
			bot_board[cell.y][cell.x] = bot_piece
	var cleared := _clear_lines(bot_board)
	bot_lines += cleared
	if cleared > 0:
		_attack_player(cleared)
		if screen != Screen.PLAYING:
			return
	_spawn_bot_piece()


func _copy_board(source_board: Array) -> Array:
	var copy := []
	for y in ROWS:
		copy.append(source_board[y].duplicate())
	return copy


func _count_full_lines(target_board: Array) -> int:
	var count := 0
	for y in ROWS:
		var full := true
		for x in COLS:
			if target_board[y][x] == "":
				full = false
				break
		if full:
			count += 1
	return count


func _column_heights(target_board: Array) -> Array[int]:
	var heights: Array[int] = []
	for x in COLS:
		var height := 0
		for y in ROWS:
			if target_board[y][x] != "":
				height = ROWS - y
				break
		heights.append(height)
	return heights


func _aggregate_height(target_board: Array) -> int:
	var total := 0
	for height in _column_heights(target_board):
		total += height
	return total


func _count_holes(target_board: Array) -> int:
	var holes := 0
	for x in COLS:
		var seen_block := false
		for y in ROWS:
			if target_board[y][x] != "":
				seen_block = true
			elif seen_block:
				holes += 1
	return holes


func _bumpiness(target_board: Array) -> int:
	var heights := _column_heights(target_board)
	var total := 0
	for i in range(heights.size() - 1):
		total += abs(heights[i] - heights[i + 1])
	return total


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


func _count_garbage(target_board: Array) -> int:
	var count := 0
	for y in ROWS:
		for x in COLS:
			if target_board[y][x] == "G":
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
	for base in _piece_shape(piece):
		var p: Vector2i = base
		for i in rot % 4:
			p = Vector2i(-p.y, p.x)
		if piece == "O":
			p = base
		cells.append(pos + p)
	return cells


func _piece_shape(piece: String) -> Array:
	if SIX_PACK_PIECES.has(piece):
		return SIX_PACK_PIECES[piece][0]
	return PIECES[piece][0]


func _ghost_pos() -> Vector2i:
	var ghost := active_pos
	while _can_place(active, ghost + Vector2i(0, 1), active_rot, board):
		ghost.y += 1
	return ghost


func _finish_game(message_key: String) -> void:
	result_key = message_key
	screen = Screen.GAME_OVER
	_play_sfx("win" if message_key == "you_win" or message_key == "board_cleared" else "game_over")
	_save_score()
	_update_history_ui()
	history_box.visible = true
	history_box.position = Vector2(910, 126)
	hint_label.text = _text("game_over_hint")


func _save_score() -> void:
	var entry := {
		"mode": int(mode),
		"difficulty": int(difficulty),
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
	header.text = _text("history")
	header.add_theme_font_size_override("font_size", 24)
	history_box.add_child(header)
	if history.is_empty():
		var empty := Label.new()
		empty.text = _text("no_scores")
		history_box.add_child(empty)
		return
	for i in min(history.size(), 8):
		var entry = history[i]
		var label := Label.new()
		label.text = "%d. %s  %d" % [i + 1, _history_entry_name(entry), int(entry.get("score", 0))]
		label.add_theme_font_size_override("font_size", 16)
		history_box.add_child(label)


func _update_labels() -> void:
	title_label.text = "DROP"
	stats_label.text = "%s\n%s %d\n%s %d\n%s %d\n%s %s" % [
		_mode_name(mode) + (" / " + _difficulty_name() if mode == Mode.MARATHON else ""),
		_text("score"),
		score,
		_text("lines"),
		lines,
		_text("level"),
		level,
		_text("hold"),
		hold_piece if not hold_piece.is_empty() else "-"
	]
	if mode == Mode.VERSUS:
		stats_label.text += "\n%s %d" % [_text("bot_lines"), bot_lines]
	hint_label.text = _text("play_hint")


func _draw() -> void:
	_draw_background()
	if screen == Screen.MENU:
		_draw_menu()
		return
	_draw_board(board, BOARD_ORIGIN, true)
	_draw_side_panel()
	if mode == Mode.VERSUS:
		_draw_bot_board(Vector2(950, 112), 16)
	if screen == Screen.PAUSED:
		if pause_quit_prompt:
			_draw_pause_quit_overlay()
		else:
			_draw_overlay(_text("paused"))
	elif screen == Screen.GAME_OVER:
		_draw_overlay(_text(result_key))


func _draw_background() -> void:
	var theme: Dictionary = _theme_data()
	var bg: Color = theme["bg"]
	var primary: Color = theme["glow_a"]
	var secondary: Color = theme["glow_b"]
	draw_rect(Rect2(Vector2.ZERO, size), bg)
	_draw_theme_background_image()
	draw_rect(Rect2(Vector2.ZERO, size), Color("#000000", 0.14))
	_draw_background_grid(theme)
	_draw_particle_sparks(primary, secondary)
	_draw_vignette()


func _draw_theme_background_image() -> void:
	var key: String = THEME_KEYS[theme_index]
	var texture: Texture2D = background_textures.get(key)
	if not texture:
		return
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale: float = max(size.x / texture_size.x, size.y / texture_size.y)
	var draw_size := texture_size * scale
	var draw_pos := (size - draw_size) * 0.5
	draw_texture_rect(texture, Rect2(draw_pos, draw_size), false)


func _draw_background_grid(theme: Dictionary) -> void:
	for y in range(0, int(size.y), 36):
		var alpha := 0.18 if y % 144 == 0 else 0.08
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(theme["grid"], alpha), 1.0)
	for x in range(0, int(size.x), 36):
		var alpha := 0.16 if x % 144 == 0 else 0.07
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(theme["grid_alt"], alpha), 1.0)
	for y in range(18, int(size.y), 72):
		draw_line(Vector2(0, y), Vector2(size.x, y - size.x * 0.08), Color(theme["grid"], 0.04), 1.0)


func _draw_glow_circle(center: Vector2, radius: float, color: Color) -> void:
	for i in range(7, 0, -1):
		var step := float(i) / 7.0
		draw_circle(center, radius * step, Color(color, color.a * 0.18 * (1.0 - step * 0.55)))


func _draw_neon_beam(start: Vector2, end: Vector2, color: Color, width: float) -> void:
	var direction := (end - start).normalized()
	var normal := Vector2(-direction.y, direction.x) * width
	draw_polygon([
		start - normal,
		start + normal,
		end + normal,
		end - normal
	], [color])
	draw_line(start, end, Color(color, min(color.a + 0.10, 0.22)), 2.0)


func _draw_background_blocks(primary: Color, secondary: Color) -> void:
	for i in BACKDROP_BLOCKS.size():
		var spec: Dictionary = BACKDROP_BLOCKS[i]
		var color := primary if i % 2 == 0 else secondary
		_draw_tetromino_silhouette(
			spec["piece"],
			Vector2(size.x * spec["pos"].x, size.y * spec["pos"].y),
			spec["size"],
			spec["rot"],
			Color(color, spec["alpha"])
		)


func _draw_tetromino_silhouette(piece: String, origin: Vector2, block_size: float, rotation: int, color: Color) -> void:
	for cell in _piece_cells(piece, Vector2i.ZERO, rotation):
		var rect := Rect2(origin + Vector2(cell.x, cell.y) * block_size, Vector2(block_size, block_size))
		draw_rect(rect.grow(-2.0), color)
		draw_rect(rect.grow(-2.0), Color(color, min(color.a * 1.8, 0.22)), false, 1.0)


func _draw_particle_sparks(primary: Color, secondary: Color) -> void:
	for i in 42:
		var x := fmod(float(i * 197 + theme_index * 53), 1000.0) / 1000.0 * size.x
		var y := fmod(float(i * 113 + theme_index * 97), 1000.0) / 1000.0 * size.y
		var color := primary if i % 2 == 0 else secondary
		var radius := 1.2 + float(i % 4) * 0.45
		draw_circle(Vector2(x, y), radius, Color(color, 0.16))


func _draw_vignette() -> void:
	var edge := Color("#000000", 0.22)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 22)), edge)
	draw_rect(Rect2(Vector2(0, size.y - 32), Vector2(size.x, 32)), edge)
	draw_rect(Rect2(Vector2.ZERO, Vector2(22, size.y)), edge)
	draw_rect(Rect2(Vector2(size.x - 22, 0), Vector2(22, size.y)), edge)


func _draw_menu() -> void:
	var theme := _theme_data()
	draw_string(get_theme_default_font(), Vector2(56, 180), _text("tagline"), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, theme["text"])
	draw_string(get_theme_default_font(), Vector2(56, 618), _text("mode_summary"), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, theme["muted"])


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


func _draw_bot_board(origin: Vector2, block_size: int) -> void:
	_draw_board(bot_board, origin, false, block_size)
	if bot_piece.is_empty() or screen == Screen.MENU:
		return
	var ghost := bot_pos
	while _can_place(bot_piece, ghost + Vector2i(0, 1), bot_rot, bot_board):
		ghost.y += 1
	for cell in _piece_cells(bot_piece, ghost, bot_rot):
		if cell.y >= 0:
			var ghost_rect := Rect2(origin + Vector2(cell.x * block_size, cell.y * block_size), Vector2(block_size, block_size))
			draw_rect(ghost_rect.grow(-2), Color(PALETTE[bot_piece], 0.12), false, 1.5)
	for cell in _piece_cells(bot_piece, bot_pos, bot_rot):
		if cell.y >= 0:
			var piece_rect := Rect2(origin + Vector2(cell.x * block_size, cell.y * block_size), Vector2(block_size, block_size))
			_draw_block(piece_rect, PALETTE[bot_piece])


func _draw_block(rect: Rect2, color: Color, muted: bool = false) -> void:
	var fill := color.darkened(0.25) if muted else color
	draw_rect(rect.grow(-2), fill)
	draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8, 5)), Color.WHITE if not muted else Color("#9aa5ba"), true)
	draw_rect(rect.grow(-2), Color("#ffffff", 0.25), false, 1.0)


func _draw_side_panel() -> void:
	var font := get_theme_default_font()
	var next_x := 720 if mode == Mode.VERSUS else 760
	draw_string(font, Vector2(next_x, 72), _text("next"), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#ffffff"))
	for i in min(5, next_queue.size()):
		_draw_mini_piece(next_queue[i], Vector2(next_x + 20, 112 + i * 76), 16)
	if mode == Mode.VERSUS:
		draw_string(font, Vector2(950, 72), _text("bot"), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#ffffff"))


func _draw_mini_piece(piece: String, origin: Vector2, mini: int) -> void:
	for cell in _piece_cells(piece, Vector2i.ZERO, 0):
		var rect := Rect2(origin + Vector2((cell.x + 2) * mini, (cell.y + 2) * mini), Vector2(mini, mini))
		_draw_block(rect, PALETTE[piece])


func _draw_overlay(text: String) -> void:
	var rect := Rect2(Vector2(360, 250), Vector2(560, 160))
	draw_rect(rect, Color("#090b13", 0.92))
	draw_rect(rect, PALETTE["O"], false, 3.0)
	draw_string(get_theme_default_font(), rect.position + Vector2(44, 70), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color("#ffffff"))
	draw_string(get_theme_default_font(), rect.position + Vector2(44, 112), "%s %d" % [_text("score"), score], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#dce7ff"))


func _draw_pause_quit_overlay() -> void:
	var rect := Rect2(Vector2(360, 240), Vector2(560, 190))
	draw_rect(rect, Color("#090b13", 0.94))
	draw_rect(rect, PALETTE["O"], false, 3.0)
	draw_string(get_theme_default_font(), rect.position + Vector2(44, 58), _text("quit_prompt"), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#ffffff"))
	var quit_rect := Rect2(rect.position + Vector2(54, 104), Vector2(200, 52))
	var play_rect := Rect2(rect.position + Vector2(306, 104), Vector2(200, 52))
	_draw_pause_choice(quit_rect, _text("quit"), pause_quit_choice == 0)
	_draw_pause_choice(play_rect, _text("play"), pause_quit_choice == 1)


func _draw_pause_choice(rect: Rect2, label: String, selected: bool) -> void:
	var fill := Color("#ffde59", 0.88) if selected else Color("#1a2136", 0.92)
	var text_color := Color("#11131a") if selected else Color("#ffffff")
	draw_rect(rect, fill)
	draw_rect(rect, Color("#ffffff", 0.35), false, 2.0)
	draw_string(get_theme_default_font(), rect.position + Vector2(0, 34), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 24, text_color)
