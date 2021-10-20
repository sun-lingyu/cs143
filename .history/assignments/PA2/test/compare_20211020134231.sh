#!/bin/bash

cd ..
make lexer
cd -

../lexer ../test.cl > my_result.log
../../../bin/lexer test.cl > ref_result.log

diff my_result.log ref_result.log


