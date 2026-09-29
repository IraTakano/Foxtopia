extends RefCounted
class_name ClimateCalendar

## One world date for all colonies; the local season is derived from latitude.
## A year has four 15-day periods. Temperatures are deterministic climate normals,
## rather than random weather: every preview, save and network peer sees the same
## seasonal forecast for the same tile.
const DAYS_PER_PERIOD := 15
const PERIODS_PER_YEAR := 4
const DAYS_PER_YEAR := DAYS_PER_PERIOD * PERIODS_PER_YEAR
const START_YEAR := 5500
const DEFAULT_DAY_LENGTH := 600
const MIN_GROWING_TEMPERATURE := 5.0
const MAX_GROWING_TEMPERATURE := 42.0


static func world_calendar() -> Dictionary:
	return {"days_per_period": DAYS_PER_PERIOD, "periods_per_year": PERIODS_PER_YEAR,
		"days_per_year": DAYS_PER_YEAR, "start_year": START_YEAR,
		"period_names": ["Seedtime", "Highsun", "Harvestfall", "Frostrest"]}


static func date_from_steps(steps: int, day_length: int = DEFAULT_DAY_LENGTH) -> Dictionary:
	var elapsed_days := maxi(0, steps) / maxi(1, day_length)
	var year_day := elapsed_days % DAYS_PER_YEAR
	return {"year": START_YEAR + elapsed_days / DAYS_PER_YEAR,
		"period_index": year_day / DAYS_PER_PERIOD,
		"period_day": year_day % DAYS_PER_PERIOD + 1,
		"year_day": year_day + 1, "elapsed_days": elapsed_days}


static func seasonal_amplitude(latitude: float) -> float:
	# Latitude affects the seasonal swing; sites near the equator vary less.
	return 2.5 + 19.0 * pow(clampf(absf(latitude) / 90.0, 0.0, 1.0), 0.9)


static func temperature_for_day(average_temperature: float, latitude: float, year_day: int) -> float:
	var direction := 1.0 if latitude >= 0.0 else -1.0
	var phase := TAU * float(posmod(year_day, DAYS_PER_YEAR)) / float(DAYS_PER_YEAR)
	return snappedf(average_temperature + direction * seasonal_amplitude(latitude) * sin(phase), 0.1)


static func can_grow(temperature: float) -> bool:
	return temperature >= MIN_GROWING_TEMPERATURE and temperature <= MAX_GROWING_TEMPERATURE


static func describe(average_temperature: float, latitude: float) -> Dictionary:
	var month_data: Array = []
	var growable_days: Array = []
	var annual_min := INF
	var annual_max := -INF
	for period in range(PERIODS_PER_YEAR):
		var period_min := INF
		var period_max := -INF
		var period_total := 0.0
		var period_growing_days := 0
		for day in range(DAYS_PER_PERIOD):
			var year_day := period * DAYS_PER_PERIOD + day
			var temperature := temperature_for_day(average_temperature, latitude, year_day)
			period_min = minf(period_min, temperature)
			period_max = maxf(period_max, temperature)
			period_total += temperature
			var growable := can_grow(temperature)
			growable_days.append(growable)
			if growable: period_growing_days += 1
		annual_min = minf(annual_min, period_min)
		annual_max = maxf(annual_max, period_max)
		month_data.append({"period_index": period, "min": period_min, "max": period_max,
			"average": snappedf(period_total / float(DAYS_PER_PERIOD), 0.1),
			"growing_days": period_growing_days})
	var pattern := "four_seasons"
	if annual_max <= 3.0:
		pattern = "permanent_winter"
	elif annual_min >= 18.0:
		pattern = "permanent_summer"
	elif seasonal_amplitude(latitude) < 7.0:
		pattern = "two_seasons"
	for period in range(PERIODS_PER_YEAR):
		month_data[period]["season"] = season_for_period(pattern, latitude, period)
	var growing_periods: Array = []
	var start_day := -1
	for year_day in range(DAYS_PER_YEAR + 1):
		var growable := year_day < DAYS_PER_YEAR and bool(growable_days[year_day])
		if growable and start_day < 0:
			start_day = year_day + 1
		elif not growable and start_day >= 0:
			growing_periods.append({"start_day": start_day, "end_day": year_day})
			start_day = -1
	return {"average_temperature": snappedf(average_temperature, 0.1),
		"temperature_min": annual_min, "temperature_max": annual_max,
		"monthly_temperatures": month_data, "season_pattern": pattern,
		"growing_days": growable_days.count(true), "growing_periods": growing_periods,
		"min_growing_temperature": MIN_GROWING_TEMPERATURE,
		"max_growing_temperature": MAX_GROWING_TEMPERATURE}


static func season_for_period(pattern: String, latitude: float, period_index: int) -> String:
	if pattern == "permanent_winter": return "winter"
	if pattern == "permanent_summer": return "summer"
	var local_period := posmod(period_index + (0 if latitude >= 0.0 else 2), PERIODS_PER_YEAR)
	if pattern == "two_seasons": return "warm" if local_period in [0, 1] else "cool"
	return ["spring", "summer", "autumn", "winter"][local_period]
