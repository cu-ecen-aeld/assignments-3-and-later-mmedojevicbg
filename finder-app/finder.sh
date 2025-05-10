#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Missing required two arguments."
    exit 1
fi
filesdir="$1"
searchstr="$2"
if [ ! -d "$filesdir" ]; then
    echo "Provided argument is not directory."
    exit 1
fi
file_count=$(find "$filesdir" -type f | wc -l)
matching_lines=$(grep -r "$searchstr" "$filesdir" | wc -l)
echo "The number of files are $file_count and the number of matching lines are $matching_lines"
