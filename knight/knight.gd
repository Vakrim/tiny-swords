class_name Knight
extends RigidBody2D

@export var team: Team

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attack_area: Area2D = $AttackArea
@onready var healing_area: Area2D = $HealingArea

var state: State = null

var health = 3

func _ready() -> void:
  sprite.sprite_frames = team.get_knight_sprite_frames()

  add_to_group(team.get_units_group_name())

  change_state(IdleState.new())

func _physics_process(delta: float) -> void:
  state.update(delta)

func get_closest(group_name: String) -> Node2D:
  var entities = get_tree().get_nodes_in_group(group_name)
  var closest_entity = null
  var closest_distance = 1000000

  for entity in entities:
    var distance = global_position.distance_to(entity.global_position)
    if distance < closest_distance:
      closest_distance = distance
      closest_entity = entity

  return closest_entity

func receive_damage() -> void:
  change_state(StunState.new())
  health -= 1
  if health <= 0:
    change_state(GhostState.new())

func receive_healing() -> void:
  health = 3
  change_state(IdleState.new())

func change_state(new_state: State) -> void:
  if state:
    state.exit()
  state = new_state
  state.init(self)
  state.enter()

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
    var enemies = actor.get_tree().get_nodes_in_group(actor.team.get_enemy_units_group_name())
    if enemies.size() > 0:
      actor.change_state(WalkTowardEnemyState.new())

class WalkTowardEnemyState extends State:
  func enter() -> void:
    actor.sprite.play("walk")

  func update(_delta: float) -> void:
    var enemies = actor.get_tree().get_nodes_in_group(actor.team.get_enemy_units_group_name())

    for enemy in enemies:
      if actor.attack_area.overlaps_body(enemy):
        actor.change_state(AttackState.new())

    var enemy = actor.get_closest(actor.team.get_enemy_units_group_name())
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
      var enemies = actor.get_tree().get_nodes_in_group(actor.team.get_enemy_units_group_name())

      for enemy: Knight in enemies:
        if actor.attack_area.overlaps_body(enemy):
          var push_back_impulse = (enemy.global_position - actor.global_position).normalized() * 300

          enemy.apply_central_impulse(push_back_impulse)
          enemy.receive_damage()

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

class GhostState extends State:
  func enter() -> void:
    actor.sprite.play("walk")
    actor.sprite.material = ShaderMaterial.new()
    actor.sprite.material.shader = preload("res://knight/ghost.gdshader")
    actor.healing_area.connect("body_entered", _on_body_entered)

  func exit() -> void:
    actor.sprite.material = null

  func update(_delta: float) -> void:
    var tower = actor.get_closest(actor.team.get_towers_group_name())

    if tower:
      var direction = (tower.global_position - actor.global_position).normalized()

      actor.apply_central_force(direction * 100)

      actor.sprite.flip_h = direction.x < 0
      actor.attack_area.scale.x = -1 if direction.x < 0 else 1

  func _on_body_entered(body: Node) -> void:
    if body.is_in_group(actor.team.get_towers_group_name()):
      actor.receive_healing()
