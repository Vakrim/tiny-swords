class_name Knight
extends RigidBody2D

enum Team {BLUE, RED}

@export var team = Team.BLUE

@onready var sprite = $Sprite as AnimatedSprite2D
@onready var attack_area = $AttackArea as Area2D

var state: State = null

func _ready() -> void:
  if team == Team.RED:
    sprite.sprite_frames = load("res://knight/knight-red.tres")
  else:
    sprite.sprite_frames = load("res://knight/knight-blue.tres")

  add_to_group(get_my_team_group_name())

  change_state(IdleState.new())

func _physics_process(delta: float) -> void:
  state.update(delta)

func get_closest_enemy() -> Node2D:
  var enemies = get_tree().get_nodes_in_group(get_enemy_team_group_name())
  var closest_enemy = null
  var closest_distance = 1000000

  for enemy in enemies:
    var distance = global_position.distance_to(enemy.global_position)
    if distance < closest_distance:
      closest_distance = distance
      closest_enemy = enemy

  return closest_enemy

func change_state(new_state: State) -> void:
  if state:
    state.exit()
  state = new_state
  state.init(self)
  state.enter()

func get_my_team_group_name() -> String:
  var team_name
  match team:
    Team.BLUE: team_name = "blue"
    Team.RED: team_name = "red"

  return "team_" + team_name

func get_enemy_team_group_name() -> String:
  var enemy_team_name
  match team:
    Team.BLUE: enemy_team_name = "red"
    Team.RED: enemy_team_name = "blue"

  return "team_" + enemy_team_name

class State:
  var actor: Knight = null

  func init(_actor: Knight) -> void:
    actor = _actor

  func enter() -> void:
    pass

  func exit() -> void:
    pass

  func update(_delta: float) -> void:
    pass

class IdleState extends State:
  func enter() -> void:
    actor.sprite.play("idle")

  func update(_delta: float) -> void:
    var enemies = actor.get_tree().get_nodes_in_group(actor.get_enemy_team_group_name())
    if enemies.size() > 0:
      actor.change_state(WalkTowardEnemyState.new())

class WalkTowardEnemyState extends State:
  func enter() -> void:
    actor.sprite.play("walk")

  func update(_delta: float) -> void:
    var enemies = actor.get_tree().get_nodes_in_group(actor.get_enemy_team_group_name())

    for enemy in enemies:
      if actor.attack_area.overlaps_body(enemy):
        actor.change_state(AttackState.new())

    var enemy = actor.get_closest_enemy()
    if enemy:
      var direction = (enemy.global_position - actor.global_position).normalized()

      actor.apply_central_force(direction * 100)

      actor.sprite.flip_h = direction.x < 0
      actor.attack_area.scale.x = -1 if direction.x < 0 else 1
    else:
      actor.change_state(IdleState.new())

class AttackState extends State:
  func enter() -> void:
    actor.sprite.play("attack" if randi() % 2 == 0 else "attack2")

    actor.sprite.connect("frame_changed", _on_frame_changed)
    actor.sprite.connect("animation_finished", _on_animation_finished)

  func _on_frame_changed() -> void:
    if actor.sprite.frame == 3:
      var enemies = actor.get_tree().get_nodes_in_group(actor.get_enemy_team_group_name())

      for enemy: Knight in enemies:
        if actor.attack_area.overlaps_body(enemy):
          var push_back_impulse = (enemy.global_position - actor.global_position).normalized() * 1300

          enemy.apply_central_impulse(push_back_impulse)
          enemy.change_state(StunState.new())

  func _on_animation_finished() -> void:
    actor.change_state(IdleState.new())

class StunState extends State:
  var duration: float = 0.5

  func enter() -> void:
    actor.sprite.rotation_degrees = 15 if randi() % 2 == 0 else -15

  func exit() -> void:
    actor.sprite.rotation_degrees = 0

  func update(delta: float) -> void:
    duration -= delta
    if duration <= 0:
      actor.change_state(IdleState.new())
