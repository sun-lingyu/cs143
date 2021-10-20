#!/bin/bash

cd ..

make lexer

cd -

./lexer test.cl > myresult.log


