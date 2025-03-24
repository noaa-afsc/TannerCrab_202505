#Create TCSAM02 files from NMFS Survey Data design-based indices
require(tcsamSurveyData);

#--get assessment project folder
rstudio = rstudioapi::isAvailable();
if (rstudio)
  dirPrj = rstudioapi::getActiveProject();
if (!exists("dirPrj")) stop("dirPrj does not exist!");

#--get assessment setup info
s = wtsUtilities::getObj(file.path(dirPrj,"rda_AssessmentSetup.RData"));

#--output folder
dirOut<-s$dirs$DataTIFs;
if(!dir.exists(dirOut)) dir.create(dirOut);

#--Load NMFS design-based indices objects
lstDBI = wtsUtilities::getObj(s$fnDataSrvNMFS.DBI);
mxYr   = max(lstDBI$lstABs$ABs$EBS$YEAR);

#--write TCSAM02 input data file for male NMFS data
createInputFile.SurveyData(file.path(dirOut,fn=paste0("Data.Survey.",mxYr,".NMFS_M.inp")),
                           survey_name="NMFS_M",
                           cutpts=s$cutptsAM,
                           acdInfo=list(abundance=list(fitType="BY_X",
                                                        likeType="LOGNORMAL",
                                                        likeWgt=0.0,
                                                        unitsIn="MILLIONS",
                                                        unitsOut="MILLIONS"),
                                        biomass=list(fitType="BY_X",
                                                      likeType="LOGNORMAL",
                                                      likeWgt=1.0,
                                                      unitsIn="THOUSANDS_MT",
                                                      unitsOut="THOUSANDS_MT")),
                            zcsInfo=list(fitType="BY_X",
                                         likeType="MULTINOMIAL",
                                         likeWgt=1.0,
                                         tail_compression=c(0.05,0.05),
                                         unitsIn="MILLIONS",
                                         unitsOut="MILLIONS"),
                           dfrACD=lstDBI$lstABs$ABs$EBS   |> dplyr::filter(SEX=="MALE"),
                           dfrZCs=lstDBI$lstZCs$EBS       |> dplyr::filter(SEX=="MALE"),
                           dfrSSs=lstDBI$lstSSs$relSS$EBS |> dplyr::filter(SEX=="MALE"),
                           ssCol="relSS",
                           verbose=TRUE);
#--write TCSAM02 input data file for female NMFS data
createInputFile.SurveyData(file.path(dirOut,paste0("Data.Survey.",mxYr,".NMFS_F.inp")),
                           survey_name="NMFS_F",
                           cutpts=s$cutptsAM,
                            acdInfo=list(abundance=list(fitType="BY_XM",
                                                        likeType="LOGNORMAL",
                                                        likeWgt=0.0,
                                                        unitsIn="MILLIONS",
                                                        unitsOut="MILLIONS"),
                                         biomass=list(fitType="BY_XM",
                                                      likeType="LOGNORMAL",
                                                      likeWgt=1.0,
                                                      unitsIn="THOUSANDS_MT",
                                                      unitsOut="THOUSANDS_MT")),
                            zcsInfo=list(fitType="BY_XM",
                                         likeType="MULTINOMIAL",
                                         likeWgt=1.0,
                                         tail_compression=c(0.05,0.05),
                                         unitsIn="MILLIONS",
                                         unitsOut="MILLIONS"),
                           dfrACD=lstDBI$lstABs$ABs$EBS   |> dplyr::filter(SEX=="FEMALE"),
                           dfrSSs=lstDBI$lstSSs$relSS$EBS |> dplyr::filter(SEX=="FEMALE"),
                           dfrZCs=lstDBI$lstZCs$EBS       |> dplyr::filter(SEX=="FEMALE"),
                           ssCol="relSS",
                           verbose=TRUE);

