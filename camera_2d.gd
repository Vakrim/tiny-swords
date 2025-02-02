extends Camera2D

@export var teams: Array[Team] = []

func _process(_delta: float) -> void:
    var units: Array = []

    for team in teams:
        units += get_tree().get_nodes_in_group(team.get_units_group_name())

    if units.size() == 0:
        return

    var center = Vector2.ZERO

    for unit in units:
        center += unit.global_position

    center /= units.size()

    global_position = center
