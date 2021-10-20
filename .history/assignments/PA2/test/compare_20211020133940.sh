#!/bin/bash

chdir ..

make lexer

cd -

./lexer test.cl > myresult.log


