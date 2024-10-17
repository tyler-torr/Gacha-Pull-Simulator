# pull_simulator.gd
extends Control


var banner: Banner = load("res://resources/HSRBanner.tres")
var run: RunData = RunData.new()

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
	print("Initializing banner and run")


func simulate_fifty_fifty(banner_type: Banner.PullType, rarity: Banner.Rarity, guarantee: bool) -> void:
	match rarity:
		Banner.Rarity.FIVE_STAR:
			run.add_gems(banner, 40)
			if banner.fifty_fifty(banner_type, rarity, guarantee): # Won 50/50
				run.win_fifty_fifty(banner_type, rarity)
			else: # Lost 50/50
				run.lose_fifty_fifty(banner_type, rarity)
		Banner.Rarity.FOUR_STAR:
			var type: Banner.PullType = banner_type
			if not banner.fifty_fifty(banner_type, rarity, guarantee): # If you lose 50/50, chance to get any 4*
				type = banner.roll_type()
			if type == Banner.PullType.CHARACTER:
				run.add_gems(banner, 20)
			elif type == Banner.PullType.WEAPON:
				run.add_gems(banner, 8)


func simulate_char_banner(banner_type: Banner.PullType, pity: int, four_star_pity: int, guarantee: bool, 
		four_star_guarantee: bool) -> void:
	var pull: Banner.Rarity = banner.simulate_pull(banner_type, pity, four_star_pity)
	match pull:
		Banner.Rarity.FIVE_STAR:
			run.char_pity = 0 # Reset 5-star pity on pull
			run.char_four_star_pity += 1
			simulate_fifty_fifty(banner_type, pull, guarantee)
		Banner.Rarity.FOUR_STAR:
			run.char_pity += 1
			run.char_four_star_pity = 0 # Reset 4-star pity on pull
			simulate_fifty_fifty(banner_type, pull, guarantee)
		Banner.Rarity.THREE_STAR:
			run.char_pity += 1
			run.char_four_star_pity += 1


func simulate_wep_banner(banner_type: Banner.PullType, pity: int, four_star_pity: int, guarantee: bool, 
		four_star_guarantee: bool) -> void:
	var pull = banner.simulate_pull(banner_type, pity, four_star_pity)
	match pull:
		Banner.Rarity.FIVE_STAR:
			run.wep_pity = 0 # Reset 5-star pity on pull
			run.wep_four_star_pity += 1
			simulate_fifty_fifty(banner_type, pull, guarantee)
		Banner.Rarity.FOUR_STAR:
			run.wep_pity += 1
			run.wep_four_star_pity = 0 # Reset 4-star pity on pull
			simulate_fifty_fifty(banner_type, pull, guarantee)
		Banner.Rarity.THREE_STAR:
			run.wep_pity += 1
			run.wep_four_star_pity += 1


# Run x number of simulations (default 10000). In each simulation, roll down to 0 pulls and see if the run managed
# to reach the desired number of 5* characters and weapons. Return an averaged percentage of runs that could
func calculate_average_success(desired_chars: int, desired_weps: int, simulation_runs: int) -> float:
	var successful_runs = 0
	for i in range(simulation_runs):
		reset_values()
		while run.remaining_pulls > 0:
			run.remaining_pulls -= 1
			# Character banners
			if run.chars_pulled < desired_chars:
				simulate_char_banner(Banner.PullType.CHARACTER, run.char_pity, run.char_four_star_pity, run.char_guarantee, 
				run.char_four_star_guarantee)
			# Weapon banners
			elif run.weps_pulled < desired_weps:
				simulate_wep_banner(Banner.PullType.WEAPON, run.wep_pity, run.wep_four_star_pity, run.wep_guarantee, 
				run.wep_four_star_guarantee)
		# Check if all wanted characters and weapons are pulled
		if (run.chars_pulled >= desired_chars) and (run.weps_pulled >= desired_weps):
			successful_runs += 1
	
	var average_success: float = float(successful_runs) / float(simulation_runs)
	print("Total average success across simulations: ", average_success)
	return average_success


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
