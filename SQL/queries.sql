SELECT * FROM public.economics
ORDER BY year ASC, year ASC LIMIT 100;

CREATE OR REPLACE VIEW global_indicators AS
SELECT
    e.country_code,
    r.name AS country_name,
    r.region,
    r."sub-region",
    e.year,
    e.gdp,
    p.total_population,
    e.gdp / NULLIF(p.total_population,0) AS gdp_per_capita,
    p.fertility_rate,
    p.life_expectancy,
    p.life_expectancy_male,
    p.life_expectancy_female,
    e.electric_power_consumption,
    p.mortality_rate
FROM economics e
LEFT JOIN population p
    ON e.country_code = p.country_code
   AND e.year = p.year
LEFT JOIN regions r
    ON e.country_code = r.country_code;

-- TOP 20 countries by GDP per capita in 2024
SELECT 
	country_code
	, country_name
	, year
	, gdp
	, total_population
	, gdp_per_capita
FROM global_indicators
WHERE year = 2024
  AND gdp IS NOT NULL
ORDER BY gdp_per_capita DESC
LIMIT 20;

-- Ranking of countries in their regions by GDP per capita (2022)
SELECT *
FROM (
    SELECT 
		country_code
		, region
		, country_name
		, gdp_per_capita
    	, RANK() OVER (
			PARTITION BY region 
			ORDER BY gdp_per_capita DESC
		) AS region_rank
    FROM global_indicators
    WHERE year = 2022
		AND gdp IS NOT NULL
) ranked
WHERE region_rank <= 5
ORDER BY region, region_rank;

-- The most significant population growth compared to the previous year
WITH pop AS (
    SELECT
        country_code
        , year
        , total_population
        , LAG(total_population) OVER (
			PARTITION BY country_code 
			ORDER BY year
		) AS prev_year
    FROM population
)
SELECT
    country_code
    , year
    , (total_population - prev_year) * 100.0 / prev_year AS growth_rate
FROM pop
WHERE prev_year IS NOT NULL
ORDER BY growth_rate DESC
LIMIT 20;

-- TOP Countries by Electric Power Consumption per capita in 2022
SELECT
	country_name
	, region
	, electric_power_consumption AS el_power_consumption_KWh_per_capita
FROM global_indicators
WHERE year = 2022
  AND electric_power_consumption IS NOT NULL
ORDER BY el_power_consumption_KWh_per_capita DESC
LIMIT 20;

-- Correlation between life expectancy and GDP per capita (2023)
SELECT
    corr(life_expectancy, gdp / total_population) AS life_gdp_correlation
FROM global_indicators
WHERE year = 2023;

-- Top 10 countries with the highest mortality rates (2022)
SELECT 
	country_name
	, "sub-region"
    , mortality_rate
FROM global_indicators
WHERE year = 2022
	AND mortality_rate IS NOT NULL
ORDER BY mortality_rate DESC
LIMIT 20;

-- Top countries with low fertility rates (fertility rate < 2) (2023)
SELECT
	country_name
	, region
    , fertility_rate
FROM global_indicators
WHERE year = 2023
  AND fertility_rate < 2
ORDER BY fertility_rate;

-- Countries with the largest gender gap in life expectancy (2023)
SELECT
	country_name
    , life_expectancy_female - life_expectancy_male AS life_gap
FROM global_indicators
WHERE year = 2023
ORDER BY life_gap DESC
LIMIT 20;
