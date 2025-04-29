makeTable.OFCs.DCs<-function(dfrOFCs,
                             fleets=NULL,
                             categories=c("surveys data","fisheries data"),
                             value.var="objfun",
                             fun.aggregate=wtsUtilities::Sum){
  tmp<-dfrOFCs;
  uCs<-unique(tmp$case); 
  tmp$case<-factor(tmp$case,levels=uCs);
  tmp$category<-factor(tmp$category,levels=categories);
  if (!is.null(fleets)) tmp$fleet<-factor(tmp$fleet,levels=fleets);
  
  tmp0<-tmp %>% subset(category %in% categories);
  tmp1<-reshape2::dcast(tmp0,
                        category+fleet+catch.type+data.type+x~case,
                        fun.aggregate=fun.aggregate,drop=TRUE,value.var=value.var);
  tmp2<-reshape2::dcast(tmp0,
                        category+fleet+catch.type+data.type+x~.,
                        fun.aggregate=fun.aggregate,drop=TRUE,value.var=value.var);
  tmp2<-tmp2 %>% subset(!(`.`==0)) %>% dplyr::select(!tidyselect::last_col());
  tmp3<-dplyr::inner_join(tmp1,tmp2,by=c("category","fleet","catch.type","data.type","x"));
  names(tmp3)[1:5]<-c("category","fleet","catch type","data type","sex");
  return(tmp3)
}

makeTable.OFCs.NDCs<-function(dfrOFCs){
  value.var="objfun";
  fun.aggregate=wtsUtilities::Sum;
  tmp<-dfrOFCs;
  uCs<-unique(tmp$case); 
  tmp$case<-factor(tmp$case,levels=uCs);
  tmp[[value.var]][tmp[[value.var]]<1.0e-5]<-0;
  tmp1<-reshape2::dcast(tmp,
                        category+type+element+level~case,
                        fun.aggregate=fun.aggregate,drop=TRUE,value.var=value.var);
  tmp2<-reshape2::dcast(tmp,
                        category+type+element+level~.,
                        fun.aggregate=fun.aggregate,drop=TRUE,value.var=value.var);
  tmp2<-tmp2 %>% subset(!(`.`==0)) %>% dplyr::select(!tidyselect::last_col());
  tmp3<-dplyr::inner_join(tmp1,tmp2,by=c("category","type","element","level"));
  return(tmp3);
}

