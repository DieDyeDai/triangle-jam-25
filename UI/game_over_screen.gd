class_name GameOverScreen extends Control

@onready var p1_win_label: Label = $VBoxContainer/HBoxContainer/p1WinLabel
@onready var p2_win_label: Label = $VBoxContainer/HBoxContainer/p2WinLabel
@onready var score_text_label: Label = $VBoxContainer/ScoreTextLabel
@onready var score_number_label: Label = $VBoxContainer/ScoreNumberLabel
@onready var restart_text_label: Label = $VBoxContainer/RestartTextLabel

var is_playing : bool = false

func on_win(p1win : bool, p2win: bool) -> void:
	is_playing = true
	await get_tree().create_timer(1.0, true).timeout
	show_win_text(p1win, p2win)
	await get_tree().create_timer(0.5, true).timeout
	score_text_label.visible = true
	await get_tree().create_timer(0.5, true).timeout
	score_number_label.visible = true
	score_number_label.text = str(Globals.p1score) + " - " + str(Globals.p2score)
	restart_text_label.visible = true
	is_playing = false

func show_win_text(p1win : bool, p2win: bool) -> void:
	if p1win:
		p1_win_label.visible = true
	elif p2win:
		p2_win_label.visible = true

func reset() -> void:
	p1_win_label.visible = false
	p2_win_label.visible = false
	score_text_label.visible = false
	score_number_label.visible = false
	restart_text_label.visible = false
	is_playing = false
