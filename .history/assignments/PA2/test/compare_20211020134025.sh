#!/bin/bash

chdir("..")

make lexer
chdir("test")

./lexer test.cl > myresult.log


