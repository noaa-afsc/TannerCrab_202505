#!/bin/sh
echo on
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}
cp /Users/williamstockhausen/Work/Programming/GMACS-project/GMACS_tpl-cpp_code/_build/gmacs ./gmacs
./gmacs  -rs -nox -phase 8  -ainp gmacs.pin
./gmacs  -rs -nox -phase 8  -binp gmacs.bar -hess_step 5

rm gmacs.b0*
rm gmacs.p0*
rm gmacs.r0*
rm *.rept
rm variance
rm *.tmp
rm fmin.log