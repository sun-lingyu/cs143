#!/bin/zsh

# execute the following command in assignment/PA3 folder:
# ./test/compare.sh
# then diff between referece-parser and my-parser will be printed to terminal

if [[ $1 = "" ]]
then
    echo "must give a filename"
    exit 1
fi

./myparser $1 > test/myresult.log
./myparser-right $1 > test/myresult-right.log

diff myresult.log myresult-right.log