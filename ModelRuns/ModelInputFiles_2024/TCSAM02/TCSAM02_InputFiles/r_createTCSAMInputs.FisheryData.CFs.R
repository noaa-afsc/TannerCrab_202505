#
#--Script to create TCSAM02 input files for Tanner crab from ADFG fishery data
#
#--NOTE: review created files to drop questionable size compositions:
#----TCF: 1990 total catch size comps
#----RKF: 1996 total catch size comps
#--NOTE: 
#----RKF: size comps do not include data from cost recovery fisheries
#----GKF: size comps do not include data from golden king crab fishery
#
rstudio = rstudioapi::isAvailable();#--is file run from RStudio?
if (rstudio){
  dirPrj = rstudioapi::getActiveProject();
}

#--get assessment setup info
s = wtsUtilities::getObj(file.path(dirPrj,"rda_AssessmentSetup.RData"));

#--output folder
dirOut<-s$dirs$DataTIFs;
if(!dir.exists(dirOut)) dir.create(dirOut);

#--load data objects from step 1a and 2a
#     asmtYr,cutpts,dfrMQs,dfrCls,dfrEff,
#     dfrRC_ABs_FAYXMS,dfrRC_SSs_ByFAYXMS,dfrRC_SSs_inp,dfrRC_ZCs_ByFAYXMS,
#     dfrTC_ABs_FAYXMS,dfrTC_SSs_ByFAYXMS,dfrTC_SSs_inp,dfrTC_ZCs_ByFAYXMS,
lstCD = wtsUtilities::getObj(s$fnDataCFsA);#--combined crab fishery data

#--create dataframes for assumed crab fishery CVs
dfrCVsRC = dplyr::bind_rows(
             tibble::tibble(year=1965:1979,cv=0.100,minErr=1000,type="ABUNDANCE"),#--minErr in 1's
             tibble::tibble(year=1980:1995,cv=0.025,minErr=1000,type="ABUNDANCE"),
             tibble::tibble(year=1996:2100,cv=0.010,minErr=1000,type="ABUNDANCE"),
             tibble::tibble(year=1965:1979,cv=0.100,minErr=1000,type="BIOMASS"),#--minErr in KG
             tibble::tibble(year=1980:1995,cv=0.025,minErr=1000,type="BIOMASS"),
             tibble::tibble(year=1996:2100,cv=0.010,minErr=1000,type="BIOMASS"));
dfrCVsTC = dplyr::bind_rows(
             tibble::tibble(year=1965:2100,cv=0.200,minErr=10000,type="ABUNDANCE"),#--minErr in 1's
             tibble::tibble(year=1965:2100,cv=0.200,minErr=10000,type="BIOMASS"));#--minErr in KG

#--write DATA to FILES

#----define tables with non-closed years to exclude from input
dropTC_ZCs<-rbind(tibble::tibble(fishery="TCF",drop=c(1990)),
                  tibble::tibble(fishery="RKF",drop=c(1996)));
#----loop over fisheries
effAvg = c("SCF","RKF");
for (f in c("RKF","SCF","TCF")){
  #--testing: f = "TCF";
  #--extract closure info
  closed = lstCD$dfrCls |> dplyr::filter(fishery==f,area=="all EBS");
  if (nrow(closed)==0){
    closed = NULL;
  } else {
    closed=closed$year;
  }
  #--define effort data input list
  lstEff = NULL;
  if (f %in% effAvg){
    tmpEff<-lstCD$dfrEff |> dplyr::filter(fishery==f,area=="all EBS");
    lstEff = tcsamFunctions::inputList_EffortData(
                               dfr=tmpEff,
                               avgInterval="[1992:-1]",
                               likeType = "NORM2",
                               likeWgt = 1,
                               unitsIn = "ONES",
                               unitsOut = "ONES"
                             );
  }
  
  #--define retained catch data list (only TCF)
  lstRC = NULL;
  if (f=="TCF"){
    tmpRC_ABs<-lstCD$dfrRC_ABs_FAYXMS   |> subset((fishery==f)&(area=="all EBS"));
    tmpRC_ZCs<-lstCD$dfrRC_ZCs_ByFAYXMS |> subset((fishery==f)&(area=="all EBS"));
    tmpRC_SSs<-lstCD$dfrRC_SSs_inp      |> subset((fishery==f)&(area=="all EBS"));
    lstAbd=tcsamFunctions::inputList_AggregateCatchData(
                             type="ABUNDANCE",
                             dfr=tmpRC_ABs |> dplyr::select(year,sex,maturity,`shell condition`,value=abundance),
                             cv=dfrCVsRC |> dplyr::filter(type=="ABUNDANCE"), #--assumed cv's by year
                             minErr=1000,  #--
                             optFit="BY_X",
                             likeType="LOGNORMAL",
                             likeWgt=0,
                             unitsIn = "ONES",
                             unitsOut="MILLIONS"
                           );
    lstBio=tcsamFunctions::inputList_AggregateCatchData(
                             type="BIOMASS",
                             dfr=tmpRC_ABs |> dplyr::select(year,sex,maturity,`shell condition`,value=`biomass (kg)`),
                             cv=dfrCVsRC |> dplyr::filter(type=="BIOMASS"), #--assumed cv's by year
                             minErr=1000,  #--in kg
                             optFit="BY_X",
                             likeType="LOGNORMAL",
                             likeWgt=1,
                             unitsIn = "KG",
                             unitsOut="MILLIONS_LBS"
                           );
    lstZCs=tcsamFunctions::inputList_SizeCompsData(
                             dfrZCs=tmpRC_ZCs |> dplyr::select(year,sex,maturity,`shell condition`,size,value=abundance),
                             dfrSSs=tmpRC_SSs,
                             cutpts = s$cutptsAM,
                             tail_compression = c(0.05,0.05),
                             optFit = "BY_X",
                             likeType="MULTINOMIAL",
                             likeWgt=1,
                             unitsIn="ONES",
                             unitsOut="MILLIONS"
                           );
    lstRC = list(lstAbd=lstAbd,lstBio=lstBio,lstZCs=lstZCs);
    rm(lstAbd,lstBio,lstZCs);
  }
  #--define total catch data list
  dropZCs<-(dropTC_ZCs |> dplyr::filter(fishery==f))$drop;
  tmpTC_ABs<-lstCD$dfrTC_ABs_FAYXMS |> dplyr::filter(fishery==f,area=="all EBS") |>
                                        dplyr::group_by(fishery,area,year,sex) |>
                                        dplyr::summarize(abundance=wtsUtilities::Sum(abundance),
                                                         `biomass (kg)`=wtsUtilities::Sum(`biomass (kg)`)) |>
                                        dplyr::ungroup() |>
                                        dplyr::mutate(maturity="undetermined",
                                                      `shell condition`="undetermined");
  tmpTC_ZCs<-lstCD$dfrTC_ZCs_ByFAYXMS |> dplyr::filter(fishery==f,area=="all EBS",!(year %in% dropZCs));
  tmpTC_SSs<-lstCD$dfrTC_SSs_inp      |> dplyr::filter(fishery==f,area=="all EBS",!(year %in% dropZCs));
  lstAbd=tcsamFunctions::inputList_AggregateCatchData(
                            type="ABUNDANCE",
                            dfr=tmpTC_ABs |> dplyr::select(year,sex,maturity,`shell condition`,value=abundance),
                            cv=dfrCVsTC |> dplyr::filter(type=="ABUNDANCE"), #--assumed cv's by year
                            minErr=10000, #--in counts (so 0.01M)
                            optFit="BY_TOTAL",
                            likeType="LOGNORMAL",
                            likeWgt=0,
                            unitsIn="ONES",
                            unitsOut="MILLIONS"
                         );
  lstBio=tcsamFunctions::inputList_AggregateCatchData(
                            type="BIOMASS",
                            dfr=tmpTC_ABs |> dplyr::select(year,sex,maturity,`shell condition`,value=`biomass (kg)`),
                            cv=dfrCVsTC |> dplyr::filter(type=="ABUNDANCE"), #--assumed cv's by year
                            minErr=10000, #--in kg (so 10 t, 0.01kt, or 0.022 mlbs)
                            optFit="BY_TOTAL",
                            likeType="LOGNORMAL",
                            likeWgt=1,
                            unitsIn="KG",
                            unitsOut="MILLIONS_LBS"
                        );
  dfrZCs=tmpTC_ZCs |> dplyr::select(year,sex,maturity,`shell condition`,size,value=abundance);
  lstZCs=tcsamFunctions::inputList_SizeCompsData(
                           dfrZCs=dfrZCs,
                           dfrSSs=tmpTC_SSs,
                           cutpts=s$cutptsAM,
                           tail_compression=c(0.05,0.05),
                           optFit="BY_XE",
                           likeType="MULTINOMIAL",
                           likeWgt=1,
                           unitsIn="ONES",
                           unitsOut="MILLIONS"
                        );
  lstTC = list(lstAbd=lstAbd,lstBio=lstBio,lstZCs=lstZCs);
  rm(lstAbd,lstBio,lstZCs,dfrZCs);
  #--write file
  tcsamFisheryDataADFG::adfgWrite_TCSAMInputFile(
                          fishery=f,
                          fn=file.path(dirOut,paste0("Data.Fishery",".",s$asmtYr,".",f,".inp")),
                          closed=closed,
                          lstRC=lstRC,
                          lstTC=lstTC,
                          lstEff=lstEff
                        );
  rm(lstRC,lstTC,lstEff);
}
rm(f);

