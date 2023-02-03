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

-- SELECT p2.specialty_description
-- FROM prescription AS p1
-- NATURAL JOIN drug AS d
-- NATURAL JOIN prescriber AS p2
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

-- There are 7 specialties not in the prescription table

--  d) Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- SELECT 
-- 	specialty_description,
-- 	ROUND(AVG(CASE WHEN opioid_drug_flag = 'Y' THEN 1
-- 		ELSE 0 END) * 100.0, 2) AS percent_opioid
-- FROM prescriber
-- NATURAL JOIN prescription
-- NATURAL JOIN drug
-- GROUP BY specialty_description
-- ORDER BY percent_opioid DESC
-- LIMIT 5;

-- 3
--  a) Which drug (generic_name) had the highest total drug cost?

-- SELECT generic_name, total_drug_cost
-- FROM drug
-- NATURAL JOIN prescription
-- ORDER BY total_drug_cost DESC
-- LIMIT 5;

-- Pirfenidone is the drug with the highest total cost.

--  b) Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

-- SELECT generic_name, ROUND(total_drug_cost / total_day_supply, 2) AS cost_per_day
-- FROM drug
-- NATURAL JOIN prescription
-- ORDER BY cost_per_day DESC
-- LIMIT 5;

-- Immun Glob G has the highest cost per day.

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
-- 	SUM(total_drug_cost) AS money
-- FROM drug
-- NATURAL JOIN prescription
-- GROUP BY drug_type
-- ORDER BY MONEY DESC;

-- More money was spent on opioids than antibiotics.

-- 5
--  a) How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

-- SELECT COUNT(cbsa) 
-- FROM cbsa
-- NATURAL JOIN fips_county
-- WHERE state = 'TN'

-- There are 42 CBSAs in Tennessee.

--  b) Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

-- (SELECT cbsaname, SUM(population) AS total_pop
-- FROM cbsa
-- NATURAL JOIN population
-- GROUP BY cbsaname
-- ORDER BY total_pop DESC 
-- LIMIT 1)
-- UNION
-- (SELECT cbsaname, SUM(population) AS total_pop
-- FROM cbsa
-- NATURAL JOIN population
-- GROUP BY cbsaname
-- ORDER BY total_pop
-- LIMIT 1)
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