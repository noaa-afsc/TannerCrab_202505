#--create TCSAM02 input file for male maturity ogive data
require(dplyr)
require(ggplot2);
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

#--get maturity data for TCSAM02 input file
lstMOs = wtsUtilities::getObj(s$fnDataSrvNMFS.MOs);
cutpts     = lstMOs$cutpts;
tblMOs.TID = lstMOs$tblMOs.TID;

#--write TCSAM02 input file
mxYr = max(tblMOs.TID$year);
ncps = length(cutpts);
fn<-file.path(dirOut,paste0("Data.Survey.",mxYr,".NMFS.MaleMaturityOgives.inp"));
if (!file.exists(fn)) {
  res<-file.create(fn);
  if (!res) stop(paste0("Could not create file '",fn,"'.\nAborting...\n"));
}
con<-file(fn);
open(con,open="w");
cat(file=con,"#--Maturity Ogive Data\n");
cat(file=con,"MATURITYOGIVE_DATA        #required keyword\n");
cat(file=con,"EBS_mature_male_ratios    #dataset name\n");
cat(file=con,"NMFS_M                    #survey name\n");
cat(file=con,"MALE	                    #sex\n");
cat(file=con,"BINOMIAL		              #likelihood type\n");
cat(file=con,"1.0	                      #likelihood weight\n");
cat(file=con,ncps-1,"                   #number of size bins\n");
cat(file=con,"#--cutpoints\n");
cat(file=con,cutpts,"\n",sep="\t");
cat(file=con,"#--observations\n");
cat(file=con,nrow(tblMOs.TID),"         #number of observations\n");
cat(file=con,"#year\t\tsize\tindex\tN\tprMature\n");
for (r in 1:nrow(tblMOs.TID)){
  rw<-tblMOs.TID[r,];
  cat(file=con,rw$year,rw$size_bin,rw$index,rw$N,rw$ratio,"\n",sep="\t\t");
}
close(con);





