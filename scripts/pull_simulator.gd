extends Control


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
	banner = load("res://resources/HSRBanner.tres")


func simulate_banner(available_pulls: int, available_currency: int, available_gems: int, simulation_runs: int,
					desired_chars: int, character_pity: int, guarantee: bool, desired_weps: int,
					weapon_pity: int, weapon_guarantee: bool) -> float:
	var successful_runs = 0
	
	for i in range(simulation_runs):
		var remaining_gems = available_gems
		var remaining_pulls = available_pulls
		remaining_pulls += banner.currency_to_pulls(available_currency)
		remaining_pulls += banner.gems_to_pulls(remaining_gems)
		remaining_gems %= banner.gem_conversion_rate
		
		var chars_pulled = 0
		var weps_pulled = 0
		var chars_4_star_pulled = 0
		var weps_4_star_pulled = 0
		
		var char_pity = character_pity
		var wep_pity = weapon_pity
		var char_4_star_pity = 0
		var wep_4_star_pity = 0
		
		var char_guarantee = guarantee
		var wep_guarantee = weapon_guarantee
		var char_4_star_guarantee = false
		var wep_4_star_guarantee = false
		
		while (remaining_pulls > 0) or (remaining_gems >= banner.gem_conversion_rate):
			remaining_pulls -= 1
			
			# Character banners
			if chars_pulled < desired_chars:
				var result: Array = simulate_banner("CHARACTER", five_stars_pulled, pity, current_guarantee, remaining_gems)
				five_stars_pulled = result[0]
				pity = result[1]
				current_guarantee = result[2]
				remaining_gems = result[3]
			# Weapon banners
			if weapons_pulled < desired_weps:
				var result: Array = simulate_banner("WEAPON", weapons_pulled, wep_pity, wep_guarantee, remaining_gems)
				weapons_pulled = result[0]
				wep_pity = result[1]
				wep_guarantee = result[2]
				remaining_gems = result[3]
		
		if (five_stars_pulled >= desired_five_stars) and (weapons_pulled >= desired_five_star_weapons):
			successful_runs += 1

	
	return float(successful_runs) / float(simulation_runs)


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


func _on_copies_button_item_selected(index: int) -> void:
	if index == 0:
		copies_preference = 0
	elif index == 1:
		copies_preference = 1
