#!/bin/sh

rm -f tmp.db

printf=/bin/printf

csv="$1"
table="$2"
clean="$3"
unique="$4"

import_name="$(echo "$csv" | sed 's,/,-,g' | sed 's/.csv$//')"
sql="import-$import_name.sql"

rm -f "$sql"

if ! [ -s "$csv" ]; then
    touch "$sql"
    printf 'empty file %s\n' "$csv" 1>&2
    exit
fi

$printf '.import --csv "%s" tmp\n' "$csv"  | sqlite3 tmp.db

$printf '.import --csv "%s" tmp\n' "$csv"  >"$sql"
$printf '-- UPDATE "tmp" SET "__foo__"=NULL WHERE "__foo__" = '"''"';\n'  >>"$sql"
$printf '-- and any other massaging you need to do goes here\n\n' >>"$sql"

if [ -e "$clean" ]; then
    cat "$clean" >>"$sql"
else
    echo "No clean file - be sure to edit $sql"
fi

$printf 'INSERT INTO "%s"(\n' $table >>"$sql"

$printf 'pragma table_info(tmp);\n' \
| sqlite3 tmp.db  \
| cut -d'|' -f2 \
| tr '[:upper:]' '[:lower:]' \
| sed 's/ /_/g' \
| sed 's/.*/    "&",/' \
| sed '$s/,$//' \
>>"$sql"
$printf ')\n' >>"$sql"

$printf 'SELECT\n' >>"$sql"

$printf 'pragma table_info(tmp);\n' \
| sqlite3 tmp.db  \
| cut -d'|' -f2 \
| sed 's/.*/    "&",/' \
| sed '$s/,$//' \
>>"$sql"

$printf 'FROM\n  "tmp"\n' >>"$sql"

if [ -n "$unique" ]; then
    $printf 'WHERE true\n' >>"$sql"
    $printf 'ON CONFLICT("%s") DO NOTHING\n' "$unique" >>"$sql"
fi

$printf ';\n' >>"$sql"



$printf 'DROP TABLE "tmp";\n' >>"$sql"

rm -f tmp.db
