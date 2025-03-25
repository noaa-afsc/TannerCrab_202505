#!/bin/sh
echo on
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}
cp /Users/williamstockhausen/Work/StockAssessments-Crab/AssessmentModelDevelopment/VS_Code/tcsam02/_build/tcsam02 ./tcsam02
./tcsam02  -rs -nox  -configFile ../MCI.inp -phase 5  -calcOFL -nohess -pin tcsam02.pin

