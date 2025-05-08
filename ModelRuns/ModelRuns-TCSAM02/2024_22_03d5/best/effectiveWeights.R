effWgts=list(
#--Calculating effective weights in FINAL_PHASE--
effWgts.final=list(
surveys=#--Starting calcWeightsForSurveySizeComps()
list(
#--calculating size comps weights for survey NMFS_M
`NMFS_M`=list(
index.catch=list(
effWgts=
structure(c(49, 0.885321, 0.891896, 0, 1, 1),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('all maturity'), s=c('all shell')),dim=c(3, 2, 1, 1)))
),
#--calculating size comps weights for survey NMFS_F
`NMFS_F`=list(
index.catch=list(
effWgts=
structure(c(0, 1, 1, 49, 0.973081, 0.320649, 0, 1, 1, 49, 1.39782, 0.331459),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('immature', 'mature'), s=c('all shell')),dim=c(3, 2, 2, 1)))
),
#--calculating size comps weights for survey SBS_NMFS_M
`SBS_NMFS_M`=list(
index.catch=list(
effWgts=
structure(c(5, 0.507016, 1.10931, 0, 1, 1),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('all maturity'), s=c('all shell')),dim=c(3, 2, 1, 1)))
),
#--calculating size comps weights for survey SBS_NMFS_F
`SBS_NMFS_F`=list(
index.catch=list(
effWgts=
structure(c(0, 1, 1, 5, 1.51267, 0.254709, 0, 1, 1, 5, 1.48277, 0.616628),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('immature', 'mature'), s=c('all shell')),dim=c(3, 2, 2, 1)))
),
#--calculating size comps weights for survey SBS_BSFRF_M
`SBS_BSFRF_M`=list(
index.catch=list(
effWgts=
structure(c(6, 0.389886, 0.826735, 0, 1, 1),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('all maturity'), s=c('all shell')),dim=c(3, 2, 1, 1)))
),
#--calculating size comps weights for survey SBS_BSFRF_F
`SBS_BSFRF_F`=list(
index.catch=list(
effWgts=
structure(c(0, 1, 1, 6, 0.535419, 0.126241, 0, 1, 1, 6, 1.65292, 0.66784),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('immature', 'mature'), s=c('all shell')),dim=c(3, 2, 2, 1)))
),
NULL)
#--Finished calcWeightsForSurveySizeComps()
,
fisheries=#--Starting calcWeightsForFisherySizeComps()
list(
#--calculating effective weights for fishery TCF
`TCF`=list(
retained.catch=list(
#---retained catch size frequencies
effWgts=
structure(c(28, 1.15483, 0.377971, 0, 1, 1),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('male', 'female'), m=c('all maturity'), s=c('all shell')),dim=c(3, 2, 1, 1))),
total.catch=list(
#---total catch size frequencies
effWgts=
structure(c(20, 0.567295, 0.363288),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('all sex'), m=c('all maturity'), s=c('all shell')),dim=c(3, 1, 1, 1))),
NULL),
#--calculating effective weights for fishery SCF
`SCF`=list(
total.catch=list(
#---total catch size frequencies
effWgts=
structure(c(32, 1.57387, 0.353561),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('all sex'), m=c('all maturity'), s=c('all shell')),dim=c(3, 1, 1, 1))),
NULL),
#--calculating effective weights for fishery GF_All
`GF_All`=list(
total.catch=list(
#---total catch size frequencies
effWgts=
structure(c(51, 1.20241, 1.1691),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('all sex'), m=c('all maturity'), s=c('all shell')),dim=c(3, 1, 1, 1))),
NULL),
#--calculating effective weights for fishery RKF
`RKF`=list(
total.catch=list(
#---total catch size frequencies
effWgts=
structure(c(29, nan, nan),
      dimnames=list(c('N','McAllister-Ianelli','Francis'), x=c('all sex'), m=c('all maturity'), s=c('all shell')),dim=c(3, 1, 1, 1))),
NULL),
NULL)
#--Finished calcWeightsForFisherySizeComps()

)
#--Finished calculating effective weights in FINAL_PHASE--
)
