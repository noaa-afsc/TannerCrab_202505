#--make jitter runs
require(wtsGMACS);

wtsGMACS::runJitter(path2out=".",
                    path2exe="/Users/williamstockhausen/Work/Programming/GMACS-project/GMACS_tpl-cpp_code/_build",
                    path2dat=".",
                    numRuns=200,
                    minPhase=8,
                    calcOFL=FALSE,
                    calcOFLJitter=FALSE,
                    test=FALSE);

