#!/bin/bash

BASE="$1"
YEAR_FROM="$2"
YEAR_TO="$3"
OUT="$4"
FILTER="$5"     # opcjonalnie np. appsrv-blog
JOBS=4          # ile lat równolegle

if [ -z "$OUT" ]; then
    echo "Użycie:"
    echo "$0 BASE YEAR_FROM YEAR_TO OUTPUT_FILE [FILTER]"
    exit 1
fi

TMPDIR=$(mktemp -d)
echo "Start indeksowania $BASE ($YEAR_FROM-$YEAR_TO)"
echo "Filter: ${FILTER:-BRAK}"

generate_year() {
    YEAR="$1"
    OUTFILE="$TMPDIR/$YEAR.txt"

    if [ -d "$BASE/$YEAR" ]; then
        if [ -n "$FILTER" ]; then
            find "$BASE/$YEAR" -type f -path "*$FILTER*" -name "*.gz" \
                -printf "%P|%s|%T@\n" > "$OUTFILE"
        else
            find "$BASE/$YEAR" -type f -name "*.gz" \
                -printf "%P|%s|%T@\n" > "$OUTFILE"
        fi
    fi
}

export BASE FILTER TMPDIR
export -f generate_year

# równoległość bez GNU parallel
for YEAR in $(seq "$YEAR_FROM" "$YEAR_TO"); do
    generate_year "$YEAR" &
    
    # limit równoległych jobów
    while [ "$(jobs -r | wc -l)" -ge "$JOBS" ]; do
        sleep 1
    done
done

wait

cat "$TMPDIR"/*.txt | sort > "$OUT"
rm -rf "$TMPDIR"

echo "Gotowe: $OUT"
echo "Liczba plików: $(wc -l < "$OUT")"
echo "Łączny rozmiar (GB): $(awk -F'|' '{sum+=$2} END {printf "%.2f", sum/1024/1024/1024}' "$OUT")"
