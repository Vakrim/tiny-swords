class_name Team
extends Resource

enum Hue {BLUE, RED}

@export var hue: Hue = BLUE

func get_team_name() -> String:
  match hue:
    BLUE: return "blue"
    RED: return "red"
    _:
      assert(false, "Invalid team")
      return "unknown"

func get_enemy_team_name() -> String:
  match hue:
    BLUE: return "red"
    RED: return "blue"
    _:
      assert(false, "Invalid team")
      return "unknown"


func get_units_group_name() -> String:
  return get_team_name() + "_units"

func get_enemy_units_group_name() -> String:
  return get_enemy_team_name() + "_units"

func get_towers_group_name() -> String:
  return get_team_name() + "_towers"

func get_knight_sprite_frames():
  match hue:
    BLUE: return preload("res://knight/knight-blue.tres")
    RED: return preload("res://knight/knight-red.tres")
    _:
      assert(false, "Invalid team")
      return null

func get_tower_texture():
  match hue:
    BLUE: return preload("res://tower/tower-blue.png")
    RED: return preload("res://tower/tower-red.png")
    _:
      assert(false, "Invalid team")
      return null

const BLUE = Hue.BLUE
const RED = Hue.RED
