@tool
extends WeaponData
class_name ShieldWeaponData

# I don't think we need this with the new shield attacks

enum SHIELD_STATE{DOWN, RAISING_SHIELD, HOLDING_SHIELD, N_ENUM}

@export var state: SHIELD_STATE = SHIELD_STATE.DOWN
@export var just_raised: bool = false
