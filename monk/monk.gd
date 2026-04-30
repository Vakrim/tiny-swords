# States:
#   IdleState            — ghosts present → WalkTowardGhostState; allies present → FollowAllyState
#   WalkTowardGhostState — HealArea overlaps ghost → HealState; no ghosts → IdleState
#   HealState            — plays heal anim + heal_effect on target; on finish → target.receive_healing(), IdleState
#   FollowAllyState      — follows nearest ally; ghosts appear → WalkTowardGhostState
#   Death                — queue_free(); tower respawns a new monk after 3 s
class_name Monk
extends RigidBody2D

@export var team: Team
@export var home_tower: Tower

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var heal_area: Area2D = $HealArea

var state: State = null
var health := 2

func _ready() -> void:
  sprite.sprite_frames = team.get_monk_sprite_frames()
  add_to_group(team.get_units_group_name())
  add_to_group(team.get_monks_group_name())
  change_state(IdleState.new())

func _physics_process(delta: float) -> void:
  state.update(delta)

func get_closest(group_name: String) -> Node2D:
  var entities = get_tree().get_nodes_in_group(group_name)
  var closest_entity = null
  var closest_distance = 1000000.0
  for entity in entities:
    if entity == self:
      continue
    var distance = global_position.distance_to(entity.global_position)
    if distance < closest_distance:
      closest_distance = distance
      closest_entity = entity
  return closest_entity

func receive_damage() -> void:
  health -= 1
  if health <= 0:
    if is_instance_valid(home_tower):
      home_tower.schedule_monk_spawn()
    queue_free()

func change_state(new_state: State) -> void:
  if state:
    state.exit()
  state = new_state
  state.init(self)
  state.enter()

class State:
  var actor: Monk = null

  func init(_actor: Monk) -> void:
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
    var ghosts = actor.get_tree().get_nodes_in_group(actor.team.get_ghosts_group_name())
    if ghosts.size() > 0:
      actor.change_state(WalkTowardGhostState.new())
    elif actor.get_closest(actor.team.get_units_group_name()) != null:
      actor.change_state(FollowAllyState.new())

class WalkTowardGhostState extends State:
  func enter() -> void:
    actor.sprite.play("walk")

  func update(_delta: float) -> void:
    var ghosts = actor.get_tree().get_nodes_in_group(actor.team.get_ghosts_group_name())
    if ghosts.size() == 0:
      actor.change_state(IdleState.new())
      return
    for ghost in ghosts:
      if actor.heal_area.overlaps_body(ghost):
        var heal_state = HealState.new()
        heal_state.target = ghost
        actor.change_state(heal_state)
        return
    var ghost = actor.get_closest(actor.team.get_ghosts_group_name())
    if ghost:
      var direction = (ghost.global_position - actor.global_position).normalized()
      actor.apply_central_force(direction * 100)
      actor.sprite.flip_h = direction.x < 0

class HealState extends State:
  var target: Node2D = null

  func enter() -> void:
    actor.sprite.play("heal")
    actor.sprite.connect("animation_finished", _on_animation_finished, CONNECT_ONE_SHOT)
    if is_instance_valid(target):
      var effect = AnimatedSprite2D.new()
      effect.sprite_frames = actor.sprite.sprite_frames
      effect.position = Vector2(0, -32)
      effect.connect("animation_finished", effect.queue_free, CONNECT_ONE_SHOT)
      target.add_child(effect)
      effect.play("heal_effect")

  func _on_animation_finished() -> void:
    if is_instance_valid(target):
      target.receive_healing()
    actor.change_state(IdleState.new())

class FollowAllyState extends State:
  func enter() -> void:
    actor.sprite.play("walk")

  func update(_delta: float) -> void:
    var ghosts = actor.get_tree().get_nodes_in_group(actor.team.get_ghosts_group_name())
    if ghosts.size() > 0:
      actor.change_state(WalkTowardGhostState.new())
      return
    var ally = actor.get_closest(actor.team.get_units_group_name())
    if ally:
      var direction = (ally.global_position - actor.global_position).normalized()
      actor.apply_central_force(direction * 80)
      actor.sprite.flip_h = direction.x < 0
    else:
      actor.change_state(IdleState.new())
