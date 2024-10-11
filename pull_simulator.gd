extends Control


const HSR_BANNER = {
	"CHARACTER": {
		"PULL_RATE": 0.006,
		"PITY_RATE": 0.06,
		"SOFT_PITY_START": 74,
		"HARD_PITY": 90,
		"FIFTY_FIFTY": 0.564 # According to 棵平衡樹, HSR's character banner has 56.4% odds to win
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

const WUWA_BANNER = {
	"CHARACTER": {
		"PULL_RATE": 0.008,
		"PITY_RATE": 0.08, # Pure speculation based on statistics from wuwatracker.com
		"SOFT_PITY_START": 66, # Pure speculation based on statistics from wuwatracker.com
		"HARD_PITY": 80,
		"FIFTY_FIFTY": 0.5
	},
	"WEAPON": {
		"PULL_RATE": 0.008,
		"PITY_RATE": 0.08, # Pure speculation based on statistics from wuwatracker.com
		"SOFT_PITY_START": 66, # Pure speculation based on statistics from wuwatracker.com
		"HARD_PITY": 80,
		"FIFTY_FIFTY": 1.0 # There is no fifty fifty on WuWa's Weapon Banner
	}
}

var banner

@onready var available_pulls_input = $AvailablePullsInput
@onready var available_currency_input = $AvailableCurrencyInput
@onready var available_gems_input = $AvailableGemsInput
@onready var simulation_runs_input = $SimulationRunsInput
@onready var desired_five_stars_input = $FiveStarCharacterInput
@onready var character_pity_input = $CharacterPityInput
@onready var guarantee_input = $GuaranteeInput
@onready var desired_five_star_weapons_input = $FiveStarWeaponInput
@onready var weapon_pity_input = $WeaponPityInput
@onready var weapon_guarantee_input = $WeaponGuaranteeInput


func ready() -> void:
	pass


func pull(banner_type: String, pity: int) -> bool:
	var current_pull_rate = banner[banner_type]["PULL_RATE"]
	if pity == banner[banner_type]["HARD_PITY"]:
		current_pull_rate = 1.0
	elif pity >= banner[banner_type]["SOFT_PITY_START"]:
		current_pull_rate += banner[banner_type]["PITY_RATE"] * (pity - banner[banner_type]["SOFT_PITY_START"] + 1)
	return current_pull_rate >= randf()


func fifty_fifty(banner_type: String, guarantee: bool) -> bool:
	return guarantee or randf() <= banner[banner_type]["FIFTY_FIFTY"]


func gem_conversion(conversion_rate: int, remaining_gems: int) -> int:
	return remaining_gems / conversion_rate


func simulate_banner(banner_type: String, five_stars_pulled: int, pity: int, guarantee: bool,
					remaining_gems: int) -> Array:
	if pull(banner_type, pity):
		pity = 0
		remaining_gems += banner["OTHER"]["5-STAR_GEM_GAIN"]
		if fifty_fifty(banner_type, guarantee):
			guarantee = false
			five_stars_pulled += 1
		else:
			guarantee = true
	else:
		pity += 1
	return [five_stars_pulled, pity, guarantee, remaining_gems]


func simulate_pulls(available_pulls: int, available_currency: int, available_gems: int, simulation_runs: int,
					desired_five_stars: int, character_pity: int, guarantee: bool, desired_five_star_weapons: int,
					weapon_pity: int, weapon_guarantee: bool) -> float:
	var total_success = 0
	
	for i in range(simulation_runs):
		var five_stars_pulled = 0
		var weapons_pulled = 0
		var remaining_pulls = available_pulls + (available_currency / 160)
		
		var remaining_gems = available_gems
		
		var pity = character_pity
		var wep_pity = weapon_pity
		# var four_star_pity = 0
		
		var current_guarantee = guarantee
		var wep_guarantee = weapon_guarantee
		
		while remaining_pulls > 0 || remaining_gems >= banner["OTHER"]["GEM_CONVERSION_RATE"]:
			if (remaining_gems >= banner["OTHER"]["GEM_CONVERSION_RATE"]):
				remaining_pulls += gem_conversion(banner["OTHER"]["GEM_CONVERSION_RATE"], remaining_gems)
				remaining_gems %= banner["OTHER"]["GEM_CONVERSION_RATE"]
			remaining_pulls -= 1
			
			# Character banners
			if five_stars_pulled < desired_five_stars:
				var result: Array = simulate_banner("CHARACTER", five_stars_pulled, pity, current_guarantee, remaining_gems)
				five_stars_pulled = result[0]
				pity = result[1]
				current_guarantee = result[2]
				remaining_gems = result[3]
			# Weapon banners
			if weapons_pulled < desired_five_star_weapons:
				var result: Array = simulate_banner("WEAPON", weapons_pulled, wep_pity, wep_guarantee, remaining_gems)
				weapons_pulled = result[0]
				wep_pity = result[1]
				wep_guarantee = result[2]
				remaining_gems = result[3]
		
		if (five_stars_pulled >= desired_five_stars) and (weapons_pulled >= desired_five_star_weapons):
			total_success += 1
	
	return float(total_success) / float(simulation_runs)


func _on_run_button_pressed() -> void:
	var available_pulls = int(available_pulls_input.value)
	var available_currency = int(available_currency_input.value)
	var available_gems = int(available_gems_input.value)
	var simulation_runs = int(simulation_runs_input.value)
	var desired_five_stars = int(desired_five_stars_input.value)
	var character_pity = int(character_pity_input.value)
	var guarantee = guarantee_input.is_pressed()
	var desired_five_star_weapons = int(desired_five_star_weapons_input.value)
	var weapon_pity = int(weapon_pity_input.value)
	var weapon_guarantee = weapon_guarantee_input.is_pressed()
	
	var average_success = simulate_pulls(available_pulls, available_currency, available_gems, simulation_runs,
										desired_five_stars, character_pity, guarantee, desired_five_star_weapons,
										weapon_pity, weapon_guarantee)
	
	$ResultLabel.text = "Success Rate: " + str(average_success * 100) + "%"


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		banner = HSR_BANNER
	elif index == 1:
		banner = WUWA_BANNER
