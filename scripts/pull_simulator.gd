# pull_simulator.gd
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

var banner: Banner
var run: RunData

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


# Called when the node enters the scene tree for the first time.
func ready() -> void:
	banner = load("res://resources/HSRBanner.tres")
	run = RunData.new()


func simulate_banner(banner_type: String, pity: int, four_star_pity: int, guarantee: bool) -> void:
	var pull = banner.simulate_pull(banner_type, pity, four_star_pity)
	match banner_type:
		"5-STAR":
			run.char_pity = 0
			run.char_4_star_pity += 1
			run.remaining_gems += banner.gem_5_star_gain
			if banner.fifty_fifty(banner_type, guarantee):
				run.win_fifty_fifty(banner_type)
			else:
				run.lose_fifty_fifty(banner_type)
		"4-STAR":
			run.char_pity += 1
		"_":
			run.char_pity += 1
			run.four_star_pity += 1


func calculate_average_success(desired_chars: int, desired_weps: int, simulation_runs: int) -> float:
	var successful_runs = 0
	
	for i in range(simulation_runs):
		run.reset(banner)
		
		while run.remaining_pulls > 0:
			run.remaining_pulls -= 1
			
			# Character banners
			if run.chars_pulled < desired_chars:
				pass
		
		if (run.chars_pulled >= desired_chars) and (run.weps_pulled >= desired_weps):
			successful_runs += 1
	
	return float(successful_runs) / float(simulation_runs)


func _on_run_button_pressed() -> void:
	run.remaining_pulls = int(available_pulls_input.value)
	run.remaining_currency = int(available_currency_input.value)
	run.remaining_gems = int(available_gems_input.value)
	run.char_pity = int(character_pity_input.value)
	run.wep_pity = int(weapon_pity_input.value)
	run.char_guarantee = guarantee_input.is_pressed()
	run.wep_guarantee = weapon_guarantee_input.is_pressed()
	
	var desired_chars = int(desired_five_stars_input.value)
	var desired_weps = int(desired_five_star_weapons_input.value)
	var simulation_runs = int(simulation_runs_input.value)
	
	var average_success = calculate_average_success(desired_chars, desired_weps, simulation_runs)
	
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
