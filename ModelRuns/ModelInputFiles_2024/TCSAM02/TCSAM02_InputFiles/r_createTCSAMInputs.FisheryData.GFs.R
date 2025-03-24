#--write GTF fishery data as TCSAM02 input files 
#----one by gear type, one aggregated across gear types
options(stringsAsFactors=FALSE);
require(tcsamFisheryDataAKFIN);
require(tcsamFunctions);
require(wtsSizeComps);
require(wtsUtilities);

rstudio = rstudioapi::isAvailable();#--is file run from RStudio?
if (rstudio){
  dirPrj = rstudioapi::getActiveProject();
}

#--get assessment setup info
s = wtsUtilities::getObj(file.path(dirPrj,"rda_AssessmentSetup.RData"));

#--output folder
dirOut<-s$dirs$DataTIFs;
if(!dir.exists(dirOut)) dir.create(dirOut);

#--get groundfish fishery info
lstGF = wtsUtilities::getObj(s$fnDataGFs);

#--get crab fisheries info
lstCF = wtsUtilities::getObj(s$fnDataCFsA);

#--calc input sample sizes
dfrSSs_inp.YGX = lstGF$dfrSSs.tnYGAX |> 
                   dplyr::group_by(year,gear,sex) |>
                   dplyr::summarize(ss=sum(ss)) |>
                   dplyr::ungroup() |>
                   akfin.ScaleInputSSs(.ss_scl=lstCF$ss_scl,
                                       .ss_max=lstCF$ss_max);
################################################################################
#--write output to assessment data files for catch by gear type
  years<-1991:(s$asmtYr-1);
  for (g in c("fixed","trawl")){
    #--testing: g="fixed";
    dfrABs <- lstGF$dfrABs.YGAT |> 
                dplyr::filter(gear==g,year %in% years) |>
                dplyr::group_by(year,gear) |>
                dplyr::summarize(num=sum(num),wgt=sum(`wgt (kg)`)) |>
                dplyr::ungroup();
    dfrSSs <- dfrSSs_inp.YGX |> 
                dplyr::filter(gear==g,year %in% years);
    dfrZCs <- lstGF$dfrZCs.tnYGAXZ |> 
                dplyr::filter(gear==g,year %in% years) |>
                dplyr::group_by(year,gear,sex,size) |>
                dplyr::summarize(N=sum(N)) |>
                dplyr::ungroup() |> 
                wtsSizeComps::rebinSizeComps(id.size="size",
                                             id.value="N",
                                             id.facs=c("year","gear","sex"),
                                             cutpts=s$cutptsAM,
                                             truncate.low=TRUE,
                                             truncate.high=FALSE);
    #--calculate missing total abundance
    tmp<-dfrZCs |> 
                dplyr::filter(gear==g,year %in% years) |>
                dplyr::group_by(year,gear) |>
                dplyr::summarize(N=sum(N)) |>
                dplyr::ungroup();
    idx<-!is.na(dfrABs$num);
    dfrABs$num[idx] = tmp$N[idx];
    rm(tmp);
    
    gt = ifelse(g=="undetermined","All",stringr::str_to_sentence(g));
    fn <- file.path(dirOut,paste0("Data.Fishery.",s$asmtYr,".GF_",gt,".inp"));
    
    lstAbd = inputList_AggregateCatchData(
                type="ABUNDANCE",
                dfr = dfrABs |> 
                      dplyr::mutate(sex="undetermined",maturity="undetermined",`shell condition`="undetermined") |>
                      dplyr::select(year,sex,maturity,`shell condition`,value=num),
                cv=0.2,
                minErr=10000,
                optFit="BY_TOTAL",
                likeType="LOGNORMAL",
                likeWgt=1,
                unitsIn="ONES",
                unitsOut="MILLIONS");
                  
    lstBio = inputList_AggregateCatchData(
                type="BIOMASS",
                dfr = dfrABs |> 
                      dplyr::mutate(sex="undetermined",maturity="undetermined",`shell condition`="undetermined") |>
                      dplyr::select(year,sex,maturity,`shell condition`,value=wgt),
                cv=0.2,
                minErr=10000,
                optFit="BY_TOTAL",
                likeType="LOGNORMAL",
                likeWgt=1,
                unitsIn="KG",
                unitsOut="THOUSANDS_MT");
                  
  lstZCs=inputList_SizeCompsData(
           dfrZCs=dfrZCs |> 
                    dplyr::mutate(maturity="undetermined",`shell condition`="undetermined") |>
                    dplyr::select(year,sex,maturity,`shell condition`,size,value=N),
           dfrSSs=dfrSSs |> 
                    dplyr::mutate(maturity="undetermined",`shell condition`="undetermined") |>
                    dplyr::select(year,sex,maturity,`shell condition`,ss),
           cutpts=s$cutptsAM,
           tail_compression=c(0.05,0.05),
           optFit="BY_XE",
           likeType="MULTINOMIAL",
           likeWgt=1,
           unitsIn="ONES",
           unitsOut="MILLIONS");

    akfinWrite_TCSAMInputFile(fishery=paste0("GF_",gt),
                              fn=fn,
                              lstAbd=lstAbd,
                              lstBio=lstBio,
                              lstZCs=lstZCs);
  } #--g

##############################################################################
#--write output to assessment data files aggregated across gear types
years<-1973:(s$asmtYr-1);
g<-"All";
dfrABs <- lstGF$dfrABs.YGAT |> 
            dplyr::filter(year %in% years) |>
            dplyr::group_by(year) |>
            dplyr::summarize(num=sum(num),wgt=sum(`wgt (kg)`)) |>
            dplyr::ungroup();
dfrSSs <- dfrSSs_inp.YGX |> 
            dplyr::filter(year %in% years) |> 
            dplyr::group_by(year,sex) |> 
            dplyr::summarize(ss=wtsUtilities::Sum(ss)) |>
            dplyr::ungroup();
dfrZCs <- lstGF$dfrZCs.tnYGAXZ |> 
            dplyr::filter(year %in% years) |>
            dplyr::group_by(year,sex,size) |>
            dplyr::summarize(N=sum(N)) |>
            dplyr::ungroup() |> 
            wtsSizeComps::rebinSizeComps(id.size="size",
                                         id.value="N",
                                         id.facs=c("year","sex"),
                                         cutpts=s$cutptsAM,
                                         truncate.low=TRUE,
                                         truncate.high=FALSE);
#--recalculate total numbers based on truncated size bins from expanded ZCs
tmp<-dfrZCs |> 
            dplyr::filter(year %in% years) |>
            dplyr::group_by(year) |>
            dplyr::summarize(N=sum(N)) |>
            dplyr::ungroup();
idx<-!is.na(dfrABs$num);
dfrABs$num[idx] = tmp$N[idx];
rm(tmp);

dfrp<-reshape2::dcast(dfrZCs,year+sex~size,fun.aggregate=sum,value.var="N");

lstAbd = inputList_AggregateCatchData(
            type="ABUNDANCE",
            dfr = dfrABs |> 
                  dplyr::mutate(sex="undetermined",maturity="undetermined",`shell condition`="undetermined") |>
                  dplyr::select(year,sex,maturity,`shell condition`,value=num) |>
                  dplyr::filter(!is.na(value)),
            cv=0.2,
            minErr=10000,
            optFit="BY_TOTAL",
            likeType="LOGNORMAL",
            likeWgt=1,
            unitsIn="ONES",
            unitsOut="MILLIONS");
              
lstBio = inputList_AggregateCatchData(
            type="BIOMASS",
            dfr = dfrABs |> 
                  dplyr::mutate(sex="undetermined",maturity="undetermined",`shell condition`="undetermined") |>
                  dplyr::select(year,sex,maturity,`shell condition`,value=wgt),
            cv=0.2,
            minErr=10000,
            optFit="BY_TOTAL",
            likeType="LOGNORMAL",
            likeWgt=1,
            unitsIn="KG",
            unitsOut="THOUSANDS_MT");
              
lstZCs=inputList_SizeCompsData(
         dfrZCs=dfrZCs |> 
                  dplyr::mutate(maturity="undetermined",`shell condition`="undetermined") |>
                  dplyr::select(year,sex,maturity,`shell condition`,size,value=N),
         dfrSSs=dfrSSs |> 
                  dplyr::mutate(maturity="undetermined",`shell condition`="undetermined") |>
                  dplyr::select(year,sex,maturity,`shell condition`,ss),
         cutpts=s$cutptsAM,
         tail_compression=c(0.05,0.05),
         optFit="BY_XE",
         likeType="MULTINOMIAL",
         likeWgt=1,
         unitsIn="ONES",
         unitsOut="MILLIONS");

gt = ifelse(g=="undetermined","All",stringr::str_to_sentence(g));
fn <- file.path(dirOut,paste0("Data.Fishery.",s$asmtYr,".GF_",gt,".inp"));

akfinWrite_TCSAMInputFile(fishery=paste0("GF_",g),
                          fn=fn,
                          lstAbd=lstAbd,
                          lstBio=lstBio,
                          lstZCs=lstZCs);
