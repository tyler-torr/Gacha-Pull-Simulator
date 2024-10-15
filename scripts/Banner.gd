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


# Calculate the chance of getting a 4* or 5*
func calculate_chance(pity: int, pull_rate: float, hard_pity: int, soft_pity_start: int, 
		soft_pity_rate: float) -> float:
	var chance = pull_rate
	if pity >= hard_pity: # Reached hard pity, chance is guaranteed
		return 1.0
	elif pity >= soft_pity_start: # Reached soft pity (But not hard pity yet), chance is rising
		var pity_step: int = pity - soft_pity_start + 1
		return chance + (pity_step * soft_pity_rate)
	else: # Base chance
		return chance


# Roll to see if you get a 5* or 4* (Get a 3* if you miss)
func roll_rarity(five_star_odds: float, four_star_odds: float) -> String:
	var roll = randf()
	if roll <= five_star_odds:
		return "5-STAR"
	elif roll <= four_star_odds:
		return "4-STAR"
	else:
		return "3-STAR"


# Roll to see if you get a character or a weapon. Used for finding out how many gems are gained
# (Assuming you have max copies of all characters, you get more gems for characters)
func roll_type() -> String:
	var roll = randf() # Assuming there are an equal amount of characters and weapons in a game
	if roll <= 0.5:
		return "CHARACTER"
	else:
		return "WEAPON"


# Based on banner type, calculate odds of getting a 4* and 5*, then see what you get from a pull
func simulate_pull(banner_type: String, pity: int, four_star_pity: int) -> String:
	var chance: float
	var four_star_chance: float
	
	match banner_type:
		"CHARACTER":
			chance = calculate_chance(pity, char_pull_rate, char_hard_pity, char_soft_pity_start, char_soft_pity_rate)
		"WEAPON":
			chance = calculate_chance(pity, wep_pull_rate, wep_hard_pity, wep_soft_pity_start, wep_soft_pity_rate)
	
	four_star_chance = calculate_chance(four_star_pity, four_star_pull_rate, four_star_hard_pity,
			four_star_soft_pity_start, four_star_soft_pity_rate)
	
	return roll_rarity(chance, four_star_chance)


# If a 4* or 5* is pulled, check whether they win the 50/50. If guarantee = true, 50/50 automatically wins
func fifty_fifty(pull_type: String, rarity: String, guarantee: bool) -> bool:
	var chance: float
	match rarity:
		"5-STAR":
			if pull_type == "CHARACTER":
				chance = char_fifty_fifty
			elif pull_type == "WEAPON":
				chance = wep_fifty_fifty
		"4-STAR":
			chance = wep_fifty_fifty
	return guarantee or chance >= randf()
