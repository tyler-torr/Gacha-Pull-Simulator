extends Control


const HSR_BANNER = {
	"CHARACTER": {
		"FIVE_STAR_RATE": 0.006,
		"SOFT_PITY": 74,
		"HARD_PITY": 90,
		"FIFTY_FIFTY": 0.564 # According to 棵平衡樹, HSR's character banner actually has 56.4% odds of winning a 5*
	},
	"WEAPON": {
		"FIVE_STAR_RATE": 0.008,
		"SOFT_PITY": 64, # Temporary
		"HARD_PITY": 80,
		"FIFTY_FIFTY": 0.75
	}
}

var banner = HSR_BANNER

@onready var desired_five_stars_input = $FiveStarCharacterInput
@onready var desired_five_star_weapons_input = $FiveStarWeaponInput
@onready var available_pulls_input = $AvailablePullsInput
@onready var available_gems_input = $AvailableGemsInput
@onready var simulation_runs_input = $SimulationRunsInput
@onready var character_guarantee_input = $CharacterGuaranteeInput
@onready var weapon_guarantee_input = $WeaponGuaranteeInput


func ready() -> void:
	pass


func pull_character(banner: Dictionary, pity: int) -> bool:
	var current_pull_rate = banner["CHARACTER"]["FIVE_STAR_RATE"]
	
	if pity >= banner["CHARACTER"]["HARD_PITY"]:
		current_pull_rate = 1.0
	elif pity >= banner["CHARACTER"]["SOFT_PITY"]:
		current_pull_rate += 0.06 * (pity - banner["SOFT_PITY"] + 1)
	
	current_pull_rate = clamp(current_pull_rate, banner["CHARACTER"]["FIVE_STAR_RATE"], 1.0) # Necessary?
	return current_pull_rate >= randf()


func pull_weapon(banner: Dictionary, pity: int) -> bool:
	var current_pull_rate = banner["WEAPON"]["FIVE_STAR_RATE"]
	
	if pity >= banner["WEAPON"]["HARD_PITY"]:
		current_pull_rate = 1.0
	elif pity >= banner["WEAPON"]["SOFT_PITY"]:
		current_pull_rate += 0.06 * (pity - banner["SOFT_PITY"] + 1)
	
	current_pull_rate = clamp(current_pull_rate, banner["WEAPON"]["FIVE_STAR_RATE"], 1.0) # Necessary?
	return current_pull_rate >= randf()


# Check whether the 50/50 is won or not
func fifty_fifty(banner: Dictionary, guarantee: bool) -> bool:
	return guarantee or randf() <= banner["FIFTY_FIFTY"]


func simulate_pulls(banner: Dictionary, desired_five_stars: int, available_pulls: int, simulation_runs: int,
		character_guarantee: bool, weapon_guarantee: bool) -> float:
	var total_success = 0
	
	for i in range(simulation_runs):
		var characters_pulled = 0
		var remaining_pulls = available_pulls
		var pity = 0
		var current_character_guarantee = character_guarantee
		
		while remaining_pulls != 0:
			remaining_pulls -= 1
			
			if pull_character(banner, pity):
				pity = 0
				if fifty_fifty(banner, current_character_guarantee):
					current_character_guarantee = false
					characters_pulled += 1
					if characters_pulled >= desired_five_stars:
						total_success += 1
						break
				else:
					current_character_guarantee = true
			else:
				pity += 1
	
	return float(total_success) / float(simulation_runs)


func _on_run_button_pressed() -> void:
	var desired_five_stars = int(desired_five_stars_input.value)
	var available_pulls = int(available_pulls_input.value)
	var available_gems = int(available_gems_input.value)
	var simulation_runs = int(simulation_runs_input.value)
	var character_guarantee = character_guarantee_input.is_pressed()
	var weapon_guarantee = weapon_guarantee_input.is_pressed()
	
	available_pulls += (available_gems / 160)
	
	var average_success = simulate_pulls(desired_five_stars, available_pulls, simulation_runs, character_guarantee,
			weapon_guarantee)
	
	$ResultLabel.text = "Success rate: " + str(average_success * 100) + "%"
