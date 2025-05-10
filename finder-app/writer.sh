#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Missing two arguments."
    exit 1
fi
writefile="$1"
writestr="$2"
dir_path=$(dirname "$writefile")
mkdir -p "$dir_path"
echo "$writestr" > "$writefile"
if [ $? -ne 0 ]; then
    echo "Write file failed"
    exit 1
fi
exit 0
