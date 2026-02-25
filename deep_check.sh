#!/bin/bash

BASE1="$1"
BASE2="$2"
DIFF_FILE="$3"

OUT="deep_hash_compare.txt"

cut -d',' -f1 "$DIFF_FILE" | while read FILE
do
    H1=$(sha256sum "$BASE1/$FILE" | awk '{print $1}')
    H2=$(sha256sum "$BASE2/$FILE" | awk '{print $1}')
    
    if [ "$H1" != "$H2" ]; then
        echo "$FILE HASH_DIFFER"
    fi
done > "$OUT"

echo "Deep check gotowy: $OUT"
