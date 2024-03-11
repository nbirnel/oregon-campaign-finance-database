-- who are the 10 largest contributors, and what did they contribute?
SELECT 
    sum(amount) as total,
    contributor
FROM contributions
GROUP BY contributor
ORDER BY total DESC
LIMIT 10
;

-- Miscellaneous Cash Contributions $100 and under is not "a" contributor,
-- so perhaps we would like to filter it out
SELECT 
    sum(amount) as total,
    contributor
FROM contributions
GROUP BY contributor
HAVING contributor != 'Miscellaneous Cash Contributions $100 and under'
ORDER BY total DESC
LIMIT 10
;

-- what are the 10 largest contributions, how much from who to what?
SELECT 
    amount,
    contributor,
    committee
FROM contributions
ORDER BY cast(amount as float) DESC, lower(contributor), committee
LIMIT 10
;

-- what 10 campaigns had the greatest contributions?
-- this is hard to answer, because transactions are not associated with a single active election!

-- what committees received the most contributions?
SELECT 
    sum(amount) as total,
    committee
FROM contributions
GROUP BY committee
ORDER BY total DESC
LIMIT 10
;

-- Well, we can at least group them by year.
SELECT 
    sum(amount) as total,
    committee,
    substr(transaction_date_iso8601, 1, 4) as year
FROM contributions
GROUP BY committee, year
ORDER BY total DESC, year, committee
LIMIT 10
;

-- this year?

SELECT 
    sum(amount) as total,
    committee
FROM contributions
WHERE transaction_date_iso8601 > '2023-03-14'
GROUP BY committee
ORDER BY total DESC
;

-- what committees have contributed how much in how many donations to other committees?
SELECT 
    c.name as donor,
    sum(t.amount),
    count(*),
    t.committee as recipient
FROM contributions t
JOIN committees c
ON c.id = t.contributor_or_payee_committee_id
WHERE contributor_or_payee_committee_id IS NOT NULL
GROUP BY donor, recipient
ORDER BY lower(donor), lower(recipient)
;

-- which addresses have multiple contributors?
SELECT 
    addr_line1 || addr_line2 || city || state || zip as catenated_address,
    count(DISTINCT contributor) as contributors
FROM contributions
WHERE catenated_address != ''
GROUP BY contributor
HAVING contributors > 1
ORDER BY contributors desc, catenated_address
;


-- which committees have changed their treasurer?
SELECT name 
FROM committees 
WHERE id IN (
    SELECT committee_id 
    FROM statements 
    GROUP BY committee_id 
    HAVING count(DISTINCT treasurer) > 1
)
;

-- who were those, and in what election?
SELECT
    committee,
    treasurer,
    active_election
FROM
    committee_statements
WHERE committee_id IN (
    SELECT committee_id 
    FROM committee_statements
    GROUP BY committee_id 
    HAVING count(DISTINCT treasurer) > 1
)
ORDER BY
    committee,
    active_election
;

-- What candidates are their own treasurer?
SELECT 
  distinct candidate
FROM statements
WHERE
   candidate = treasurer
ORDER BY candidate_name_for_order
;

-- Which candidates share an address with their treasurer?
SELECT 
  candidate,
  treasurer
FROM statements
WHERE
   candidate_mailing_address = treasurer_mailing_address 
AND
    candidate != treasurer
ORDER BY 
    candidate_name_for_order,
    treasurer_name_for_order,
;

-- Who are the 25 most active treasurers?
SELECT
  treasurer,
  count(id) as campaigns
FROM 
  statements
GROUP BY
  treasurer
ORDER BY
  campaigns DESC,
  lower(treasurer_last_name), 
  lower(treasurer_first_name) 
LIMIT 25
;

-- Wow, Jef Green has been treasurer for 603 campaigns! 
-- What sort of things does he work on?

CREATE TEMP VIEW jefgreen_statements as
SELECT *
FROM committee_statements
WHERE
    treasurer = 'Jef Green'
;

-- what kind of committee?
SELECT 
    count(*),
    "committee_type"
FROM jefgreen_statements
GROUP BY "committee_type"
;
-- 395|CC
-- 5|CPC
-- 203|PAC

-- Are they measures or offices? What kind of office?
SELECT
    count(*) as "number",
    CASE
    WHEN
        candidate_office_group like '%_'
    THEN
        candidate_office_group
    WHEN
        measure like '%_'
    THEN
        'measure'
    ELSE
        'Neither candidate nor measure!'
    END AS kind
FROM jefgreen_statements
GROUP BY kind
ORDER BY "number" DESC, kind
;

-- Is he more active over the years?
SELECT 
    count(*),
    active_election 
FROM jefgreen_statements
GROUP BY active_election
ORDER BY active_election
;

-- Are there statements with neither active_election, candidate, or measure?
SELECT count(*)
FROM statements
WHERE candidate_or_measure NOT LIKE '%_'
AND active_election NOT LIKE '%_'
;

-- What committees are making these statements?
SELECT 
    count(*) as how_many,
    committee
FROM committee_statements
WHERE candidate_or_measure NOT LIKE '%_'
AND active_election NOT LIKE '%_'
GROUP BY committee
ORDER BY how_many, committee
;

-- What treasurers are making these statements?
SELECT 
    count(*) as how_many,
    treasurer
FROM statements
WHERE candidate_or_measure NOT LIKE '%_'
AND active_election NOT LIKE '%_'
GROUP BY treasurer
ORDER BY how_many, lower(treasurer_last_name), lower(treasurer_first_name)
;
