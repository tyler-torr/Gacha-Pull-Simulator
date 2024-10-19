# Banner.gd
extends Resource
class_name Banner


enum PullType { 
	CHARACTER, 
	WEAPON 
}
enum Rarity { FIVE_STAR, 
	FOUR_STAR, 
	THREE_STAR 
}

const GUARANTEED_CHANCE = 1.0
const COIN_FLIP_CHANCE = 0.5

@export_group("5-Star Characters")
@export_range(0.0, 1.0) var char_pull_rate: float
@export var char_soft_pity_start: int
@export_range(0.0, 1.0) var char_soft_pity_rate: float
@export var char_hard_pity: int
@export_range(0.0, 1.0) var char_fifty_fifty: float # According to 棵平衡樹, HSR's character banner has 56.4% odds to win

@export_group("5-Star Weapons")
@export_range(0.0, 1.0) var wep_pull_rate: float
@export var wep_soft_pity_start: int
@export_range(0.0, 1.0) var wep_soft_pity_rate: float
@export var wep_hard_pity: int
@export_range(0.0, 1.0) var wep_fifty_fifty: float

@export_group("4-Star Info")
@export_range(0.0, 1.0) var four_star_pull_rate: float
@export var four_star_soft_pity_start: int
@export_range(0.0, 1.0) var four_star_soft_pity_rate: float
@export var four_star_hard_pity: int
@export_range(0.0, 1.0) var four_star_fifty_fifty: float

@export_group("Currency & Gem Gain")
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
		chance = GUARANTEED_CHANCE
	elif pity >= soft_pity_start: # Reached soft pity (But not hard pity yet), chance is rising
		var pity_step: int = pity - soft_pity_start + 1
		chance += pity_step * soft_pity_rate
	return chance


# Roll to see if you get a 5* or 4* (Get a 3* if you miss)
func roll_rarity(five_star_odds: float, four_star_odds: float) -> Rarity:
	var roll = randf()
	if roll <= five_star_odds:
		return Rarity.FIVE_STAR
	elif roll <= (four_star_odds + five_star_odds):
		return Rarity.FOUR_STAR
	else:
		return Rarity.THREE_STAR


# Roll to see if you get a character or a weapon. Used for finding out how many gems are gained
# (Assuming you have max copies of all characters, you get more gems for characters)
func roll_type() -> PullType:
	var roll = randf() # Assuming there are an equal amount of characters and weapons in a game
	if roll <= COIN_FLIP_CHANCE:
		return PullType.CHARACTER
	else:
		return PullType.WEAPON


# Based on banner type, calculate odds of getting a 4* and 5*, then see what you get from a pull
func simulate_pull(pull_type: PullType, pity: int, four_star_pity: int) -> Rarity:
	var chance: float
	var four_star_chance: float = calculate_chance(four_star_pity, four_star_pull_rate, four_star_hard_pity,
			four_star_soft_pity_start, four_star_soft_pity_rate)
	match pull_type:
		PullType.CHARACTER:
			chance = calculate_chance(pity, char_pull_rate, char_hard_pity, char_soft_pity_start, char_soft_pity_rate)
		PullType.WEAPON:
			chance = calculate_chance(pity, wep_pull_rate, wep_hard_pity, wep_soft_pity_start, wep_soft_pity_rate)
	return roll_rarity(chance, four_star_chance)


# If a 4* or 5* is pulled, check whether they win the 50/50. If guarantee = true, 50/50 automatically wins
func fifty_fifty(pull_type: PullType, rarity: Rarity, guarantee: bool) -> bool:
	if guarantee:
		return true
	var chance: float
	match rarity:
		Rarity.FIVE_STAR:
			match pull_type:
				PullType.CHARACTER:
					chance = char_fifty_fifty
				PullType.WEAPON:
					chance = wep_fifty_fifty
		Rarity.FOUR_STAR:
			chance = four_star_fifty_fifty
	return chance >= randf()
