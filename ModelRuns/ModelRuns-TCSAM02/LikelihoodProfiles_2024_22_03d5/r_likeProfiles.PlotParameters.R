#plot likelihood profiles for parameter values
require(ggplot2);

##--PROFILING on pLnR[2]----
param = "mean ln-scale R";

dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);

if (FALSE){
  #--load results
  cases = wtsUtilities::getObj(file.path(dirThs,"rda_cases.RData"));
  base = as.character(cases[1]);
  lst<-list();
  for (case in cases){
    fn = file.path(dirThs,paste0("./LP_Results/Results_",case,".RData"));
    if (file.exists(fn)){
      load(fn);
      if (!is.null(best$rep)){
        casep = as.character(case);
        dfrp<-rTCSAM02::getMDFR.ParameterValues(best) |>
                dplyr::mutate(case=casep);
        lst[[casep]]<-dfrp;
        rm(casep,dfrp);
      }
      rm(best);
    }
    rm(fn);
  }#--case
  dfrPs = dplyr::bind_rows(lst); #rm(lst);
  dfrPsBase = dfrPs |>
                dplyr::filter(case==base) |>
                dplyr::mutate(base=final_arith_value) |>
                dplyr::filter(phase>0) |>
                dplyr::select(category,process,label,type,name,index,base);
  dfrPds = dfrPs |>
             dplyr::inner_join(dfrPsBase,
                               by=dplyr::join_by(category,process,label,type,name,index)) |>
             dplyr::mutate(diff=final_arith_value-base,
                           pct=100*diff/abs(base),
                           case=as.numeric(case)) |>
             dplyr::select(!c(min_param,max_param,init_param_value,final_param_value,stdv));
  wtsUtilities::saveObj(dfrPds,file.path(dirThs,"rda_dfrParamDiffs.RData"));
}

#--plot parameter profiles
dfrPds = wtsUtilities::getObj(file.path("rda_dfrParamDiffs.RData"));
require(ggplot2);
# #----specific number parameters
# uCPs = dfrPds |> dplyr::distinct(category,process);
# uPs  = c("pS2[2]");
# for (rw in 1:nrow(uCPs)){
#   #--testing: rw = 1;
#   tmp1<-dfrPds |> dplyr::filter(name %in% uPs) |>
#           dplyr::inner_join(uCPs[rw,,drop=FALSE],by=dplyr::join_by(category,process)) |>
#           dplyr::filter(type==" param_init_bounded_number");
#   if (nrow(tmp1)>0){
#     p = ggplot(tmp1,mapping=aes(x=case,y=diff,colour=name)) +
#           geom_hline(yintercept=0,linetype=3) +
#           geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
#           geom_line() +
#           labs(x="profiled parameter",y="parameter difference\n(arith. scale)",colour="parameter",
#                subtitle=paste0(uCPs$category[rw],": ",uCPs$process[rw])) +
#           wtsPlots::getStdTheme();
#     print(p);
#     p = ggplot(tmp1,mapping=aes(x=case,y=pct,colour=name)) +
#           geom_hline(yintercept=0,linetype=3) +
#           geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
#           geom_line() +
#           labs(x="profiled parameter",y="parameter percent difference\n(arith. scale)",colour="parameter",
#                subtitle=paste0(uCPs$category[rw],": ",uCPs$process[rw])) +
#           wtsPlots::getStdTheme();
#     print(p);
#   }
# }

#----all number parameters
dfrPds = wtsUtilities::getObj("rda_dfrParamDiffs.RData");
require(ggplot2);
uCPs = dfrPds |> dplyr::distinct(category,process);
for (rw in 1:nrow(uCPs)){
  #--testing: rw = 1;
  tmp1<-dfrPds |>
          dplyr::inner_join(uCPs[rw,,drop=FALSE],by=dplyr::join_by(category,process)) |>
          dplyr::filter(type==" param_init_bounded_number");
  if (nrow(tmp1)>0){
    p = ggplot(tmp1,mapping=aes(x=case,y=diff,colour=name)) +
          geom_hline(yintercept=0,linetype=3) +
          geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
          geom_line() +
          labs(x="param",y="parameter difference\n(arith. scale)",colour="parameter",
               subtitle=paste0(uCPs$category[rw],": ",uCPs$process[rw])) +
          wtsPlots::getStdTheme();
    print(p);
    p = ggplot(tmp1,mapping=aes(x=case,y=pct,colour=name)) +
          geom_hline(yintercept=0,linetype=3) +
          geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
          geom_line() +
          labs(x=param,y="parameter percent difference\n(arith. scale)",colour="parameter",
               subtitle=paste0(uCPs$category[rw],": ",uCPs$process[rw])) +
          wtsPlots::getStdTheme();
    print(p);
  }
}

