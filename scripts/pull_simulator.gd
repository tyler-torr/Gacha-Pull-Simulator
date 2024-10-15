# pull_simulator.gd
extends Control


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


func calculate_gems(won_fifty_fifty: bool):
	var swap_type: bool = false
	if not won_fifty_fifty:
		if randf() >= 0.5:
			swap_type = true
	

func simulate_fifty_fifty(banner_type: String, rarity: String, guarantee: bool) -> void:
	if banner.fifty_fifty(banner_type, rarity, guarantee):
		run.win_fifty_fifty(banner_type, rarity)
		calculate_gems(true)
	else:
		run.lose_fifty_fifty(banner_type, rarity)
		calculate_gems(false)


# 
func simulate_banner(banner_type: String, pity: int, four_star_pity: int, guarantee: bool, 
		four_star_guarantee: bool) -> void:
	var pull = banner.simulate_pull(banner_type, pity, four_star_pity)
	match pull:
		"5-STAR":
			pity = 0
			four_star_pity += 1
			run.add_gems(banner, banner.gem_5_star_gain)
			simulate_fifty_fifty(banner_type, pull, guarantee)
		"4-STAR":
			pity += 1
			four_star_pity = 0
			simulate_fifty_fifty(banner_type, pull, guarantee)
			if banner.fifty_fifty("4-STAR", four_star_guarantee):
				if banner_type == "CHARACTER":
					run.add_gems(banner, banner.gem_4_star_excess_gain)
				elif banner_type == "WEAPON":
					run.add_gems(banner, banner.gem_4_star_gain)
			else:
				var swap_type: String = banner.roll_type()
				if swap_type == "CHARACTER":
					run.add_gems(banner, banner.gem_4_star_excess_gain)
				elif swap_type == "WEAPON":
					run.add_gems(banner, banner.gem_4_star_gain)
		"_":
			pity += 1
			four_star_pity += 1


func calculate_average_success(desired_chars: int, desired_weps: int, simulation_runs: int) -> float:
	var successful_runs = 0
	for i in range(simulation_runs):
		reset_values()
		while run.remaining_pulls > 0:
			run.remaining_pulls -= 1
			# Character banners
			if run.chars_pulled < desired_chars:
				simulate_banner("CHARACTER", run.char_pity, run.char_four_star_pity, run.char_guarantee, 
				run.char_four_star_guarantee)
			# Weapon banners
			elif run.weps_pulled < desired_weps:
				simulate_banner("WEAPON", run.wep_pity, run.wep_four_star_pity, run.wep_guarantee, 
				run.wep_four_star_guarantee)
		# Check if all wanted characters and weapons are pulled
		if (run.chars_pulled >= desired_chars) and (run.weps_pulled >= desired_weps):
			successful_runs += 1
	return float(successful_runs) / float(simulation_runs)


# Called at the start of each simulated run. Resets some values to ones specified by user
func reset_values() -> void:
	run.reset(banner)
	run.remaining_pulls = int(available_pulls_input.value)
	run.remaining_currency = int(available_currency_input.value)
	run.remaining_gems = int(available_gems_input.value)
	run.char_pity = int(character_pity_input.value)
	run.wep_pity = int(weapon_pity_input.value)
	run.char_guarantee = guarantee_input.is_pressed()
	run.wep_guarantee = weapon_guarantee_input.is_pressed()


func _on_run_button_pressed() -> void:
	var desired_chars = int(desired_five_stars_input.value)
	var desired_weps = int(desired_five_star_weapons_input.value)
	var simulation_runs = int(simulation_runs_input.value)
	
	var average_success = calculate_average_success(desired_chars, desired_weps, simulation_runs)
	
	$ResultLabel.text = "Success Rate: " + str(average_success * 100) + "%"


func _on_option_button_item_selected(index: int) -> void:
	#if index == 0:
		#banner = HSR_BANNER
	#elif index == 1:
		#banner = WUWA_BANNER
	pass
