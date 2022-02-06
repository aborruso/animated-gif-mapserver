#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/resources
mkdir -p "$folder"/processing
mkdir -p "$folder"/gifInput

dataURL="https://zenodo.org/record/5112881/files/Mesibov_collecting_events_1973-2020.txt?download=1"

# download the data it if it doesn't exist
if [ ! -f "$folder"/resources/data.txt ]; then
  curl -L "$dataURL" >"$folder"/resources/data.txt
fi

# extract the useful field
mlr --icsvlite --ocsv --ifs "\t" cut -r -f "(year|decimal)" then uniq -a then sort -f year "$folder"/resources/data.txt >"$folder"/processing/data.txt

# extract the years
mlr --c2n cut -f year then uniq -a "$folder"/processing/data.txt >"$folder"/processing/years.txt

# create one png for each year
cat "$folder"/processing/years.txt | while read year; do
  echo "$year"
  mapserv -nh 'QUERY_STRING=map='"${folder}"'/processing/data.map&mode=map&year='"${year}"'&map_layer[labelyear]=FEATURE+POINTS+300+-560+END+TEXT+"'"${year}"'"+END' > "$folder"/gifInput/${year}.png
done

convert -delay 10 -loop 0 "$folder"/gifInput/*.png "$folder"/animation.gif


