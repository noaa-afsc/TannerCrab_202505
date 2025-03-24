#--female maturity ogives
require(ggplot2);

#--set working directory----
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);
setwd(dirThs);

#--get TCSAM02 Tanner crab survey results----
dirTC = "~/Work/StockAssessments-Crab/Assessments/TannerCrab/2024-09_TannerCrab/AssessmentData/Data_Surveys_NMFS";
lstTC = wtsUtilities::getObj(file.path(dirTC,"rda_SrvData.NMFS.DBI.RData"));

#--extract female new shell abundance by maturity state and size----
##--calculate fraction that underwent terminal molt to maturity----
dfrMat = lstTC$lstZCs$EBS |>
           dplyr::filter(SEX=="FEMALE",SHELL_CONDITION=="NEW_SHELL") |>
           dplyr::select(y=YEAR,x=SEX,m=MATURITY,z=SIZE,numIndivs,totAbd=totABUNDANCE) |>
           tidyr::pivot_wider(names_from=m,values_from=c(numIndivs,totAbd)) |>
           dplyr::mutate(yf=factor(y),
                         nTot=numIndivs_IMMATURE+numIndivs_MATURE,
                         prMature=totAbd_MATURE/(totAbd_IMMATURE+totAbd_MATURE)) |>
           dplyr::mutate(prMature=ifelse(!is.nan(prMature),prMature,0*(z<=80)+1*(z>=100))) |>     #--replace NaNs
           dplyr::mutate(prMature=ifelse((prMature==0)&(y==2006)&(z==115)&(nTot==1),1,prMature)); #--replace single observed crab

#--plot results----
p1 = ggplot(dfrMat,aes(x=z,y=prMature,colour=yf,fill=yf)) +
       geom_line() +
       geom_point(aes(size=nTot)) +
       scale_size_area(guide="none") +
       #guides(colour="none",fill="none") +
       labs(x="size (mm CW)",y="Pr(mature)",colour="observed\nyear",fill="observed\nyear") +
       wtsPlots::getStdTheme() +
       theme(legend.position="inside",
             legend.position.inside=c(0.99,0.01),
             legend.justification.inside=c(1,0));
print(p1);

#--identify problematic values----
##--fixed in the above now
dfrMat |> dplyr::filter(z>=100,prMature==0)

#--extract relevant results and export to csv----
dfrTmp = dfrMat |> dplyr::select(y,z,p=prMature) |>
           tidyr::pivot_wider(names_from=z,values_from=p);
readr::write_csv(dfrTmp,file=file.path(dirThs,"csv_MaturityOgives-FemalesEstimated.csv"));



