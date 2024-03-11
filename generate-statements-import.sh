#!/bin/sh

csv="$1"

import_name="$(echo "$csv" | sed 's,/,-,g' | sed 's/.csv$//')"
sql="import-$import_name.sql"

rm -f "$sql"

if ! [ -s "$csv" ]; then
    touch "$sql"
    printf 'empty file %s\n' "$csv" 1>&2
    exit
fi

cat <<EOF >"$sql"
.mode csv
.import "$csv" tmp

UPDATE "tmp" SET "Committee Name"=NULL WHERE trim("Committee Name") = '';
UPDATE "tmp" SET "Committee Type"=NULL WHERE trim("Committee Type") = '';
UPDATE "tmp" SET "Committee SubType"=NULL WHERE trim("Committee SubType") = '';
UPDATE "tmp" SET "Candidate Office"=NULL WHERE trim("Candidate Office") = '';
UPDATE "tmp" SET "Candidate Office Group"=NULL WHERE trim("Candidate Office Group") = '';
UPDATE "tmp" SET "Filing Date"=NULL WHERE trim("Filing Date") = '';
UPDATE "tmp" SET "Organization Filing Date"=NULL WHERE trim("Organization Filing Date") = '';
UPDATE "tmp" SET "Treasurer First Name"=NULL WHERE trim("Treasurer First Name") = '';
UPDATE "tmp" SET "Treasurer Last Name"=NULL WHERE trim("Treasurer Last Name") = '';
UPDATE "tmp" SET "Treasurer Mailing Address"=NULL WHERE trim("Treasurer Mailing Address") = '';
UPDATE "tmp" SET "Treasurer Work Phone"=NULL WHERE trim("Treasurer Work Phone") = '';
UPDATE "tmp" SET "Treasurer Fax"=NULL WHERE trim("Treasurer Fax") = '';
UPDATE "tmp" SET "Candidate First Name"=NULL WHERE trim("Candidate First Name") = '';
UPDATE "tmp" SET "Candidate Last Name"=NULL WHERE trim("Candidate Last Name") = '';
UPDATE "tmp" SET "Candidate Maling Address"=NULL WHERE trim("Candidate Maling Address") = '';
UPDATE "tmp" SET "Candidate Work Phone"=NULL WHERE trim("Candidate Work Phone") = '';
UPDATE "tmp" SET "Candidate Residence Phone"=NULL WHERE trim("Candidate Residence Phone") = '';
UPDATE "tmp" SET "Candidate Fax"=NULL WHERE trim("Candidate Fax") = '';
UPDATE "tmp" SET "Candidate Email"=NULL WHERE trim("Candidate Email") = '';
UPDATE "tmp" SET "Active Election"=NULL WHERE trim("Active Election") = '';
UPDATE "tmp" SET "Measure"=NULL WHERE trim("Measure") = '';

UPDATE "tmp" SET "Committee Name"=trim("Committee Name");
UPDATE "tmp" SET "Committee Type"=trim("Committee Type");
UPDATE "tmp" SET "Committee SubType"=trim("Committee SubType");
UPDATE "tmp" SET "Candidate Office"=trim("Candidate Office");
UPDATE "tmp" SET "Candidate Office Group"=trim("Candidate Office Group");
UPDATE "tmp" SET "Filing Date"=trim("Filing Date");
UPDATE "tmp" SET "Organization Filing Date"=trim("Organization Filing Date");
UPDATE "tmp" SET "Treasurer First Name"=trim("Treasurer First Name");
UPDATE "tmp" SET "Treasurer Last Name"=trim("Treasurer Last Name");
UPDATE "tmp" SET "Treasurer Mailing Address"=trim("Treasurer Mailing Address");
UPDATE "tmp" SET "Treasurer Work Phone"=trim("Treasurer Work Phone");
UPDATE "tmp" SET "Treasurer Fax"=trim("Treasurer Fax");
UPDATE "tmp" SET "Candidate First Name"=trim("Candidate First Name");
UPDATE "tmp" SET "Candidate Last Name"=trim("Candidate Last Name");
UPDATE "tmp" SET "Candidate Maling Address"=trim("Candidate Maling Address");
UPDATE "tmp" SET "Candidate Work Phone"=trim("Candidate Work Phone");
UPDATE "tmp" SET "Candidate Residence Phone"=trim("Candidate Residence Phone");
UPDATE "tmp" SET "Candidate Fax"=trim("Candidate Fax");
UPDATE "tmp" SET "Candidate Email"=trim("Candidate Email");
UPDATE "tmp" SET "Active Election"=trim("Active Election");
UPDATE "tmp" SET "Measure"=trim("Measure");

INSERT INTO "committees"(
    "id",
    "name",
    "type",
    "subtype"
)
SELECT
    "Committee Id",
    "Committee Name",
    "Committee Type",
    "Committee SubType"
FROM
  "tmp"
WHERE true
ON CONFLICT("id") DO NOTHING
;

INSERT INTO "addresses"(
    "address"
)
SELECT
    "Treasurer Mailing Address"
FROM
    "tmp"
WHERE "Treasurer Mailing Address" is not NULL
ON CONFLICT DO NOTHING
;

INSERT INTO "addresses"(
    "address"
)
SELECT
    "Candidate Maling Address"
FROM
    "tmp"
WHERE "Candidate Maling Address" is not NULL
ON CONFLICT DO NOTHING
;

INSERT INTO "statements"(
    "committee_id",
    "candidate_office",
    "candidate_office_group",
    "filing_date",
    "organization_filing_date",
    "treasurer_first_name",
    "treasurer_last_name",
    "treasurer_mailing_address",
    "treasurer_work_phone",
    "treasurer_fax",
    "candidate_first_name",
    "candidate_last_name",
    "candidate_mailing_address",
    "candidate_work_phone",
    "candidate_residence_phone",
    "candidate_fax",
    "candidate_email",
    "active_election",
    "measure"
)
SELECT
    "Committee Id",
    "Candidate Office",
    "Candidate Office Group",
    "Filing Date",
    "Organization Filing Date",
    "Treasurer First Name",
    "Treasurer Last Name",
    "Treasurer Mailing Address",
    "Treasurer Work Phone",
    "Treasurer Fax",
    "Candidate First Name",
    "Candidate Last Name",
    "Candidate Maling Address",
    "Candidate Work Phone",
    "Candidate Residence Phone",
    "Candidate Fax",
    "Candidate Email",
    "Active Election",
    "Measure"
FROM
  "tmp"
WHERE true
ON CONFLICT DO NOTHING
;

DROP TABLE "tmp";
EOF
