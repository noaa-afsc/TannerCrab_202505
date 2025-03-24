#create TCSAM02 input files for SBS survey data
require(dplyr);
require(tcsamSurveyData);

#--get assessment project folder
rstudio = rstudioapi::isAvailable();
if (rstudio)
  dirPrj = rstudioapi::getActiveProject();
if (!exists("dirPrj")) stop("dirPrj does not exist!");

#--get assessment setup info
s = wtsUtilities::getObj(file.path(dirPrj,"rda_AssessmentSetup.RData"));

#--Load SBS design-based indices objects
lstDBI = wtsUtilities::getObj(s$fnDataSrvSBS.DBI);

#--output folder
dirOut<-s$dirs$DataTIFs;
if(!dir.exists(dirOut)) dir.create(dirOut);

verbosity = 0;

#--write TCSAM02 input data files for NMFS SBS data
sex         = "MALE";
survey_name = "SBS_NMFS_males";
fnOut       = file.path(dirOut,"Data.Survey.SBS_NMFS.Males.inp");
createInputFile.SurveyData(fnOut,
                           survey_name=survey_name,
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
                           cutpts=s$cutptsAM,
                           dfrACD=lstDBI$lstABs_NMFS$ABs$EBS   |> dplyr::filter(SEX==sex),
                           dfrZCs=lstDBI$lstZCs_NMFS$EBS       |> dplyr::filter(SEX==sex),
                           dfrSSs=lstDBI$lstSSs_NMFS$relSS$EBS |> dplyr::filter(SEX==sex),
                           ssCol="relSS",
                           verbose=TRUE);
rm(sex,survey_name,fnOut);
#------
sex         = "FEMALE";
survey_name = "SBS_NMFS_females";
fnOut       = file.path(dirOut,"Data.Survey.SBS_NMFS.Females.inp");
createInputFile.SurveyData(fnOut,
                           survey_name=survey_name,
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
                           cutpts=s$cutptsAM,
                           dfrACD=lstDBI$lstABs_NMFS$ABs$EBS   |> dplyr::filter(SEX==sex),
                           dfrZCs=lstDBI$lstZCs_NMFS$EBS       |> dplyr::filter(SEX==sex),
                           dfrSSs=lstDBI$lstSSs_NMFS$relSS$EBS |> dplyr::filter(SEX==sex),
                           ssCol="relSS",
                           verbose=TRUE);
rm(sex,survey_name,fnOut);

#--write TCSAM02 input data file for BSFRF SBS data
sex         = "MALE";
survey_name = "SBS_BSFRF_males";
fnOut       = file.path(dirOut,"Data.Survey.SBS_BSFRF.Males.inp");
createInputFile.SurveyData(fnOut,
                           survey_name=survey_name,
                           acdInfo=list(abundance=list(fitType="BY_TOTAL",
                                                        likeType="LOGNORMAL",
                                                        likeWgt=0.0,
                                                        unitsIn="MILLIONS",
                                                        unitsOut="MILLIONS"),
                                        biomass=list(fitType="BY_TOTAL",
                                                      likeType="LOGNORMAL",
                                                      likeWgt=1.0,
                                                      unitsIn="THOUSANDS_MT",
                                                      unitsOut="THOUSANDS_MT")),
                            zcsInfo=list(fitType="BY_TOTAL",
                                         likeType="MULTINOMIAL",
                                         likeWgt=1.0,
                                         tail_compression=c(0.05,0.05),
                                         unitsIn="MILLIONS",
                                         unitsOut="MILLIONS"),
                           cutpts=s$cutptsAM,
                           dfrACD=lstDBI$lstABs_BSFRF$ABs$EBS   |> dplyr::filter(SEX==sex),
                           dfrZCs=lstDBI$lstZCs_BSFRF$EBS       |> dplyr::filter(SEX==sex),
                           dfrSSs=lstDBI$lstSSs_BSFRF$relSS$EBS |> dplyr::filter(SEX==sex),
                           ssCol="relSS",
                           verbose=TRUE);
rm(sex,survey_name,fnOut);
#------
sex         = "FEMALE";
survey_name = "SBS_BSFRF_females";
fnOut     = file.path(s$dirDataSrvSBS,"Data.Survey.SBS_BSFRF.Females.inp");
createInputFile.SurveyData(fnOut,
                           survey_name=survey_name,
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
                           cutpts=s$cutptsAM,
                           dfrACD=lstDBI$lstABs_BSFRF$ABs$EBS   |> dplyr::filter(SEX==sex),
                           dfrZCs=lstDBI$lstZCs_BSFRF$EBS       |> dplyr::filter(SEX==sex),
                           dfrSSs=lstDBI$lstSSs_BSFRF$relSS$EBS |> dplyr::filter(SEX==sex),
                           ssCol="relSS",
                           verbose=TRUE);
rm(sex,survey_name,fnOut);



