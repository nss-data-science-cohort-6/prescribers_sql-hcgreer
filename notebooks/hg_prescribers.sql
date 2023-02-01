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