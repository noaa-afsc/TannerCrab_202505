require(dplyr)
require(magrittr)
require(tables)
require(tidyr)

doTable.PsAtBs<-function(dfr){
  tmp = dfr %>% dplyr::mutate(case=as.factor(case),
                              category=as.factor(category),
                              process=as.factor(process),
                              name=as.factor(name),
                              label=as.factor(label),
                              test=ifelse(test=="at upper bound",1,-1));
  tbl = tabular(category*process*name*label~case*(test*sum)*DropEmpty(empty="--",which=c("row","cell")),data=tmp);
  colLabels(tbl) = colLabels(tbl)[2,];
  return(tbl);
}

doTable.ParamVals<-function(dfr,ctg=NULL,prc=NULL,devs=FALSE){
  tmp = dfr %>% dplyr::select(case,category,process,label,type,name,estimate=final_param_value,`std. dev.`=stdv);
  if (!is.null(ctg))  tmp %<>% dplyr::filter(category %in% ctg);
  if (!is.null(prc))  tmp %<>% dplyr::filter(process %in% prc);
  if (!is.null(lbl))  tmp %<>% dplyr::filter(label %in% lbl);
  if (!is.null(nm))   tmp %<>% dplyr::filter(grepl(nm,name));
  idx = grepl(glob2rx("*devs*"),tmp$type);
  if (devs) {tmp %<>% dplyr::filter(idx)} else {tmp %<>% dplyr::filter(!idx)}
  
  tmp %<>% dplyr::mutate(case=as.factor(case),
                         category=as.factor(category),
                         process=as.factor(process),
                         name=as.factor(name),
                         label=as.factor(label));
  tbl = tabular(category*process*name*label~
                  case*(estimate+`std. dev.`)*sum*DropEmpty(empty="--",which=c("row","cell")),
                data=tmp);
  colLabels(tbl) = colLabels(tbl)[c(2,3),];
  return(tbl);
}