extends Resource
class_name Banner

@export var character_pity: int
@export var weapon_pity: int
@export var gem_conversion_rate: int

@export var prem_char_soft_pity: int # 
@export var soft_pity_rate: float
@export var hard_pity: int
@export var 

@export var five_star_rate: float
@export var weapon_five_star_rate: float

const HSR_BANNER = {
	"CHARACTER": {
		"PULL_RATE": 0.006,
		"PITY_RATE": 0.06,
		"SOFT_PITY_START": 74,
		"HARD_PITY": 90, # According to 棵平衡樹, HSR's character banner has 56.4% odds to win
		"FIFTY_FIFTY": 0.564
	},
	"WEAPON": {
		"PULL_RATE": 0.008,
		"PITY_RATE": 0.08,
		"SOFT_PITY_START": 63,
		"HARD_PITY": 80,
		"FIFTY_FIFTY": 0.75
	},
	"4-STAR": {
		"PULL_RATE": 0.051,
		"PITY_RATE": 0.00, # Unknown value
		"SOFT_PITY_START": 8, # Unknown value
		"HARD_PITY": 10,
		"FIFTY_FIFTY": 0.5
	},
	"OTHER": {
		"GEM_CONVERSION_RATE": 20,
		"4-STAR_GEM_GAIN": 8,
		"4-STAR_EXCESS_GEM_GAIN": 20,
		"5-STAR_GEM_GAIN": 40
	}
}

func reset():
	character_pity = 0
	weapon_pity = 0
