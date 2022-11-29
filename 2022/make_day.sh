#!/bin/bash

DAY=$1
ZERO_PADDED_DAY=$DAY
if [[ $DAY -lt 10 ]]; then
  ZERO_PADDED_DAY="0$DAY"
fi

cp Template.pm "Day$ZERO_PADDED_DAY.pm"

sed -i '' "s/THE_DAY/$ZERO_PADDED_DAY/g" "Day$ZERO_PADDED_DAY.pm"

temp_file=$(mktemp)
vi $temp_file

TEST_DATA=$(cat $temp_file)
rm -rf $temp_file

TEST_DATA="${TEST_DATA//
/\\n}"

sed -i '' "s/{test-data}/$TEST_DATA/" "Day$ZERO_PADDED_DAY.pm"

COOKIE=$(cat COOKIE)

curl -H"Cookie: session=$COOKIE" "https://adventofcode.com/2022/day/$DAY/input" > "input-$ZERO_PADDED_DAY"

vi "Day$ZERO_PADDED_DAY.pm"

