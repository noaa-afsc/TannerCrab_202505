require(ggplot2)
require(wtsGMACS)
dirPrj = rstudioapi::getActiveProject();
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);
setwd(dirThs);

#--get TCSAM02 22_03d5 model results
resTCSAM02 = list(tcsam02=
                    wtsUtilities::getObj(file.path(dirPrj,"ModelRuns/ModelRuns-TCSAM02/2024_22_03d5/best_results/Results.RData")));

#--read gmacs.rep1 and Gmacsall.out files----
fldrs = list("25_03"="run");
resGMACS = wtsGMACS::readModelResultsAlt(fldrs,TRUE);
wtsUtilities::saveObj(resGMACS,"rda_GMACS_reslstALt.RData");

rep = resGMACS$`25_03`$rep;

#--model configuration----
zBs = rep$size_midpoints;
nZBs = length(zBs);

#--estimated parameters----
dfrEstPars = rep$`Estimated parameters` |>
               dplyr::mutate(
                 dplyr::across(!par_type,as.numeric)
               );
View(dfrEstPars);
##--check parameters at bounds----
dfrPsAtBs = dfrEstPars |>
              dplyr::filter((!is.na(status)) & (status!=0));
View(dfrPsAtBs)
##--check other parameters?----
dfrOthrPs = dfrEstPars |>
              dplyr::filter(est_par_cnt==132);#--

#--Summary dataframe----
dfrSmry = rep$Summary |>
           dplyr::mutate(dplyr::across(dplyr::everything(),as.numeric));

#--estimated population quantities----
##--recruitment----
dfrR_y = dplyr::bind_rows(
           rep$R_y |>
             dplyr::mutate(dplyr::across(dplyr::everything(),as.numeric),
                           model="GMACS"),
           rCompTCMs::extractMDFR.Pop.Recruitment(resTCSAM02) |>
             dplyr::select(year=y,est=val) |>
             dplyr::mutate(dplyr::across(dplyr::everything(),as.numeric),
                           model="TCSAM02")
         );
ggplot(dfrR_y,aes(x=year,y=est,colour=model)) +
  geom_point() + geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  labs(y="Recruitment (milions)") +
  wtsPlots::getStdTheme();

ggplot(dfrSmry,aes(x=year,y=rec_dev)) +
  geom_point() + geom_line() +
  geom_hline(yintercept=0,linetype=3) +
  scale_y_continuous() +
  labs(y="ln-scale rec devs") +
  wtsPlots::getStdTheme();

##--size at recruitment----
dfrR_z=dplyr::bind_rows(
         rep$R_z |> dplyr::filter(sex=="male") |>
           dplyr::mutate(dplyr::across(2:3,as.numeric),
                         model="GMACS",
                         sex="all"),
         rCompTCMs::extractMDFR.Pop.RecSizeDistribution(resTCSAM02) |>
           dplyr::filter(pc==2) |> dplyr::select(sex=x,size=z,est=val) |>
           dplyr::mutate(dplyr::across(2:3,as.numeric),
                         model="TCSAM02")
       );
ggplot(dfrR_z,aes(x=size,y=est,colour=model)) +
  geom_line() +
  labs(y="proportion") +
  wtsPlots::getStdTheme();

##--population numbers-at-population category-and-size----
#--GMACS run has only one shell condition
dfrN_YXMSZg = rep$N_YXMSZ |>
               tidyr::pivot_longer(cols=!c(year,sex,maturity,shell_con),
                                   names_to="size",
                                   values_to="est") |>
               dplyr::select(y=year,x=sex,m=maturity,s=shell_con,z=size,val=est) |>
               dplyr::mutate(dplyr::across(c(y,z,val),as.numeric),
                             s="all",
                            case="gmacs") |>
               rCompTCMs::getMDFR.CanonicalFormat();
dfrN_YXMSZt = rCompTCMs::extractMDFR.Pop.Abundance(resTCSAM02,cast="y+x+m+z") |>
                dplyr::mutate((dplyr::across(c(y,z,val),as.numeric)));
dfrN_YXMSZ = dplyr::bind_rows(dfrN_YXMSZg,dfrN_YXMSZt);
###--final population abundance by category and size----
dfrNF = dfrN_YXMSZ |>
          dplyr::filter(y==2024);
ggplot(dfrNF,aes(x=z,y=val,colour=case)) +
  geom_point() +
  geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  labs(y="Population Abdundance (millions)") +
  facet_grid(m~x) +
  wtsPlots::getStdTheme();
###--population abundance by sex, maturity----
dfrN_YXM = dfrN_YXMSZ |>
             dplyr::group_by(case,y,x,m) |>
             dplyr::summarize(val=sum(val)) |>
             dplyr::ungroup();
ggplot(dfrN_YXM,aes(x=y,y=val,colour=case)) +
  geom_point() + geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  labs(y="Population Abdundance (millions)") +
  facet_grid(m~x) +
  wtsPlots::getStdTheme();

##--population biomass by population category and size----
dfrB_YXMSZg = rep$B_YXMSZ |>
               tidyr::pivot_longer(cols=!c(year,sex,maturity,shell_con),
                                   names_to="size",
                                   values_to="est") |>
               dplyr::select(y=year,x=sex,m=maturity,s=shell_con,z=size,val=est) |>
               dplyr::mutate(dplyr::across(c(y,z,val),as.numeric),
                             s="all",
                            case="gmacs") |>
               rCompTCMs::getMDFR.CanonicalFormat();
dfrB_YXMSZt = rCompTCMs::extractMDFR.Pop.Biomass(resTCSAM02,cast="y+x+m+z") |>
                dplyr::mutate((dplyr::across(c(y,z,val),as.numeric)));
dfrB_YXMSZ = dplyr::bind_rows(dfrB_YXMSZg,dfrB_YXMSZt);
###--final population biomass by category and size----
dfrBF = dfrB_YXMSZ |>
          dplyr::filter(y==2024);
ggplot(dfrBF,aes(x=z,y=val,colour=case)) +
  geom_point() +
  geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  labs(y="Population Biomass (1,000's t)") +
  facet_grid(m~x) +
  wtsPlots::getStdTheme();
###--population biomass by sex, maturity----
dfrB_YXM = dfrB_YXMSZ |>
             dplyr::group_by(case,y,x,m) |>
             dplyr::summarize(val=sum(val)) |>
             dplyr::ungroup();
ggplot(dfrN_YXM,aes(x=y,y=val,colour=case)) +
  geom_point() + geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  labs(y="Population Biomass (1,000's t)") +
  facet_grid(m~x) +
  wtsPlots::getStdTheme();

#--selectivity----
dfrSelg = rep$selfcns |>
           tidyr::pivot_longer(cols=4+(1:nZBs),names_to="z",values_to="val") |>
           dplyr::rename(y=year,x=sex) |>
           dplyr::mutate(dplyr::across(c(2,5,6),as.numeric),
                         case="gmacs") |>
           dplyr::filter(type!="discard") |>
           rCompTCMs::getMDFR.CanonicalFormat();
dfrSelt = dplyr::bind_rows(
            rCompTCMs::extractMDFR.Fisheries.RetFcns(resTCSAM02) |> dplyr::mutate(type="retained"),
            rCompTCMs::extractMDFR.Fisheries.SelFcns(resTCSAM02) |> dplyr::mutate(type="capture"),
            rCompTCMs::extractMDFR.Surveys.SelFcns(resTCSAM02) |> dplyr::mutate(type="capture")
          ) |> dplyr::mutate((dplyr::across(c(y,z,val),as.numeric)));
dfrSel = dplyr::bind_rows(dfrSelg,dfrSelt);
##--surveys----
tmp =  dfrSel |> dplyr::filter(fleet %in% fleets,type=="capture",year==1982)
ggplot(dfrSel |> dplyr::filter(fleet %in% fleets,type=="capture",year==1982),
       aes(x=size,y=est,colour=sex)) +
  geom_line() +
  facet_wrap(~sex,ncol=1) +
  scale_y_continuous(limits=c(0,NA)) +
  wtsPlots::getStdTheme();
##--retained selectivity, directed fishery----
fleets = c("TCF");
tmp =  dfrSel |> dplyr::filter(fleet %in% fleets,type=="retained",year==1982)
ggplot(dfrSel |> dplyr::filter(fleet %in% fleets,type=="retained",year==1982),
       aes(x=size,y=est,colour=sex)) +
  geom_point() + geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  facet_wrap(~fleet,ncol=1) +
  labs(y="Retention") +
  wtsPlots::getStdTheme()
##--capture selectivity, crab fisheries----
fleets = c("TCF","SCF","RKF");
tmp =  dfrSel |> dplyr::filter(fleet %in% fleets,type=="capture",year==1982)
ggplot(dfrSel |> dplyr::filter(fleet %in% fleets,type=="capture",year==1982),
       aes(x=size,y=est,colour=sex)) +
  geom_point() + geom_line() +
  scale_y_continuous(limits=c(0,NA)) +
  facet_wrap(~fleet,ncol=1) +
  labs(y="Capture Selectivity") +
  wtsPlots::getStdTheme()
##--capture selectivity, groundfish fisheries----
fleets = c("GFA");
tmp =  dfrSel |> dplyr::filter(fleet %in% fleets,type=="capture",year %in% c(1982,2000))
ggplot(dfrSel |> dplyr::filter(fleet %in% fleets,type=="capture",year %in% c(1982,2000)),
       aes(x=size,y=est,colour=sex)) +
  geom_point() + geom_line() +
  facet_wrap(~fleet,ncol=1) +
  labs(y="Capture Selectivity") +
  wtsPlots::getStdTheme();

#--growth----
sexes = c("male","female");
dfrObsGrowth = lstAll$growth_data |>
                 dplyr::mutate(sex=sexes[as.integer(sex)],
                               `premolt size`=as.numeric(premolt_size),
                               observed=as.numeric(obs_postmolt_size),
                               predicted=as.numeric(prd_postmolt_size),
                               nll=as.numeric(nll),
                               .keep="none");
ggplot(dfrObsGrowth,aes(x=`premolt size`)) +
  geom_point(aes(y=observed)) + geom_line(aes(y=predicted)) +
  facet_grid(sex~.) +
  geom_abline(slope=1,linetype=3) +
  wtsPlots::getStdTheme();

##--mean growth----
dfrMnGr = rep$`Mean growth` |>
            dplyr::mutate(dplyr::across(3:5,as.numeric));
ggplot(dfrMnGr,aes(x=premolt_size,y=mean_postmolt_size,colour=block)) +
  geom_line() +
  geom_abline(slope=1,linetype=3) +
  scale_y_continuous() +
  labs(x="pre-molt size (mm CW)",y="mean post-molt size (mm CW}") +
  facet_wrap(~sex,ncol=1) +
  wtsPlots::getStdTheme()
##--growth matrices----
dfrPrGr = rep$growth_matrix |>
            tidyr::pivot_longer(cols=!c(sex,block,premolt_size),
                                names_to="postmolt_size",values_to="est") |>
           dplyr::mutate(dplyr::across(3:5,as.numeric));
ggplot(dfrPrGr |> dplyr::filter(est>0.0001),
       aes(x=premolt_size,y=postmolt_size,size=est,fill=est)) +
  geom_point(alpha=0.5,shape=21) +
  scale_size_area() +
  geom_line(aes(x=premolt_size,y=mean_postmolt_size),data=dfrMnGr,inherit.aes=FALSE) +
  geom_abline(slope=1,linetype=3) +
  scale_fill_viridis_c(option="magma") +
  facet_wrap(~sex,ncol=1) +
  labs(x="pre-molt size (mm CW)",y="postmolt size (mm CW)") +
  wtsPlots::getStdTheme();
##--size transition matrices----
dfrPrTr = rep$size_matrix |>
            tidyr::pivot_longer(cols=!c(sex,block,premolt_size),
                                names_to="postmolt_size",values_to="est") |>
           dplyr::mutate(dplyr::across(3:5,as.numeric));
ggplot(dfrPrTr |> dplyr::filter(est>0.0001),
       aes(x=premolt_size,y=postmolt_size,size=est,fill=est)) +
  geom_point(alpha=0.5,shape=21) +
  scale_size_area() +
  geom_line(aes(x=premolt_size,y=mean_postmolt_size),data=dfrMnGr,inherit.aes=FALSE) +
  geom_abline(slope=1,linetype=3) +
  scale_fill_viridis_c(option="magma") +
  facet_wrap(~sex,ncol=1) +
  labs(x="pre-molt size (mm CW)",y="postmolt size (mm CW)") +
  wtsPlots::getStdTheme();

#----maturity----
dfrPrM2M = rep$prMature |>
                tidyr::pivot_longer(cols=!c(year,sex),
                                    names_to="size",values_to="est") |>
                dplyr::mutate(dplyr::across(c(year,size,est),as.numeric));
ggplot(dfrPrM2M |> dplyr::filter(year==1982),
       aes(x=size,y=est,colour=sex)) +
  geom_point() + geom_line() +
  scale_y_continuous(limits=c(0,NA))+
  labs(y="Estimated Pr(terminal molt)") +
#  facet_wrap(~sex,ncol=1) +
  wtsPlots::getStdTheme();

#--natural mortality----
dfrMbyYXMZ = rep$`Natural_mortality-by-class` |>
              tidyr::pivot_longer(cols=!c(year,sex,maturity),
                                  names_to="size",values_to="est") |>
              dplyr::mutate(dplyr::across(c(year,size,est),as.numeric));
ggplot(dfrMbyYXMZ |> dplyr::filter(year==1982),
       aes(x=size,y=est,colour=maturity)) +
  geom_point() +
  scale_y_continuous(limits=c(0,NA))+
  labs(y="Estimated M") +
  facet_wrap(~sex,ncol=1) +
  wtsPlots::getStdTheme();

#--fishing mortality-----
##--fully-selected fishing mortality rates----
dfrFMbyXFY = rep$`Fully-selected_FM_by_season_sex_and_fishery` |>
              tidyr::pivot_longer(cols=!c("sex","fleet","year"),
                                  names_to="season",
                                  values_to="est") |>
              dplyr::mutate(
                dplyr::across(c(year,est),as.numeric)
              ) |>
              dplyr::group_by(fleet,season) |>
              dplyr::filter(sum(est)>0) |>
              dplyr::ungroup();
crbFshs = c("TCF","SCF","RKF")
ggplot(dfrFMbyXFY |> dplyr::filter(fleet=="TCF"),
       aes(x=year,y=est,colour=fleet)) +
  geom_point() + geom_line() +
  facet_wrap(~sex,ncol=1,scales="free_y") +
  labs(y="Fully-selected Fishing Mortality") +
  wtsPlots::getStdTheme();
ggplot(dfrFMbyXFY |> dplyr::filter((fleet %in% "SCF")),
       aes(x=year,y=est,colour=fleet)) +
  geom_point() + geom_line() +
  geom_hline(yintercept=0) +
  facet_wrap(~sex,ncol=1,scales="free_y") +
  labs(y="Fully-selected Fishing Mortality") +
  wtsPlots::getStdTheme();
ggplot(dfrFMbyXFY |> dplyr::filter(fleet=="RKF"),
       aes(x=year,y=est,colour=fleet)) +
  geom_point() + geom_line() +
  facet_wrap(~sex,ncol=1,scales="free_y") +
  labs(y="Fully-selected Fishing Mortality") +
  wtsPlots::getStdTheme();
ggplot(dfrFMbyXFY |> dplyr::filter((fleet %in% "GFA")),
       aes(x=year,y=est,colour=fleet)) +
  geom_point() + geom_line() +
  facet_wrap(~sex,ncol=1,scales="free_y") +
  labs(y="Fully-selected Fishing Mortality") +
  wtsPlots::getStdTheme();
dfrFMbyXFY |> dplyr::filter(fleet!="TCF",year==2020);

##--fishing mortality parameters----
dfrFPs = rep$logFM_parameters |>
           dplyr::mutate(
             dplyr::across(c(index,est),as.numeric)
           );
surveys = c("NMFS","BSFRF");
ggplot() +
  geom_point(data=dfrFPs |> dplyr::filter(!is.na(index),!(fleet %in% surveys)),
             mapping=aes(x=index,y=est,colour=fleet)) +
  geom_hline(yintercept=0,linetype=1,color="black") +
  geom_hline(data=dfrFPs |> dplyr::filter(is.na(index),!(fleet %in% surveys)),
             mapping=aes(yintercept=est,colour=fleet,linetype=sex)) +
  facet_wrap(~fleet,dir="v")

##--total mortality----
dfrTM = rep$`TM-by-size-class_(continuous)`



#--fits to data----
##--catch data----
dfrCatFitg = rep$Catch_fit_summary |>
              dplyr::mutate(
                dplyr::across(c(year,obs,cv,effort,HM,prd,rsd),
                              as.numeric)
              ) |>
              dplyr::select(type,y=year,fleet,x=sex,val=prd) |>
              dplyr::group_by(type,fleet,y) |>
              dplyr::summarize(val=sum(val)) |>
              dplyr::ungroup() |>
              dplyr::mutate(case="gmacs",
                            catch.type=type,
                            type="predicted",
                            x="undetermined");
dfrCatFitt = dplyr::bind_rows(
              rCompTCMs::extractMDFR.Fits.BiomassData(resTCSAM02,
                                                       fleet.type="fishery",
                                                       catch.type="retained") |>
                dplyr::mutate(catch.type="retained"),
              rCompTCMs::extractMDFR.Fits.BiomassData(resTCSAM02,
                                                       fleet.type="fishery",
                                                       catch.type="total") |>
                dplyr::mutate(catch.type="total")) |>
            dplyr::select(case,fleet,catch.type,type,y,x,val,lci,uci) |>
            dplyr::mutate(fleet=ifelse(stringr::str_starts(fleet,"GF All"),"GFA",fleet),
                          x="undetermined");
dfrCatFit = dplyr::bind_rows(dfrCatFitt,dfrCatFitg);
plotDFR<-function(dfr,yax){
  mny = min((dfr |> dplyr::filter(type=="observed"))$y);
  dfr = dfr |> dplyr::filter(y>mny);
  p = ggplot(dfr,aes(x=y,y=val,ymin=lci,ymax=uci,colour=case,fill=case,shape=case)) +
        geom_point(data=dfr |> dplyr::filter(type=="observed"),colour="blue",shape=24) +
        geom_ribbon(data=dfr |> dplyr::filter(type=="observed"),colour=NA,fill="blue",alpha=0.3) +
        geom_line() + geom_point() +
        geom_hline(yintercept=0,linetype=3) +
        scale_y_continuous(limits=c(0,NA)) +
        labs(y=yax,x="year") +
        facet_grid(x~fleet,scales="free_y") +
        wtsPlots::getStdTheme();
  return(p)
}
###--retained catch----
tmp = dfrCatFit |> dplyr::filter(fleet %in% "TCF",catch.type=="retained");
plotDFR(tmp,"Retained Catch (1,000's t)")
###--TCF total catch----
tmp = dfrCatFit |> dplyr::filter(fleet %in% "TCF",catch.type=="total");
plotDFR(tmp,"Total Catch (1,000's t)")
###--SCF total catch----
tmp = dfrCatFit |> dplyr::filter(fleet %in% "SCF",catch.type=="total");
plotDFR(tmp,"Total Catch (1,000's t)")
###--RKF total catch----
tmp = dfrCatFit |> dplyr::filter(fleet %in% "RKF",catch.type=="total");
plotDFR(tmp,"Total Catch (1,000's t)")
###--GFA total catch----
tmp = dfrCatFit |> dplyr::filter(fleet %in% "GFA",catch.type=="total");
plotDFR(tmp,"Total Catch (1,000's t)")


##--index data----
dfrIndxFitg = rep$Index_fit_summary |>
               dplyr::select(y=year,fleet,x=sex,m=maturity,val=prd) |>
               dplyr::mutate(
                 dplyr::across(c(y,val),as.numeric),
                 type="predicted",
                 case="gmacs"
               );
dfrIndxFitt = rCompTCMs::extractMDFR.Fits.BiomassData(resTCSAM02,fleet.type="survey") |>
                dplyr::filter(!stringr::str_starts(fleet,"SBS NMFS")) |>
                dplyr::select(case,fleet,type,y,x,m,val,lci,uci) |>
                dplyr::mutate(m=ifelse(m=="all maturity","undetermined",m),
                              fleet=ifelse(stringr::str_starts(fleet,"NMFS"),"NMFS","BSFRF"));
dfrIndxFit = dplyr::bind_rows(dfrIndxFitt,dfrIndxFitg) |> dplyr::filter((val>0)&(!is.na(val)));
plotDFR<-function(dfr){
  ggplot(dfr,aes(x=y,y=val,ymin=lci,ymax=uci,colour=case,shape=case)) +
        geom_point(data=dfr |> dplyr::filter(type=="observed"),colour="blue",shape=24) +
        geom_ribbon(data=dfr |> dplyr::filter(type=="observed"),colour=NA,fill="blue",alpha=0.3) +
        geom_line(data=dfr |> dplyr::filter(type=="observed"),colour="blue",alpha=0.5) +
        geom_line(data=dfr |> dplyr::filter(type!="observed")) +
        geom_point(data=dfr |> dplyr::filter(type!="observed")) +
        geom_hline(yintercept=0,linetype=3) +
        facet_grid(x+m~fleet,scales="free") +
        labs(y="Survey Biomass (1,000's t)",x="year") +
        wtsPlots::getStdTheme();
}
###--NMFS survey----
tmp = dfrIndxFit |> dplyr::filter(fleet=="NMFS");
plotDFR(tmp)
###--BSFRF survey----
tmp = dfrIndxFit |> dplyr::filter(fleet=="BSFRF");
plotDFR(tmp);

##--size comps----
dfrZCs = rep$Size_fit_summary |>
           dplyr::mutate(
             dplyr::across(c(year,size,inpSS,inpN,aggObs,aggPrd,aggRes),
                           as.numeric)
           );
dfrUIDs = dfrZCs |> dplyr::distinct(aggID,origID);
for (ir in 1:nrow(dfrUIDs)){
  #--test: ir = 1;
  aID = dfrUIDs$aggID[ir];
  oID  = dfrUIDs$origID[ir]
  tmp = dfrZCs |> dplyr::filter(aggID==aID,origID==oID);
  dfrUC = tmp |> dplyr::distinct(fleet,comp_type,sex,maturity,shell_cond);
  str = paste(dfrUC$fleet,dfrUC$comp_type);
  if (dfrUC$sex       !="undetermined") str = paste(str,dfrUC$sex);
  if (dfrUC$maturity  !="undetermined") str = paste(str,dfrUC$maturity);
  if (dfrUC$shell_cond!="undetermined") str = paste(str,dfrUC$shell_cond);
  p = compareFitsZCs(tmp,subtitle=str);
  print(p+theme(legend.position="none"));
}


