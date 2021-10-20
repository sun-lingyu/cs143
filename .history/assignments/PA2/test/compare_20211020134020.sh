#!/bin/bash

chdir("..")

make lexer

chdir("")

./lexer test.cl > myresult.log


