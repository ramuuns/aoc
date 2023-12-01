#!/bin/bash

DAY=$1
YEAR=${2:-23}
ZERO_PADDED_DAY=$DAY
if [[ $DAY -lt 10 ]]; then
  ZERO_PADDED_DAY="0$DAY"
fi

if [[ "$YEAR" != "23" ]]; then
  ZERO_PADDED_DAY="$YEAR$ZERO_PADDED_DAY"
fi 

cp template.ex "day-$ZERO_PADDED_DAY.ex"

sed -i '' "s/THE_DAY/$ZERO_PADDED_DAY/g" "day-$ZERO_PADDED_DAY.ex"
sed -i '' "s/NZ_DAY/$DAY/g" "day-$ZERO_PADDED_DAY.ex"

temp_file=$(mktemp)
vi $temp_file

TEST_DATA=$(cat $temp_file)
rm -rf $temp_file

TEST_DATA="${TEST_DATA//
/\\n}"

sed -i '' "s/{test-data}/$TEST_DATA/" "day-$ZERO_PADDED_DAY.ex"

COOKIE=$(cat COOKIE)

curl -H"User-Agent: github.com/ramuuns/aoc/blob/master/20$YEAR/make_day.sh by ramuuns@ramuuns.com" \
     -H"Cookie: session=$COOKIE" \
     "https://adventofcode.com/2023/day/$DAY/input" > "input-$ZERO_PADDED_DAY"

vi "day-$ZERO_PADDED_DAY.ex"

