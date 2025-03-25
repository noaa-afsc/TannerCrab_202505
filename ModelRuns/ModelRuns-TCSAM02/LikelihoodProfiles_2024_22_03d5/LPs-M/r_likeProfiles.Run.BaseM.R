#--run likelihood profile on pM[1] (base M) parameter
#--Notes:
#--1. modify MPI file:
#----a. substitute "&&value" for profiled parameter value
#----b. set parameter phase to < 0 (i.e., fix profiled parameter)
#--2. modify Model Configuration file to use MPI.dat as MPI file
#--3. copy tcsam02.par file from previous "base" model run into working folder
#----a. substitute "&&value" for profiled parameter value
#--4. create/modify shell script to use Model Configuration file and pin file "tcsam02.pin"
#----a. osx: tmp_osx.sh
#----b. win: tmp_win.bat
#--5. Modify cases1 and cases2 below to cover range of profiled values
#--6. Make sure correct parameter scale transform is used to convert MPI initial value
#       to parameter value in all instances (check "NOTE"s)

os<-"win";#--or "win" or "osx"
top<-getwd();

#--read MPI template
fn_mpi<-"MPI.dat";
mpi<-readLines(con=fn_mpi);
mpi<-paste0(mpi," \n",collapse="");

#--read par file template
fn_par = "tcsam02.par";
par<-readLines(con=fn_par);
id_par = grep("&&value",par,fixed=TRUE);

#--identify shell script to run model
if (tolower(os)=="osx") fn_run<-"tmp_osx.sh";
if (tolower(os)=="win") fn_run<-"tmp_win.bat";

#--identify model input files
fns<-list.files(pattern=glob2rx("*.inp"));

#--identify files to remove after run
fns_run_rm<-readLines(con="r_files_to_remove.txt");

#--identify cases and run models
##--NOTE: mpi.dat values here are ln-transformed to parameter scale
base<-0.229999993114;#--base case (limits: 0.135335283   2.718281828)
cases1<-seq(from= 0.24,to= 1.00,by= 0.01);
cases2<-seq(from= 0.22,to= 0.13,by=-0.01);
# cases1<-seq(from= 0.24,to= 0.25,by=  0.01);
# cases2<-seq(from= 0.22,to= 0.21,by=-0.01);
cases<-c(base,cases1,cases2);
wtsUtilities::saveObj(cases,"rda_cases.RData");#--save for other scripts
#--process cases with parameter incremented positively to upper limit
casesUp = c(base,cases1);
for (ic in 1:length(casesUp)){
  #--testing: ic = 1;
  case = casesUp[ic];
  fldr<-paste0("./profile_",case);
  cat("running",fldr,"\n");
  runfldr<-file.path(fldr,"run");
  if (!dir.exists(fldr)) {
    dir.create(fldr);
    for (fn in fns) file.copy(from=fn,to=file.path(fldr,fn),overwrite=TRUE);
    mpip<-gsub("&&value",case,mpi,fixed=TRUE);
    writeLines(mpip,con=file.path(fldr,"MPI.dat"));
    dir.create(runfldr);
    file.copy(from=fn_run,to=file.path(runfldr,fn_run),overwrite=TRUE);
    if (ic==1){
      parp = par;
      parp[id_par] = log(case); #--NOTE: must transform to parameter scale!
      parp = paste0(parp," \n",collapse="") |>
      writeLines(parp,con=file.path(runfldr,"tcsam02.pin"));
      cat("\tusing original pin file\n")
    } else {
      lic = 1;
      fn_parp = file.path(paste0("./profile_",casesUp[ic-lic]),"run","tcsam02.par");
      while (!file.exists(fn_parp) & (lic<ic)) {
        lic = lic+1;
        fn_parp = file.path(paste0("./profile_",casesUp[ic-lic]),"run","tcsam02.par");
      }
      if (file.exists(fn_parp)) {
        cat("\ttaking pin file from",fn_parp,"\n")
        parp = readLines(con=fn_parp);
      } else {
        cat("\tusing original pin file\n")
        parp = par;#--default to original par file
      }
      parp[id_par] = log(case); #--NOTE: must transform to parameter scale!
      parp = paste0(parp," \n",collapse="") |>
      writeLines(parp,con=file.path(runfldr,"tcsam02.pin"));
    }
    Sys.chmod(file.path(runfldr,fn_run),mode='7777');#--make executable
    rm(mpip,parp);
  }
  setwd(runfldr);
  if (os=="osx")
    system(paste0("./",fn_run),wait=TRUE,ignore.stderr=TRUE,ignore.stdout=TRUE);
  if (os=="win")
    system2(fn_run,wait=TRUE,stderr=TRUE,stdout=FALSE,invisible=TRUE);
  file.remove(fns_run_rm);#--remove unnecessary files
  setwd(top);
}#--ic

#--process cases with parameter incremented negatively to  lower limit
casesDn = c(base,cases2);
for (ic in 1:length(casesDn)){
  #--testing: ic = 1;
  case = casesDn[ic];
  fldr<-paste0("./profile_",case);
  cat("running",fldr,"\n");
  runfldr<-file.path(fldr,"run");
  if (!dir.exists(fldr)) {
    dir.create(fldr);
    for (fn in fns) file.copy(from=fn,to=file.path(fldr,fn),overwrite=TRUE);
    mpip<-gsub("&&value",case,mpi,fixed=TRUE);
    writeLines(mpip,con=file.path(fldr,"MPI.dat"));
    dir.create(runfldr);
    file.copy(from=fn_run,to=file.path(runfldr,fn_run),overwrite=TRUE);
    if (ic==1){
      parp = par;
      parp[id_par] = log(case); #--NOTE: must transform to parameter scale!
      parp = paste0(parp," \n",collapse="") |>
      writeLines(parp,con=file.path(runfldr,"tcsam02.pin"));
      cat("\tusing original pin file\n")
    } else {
      lic = 1;
      fn_parp = file.path(paste0("./profile_",casesDn[ic-lic]),"run","tcsam02.par");
      while (!file.exists(fn_parp) & (lic<ic)) {
        lic = lic+1;
        fn_parp = file.path(paste0("./profile_",casesDn[ic-lic]),"run","tcsam02.par");
      }
      if (file.exists(fn_parp)) {
        cat("\ttaking pin file from",fn_parp,"\n")
        parp = readLines(con=fn_parp);
      } else {
        cat("\tusing original pin file\n")
        parp = par;#--default to original par file
      }
      parp[id_par] = log(case);  #--NOTE: must transform to parameter scale!
      parp = paste0(parp," \n",collapse="") |>
      writeLines(parp,con=file.path(runfldr,"tcsam02.pin"));
    }
    Sys.chmod(file.path(runfldr,fn_run),mode='7777');#--make executable
    rm(mpip,parp);
  }
  setwd(runfldr);
  system(paste0("./",fn_run),wait=TRUE,ignore.stderr=TRUE,ignore.stdout=TRUE);
  file.remove(fns_run_rm);#--remove unnecessary files
  setwd(top);
}#--ic

#--process results to get RData files
if (!dir.exists("./LP_Results")) dir.create("./LP_Results");
for (case in cases){
  #--testing: case = cases[1];
  fldr<-paste0("./profile_",case);
  runfldr<-file.path(fldr,"run");
  best<-rTCSAM02::getResLst(runfldr,verbose=TRUE)
  if (!is.null(best)) {
    save(best,file=paste0("./LP_Results/Results_",case,".RData"));
    mdfr<-rTCSAM02::getMDFR.OFCs.DataComponents(best,verbose=FALSE);
    write.csv(mdfr,file=paste0("./LP_Results/OFCs_",case,".DataComponents.csv"),row.names=FALSE);
    mdfrp<-rTCSAM02::getMDFR.OFCs.NonDataComponents(best,verbose=FALSE)
    write.csv(mdfrp,file=paste0("./LP_Results/OFCs_",case,".NonDataComponents.csv"),row.names=FALSE);
    fns = list.files(path=fldr,all.files=TRUE,full.names=TRUE,recursive=TRUE,include.dirs=FALSE);
    file.remove(fns);
    file.remove(runfldr);
    file.remove(fldr);
    rm(mdfr,mdfrp,fns);
  }
  rm(fldr,runfldr,best)
}#--case
