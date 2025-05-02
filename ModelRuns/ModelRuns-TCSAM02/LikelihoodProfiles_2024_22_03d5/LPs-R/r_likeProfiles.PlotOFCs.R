#plot likelihood profiles for OFCs----
require(ggplot2);

##--PROFILING on pLnR[2]----
param = "mean ln-scale R"

dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);

#--load data-related OFCs----
cases = wtsUtilities::getObj(file.path(dirThs,"rda_cases.RData"));
base = as.character(cases[1]);
if (FALSE){  #--do once, if not done previously
  lstDCs<-NULL;
  lstNCs<-NULL;
  for (case_ in cases){
    fn = file.path(dirThs,paste0("./LP_Results/OFCs_",case_,".DataComponents.csv"));
    if (file.exists(fn)){
      dfrp<-readr::read_csv(fn,show_col_types=FALSE);
      if (nrow(dfrp)>0){
        lstDCs[[fn]] = dfrp |>
                         dplyr::mutate(case=as.character(case_)) |>
                         dplyr::filter(category!="effort data", #--remove effort category
                                       objfun!=0.0);            #--remove entries with nlls = 0
        rm(dfrp);
      }
    }
    fn = file.path(dirThs,paste0("./LP_Results/OFCs_",case_,".NonDataComponents.csv"));
    if (file.exists(fn)){
      dfrp<-readr::read_csv(fn,show_col_types=FALSE);
      if (nrow(dfrp)>0){
        lstNCs[[fn]]<-dfrp|>
                         dplyr::mutate(case=as.character(case_)) |>
                         dplyr::filter(objfun!=0.0);            #--remove entries with nlls = 0
      }
      rm(fn,dfrp);
    }
  }
  dfrDCs = dplyr::bind_rows(lstDCs); #rm(lstDCs);
  dfrNCs = dplyr::bind_rows(lstNCs); #rm(lstNCs);
  wtsUtilities::saveObj(dfrDCs,file.path(dirThs,"rda_dfrDataComponentOFCs.RData"));
  wtsUtilities::saveObj(dfrNCs,file.path(dirThs,"rda_dfrNonDataComponentOFCs.RData"));
}

#--edit and extract data components----
dfrDCs = wtsUtilities::getObj(file.path(dirThs,"rda_dfrDataComponentOFCs.RData"));
dfrNCs = wtsUtilities::getObj(file.path(dirThs,"rda_dfrNonDataComponentOFCs.RData"));
idx<-dfrDCs$category=="growth data";
dfrDCs$fleet[idx]<-ifelse(dfrDCs$x[idx]=="male","NMFS M","NMFS F");
idx<-dfrDCs$x=="all sexes";
dfrDCs$x[idx]<-"all";
dfrDCsp<-reshape2::dcast(dfrDCs,"case+category+fleet+catch.type+data.type+x~.",
                         fun.aggregate=wtsUtilities::Sum,value.var="objfun");
names(dfrDCsp)[7]<-"objfun";
#--extract base case
dfrDCspBase = dfrDCsp |>
                dplyr::filter(case==base) |>
                dplyr::mutate(base=objfun) |>
                dplyr::select(!c(case,objfun));
#--append base values to other models and find difference
dfrDCsd = dfrDCsp |>
            dplyr::inner_join(dfrDCspBase,
                              by=dplyr::join_by(category, fleet, catch.type, data.type, x)) |>
            dplyr::mutate(diff=objfun-base,
                          component=paste(category,fleet,catch.type,data.type,x,sep="; "),
                          case=as.numeric(case));
#----calculate total by case
dfrDCst = dfrDCsd |>
            dplyr::group_by(case) |>
            dplyr::summarise(objfun=wtsUtilities::Sum(objfun),
                             base=wtsUtilities::Sum(base),
                             diff=wtsUtilities::Sum(diff)) |>
            dplyr::ungroup();

#--edit and extract non-data components----
dfrNCsp<-reshape2::dcast(dfrNCs,"case+category+type+element~.",
                         fun.aggregate=wtsUtilities::Sum,value.var="objfun");
names(dfrNCsp)[5]<-"objfun";

#--extract base case----
dfrNCspBase = dfrNCsp |>
                dplyr::filter(case==base) |>
                dplyr::mutate(base=objfun) |>
                dplyr::select(!c(case,objfun));
##--append base values to other models and find difference----
dfrNCsd = dfrNCsp |>
            dplyr::inner_join(dfrNCspBase,
                              by=dplyr::join_by(category,type,element)) |>
            dplyr::mutate(diff=objfun-base,
                          component=paste(category,type,element,sep="; "),
                          case=as.numeric(case));
##----calculate total by case----
dfrNCst = dfrNCsd |>
            dplyr::group_by(case) |>
            dplyr::summarise(objfun=wtsUtilities::Sum(objfun),
                             base=wtsUtilities::Sum(base),
                             diff=wtsUtilities::Sum(diff)) |>
            dplyr::ungroup();

#--create dataframe with totals by case----
dfrTs<-dplyr::bind_rows(dfrDCst,dfrNCst) |>
         dplyr::group_by(case) |>
         dplyr::summarise(objfun=wtsUtilities::Sum(objfun),
                          base=wtsUtilities::Sum(base),
                          diff=wtsUtilities::Sum(diff)) |>
         dplyr::ungroup();

#--find value at which male growth likelihood is minimized
minG = as.numeric((dfrDCsd |>
                     dplyr::filter(category=="growth data",x=="male",diff==min(diff,na.rm=TRUE)))$case);
#--plot likelihood profiles
require(ggplot2);
#----plot total objective function differences from base----
p = ggplot(dfrTs,aes(x=case,y=diff)) +
      geom_hline(yintercept=0,linetype=3) +
      geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
      geom_vline(xintercept=minG,linetype=3,colour="cyan") +
      geom_line() +
      labs(subtitle="total objective function",y="difference from base",x=param) +
      wtsPlots::getStdTheme();
print(p);

#--plot data components by category and fleet----
categories<-c("fisheries data","surveys data","growth data","maturity ogive data");
tmp1 = dfrDCsd |>
         dplyr::mutate(x=factor(x,levels=c("male","female","all")));
##--decimate cases to plot values as points----
uCs = sort(unique(tmp1$case));
dCs = uCs[seq(from=1,to=length(uCs),by=5)];
dfrPltCats = tmp1 |> dplyr::distinct(category,fleet);
for (rw in 1:nrow(dfrPltCats)){
  #--testing: rw=1;
  tmp1a = tmp1 |>
            dplyr::inner_join(dfrPltCats[rw,],by=dplyr::join_by(category,fleet));
  tmp2 = tmp1a |> dplyr::filter(case %in% dCs);
  p = ggplot(tmp1a,aes(x=case,y=diff,colour=data.type,fill=data.type,linetype=x,shape=catch.type)) +
        geom_hline(yintercept=0,linetype=3) +
        geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
        geom_vline(xintercept=minG,linetype=3,colour="cyan") +
        geom_line() +
        geom_point(data=tmp2) +
        labs(subtitle=paste0(dfrPltCats$category[rw],": ",dfrPltCats$fleet[rw]),
             y="difference from base",x=param) +
        wtsPlots::getStdTheme();
  print(p);
}

#--plot non-data components
categories<-unique(dfrNCsd$category);
tmp1<-dfrNCsd;
#------decimate cases to plot values as points
uCs = sort(unique(tmp1$case));
dCs = uCs[seq(from=1,to=length(uCs),by=5)];
dfrPltCats = tmp1 |> dplyr::distinct(category);
for (rw in 1:nrow(dfrPltCats)){
  #--testing: rw=1;
  tmp1a = tmp1 |>
            dplyr::inner_join(dfrPltCats[rw,,drop=FALSE],by=dplyr::join_by(category));
  tmp2 = tmp1a |> dplyr::filter(case %in% dCs);
  p = ggplot(tmp1a,aes(x=case,y=diff,colour=type,fill=type,shape=element)) +
        geom_hline(yintercept=0,linetype=3) +
        geom_vline(xintercept=as.numeric(cases[1]),linetype=3) +
        geom_vline(xintercept=minG,linetype=3,colour="cyan") +
        geom_line() +
        geom_point(data=tmp2) +
        labs(subtitle=paste0(dfrPltCats$category[rw]),
             y="difference from base",x=param) +
        wtsPlots::getStdTheme();
  print(p);
}


