class_name Tower
extends Node2D

@export var team := Team.RED

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
    if team == Team.RED:
        sprite.texture = preload("res://tower/tower-red.png")
    else:
        sprite.texture = preload("res://tower/tower-blue.png")
