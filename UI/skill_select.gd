class_name SkillSelect extends VBoxContainer

const HORIZONTAL_OPTIONS : int = 2
const VERTICAL_OPTIONS : int = 3

const BUTTON_SIZE : int = 32
@warning_ignore("integer_division")
const CURSOR_OFFSET : Vector2 = Vector2(BUTTON_SIZE / 2, BUTTON_SIZE / 2)

@onready var hbox_light: HBoxContainer = $HBoxContainerLight
@onready var hbox_heavy: HBoxContainer = $HBoxContainerHeavy
@onready var hbox_charge: HBoxContainer = $HBoxContainerCharge

@onready var light1: TextureButton = $HBoxContainerLight/P1Light1
@onready var light2: TextureButton = $HBoxContainerLight/P1Light2
@onready var heavy1: TextureButton = $HBoxContainerHeavy/P1Heavy1
@onready var heavy2: TextureButton = $HBoxContainerHeavy/P1Heavy2
@onready var charge1: TextureButton = $HBoxContainerCharge/P1Charge1
@onready var charge2: TextureButton = $HBoxContainerCharge/P1Charge2

@onready var selectors: Node = $Selectors
@onready var select_light: AnimatedSprite2D = $Selectors/SelectP1Light
@onready var select_heavy: AnimatedSprite2D = $Selectors/SelectP1Heavy
@onready var select_charge: AnimatedSprite2D = $Selectors/SelectP1Charge
@onready var cursor: AnimatedSprite2D = $Selectors/CursorP1

var light_selected : int = 1
var heavy_selected : int = 1
var charge_selected : int = 1

@export var right_input : String = "right1"
@export var left_input : String = "left1"
@export var up_input : String = "up1"
@export var down_input : String = "down1"
@export var select_input : String = "light1"

@export var internal_alignment : AlignmentMode = AlignmentMode.ALIGNMENT_BEGIN

var cursor_position : Vector2i = Vector2i(1,1)

func _ready() -> void:
	for sp in selectors.get_children():
		sp.play("default")
	
	hbox_light.alignment = self.internal_alignment
	hbox_heavy.alignment = self.internal_alignment
	hbox_charge.alignment = self.internal_alignment
	
	await get_tree().create_timer(0.1).timeout
	update_selections_global_position()
	update_cursor_global_position()
	
#@warning_ignore("shadowed_variable")
#func initialize(right_input: String, left_input: String, up_input: String, down_input: String, select_input: String, alignment: AlignmentMode = AlignmentMode.ALIGNMENT_BEGIN):
	#self.select_input = select_input
	#self.left_input = left_input
	#self.up_input = up_input
	#self.right_input = right_input
	#self.down_input = down_input
	#
	#self.alignment = alignment

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed(left_input) and cursor_position.x > 1:
		cursor_position.x -= 1
		update_cursor_global_position()
	if Input.is_action_just_pressed(right_input) and cursor_position.x < HORIZONTAL_OPTIONS:
		cursor_position.x += 1
		update_cursor_global_position()
	if Input.is_action_just_pressed(up_input) and cursor_position.y > 1:
		cursor_position.y -= 1
		update_cursor_global_position()
	if Input.is_action_just_pressed(down_input) and cursor_position.y < VERTICAL_OPTIONS:
		cursor_position.y += 1
		update_cursor_global_position()
	
	if Input.is_action_just_pressed(select_input): # Update selection
		update_selection_from_cursor_position()
		update_selections_global_position()

func update_selection_from_cursor_position() -> void:
	match cursor_position:
		Vector2i(1,1):
			light_selected = 1
		Vector2i(2,1):
			light_selected = 2
		Vector2i(1,2):
			heavy_selected = 1
		Vector2i(2,2):
			heavy_selected = 2
		Vector2i(1,3):
			charge_selected = 1
		Vector2i(2,3):
			charge_selected = 2

func update_cursor_global_position() -> void:
	match cursor_position:
		Vector2i(1,1):
			cursor.global_position = light1.global_position
		Vector2i(2,1):
			cursor.global_position = light2.global_position
		Vector2i(1,2):
			cursor.global_position = heavy1.global_position
		Vector2i(2,2):
			cursor.global_position = heavy2.global_position
		Vector2i(1,3):
			cursor.global_position = charge1.global_position
		Vector2i(2,3):
			cursor.global_position = charge2.global_position
	
	cursor.global_position += CURSOR_OFFSET

func update_selections_global_position() -> void:
	select_light.global_position = (light1.global_position if light_selected == 1 else light2.global_position) + CURSOR_OFFSET
	select_heavy.global_position = (heavy1.global_position if heavy_selected == 1 else heavy2.global_position) + CURSOR_OFFSET
	select_charge.global_position = (charge1.global_position if charge_selected == 1 else charge2.global_position) + CURSOR_OFFSET
