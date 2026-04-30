class_name Tower
extends StaticBody2D

@export var team: Team
@export var monk_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
  sprite.texture = team.get_tower_texture()
  add_to_group(team.get_towers_group_name())
  spawn_monk()

func spawn_monk() -> void:
  if not monk_scene:
    return
  var monk = monk_scene.instantiate()
  monk.team = team
  monk.home_tower = self
  monk.global_position = global_position
  get_parent().add_child.call_deferred(monk)

func schedule_monk_spawn() -> void:
  await get_tree().create_timer(3.0).timeout
  spawn_monk()
