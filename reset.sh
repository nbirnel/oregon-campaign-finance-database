#!/bin/sh

if [ "$1" = "-q" ]; then
    echo=:
else
    echo=echo
fi

table=ocf.db
rm -vf $table
rm -vf import-statements*.sql

$echo 'recreating schema'
cat schema.sql | sqlite3 $table

$echo 'importing cities'
cat import-oregon-cities.sql | sqlite3 $table

$echo 'generating statement imports'
for csv in $(find statements/ -type f -iname '*.csv'); do
    ./generate-statements-import.sh $csv
done

for import in import-statements*.sql; do
    $echo "importing $import"
    cat $import | sqlite3 $table
done
rm -f import-statements*.sql

$echo 'generating transaction imports'
for csv in $(find transactions/ -type f -iname '*.csv'); do
    ./generate-transactions-import.sh $csv
done

for import in import-transactions*.sql; do
    $echo "importing $import"
    cat $import | sqlite3 $table
done
rm -f import-transactions*.sql
