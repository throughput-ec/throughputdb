#! /bin/bash

mkdir -p ./data/input/awards

for i in {1959..2020}
do
  curl -o ./data/input/awards/$i.zip "https://www.nsf.gov/awardsearch/download?DownloadFileName=$i&All=true"
done
