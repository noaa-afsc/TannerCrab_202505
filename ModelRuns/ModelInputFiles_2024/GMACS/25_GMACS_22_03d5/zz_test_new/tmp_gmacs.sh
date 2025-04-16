#!/bin/sh
echo on
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}
cp ../* 
cp /Users/williamstockhausen/Work/Programming/GMACS-project/GMACS_tpl-cpp_code/_build/gmacs ./gmacs
cp ../* ./
./gmacs  -rs -nox -phase 4 > chk.rep

rm gmacs.bar
            rm gmacs.b0*
            rm gmacs.p0*
            rm gmacs.r0*
            rm *.rept
            rm variance
            rm *.tmp
            rm fmin.log