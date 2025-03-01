class_name SceneSwitcherMinimal
extends Node

signal done_loading

var current_scene_resource : PackedScene = preload("res://World/Grid.tscn")
var next_scene_resource : PackedScene
var current_scene : Node
var next_scene : Node

var starting_scene : Node

var transition_data : Dictionary = {}

@onready var animation_player = $AnimationPlayer

## Load main menu, connect to scene change signals, and fade in.
func _ready():
	
	starting_scene = current_scene_resource.instantiate()
	
	update_last_scene_change({})
	
	add_child(starting_scene)
	current_scene = starting_scene

	animation_player.play("fade_in")

## Takes in a dict of argument
@warning_ignore("shadowed_variable")
func handle_scene_change(transition_data: Dictionary):
	update_last_scene_change(transition_data)
	
	animation_player.play("fade_out")


func _on_animation_player_animation_finished(anim_name):
	match(anim_name):
		"fade_out":
			
			# On finishing the fadeout, load the next scene and unload the current scene.
			next_scene_resource = transition_data["next_scene"]
			if next_scene_resource:
				next_scene = next_scene_resource.instantiate()
				current_scene_resource = transition_data["next_scene"]
			else:
				#print("Next scene not found. Reloading current scene")
				next_scene = current_scene_resource.instantiate()
			
			current_scene.queue_free()
			
			current_scene = next_scene
			
			add_child(current_scene)
			
			animation_player.play("fade_in")
	
		"fade_in":
			animation_player.play("fade_in2")
		
		"fade_in2":
			done_loading.emit()

@warning_ignore("shadowed_variable")
func update_last_scene_change(transition_data: Dictionary):
	self.transition_data = transition_data
