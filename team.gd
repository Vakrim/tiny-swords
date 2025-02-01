class_name Team

enum Hue {BLUE, RED}

static func get_team_name(team: Hue) -> String:
    match team:
        Hue.BLUE: return "blue"
        Hue.RED: return "red"
        _:
            assert(false, "Invalid team")
            return "unknown"

static func get_enemy_team_name(team: Hue) -> String:
    match team:
        Hue.BLUE: return "red"
        Hue.RED: return "blue"
        _:
            assert(false, "Invalid team")
            return "unknown"

const BLUE = Hue.BLUE
const RED = Hue.RED
