# Banner.gd
extends Resource
class_name Banner


@export var char_pull_rate: float
@export var char_soft_pity_start: int
@export var char_soft_pity_rate: float
@export var char_hard_pity: int
@export var char_fifty_fifty: float # According to 棵平衡樹, HSR's character banner has 56.4% odds to win

@export var wep_pull_rate: float
@export var wep_soft_pity_start: int
@export var wep_soft_pity_rate: float
@export var wep_hard_pity: int
@export var wep_fifty_fifty: float

@export var four_star_pull_rate: float
@export var four_star_soft_pity_start: int
@export var four_star_soft_pity_rate: float
@export var four_star_hard_pity: int
@export var four_star_fifty_fifty: float

@export var currency_conversion_rate: int

@export var gem_conversion_rate: int
@export var gem_4_star_gain: int
@export var gem_4_star_excess_gain: int
@export var gem_5_star_gain: int


func calculate_chance(pity: int, pull_rate: float, hard_pity: int, soft_pity_start: int,
		soft_pity_rate: float) -> float:
	var chance = pull_rate
	if pity >= hard_pity:
		return 1.0
	elif pity >= soft_pity_start:
		var pity_step: int = pity - soft_pity_start + 1
		return chance + (pity_step * soft_pity_rate)
	else:
		return chance


func simulate_pull(banner_type: String, pity: int, four_star_pity: int) -> String:
	var chance: float
	var four_star_chance: float = four_star_pull_rate
	var roll: float
	
	match banner_type:
		"CHARACTER":
			chance = calculate_chance(pity, char_pull_rate, char_hard_pity, char_soft_pity_start, char_soft_pity_rate)
			
		"WEAPON":
			chance = calculate_chance(pity, wep_pull_rate, wep_hard_pity, wep_soft_pity_start, wep_soft_pity_rate)
	
	four_star_chance = calculate_chance(four_star_pity, four_star_pull_rate, four_star_hard_pity,
			four_star_soft_pity_start, four_star_soft_pity_rate)
	
	roll = randf()
	if chance >= roll:
		return "5-STAR"
	elif four_star_chance >= roll:
		return "4-STAR"
	else:
		return "3-STAR"


func fifty_fifty(pull_type: String, guarantee: bool) -> bool:
	var chance: float
	match pull_type:
		"CHARACTER":
			chance = char_fifty_fifty
		"WEAPON":
			chance = wep_fifty_fifty
		"4-STAR":
			chance = four_star_fifty_fifty
	return guarantee or chance >= randf()
