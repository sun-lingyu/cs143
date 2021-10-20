#!/bin/bash

cd ..
make lexer
cd -

filename=$1

if [[ $filename == "" ]] 
then
    filename="../test.cl"
fi

../lexer $filename > my_result.log
../../../bin/lexer $filename > ref_result.log

diff my_result.log ref_result.log


