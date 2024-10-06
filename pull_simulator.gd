extends Control


const HSR_BANNER = {
	"base_pull_rate": 0.006,
	"soft_pity_start": 74,
	"hard_pity": 90,
	"premium_chance": 0.564, # According to 棵平衡樹, HSR's character banner has 56.4% odds to win
	"wep_base_pull_rate": 0.008,
	"wep_soft_pity_start": 63, # Temporary value
	"wep_hard_pity": 80,
	"wep_premium_chance": 0.75
}

var banner = HSR_BANNER

@onready var available_pulls_input = $AvailablePullsInput
@onready var available_currency_input = $AvailableCurrencyInput
@onready var simulation_runs_input = $SimulationRunsInput
@onready var desired_five_stars_input = $FiveStarCharacterInput
@onready var character_pity_input = $CharacterPityInput
@onready var guarantee_input = $GuaranteeInput
@onready var desired_five_star_weapons_input = $FiveStarWeaponInput
@onready var weapon_pity_input = $WeaponPityInput
@onready var weapon_guarantee_input = $WeaponGuaranteeInput


func ready() -> void:
	pass


func pull(pity: int) -> bool:
	var current_pull_rate = banner["base_pull_rate"]
	
	if pity == banner["hard_pity"]:
		current_pull_rate = 1.0
	elif pity >= banner["soft_pity_start"]:
		current_pull_rate += 0.06 * (pity - banner["soft_pity_start"] + 1)
	
	return current_pull_rate >= randf()


func wep_pull(pity: int) -> bool:
	var current_pull_rate = banner["wep_base_pull_rate"]
	
	if pity == banner["wep_hard_pity"]:
		current_pull_rate = 1.0
	elif pity >= banner["wep_soft_pity_start"]:
		current_pull_rate += 0.08 * (pity - banner["wep_soft_pity_start"] + 1)
	
	return current_pull_rate >= randf()


func fifty_fifty(guarantee: bool) -> bool:
	return guarantee or randf() <= banner["premium_chance"]


func wep_fifty_fifty(guarantee: bool) -> bool:
	return guarantee or randf() <= banner["wep_premium_chance"]


func simulate_pulls(available_pulls: int, simulation_runs: int, desired_five_stars: int, character_pity: int,
		guarantee: bool, desired_five_star_weapons: int, weapon_pity: int, weapon_guarantee: bool) -> float:
	var total_success = 0
	
	for i in range(simulation_runs):
		var five_stars_pulled = 0
		var weapons_pulled = 0
		var remaining_pulls = available_pulls
		var pity = character_pity
		var wep_pity = weapon_pity
		var current_guarantee = guarantee
		var wep_guarantee = weapon_guarantee
		
		while remaining_pulls > 0:
			remaining_pulls -= 1
			
			# Character banners
			if five_stars_pulled < desired_five_stars:
				if pull(pity):
					pity = 0
					if fifty_fifty(current_guarantee):
						current_guarantee = false
						five_stars_pulled += 1
					else:
						current_guarantee = true
				else:
					pity += 1
			
			# Weapon banners
			elif weapons_pulled < desired_five_star_weapons:
				if wep_pull(wep_pity):
					wep_pity = 0
					if wep_fifty_fifty(wep_guarantee):
						current_guarantee = false
						weapons_pulled += 1
					else:
						current_guarantee = true
				else:
					wep_pity += 1
		
		if (five_stars_pulled >= desired_five_stars) and (weapons_pulled >= desired_five_star_weapons):
			total_success += 1
	
	return float(total_success) / float(simulation_runs)


func _on_run_button_pressed() -> void:
	var available_pulls = int(available_pulls_input.value)
	var available_currency = int(available_currency_input.value)
	var simulation_runs = int(simulation_runs_input.value)
	var desired_five_stars = int(desired_five_stars_input.value)
	var character_pity = int(character_pity_input.value)
	var guarantee = guarantee_input.is_pressed()
	var desired_five_star_weapons = int(desired_five_star_weapons_input.value)
	var weapon_pity = int(weapon_pity_input.value)
	var weapon_guarantee = weapon_guarantee_input.is_pressed()
	
	available_pulls += (available_currency / 160)
	
	var average_success = simulate_pulls(available_pulls, simulation_runs, desired_five_stars, character_pity,
			guarantee, desired_five_star_weapons, weapon_pity, weapon_guarantee)
	
	$ResultLabel.text = "Success Rate: " + str(average_success * 100) + "%"
