#!/bin/sh

rm -f tmp.db

printf=/bin/printf

csv="$1"
table="$2"
sql="create-$table-table.sql"

$printf '.import --csv "%s" tmp\n' "$csv"  | sqlite3 tmp.db

$printf 'CREATE TABLE "%s"(\n' $table >>"$sql"

$printf 'pragma table_info(tmp);\n' \
| sqlite3 tmp.db  \
| cut -d'|' -f2 \
| tr '[:upper:]' '[:lower:]' \
| sed 's/ /_/g' \
| sed 's/.*/    "&" TEXT,/' \
>>"$sql"

$printf '    PRIMARY KEY("__FIXME__")\n' >>"$sql"
$printf ');\n\n' >>"$sql"

rm -f tmp.db
