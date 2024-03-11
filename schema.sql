CREATE TABLE IF NOT EXISTS "oregon_cities"(
    "id" INTEGER,
    "city" TEXT,
    UNIQUE("city"),
    PRIMARY KEY("id")
);

-- There are a lot of creative spellings of cities in this database.
-- We will normalize them to lower case with the trigger "insert_oregon_city",
-- and also add observed-in-the-wild spellings
CREATE TABLE IF NOT EXISTS "oregon_city_spellings"(
    "id" INTEGER,
    "city_id" INTEGER,
    "spelling",
    UNIQUE("spelling"),
    PRIMARY KEY("id"),
    FOREIGN KEY("city_id") REFERENCES "oregon_cities"("id")
);

CREATE INDEX "oregon_city_spelling_index"
ON "oregon_city_spellings"("spelling");

CREATE TRIGGER "insert_oregon_city"
AFTER INSERT ON "oregon_cities"
BEGIN
    INSERT INTO "oregon_city_spellings"(
        "city_id",
        "spelling"
    ) VALUES (
        NEW."id",
        lower(NEW."city")
    );
END;

-- committee ids come from the State's database.
CREATE TABLE IF NOT EXISTS "committees"(
    "id" INTEGER,
    "name" TEXT,
    "type" TEXT,  -- PAC, CC, or CPC but we don't control what might come from OreStar
    "subtype" TEXT,
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "addresses"(
    "id" INTEGER,
    "address" TEXT UNIQUE,
    "street_address" TEXT AS (
        CASE WHEN
            "zip" NOT NULL
        THEN
            rtrim(
                substring(
                    "address",
                    1,
                    length("address") - 9
                ),
                ', '
            )
        ELSE NULL
        END
    ),
    "city_id" INTEGER DEFAULT NULL,
    "zip" TEXT AS (
        CASE WHEN
            "address" LIKE '% __ _____'
        THEN substring("address", -5)
        ELSE NULL
        END
    ),
    "state" TEXT AS (
        CASE WHEN
            "address" LIKE '% __ _____'
        THEN substring("address", -8, 2)
        ELSE NULL
        END
    ),
    "address_last_word" TEXT AS (
        CASE WHEN
            "zip" NOT NULL
        THEN lower(
            replace(
            substring(
                "street_address",
                length(
                    rtrim(
                        street_address,
                        replace(street_address, ' ', '|')
                    )
                ) + 1
            ), ',', '')
        )
        ELSE NULL
        END
    ) STORED,
    "address_without_last_word" TEXT AS (
        CASE WHEN
            "zip" NOT NULL
        THEN rtrim(
            rtrim(
                street_address,
                replace(street_address, ' ', '|')
            )
        )
        ELSE NULL
        END
    ),
    "address_second_last_word" TEXT AS (
        CASE WHEN
            "zip" NOT NULL
        THEN lower(
            replace(
            substring(
                "address_without_last_word",
                length(
                    rtrim(
                        address_without_last_word,
                        replace(address_without_last_word, ' ', '|')
                    )
                ) + 1
            ), ',', '')
        )
        ELSE NULL
        END
    ),
    "address_without_last_two_words" TEXT AS (
        CASE WHEN
            "zip" NOT NULL
        THEN rtrim(
            rtrim(
                address_without_last_word,
                replace(address_without_last_word, ' ', '|')
            )
        )
        ELSE NULL
        END
    ),
    "address_third_last_word" TEXT AS (
        CASE WHEN
            "zip" NOT NULL
        THEN lower(
            replace(
            substring(
                "address_without_last_two_words",
                length(
                    rtrim(
                        address_without_last_two_words,
                        replace(address_without_last_two_words, ' ', '|')
                    )
                ) + 1
             ), ',', '')
        )
        ELSE NULL
        END
    ),
    FOREIGN KEY("city_id") REFERENCES "oregon_cities"("id")
    PRIMARY KEY("id")
);

CREATE TRIGGER "insert_address"
AFTER INSERT ON "addresses"
BEGIN
    UPDATE "addresses" set city_id = (
    CASE
        WHEN
            address_last_word IN ( SELECT spelling FROM oregon_city_spellings )
        THEN (
            SELECT city_id
            FROM oregon_city_spellings
            WHERE spelling = address_last_word
            )
        WHEN
            address_second_last_word || ' ' || address_last_word IN (
                SELECT spelling FROM oregon_city_spellings )
        THEN (
            SELECT city_id
            FROM oregon_city_spellings
            WHERE
                spelling = address_second_last_word || ' ' || address_last_word
            )
        WHEN
            address_third_last_word || ' ' || address_second_last_word || ' ' || address_last_word IN (
                SELECT "spelling" FROM oregon_city_spellings )
        THEN (
            SELECT city_id
            FROM oregon_city_spellings
            WHERE
                "spelling" = address_third_last_word || ' ' || address_second_last_word || ' ' || address_last_word
            )
        ELSE NULL
    END
    )
    WHERE id = NEW.id;
END;


CREATE TABLE IF NOT EXISTS "statements"(
    "id" INTEGER,
    "committee_id" INTEGER,
    "candidate_office" TEXT,
    "candidate_office_group" TEXT,
    "filing_date" TEXT,
    -- sadly the state publishes addresses as mm-dd-yyyy.
    "filing_date_iso8601" TEXT AS (
        substr("filing_date", 7) || '-' || substr("filing_date", 1, 2) || '-' || substr("filing_date", 4, 2)
    ),
    "organization_filing_date" TEXT,
    "organization_filing_date_iso8601" TEXT AS (
        substr("organization_filing_date", 7) || '-' || substr("organization_filing_date", 1, 2) || '-' || substr("organization_filing_date", 4, 2)
    ),
    "treasurer_first_name" TEXT,
    "treasurer_last_name" TEXT,
    "treasurer" TEXT AS (
        CASE WHEN
            "treasurer_first_name" IS NULL AND "treasurer_last_name" IS NULL
        THEN
            NULL
        WHEN
            "treasurer_first_name" IS NULL AND "treasurer_last_name" IS NOT NULL
        THEN
            "treasurer_last_name"
        WHEN
            "treasurer_first_name" IS NOT NULL AND "treasurer_last_name" IS NULL
        THEN
            "treasurer_first_name"
        ELSE
            "treasurer_first_name" || ' ' || "treasurer_last_name"
        END
    ),
    "treasurer_name_for_order" TEXT AS (
        CASE WHEN
            "treasurer_first_name" IS NULL AND "treasurer_last_name" IS NULL
        THEN
            NULL
        WHEN
            "treasurer_first_name" IS NULL AND "treasurer_last_name" IS NOT NULL
        THEN
            "treasurer_last_name"
        WHEN
            "treasurer_first_name" IS NOT NULL AND "treasurer_last_name" IS NULL
        THEN
            "treasurer_first_name"
        ELSE
            lower("treasurer_last_name") || ', ' || lower("treasurer_first_name")
        END
    ) STORED,
    "treasurer_mailing_address" TEXT,
    "treasurer_address_id" INTEGER DEFAULT NULL,
    "treasurer_work_phone" TEXT,
    "treasurer_fax" TEXT,
    "candidate_first_name",
    "candidate_last_name",
    "candidate" TEXT AS (
        CASE WHEN
            "candidate_first_name" IS NULL AND "candidate_last_name" IS NULL
        THEN
            NULL
        WHEN
            "candidate_first_name" IS NULL AND "candidate_last_name" IS NOT NULL
        THEN
            "candidate_last_name"
        WHEN
            "candidate_first_name" IS NOT NULL AND "candidate_last_name" IS NULL
        THEN
            "candidate_first_name"
        ELSE
            "candidate_first_name" || ' ' || "candidate_last_name"
        END
    ) STORED,
    "candidate_name_for_order" TEXT AS (
        CASE WHEN
            "candidate_first_name" IS NULL AND "candidate_last_name" IS NULL
        THEN
            NULL
        WHEN
            "candidate_first_name" IS NULL AND "candidate_last_name" IS NOT NULL
        THEN
            "candidate_last_name"
        WHEN
            "candidate_first_name" IS NOT NULL AND "candidate_last_name" IS NULL
        THEN
            "candidate_first_name"
        ELSE
            lower("candidate_last_name") || ', ' || lower("candidate_first_name")
        END
    ) STORED,
    "candidate_mailing_address" TEXT,
    "candidate_address_id" INTEGER DEFAULT NULL,
    "candidate_work_phone" TEXT,
    "candidate_residence_phone" TEXT,
    "candidate_fax" TEXT,
    "candidate_email" TEXT,
    "active_election" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
    "measure" TEXT,
    "candidate_or_measure" TEXT AS (
        CASE
        WHEN
            candidate IS NOT NULL
        THEN
            candidate
        WHEN
            measure IS NOT NULL
        THEN
            measure
        ELSE
            ''
        END
    ) STORED,
    FOREIGN KEY("committee_id") REFERENCES "committees"("id"),
    FOREIGN KEY("treasurer_address_id") REFERENCES "addresses"("id"),
    FOREIGN KEY("candidate_address_id") REFERENCES "addresses"("id"),
    PRIMARY KEY("id")
);

-- We want these to be unique, but that slows down importing a lot.
-- An index brings it back into reasonable time.
CREATE UNIQUE INDEX "statements_index"
ON "statements"(
    "committee_id",
    "active_election",
    "candidate_or_measure"
);

CREATE TRIGGER "insert_statement"
AFTER INSERT ON "statements"
BEGIN
    UPDATE "statements" set "treasurer_address_id" = (
        SELECT "id"
        FROM "addresses"
        WHERE "address" = NEW."treasurer_mailing_address"
    )
    WHERE id = NEW.id
    ;
    UPDATE "statements" set "candidate_address_id" = (
        SELECT "id"
        FROM "addresses"
        WHERE "address" = NEW."candidate_mailing_address"
    )
    WHERE id = NEW.id
    ;
END;

CREATE TABLE IF NOT EXISTS "transactions"(
    "id" INTEGER,
    "original_id" INTEGER,
    "transaction_date" TEXT,
    "transaction_date_iso8601" TEXT AS (
            substr("transaction_date", 7) || '-' || substr("transaction_date", 1, 2) || '-' || substr("transaction_date", 4, 2)
    ),
    "transaction_status" TEXT,
    "contributor_or_payee" TEXT,
    "sub_type" TEXT,
    "payer_of_personal_expenditure" TEXT,
    "amount" TEXT,
    "aggregate_amount" TEXT,
    "contributor_or_payee_committee_id" INTEGER,
    "filer_id" INTEGER,
    "attest_by_name" TEXT,
    "attest_date" TEXT,
    "attest_date_iso8601" TEXT AS (
            substr("attest_date", 7) || '-' || substr("attest_date", 1, 2) || '-' || substr("attest_date", 4, 2)
    ),
    "review_by_name" TEXT,
    "review_date" TEXT,
    "review_date_iso8601" TEXT AS (
            substr("review_date", 7) || '-' || substr("review_date", 1, 2) || '-' || substr("review_date", 4, 2)
    ),
    "due_date" TEXT,
    "due_date_iso8601" TEXT AS (
            substr("due_date", 7) || '-' || substr("due_date", 1, 2) || '-' || substr("due_date", 4, 2)
    ),
    "occptn_ltr_date" TEXT,
    "occptn_ltr_date_iso8601" TEXT AS (
            substr("occptn_ltr_date", 7) || '-' || substr("occptn_ltr_date", 1, 2) || '-' || substr("occptn_ltr_date", 4, 2)
    ),
    "pymt_sched_txt" TEXT,
    "purp_desc" TEXT,
    "intrst_rate" TEXT,
    "check_number" TEXT,
    "tran_stsfd_ind" TEXT,
    "filed_by_name" TEXT,
    "filed_date" TEXT,
    "filed_date_iso8601" TEXT AS (
            substr("filed_date", 7) || '-' || substr("filed_date", 1, 2) || '-' || substr("filed_date", 4, 2)
    ),
    "addr_book_agent_name" TEXT,
    "book_type" TEXT,
    "title_txt" TEXT,
    "occptn_txt" TEXT,
    "employer_name" TEXT,
    "employer_city" TEXT,
    "employer_state" TEXT,
    "employ_ind" TEXT,
    "self_employ_ind" TEXT,
    "addr_line1" TEXT,
    "addr_line2" TEXT,
    "city" TEXT,
    "state" TEXT,
    "zip" TEXT,
    "zip_plus_four" TEXT,
    "county" TEXT,
    "country" TEXT,
    "foreign_postal_code" TEXT,
    "purpose_codes" TEXT,
    "exp_date" TEXT,
    "exp_date_iso8601" TEXT AS (
            substr("exp_date", 7) || '-' || substr("exp_date", 1, 2) || '-' || substr("exp_date", 4, 2)
    ),
    FOREIGN KEY("filer_id") REFERENCES "committees"("id"),
    FOREIGN KEY("contributor_or_payee_committee_id") REFERENCES "committees"("id"),
    PRIMARY KEY("id")
);

CREATE VIEW "committee_statements" AS
SELECT
    c."name" AS "committee",
    c."type" AS "committee_type",
    c."subtype" AS "committee_subtype",
    f.*
FROM "statements" f
JOIN "committees" c
ON c."id" = f."committee_id"
;

CREATE VIEW "committee_transactions" AS
SELECT 
    t.*,
    c."name" AS "committee",
    c."type" AS "committee_type",
    c."subtype" AS "committee_subtype"
FROM "transactions" t
JOIN "committees" c
ON t."filer_id" = c."id"
;

CREATE VIEW "contributions" AS
SELECT 
    *,
    contributor_or_payee as contributor
FROM "committee_transactions"
WHERE sub_type IN (
    'Cash Contribution',
    'In-Kind Contribution',
    'Pledge of Cash'
)
;
