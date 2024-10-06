extends Control


const HSR_CHARACTER_BANNER = {
	"base_pull_rate": 0.006,
	"soft_pity_start": 74,
	"hard_pity": 90,
	"premium_chance": 0.564 # According to 棵平衡樹, HSR's character banner actually has 56.4% odds of winning a 5*
}

const HSR_WEAPON_BANNER = {
	"base_pull_rate": 0.008,
	"soft_pity_start": 64, # Temporary value
	"hard_pity": 80,
	"premium_chance": 0.75
}

var banner = HSR_CHARACTER_BANNER
var weapon_banner = HSR_WEAPON_BANNER

@onready var desired_five_stars_input = $FiveStarCharacterInput
@onready var desired_five_star_weapons_input = $FiveStarWeaponInput
@onready var available_pulls_input = $AvailablePullsInput
@onready var available_currency_input = $AvailableCurrencyInput
@onready var simulation_runs_input = $SimulationRunsInput
@onready var guarantee_input = $GuaranteeInput


func ready() -> void:
	pass


func pull(pity: int) -> bool:
	var current_pull_rate = banner["base_pull_rate"]
	
	if pity == banner["hard_pity"]:
		current_pull_rate = 1.0
	elif pity >= banner["soft_pity_start"]:
		current_pull_rate += 0.06 * (pity - banner["soft_pity_start"] + 1)
	
	current_pull_rate = clamp(current_pull_rate, banner["base_pull_rate"], 1.0)
	return current_pull_rate >= randf()


func fifty_fifty(guarantee: bool) -> bool:
	return guarantee or randf() <= banner["premium_chance"]


func simulate_pulls(desired_five_stars: int, available_pulls: int, simulation_runs: int, guarantee: bool) -> float:
	var total_success = 0
	
	for i in range(simulation_runs):
		var five_stars_pulled = 0
		var remaining_pulls = available_pulls
		var pity = 0
		var current_guarantee = guarantee
		
		while remaining_pulls != 0:
			remaining_pulls -= 1
			if pull(pity):
				pity = 0
				if fifty_fifty(current_guarantee):
					current_guarantee = false
					five_stars_pulled += 1
					if five_stars_pulled >= desired_five_stars:
						total_success += 1
						break
				else:
					current_guarantee = true
			else:
				pity += 1
	
	return float(total_success) / float(simulation_runs)


func _on_run_button_pressed() -> void:
	var desired_five_stars = int(desired_five_stars_input.value)
	var available_pulls = int(available_pulls_input.value)
	var available_currency = int(available_currency_input.value)
	var simulation_runs = int(simulation_runs_input.value)
	var guarantee = guarantee_input.is_pressed()
	
	available_pulls += (available_currency / 160)
	# test test test
	
	var average_success = simulate_pulls(desired_five_stars, available_pulls, simulation_runs, guarantee)
	
	$ResultLabel.text = "Success rate: " + str(average_success * 100) + "%"
