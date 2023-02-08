-- 1
-- 	a) Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- SELECT npi, SUM(total_claim_count) AS total_claim
-- FROM prescription
-- GROUP BY npi
-- ORDER BY total_claim DESC
-- LIMIT 1;

-- 1881634483 had the most claims at 99707 total claims.

--  b) Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

-- SELECT p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description, SUM(p1.total_claim_count) AS total_claim
-- FROM prescription AS p1
-- NATURAL JOIN prescriber as p2
-- GROUP BY p1.npi, p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description
-- ORDER BY total_claim DESC
-- LIMIT 1;

-- Bruce Pendley had the most claims.

-- 2
--  a) Which specialty had the most total number of claims (totaled over all drugs)?

-- SELECT p2.specialty_description, SUM(p1.total_claim_count) AS total_claim
-- FROM prescription AS p1
-- NATURAL JOIN prescriber as p2
-- GROUP BY p2.specialty_description
-- ORDER BY total_claim DESC
-- LIMIT 1;

-- Family Practice has the most claims over all drugs.

--  b) Which specialty had the most total number of claims for opioids?

-- SELECT 
-- 	p2.specialty_description, 
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription AS p1
-- NATURAL JOIN prescriber AS p2
-- NATURAL JOIN (
-- 	SELECT 
-- 		DISTINCT drug_name,
-- 		opioid_drug_flag
-- 	FROM drug
-- ) AS d
-- WHERE opioid_drug_flag = 'Y'
-- GROUP BY p2.specialty_description
-- ORDER BY SUM(p1.total_claim_count) DESC
-- LIMIT 1;

-- Nurse Practitioner had the most claims for opioids.

--  c) Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- SELECT specialty_description
-- FROM prescriber
-- LEFT JOIN prescription
-- USING(npi)
-- GROUP BY specialty_description
-- HAVING SUM(total_claim_count) IS NULL

-- There are 15 specialties not in the prescription table

--  d) Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- SELECT 
-- 	specialty_description,
-- 	COALESCE(ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' 
-- 	   	THEN total_claim_count
-- 	   	END) * 100 / SUM(total_claim_count), 2), 0) AS percent_opioid
-- FROM prescriber
-- NATURAL JOIN prescription
-- NATURAL JOIN drug
-- GROUP BY specialty_description
-- ORDER BY percent_opioid DESC
-- LIMIT 5;

-- 3
--  a) Which drug (generic_name) had the highest total drug cost?

-- SELECT 
-- 	generic_name, 
-- 	SUM(total_drug_cost)::money AS total_cost
-- FROM drug
-- NATURAL JOIN prescription
-- GROUP BY generic_name
-- ORDER BY total_cost DESC
-- LIMIT 5;

-- INSULIN GLARGINE,HUM.REC.ANLOG is the drug with the highest total cost.

--  b) Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

-- SELECT 
-- 	generic_name, 
-- 	SUM(total_drug_cost)::money / SUM(total_day_supply) AS cost_per_day
-- FROM drug
-- NATURAL JOIN prescription
-- GROUP BY generic_name
-- ORDER BY cost_per_day DESC
-- LIMIT 5;

-- C1 ESTERASE INHIBITOR has the highest cost per day.

-- 4
--  a) For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

-- SELECT drug_name,
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 	ELSE 'neither' END AS drug_type
-- FROM drug;

--  b) Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- SELECT
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 	ELSE 'neither' END AS drug_type,
-- 	SUM(total_drug_cost)::money AS total_cost
-- FROM (
-- 	SELECT 
-- 		DISTINCT drug_name,
-- 		opioid_drug_flag,
-- 		antibiotic_drug_flag
-- 	FROM drug
-- 	WHERE 
-- 		opioid_drug_flag = 'Y' OR
-- 		antibiotic_drug_flag = 'Y'
-- ) AS d 
-- NATURAL JOIN prescription
-- GROUP BY drug_type
-- ORDER BY total_cost DESC;

-- More money was spent on opioids than antibiotics.

-- 5
--  a) How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

-- SELECT COUNT(DISTINCT cbsa) 
-- FROM cbsa
-- NATURAL JOIN fips_county
-- WHERE state = 'TN';

-- There are 10 CBSAs in Tennessee.

--  b) Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

-- (
-- 	SELECT cbsaname, SUM(population) AS total_pop
-- 	FROM cbsa
-- 	NATURAL JOIN population
-- 	GROUP BY cbsaname
-- 	ORDER BY total_pop DESC 
-- 	LIMIT 1
-- )
-- UNION
-- (
-- 	SELECT cbsaname, SUM(population) AS total_pop
-- 	FROM cbsa
-- 	NATURAL JOIN population
-- 	GROUP BY cbsaname
-- 	ORDER BY total_pop
-- 	LIMIT 1
-- )
-- ORDER BY total_pop DESC;

-- Nashville-Davidson--Murfreesboro--Franklin has the most and Morristown has the least.

--  c)  What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- SELECT county, population
-- FROM fips_county
-- NATURAL JOIN population
-- WHERE fipscounty NOT IN (
-- 	SELECT DISTINCT fipscounty
-- 	FROM cbsa
-- )
-- ORDER BY population DESC
-- LIMIT 1;

-- Sevier has the highest population with no CBSA

-- 6
--  a) Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

-- SELECT drug_name, total_claim_count
-- FROM prescription
-- WHERE total_claim_count >= 3000

-- There are 9 rows.

--  b) For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

-- SELECT 
-- 	drug_name, 
-- 	total_claim_count,
-- 	opioid_drug_flag
-- FROM prescription
-- NATURAL JOIN drug
-- WHERE total_claim_count >= 3000

-- There are two opioids

--  c) Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- SELECT 
-- 	drug_name, 
-- 	total_claim_count,
-- 	opioid_drug_flag,
-- 	nppes_provider_first_name AS first_name,
-- 	nppes_provider_last_org_name AS last_name
-- FROM prescription AS p1
-- NATURAL JOIN drug
-- INNER JOIN prescriber AS p2
-- USING(npi)
-- WHERE total_claim_count >= 3000

-- David Coffey has some explaining to do.

-- 7
--  a) First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- SELECT 
-- 	npi,
-- 	drug_name
-- FROM prescriber
-- CROSS JOIN (
-- 	SELECT drug_name
-- 	FROM drug
-- 	WHERE opioid_drug_flag = 'Y'
-- ) AS opioid
-- WHERE 
-- 	specialty_description = 'Pain Management' AND 			nppes_provider_city = 'NASHVILLE';

--  b) Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

-- SELECT 
-- 	npi,
-- 	drug_name,
-- 	COALESCE(total_claim_count, 0) AS total_claim_count
-- FROM prescriber
-- CROSS JOIN (
-- 	SELECT drug_name
-- 	FROM drug
-- 	WHERE opioid_drug_flag = 'Y'
-- ) AS opioid
-- LEFT JOIN prescription
-- USING(npi, drug_name)
-- WHERE 
-- 	specialty_description = 'Pain Management' AND 			nppes_provider_city = 'NASHVILLE';

-- Part 2

-- 1 How many npi numbers appear in the prescriber table but not in the prescription table?

-- SELECT COUNT(*) 
-- FROM (
-- 	SELECT DISTINCT npi
-- 	FROM prescriber
-- ) AS p1
-- WHERE npi NOT IN (
-- 	SELECT DISTINCT npi
-- 	FROM prescription
-- )

-- There are 4458 npi in prescibers but not in prescriptions 

-- 2 
--  a) Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

-- SELECT generic_name
-- FROM prescription
-- INNER JOIN (
-- 	SELECT DISTINCT drug_name, generic_name
-- 	FROM drug
-- ) AS d
-- USING(drug_name)
-- WHERE npi IN (
-- 	SELECT npi
-- 	FROM prescriber
-- 	WHERE specialty_description = 'Family Practice'
-- )
-- GROUP BY generic_name
-- ORDER BY SUM(total_claim_count) DESC
-- LIMIT 5;

--  b) Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

-- SELECT generic_name
-- FROM prescription
-- INNER JOIN (
-- 	SELECT DISTINCT drug_name, generic_name
-- 	FROM drug
-- ) AS d
-- USING(drug_name)
-- WHERE npi IN (
-- 	SELECT npi
-- 	FROM prescriber
-- 	WHERE specialty_description = 'Cardiology'
-- )
-- GROUP BY generic_name
-- ORDER BY SUM(total_claim_count) DESC
-- LIMIT 5;

--  c) Which drugs appear in the top five prescribed for both Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

-- (SELECT generic_name
-- FROM prescription
-- INNER JOIN (
-- 	SELECT DISTINCT drug_name, generic_name
-- 	FROM drug
-- ) AS d
-- USING(drug_name)
-- WHERE npi IN (
-- 	SELECT npi
-- 	FROM prescriber
-- 	WHERE specialty_description = 'Family Practice'
-- )
-- GROUP BY generic_name
-- ORDER BY SUM(total_claim_count) DESC
-- LIMIT 5)
-- INTERSECT
-- (SELECT generic_name
-- FROM prescription
-- INNER JOIN (
-- 	SELECT DISTINCT drug_name, generic_name
-- 	FROM drug
-- ) AS d
-- USING(drug_name)
-- WHERE npi IN (
-- 	SELECT npi
-- 	FROM prescriber
-- 	WHERE specialty_description = 'Cardiology'
-- )
-- GROUP BY generic_name
-- ORDER BY SUM(total_claim_count) DESC
-- LIMIT 5);

-- ATORVASTATIN CALCIUM and AMLODIPINE BESYLATE appear in both tables.

-- 3
--  a) First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.

-- SELECT *
-- FROM(	
-- 	WITH per_city AS (
-- 		SELECT 
-- 			npi,
-- 			nppes_provider_city,
-- 			SUM(total_claim_count) AS total_claims
-- 		FROM prescription
-- 		INNER JOIN prescriber
-- 		USING(npi)
-- 		GROUP BY npi, nppes_provider_city
-- 	)
-- 	SELECT
-- 		DISTINCT npi,
-- 		nppes_provider_city,
-- 		total_claims,
-- 		RANK() OVER(
-- 			PARTITION BY nppes_provider_city 
-- 			ORDER BY total_claims DESC
-- 		) AS rank_per_city
-- 	FROM per_city
-- ) AS sub
-- WHERE rank_per_city <= 5 AND
-- 	nppes_provider_city IN (
-- 		'NASHVILLE',
-- 		'MEMPHIS',
-- 		'KNOXVILLE',
-- 		'CHATTANOOGA'
-- 	)
-- ORDER BY nppes_provider_city, rank_per_city;

-- 4 Find all counties which had an above-average (for the state) number of overdose deaths in 2017. Report the county name and number of overdose deaths.


-- 5
--  a) Write a query that finds the total population of Tennessee.

-- SELECT SUM(population) AS total_pop
-- FROM fips_county
-- INNER JOIN population
-- USING(fipscounty)
-- WHERE state = 'TN';

--  b) Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

-- SELECT 
-- 	county,
-- 	population,
-- 	ROUND(population / (
-- 		SELECT SUM(population) AS total_pop
-- 		FROM fips_county
-- 		INNER JOIN population
-- 		USING(fipscounty)
-- 		WHERE state = 'TN'
-- 	)* 100, 2)
-- FROM fips_county
-- INNER JOIN population
-- USING(fipscounty)
-- WHERE state = 'TN';

-- Bouns Grouping Set

-- 1 Write a query which returns the total number of claims for these two groups.

-- SELECT 
-- 	specialty_description, 
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY specialty_description;

-- 2 Now, let's say that we want our output to also include the total number of claims between these two groups. Combine two queries with the UNION keyword to accomplish this.

-- (SELECT
--  	null AS specialty_description,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- 	)
-- )
-- UNION
-- (
-- SELECT 
-- 	specialty_description, 
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY specialty_description
-- );

-- 3 Now, instead of using UNION, make use of GROUPING SETS

-- SELECT 
-- 	specialty_description, 
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY GROUPING SETS((specialty_description), ());

-- 4 In addition to comparing the total number of prescriptions by specialty, let's also bring in information about the number of opioid vs. non-opioid claims by these two specialties. Modify your query (still making use of GROUPING SETS so that your output also shows the total number of opioid claims vs. non-opioid claims by these two specialites

-- SELECT 
-- 	specialty_description,
-- 	opioid_drug_flag,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- INNER JOIN drug
-- USING(drug_name)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY GROUPING SETS(
-- 	(opioid_drug_flag),
-- 	(specialty_description), 
-- 	()
-- );

-- 5 Modify your query by replacing the GROUPING SETS with ROLLUP(opioid_drug_flag, specialty_description).

-- SELECT 
-- 	specialty_description,
-- 	opioid_drug_flag,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- INNER JOIN drug
-- USING(drug_name)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY ROLLUP(
-- 	opioid_drug_flag,
-- 	specialty_description
-- );

-- 6 Switch the order of the variables inside the ROLLUP. That is, use ROLLUP(specialty_description, opioid_drug_flag).

-- SELECT 
-- 	specialty_description,
-- 	opioid_drug_flag,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- INNER JOIN drug
-- USING(drug_name)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY ROLLUP(
-- 	specialty_description,
-- 	opioid_drug_flag
-- );

-- 7 Finally, change your query to use the CUBE function instead of ROLLUP. How does this impact the output?

-- SELECT 
-- 	specialty_description,
-- 	opioid_drug_flag,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription
-- INNER JOIN prescriber
-- USING(npi)
-- INNER JOIN drug
-- USING(drug_name)
-- WHERE specialty_description IN (
-- 	'Interventional Pain Management',
-- 	'Pain Management'
-- )
-- GROUP BY CUBE(
-- 	specialty_description,
-- 	opioid_drug_flag
-- );

-- 8 In this question, your goal is to create a pivot table showing for each of the 4 largest cities in Tennessee (Nashville, Memphis, Knoxville, and Chattanooga), the total claim count for each of six common types of opioids: Hydrocodone, Oxycodone, Oxymorphone, Morphine, Codeine, and Fentanyl. For the purpose of this question, we will put a drug into one of the six listed categories if it has the category name as part of its generic name.

CREATE extension tablefunc;

	
WITH pain_name AS (
	SELECT
		DISTINCT drug_name,
		CASE WHEN drug_name LIKE '%HYDROCODONE%' 
		THEN 'hydrocodone'
		WHEN drug_name LIKE '%OXYCODONE%'
		THEN 'oxycodone'
		WHEN drug_name LIKE '%OXYMORPHONE%'
		THEN 'oxymorphone'
		WHEN drug_name LIKE '%MORPHINE%'
		THEN 'morphine'
		WHEN drug_name LIKE '%CODEINE%'
		THEN 'codine'
		WHEN drug_name LIKE '%FENTANYL%'
		THEN 'fentanyl'
		ELSE 'neither' END AS group_name
	FROM prescription
)
SELECT 
	nppes_provider_city AS city,
	group_name,
	SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN pain_name
USING(drug_name)
WHERE nppes_provider_city IN (
	'NASHVILLE',
	'MEMPHIS',
	'KNOXVILLE',
	'CHATTANOOGA'
) AND
	group_name NOT IN ('neither')
GROUP BY city, group_name



WITH pain_name AS (
		SELECT
			DISTINCT drug_name,
			CASE WHEN drug_name LIKE '%HYDROCODONE%' 
			THEN 'hydrocodone'
			WHEN drug_name LIKE '%OXYCODONE%'
			THEN 'oxycodone'
			WHEN drug_name LIKE '%OXYMORPHONE%'
			THEN 'oxymorphone'
			WHEN drug_name LIKE '%MORPHINE%'
			THEN 'morphine'
			WHEN drug_name LIKE '%CODEINE%'
			THEN 'codine'
			WHEN drug_name LIKE '%FENTANYL%'
			THEN 'fentanyl'
			ELSE 'neither' END AS group_name
		FROM prescription
)
SELECT *
FROM CROSSTAB(
	'SELECT 
		nppes_provider_city AS city,
		group_name,
		SUM(total_claim_count) AS total_claims
	FROM prescription
	INNER JOIN prescriber
	USING(npi)
	INNER JOIN (
		SELECT
			DISTINCT drug_name,
			CASE WHEN drug_name LIKE "%HYDROCODONE%" 
			THEN "hydrocodone"
			WHEN drug_name LIKE "%OXYCODONE%"
			THEN "oxycodone"
			WHEN drug_name LIKE "%OXYMORPHONE%"
			THEN "oxymorphone"
			WHEN drug_name LIKE "%MORPHINE%"
			THEN "morphine"
			WHEN drug_name LIKE "%CODEINE%"
			THEN "codine"
			WHEN drug_name LIKE "%FENTANYL%"
			THEN "fentanyl"
			ELSE "neither" END AS group_name
		FROM prescription
	) AS sub
	USING(drug_name)
	WHERE nppes_provider_city IN (
		"NASHVILLE",
		"MEMPHIS",
		"KNOXVILLE",
		"CHATTANOOGA"
	) AND
		group_name NOT IN ("neither")
	GROUP BY city, group_name'
) AS final_result(city TEXT, hydrocodone NUMERIC, oxycodone NUMERIC, oxymorphone NUMERIC, morphine NUMERIC, codeine NUMERIC, fentanyl NUMERIC);
