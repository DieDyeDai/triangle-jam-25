class_name SkillSelectMenu extends Control

@onready var skillselect1: SkillSelect = $VBoxContainer/HBoxContainer/SkillSelect1
@onready var skillselect2: SkillSelect = $VBoxContainer/HBoxContainer/SkillSelect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		Globals.p1_skills[Globals.SKILLS.LIGHT] = skillselect1.light_selected
		Globals.p1_skills[Globals.SKILLS.HEAVY] = skillselect1.heavy_selected
		Globals.p1_skills[Globals.SKILLS.CHARGE] = skillselect1.charge_selected
		Globals.p2_skills[Globals.SKILLS.LIGHT] = skillselect2.light_selected
		Globals.p2_skills[Globals.SKILLS.HEAVY] = skillselect2.heavy_selected
		Globals.p2_skills[Globals.SKILLS.CHARGE] = skillselect2.charge_selected
		
		
	
		Globals.scene_switcher.handle_scene_change({"next_scene": preload("res://World/Grid.tscn")})
		print("---")
		print(skillselect1.light_selected)
		print(skillselect1.heavy_selected)
		print(skillselect1.charge_selected)
		print(skillselect2.light_selected)
		print(skillselect2.heavy_selected)
		print(skillselect2.charge_selected)
		print(str(Globals.p1_skills))
		print(str(Globals.p2_skills))
		
		
	if Input.is_action_just_pressed("back"):
		Globals.scene_switcher.handle_scene_change({"next_scene": preload("res://UI/SkillSelectMenu.tscn")})
