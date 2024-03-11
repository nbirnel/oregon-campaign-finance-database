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

UPDATE "tmp" SET "Original Id" = trim("Original Id");
UPDATE "tmp" SET "Tran Date" = trim("Tran Date");
UPDATE "tmp" SET "Tran Status" = trim("Tran Status");
UPDATE "tmp" SET "Filer" = trim("Filer");
UPDATE "tmp" SET "Contributor/Payee" = trim("Contributor/Payee");
UPDATE "tmp" SET "Sub Type" = trim("Sub Type");
UPDATE "tmp" SET "Payer of Personal Expenditure" = trim("Payer of Personal Expenditure");
UPDATE "tmp" SET "Amount" = trim("Amount");
UPDATE "tmp" SET "Aggregate Amount" = trim("Aggregate Amount");
UPDATE "tmp" SET "Contributor/Payee Committee ID" = trim("Contributor/Payee Committee ID");
UPDATE "tmp" SET "Filer Id" = trim("Filer Id");
UPDATE "tmp" SET "Attest By Name" = trim("Attest By Name");
UPDATE "tmp" SET "Attest Date" = trim("Attest Date");
UPDATE "tmp" SET "Review By Name" = trim("Review By Name");
UPDATE "tmp" SET "Review Date" = trim("Review Date");
UPDATE "tmp" SET "Due Date" = trim("Due Date");
UPDATE "tmp" SET "Occptn Ltr Date" = trim("Occptn Ltr Date");
UPDATE "tmp" SET "Pymt Sched Txt" = trim("Pymt Sched Txt");
UPDATE "tmp" SET "Purp Desc" = trim("Purp Desc");
UPDATE "tmp" SET "Intrst Rate" = trim("Intrst Rate");
UPDATE "tmp" SET "Check Nbr" = trim("Check Nbr");
UPDATE "tmp" SET "Tran Stsfd Ind" = trim("Tran Stsfd Ind");
UPDATE "tmp" SET "Filed By Name" = trim("Filed By Name");
UPDATE "tmp" SET "Filed Date" = trim("Filed Date");
UPDATE "tmp" SET "Addr book Agent Name" = trim("Addr book Agent Name");
UPDATE "tmp" SET "Book Type" = trim("Book Type");
UPDATE "tmp" SET "Title Txt" = trim("Title Txt");
UPDATE "tmp" SET "Occptn Txt" = trim("Occptn Txt");
UPDATE "tmp" SET "Emp Name" = trim("Emp Name");
UPDATE "tmp" SET "Emp City" = trim("Emp City");
UPDATE "tmp" SET "Emp State" = trim("Emp State");
UPDATE "tmp" SET "Employ Ind" = trim("Employ Ind");
UPDATE "tmp" SET "Self Employ Ind" = trim("Self Employ Ind");
UPDATE "tmp" SET "Addr Line1" = trim("Addr Line1");
UPDATE "tmp" SET "Addr Line2" = trim("Addr Line2");
UPDATE "tmp" SET "City" = trim("City");
UPDATE "tmp" SET "State" = trim("State");
UPDATE "tmp" SET "Zip" = trim("Zip");
UPDATE "tmp" SET "Zip Plus Four" = trim("Zip Plus Four");
UPDATE "tmp" SET "County" = trim("County");
UPDATE "tmp" SET "Country" = trim("Country");
UPDATE "tmp" SET "Foreign Postal Code" = trim("Foreign Postal Code");
UPDATE "tmp" SET "Purpose Codes" = trim("Purpose Codes");
UPDATE "tmp" SET "Exp Date" = trim("Exp Date");

UPDATE "tmp" SET "Original Id" = NULL WHERE "Original Id" = '';
UPDATE "tmp" SET "Tran Date" = NULL WHERE "Tran Date" = '';
UPDATE "tmp" SET "Tran Status" = NULL WHERE "Tran Status" = '';
UPDATE "tmp" SET "Filer" = NULL WHERE "Filer" = '';
UPDATE "tmp" SET "Contributor/Payee" = NULL WHERE "Contributor/Payee" = '';
UPDATE "tmp" SET "Sub Type" = NULL WHERE "Sub Type" = '';
UPDATE "tmp" SET "Payer of Personal Expenditure" = NULL WHERE "Payer of Personal Expenditure" = '';
UPDATE "tmp" SET "Amount" = NULL WHERE "Amount" = '';
UPDATE "tmp" SET "Aggregate Amount" = NULL WHERE "Aggregate Amount" = '';
UPDATE "tmp" SET "Contributor/Payee Committee ID" = NULL WHERE "Contributor/Payee Committee ID" = '';
UPDATE "tmp" SET "Filer Id" = NULL WHERE "Filer Id" = '';
UPDATE "tmp" SET "Attest By Name" = NULL WHERE "Attest By Name" = '';
UPDATE "tmp" SET "Attest Date" = NULL WHERE "Attest Date" = '';
UPDATE "tmp" SET "Review By Name" = NULL WHERE "Review By Name" = '';
UPDATE "tmp" SET "Review Date" = NULL WHERE "Review Date" = '';
UPDATE "tmp" SET "Due Date" = NULL WHERE "Due Date" = '';
UPDATE "tmp" SET "Occptn Ltr Date" = NULL WHERE "Occptn Ltr Date" = '';
UPDATE "tmp" SET "Pymt Sched Txt" = NULL WHERE "Pymt Sched Txt" = '';
UPDATE "tmp" SET "Purp Desc" = NULL WHERE "Purp Desc" = '';
UPDATE "tmp" SET "Intrst Rate" = NULL WHERE "Intrst Rate" = '';
UPDATE "tmp" SET "Check Nbr" = NULL WHERE "Check Nbr" = '';
UPDATE "tmp" SET "Tran Stsfd Ind" = NULL WHERE "Tran Stsfd Ind" = '';
UPDATE "tmp" SET "Filed By Name" = NULL WHERE "Filed By Name" = '';
UPDATE "tmp" SET "Filed Date" = NULL WHERE "Filed Date" = '';
UPDATE "tmp" SET "Addr book Agent Name" = NULL WHERE "Addr book Agent Name" = '';
UPDATE "tmp" SET "Book Type" = NULL WHERE "Book Type" = '';
UPDATE "tmp" SET "Title Txt" = NULL WHERE "Title Txt" = '';
UPDATE "tmp" SET "Occptn Txt" = NULL WHERE "Occptn Txt" = '';
UPDATE "tmp" SET "Emp Name" = NULL WHERE "Emp Name" = '';
UPDATE "tmp" SET "Emp City" = NULL WHERE "Emp City" = '';
UPDATE "tmp" SET "Emp State" = NULL WHERE "Emp State" = '';
UPDATE "tmp" SET "Employ Ind" = NULL WHERE "Employ Ind" = '';
UPDATE "tmp" SET "Self Employ Ind" = NULL WHERE "Self Employ Ind" = '';
UPDATE "tmp" SET "Addr Line1" = NULL WHERE "Addr Line1" = '';
UPDATE "tmp" SET "Addr Line2" = NULL WHERE "Addr Line2" = '';
UPDATE "tmp" SET "City" = NULL WHERE "City" = '';
UPDATE "tmp" SET "State" = NULL WHERE "State" = '';
UPDATE "tmp" SET "Zip" = NULL WHERE "Zip" = '';
UPDATE "tmp" SET "Zip Plus Four" = NULL WHERE "Zip Plus Four" = '';
UPDATE "tmp" SET "County" = NULL WHERE "County" = '';
UPDATE "tmp" SET "Country" = NULL WHERE "Country" = '';
UPDATE "tmp" SET "Foreign Postal Code" = NULL WHERE "Foreign Postal Code" = '';
UPDATE "tmp" SET "Purpose Codes" = NULL WHERE "Purpose Codes" = '';
UPDATE "tmp" SET "Exp Date" = NULL WHERE "Exp Date" = '';

INSERT INTO "transactions"(
    "id",
    "original_id",
    "transaction_date",
    "transaction_status",
    "contributor_or_payee",
    "sub_type",
    "payer_of_personal_expenditure",
    "amount",
    "aggregate_amount",
    "contributor_or_payee_committee_id",
    "filer_id",
    "attest_by_name",
    "attest_date",
    "review_by_name",
    "review_date",
    "due_date",
    "occptn_ltr_date",
    "pymt_sched_txt",
    "purp_desc",
    "intrst_rate",
    "check_number",
    "tran_stsfd_ind",
    "filed_by_name",
    "filed_date",
    "addr_book_agent_name",
    "book_type",
    "title_txt",
    "occptn_txt",
    "employer_name",
    "employer_city",
    "employer_state",
    "employ_ind",
    "self_employ_ind",
    "addr_line1",
    "addr_line2",
    "city",
    "state",
    "zip",
    "zip_plus_four",
    "county",
    "country",
    "foreign_postal_code",
    "purpose_codes",
    "exp_date"
)
SELECT
    "Tran Id",
    "Original Id",
    "Tran Date",
    "Tran Status",
    "Contributor/Payee",
    "Sub Type",
    "Payer of Personal Expenditure",
    "Amount",
    "Aggregate Amount",
    "Contributor/Payee Committee ID",
    "Filer Id",
    "Attest By Name",
    "Attest Date",
    "Review By Name",
    "Review Date",
    "Due Date",
    "Occptn Ltr Date",
    "Pymt Sched Txt",
    "Purp Desc",
    "Intrst Rate",
    "Check Nbr",
    "Tran Stsfd Ind",
    "Filed By Name",
    "Filed Date",
    "Addr book Agent Name",
    "Book Type",
    "Title Txt",
    "Occptn Txt",
    "Emp Name",
    "Emp City",
    "Emp State",
    "Employ Ind",
    "Self Employ Ind",
    "Addr Line1",
    "Addr Line2",
    "City",
    "State",
    "Zip",
    "Zip Plus Four",
    "County",
    "Country",
    "Foreign Postal Code",
    "Purpose Codes",
    "Exp Date"
FROM
  "tmp"
WHERE true
ON CONFLICT("id") DO NOTHING
;
DROP TABLE "tmp";
