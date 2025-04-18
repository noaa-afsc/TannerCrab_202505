#--make jitter runs
require(wtsGMACS);

wtsGMACS::runJitter(path2out=".",
                    path2exe=".",
                    path2dat=".",
                    numRuns=500,
                    minPhase=4,
                    calcOFL=FALSE,
                    calcOFLJitter=FALSE,
                    test=FALSE);

