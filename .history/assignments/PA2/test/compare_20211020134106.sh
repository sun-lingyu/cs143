#!/bin/bash

chdir("..")
make lexer
chdir("test")

../lexer ../test.cl > my_result.log
../../../bin/lexer test.cl > ref_result.log



