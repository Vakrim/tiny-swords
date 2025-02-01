class_name Tower
extends StaticBody2D

@export var team: Team

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
  sprite.texture = team.get_tower_texture()

  add_to_group(team.get_towers_group_name())
