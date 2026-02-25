#!/bin/bash

FILE1="$1"
FILE2="$2"
PREFIX="$3"

if [ -z "$PREFIX" ]; then
    echo "Użycie: $0 index_A.txt index_B.txt raport"
    exit 1
fi

M1="${PREFIX}_missing_in_2.txt"
M2="${PREFIX}_missing_in_1.txt"
DIFF="${PREFIX}_size_diff.csv"
SUMMARY="${PREFIX}_summary.txt"

echo "Porównywanie..."

# brakujące
comm -23 <(cut -d'|' -f1 "$FILE1") \
         <(cut -d'|' -f1 "$FILE2") > "$M1"

comm -13 <(cut -d'|' -f1 "$FILE1") \
         <(cut -d'|' -f1 "$FILE2") > "$M2"

# różnice rozmiarów
join -t '|' -j 1 "$FILE1" "$FILE2" \
| awk -F'|' '$2 != $4 {print $1 "," $2 "," $4}' \
> "$DIFF"

# statystyki
COUNT1=$(wc -l < "$FILE1")
COUNT2=$(wc -l < "$FILE2")
MISS1=$(wc -l < "$M1")
MISS2=$(wc -l < "$M2")
DIFFC=$(wc -l < "$DIFF")

SIZE_DIFF_GB=$(awk -F',' '
{
    diff = $2 - $3
    if (diff < 0) diff = -diff
    sum += diff
}
END {printf "%.2f", sum/1024/1024/1024}
' "$DIFF")

{
echo "========== PODSUMOWANIE =========="
echo "Pliki w A: $COUNT1"
echo "Pliki w B: $COUNT2"
echo "Brakujące w B: $MISS1"
echo "Brakujące w A: $MISS2"
echo "Różnice rozmiarów: $DIFFC"
echo "Łączna różnica danych (GB): $SIZE_DIFF_GB"
echo "=================================="
} > "$SUMMARY"

echo "Gotowe."
echo "Raporty:"
echo "  $SUMMARY"
echo "  $M1"
echo "  $M2"
echo "  $DIFF"
