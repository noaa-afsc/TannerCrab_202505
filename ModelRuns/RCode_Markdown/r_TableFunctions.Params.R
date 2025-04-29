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

doTable.ParamVals<-function(dfr,ctgs=NULL,prcs=NULL,lbls=NULL,nams=NULL,
                            grep_names=NULL,param_type="number"){
  tmp = dfr;
  if (!is.null(ctgs))  tmp %<>% dplyr::filter(category %in% ctgs) %>% dplyr::mutate(category=factor(category,levels=ctgs));
  if (!is.null(prcs))  tmp %<>% dplyr::filter(process %in% prcs)  %>% dplyr::mutate(process =factor(process,levels=prcs));
  if (!is.null(lbls))  tmp %<>% dplyr::filter(label %in% lbls)    %>% dplyr::mutate(label   =factor(label,levels=lbls));
  if (!is.null(nams))  {
    #--starting with none selected, select those that match desired names
    idx1 = vector(mode="logical",length=nrow(tmp)); #--all FALSE
    for (nam in nams) 
      if(substr(nam,1,1)!="!") {
        nmp = nam;                     
        idx1 = idx1 | (substr(stringr::str_trim(tmp$name),1,nchar(nam))==nam);
      }
    #--starting with none selected, select those that match undesired names
    idx2 = vector(mode="logical",length=nrow(tmp)); #--all FALSE
    for (nam in nams) 
      if(substr(nam,1,1)=="!") {
        nmp = substr(nam,2,nchar(nam)); 
        idx2 = idx2 | (substr(stringr::str_trim(tmp$name),1,nchar(nam)-1)==nmp);
      }
    tmp %<>% dplyr::filter(idx1&(!idx2)) %>% dplyr::mutate(name=factor(name));
  }
  
  if (!is.null(grep_names)) tmp %<>% dplyr::filter(grepl(grep_names,name));
    
  if (param_type=="number"){
    tmp  %<>% dplyr::filter(stringr::str_trim(type) %in% c("param_init_number","param_init_bounded_number")) %>%
             dplyr::select(case,process,label,type,name,estimate=final_param_value,`std. dev.`=stdv) %>%
             dplyr::mutate(case=as.factor(case),
                           process=as.factor(process),
                           name=as.factor(name),
                           label=as.factor(label));
    tbl = tabular(process*name*label~
                    case*(estimate+`std. dev.`)*sum*DropEmpty(empty="--",which=c("row","cell")),
                  data=tmp);
  } else {
    tmp  %<>% dplyr::filter(!(stringr::str_trim(type) %in% c("param_init_number","param_init_bounded_number"))) %>%
             dplyr::select(case,process,label,name,index,estimate=final_param_value,`std. dev.`=stdv) %>%
             dplyr::mutate(case=as.factor(case),
                           process=as.factor(process),
                           name=as.factor(name),
                           index=as.factor(index),
                           label=as.factor(label));
    tbl = tabular(process*name*label*index~
                    case*(estimate+`std. dev.`)*sum*DropEmpty(empty="--",which=c("row","cell")),
                  data=tmp);
  }
  colLabels(tbl) = colLabels(tbl)[c(2,3),];
  return(tbl);
}

