#-----helper functions----------------------------------------------------------
require(ggplot2);
makePlot.FitACD<-function(obs_case,mdfr,
                   xlims=NULL,ylims=NULL,
                   xlab="year",ylab="Biomass (1000's t)",
                   colour_scale=ggplot2::scale_color_hue(),
                   fill_scale  =ggplot2::scale_fill_hue()){
  mdfr$facets<-paste0(mdfr$x,"\n",mdfr$m,"\n",mdfr$s);
  obs = mdfr |> dplyr::filter(type=="observed",case %in% obs_case);
  prd = mdfr |> dplyr::filter(type=="predicted");
  dfr = dplyr::bind_rows(obs,prd);
  p = ggplot(dfr,aes(x=y,y=val,color=case)) +
        geom_line(data=prd) +
        colour_scale +
        geom_point(aes(shape=case),data=obs,size=2,alpha=0.7) +
        geom_linerange(aes(ymin=lci,ymax=uci),data=obs,show.legend=FALSE) +
        geom_line(data=prd) +
        coord_cartesian(xlim=xlims,ylim=ylims) +
        labs(x=xlab,y=ylab) + 
        facet_grid(rows=facets~.,scales="free_y");
  return(p);
}
makePlot.FitACD.ZScores<-function(mdfr){
  dfr = mdfr |> dplyr::filter(type=="z-score");
  p = plotLollipops.ACD(dfr,
                        type="z-score",
                        extreme=4,
                        dw=0.6,
                        xlab="year",
                        ylab="z-score")
  return(p)
}
makePlot.FitACD.MARE<-function(mdfr,scales="free_y"){
  dfr = mdfr |> dplyr::filter(type %in% c("observed","predicted","sdobs","stdv","z-score","useFlgs")) |>
                 dplyr::select(case,fleet,y,x,m,s,type,val) |>
                 tidyr::pivot_wider(id_cols=c("case","fleet","y","x","m","s"),
                                    names_from=type,values_from=val) |>
                 dplyr::filter(!((is.na(observed)|(is.na(predicted))))) |>
                 dplyr::group_by(case,fleet,x,m,s) |>
                 dplyr::summarize(MARE=median(abs((observed-predicted)/observed),na.rm=TRUE),
                                  MAD=median(abs((observed-predicted)),na.rm=TRUE),
                                  RMSE=sqrt(mean((observed-predicted)^2,na.rm=TRUE))) |>
                 dplyr::ungroup() |>
                 dplyr::mutate(facet=paste0(x,"\n",m,"\n",s));
  #--MAD
  pMAD = ggplot(dfr,aes(x=x,y=MAD,colour=case,fill=case))+
          geom_bar(stat="identity",position="dodge") + 
          labs(x="",y="MAD") + facet_grid(facet~.,scales=scales);
  #--MARE
  pMARE = ggplot(dfr,aes(x=x,y=MARE,colour=case,fill=case))+
            geom_bar(stat="identity",position="dodge") + 
            labs(x="",y="MARE") + facet_grid(facet~.,scales=scales);
  #--RMSE
  pRMSE = ggplot(dfr,aes(x=x,y=RMSE,colour=case,fill=case))+
        geom_bar(stat="identity",position="dodge") + 
        labs(x="",y="RMSE") + facet_grid(facet~.,scales=scales);
  return(list(MAD=pMAD,MARE=pMARE,RMSE=pRMSE))
}
makeAll.FitACD.MARE<-function(tmp,ggL,ggT,std_theme,scales="free_y"){
  ggXT = theme(axis.title.x = element_blank());
  p1 = makePlot.FitACD.ZScores(tmp);
  ps = makePlot.FitACD.MARE(tmp,scales=scales);
  lg = cowplot::get_legend(p1+theme(legend.box.margin=margin(0,0,0,2)));
  p1a = p1+ggL+ggT+ggXT; 
  p2a = ps$MAD+ggL+ggT+std_theme  + ggXT; 
  p2b = ps$MARE+ggL+ggT+std_theme + ggXT; 
  p2c = ps$RMSE+ggL+ggT+std_theme + ggXT;
  pgB = cowplot::plot_grid(p2a,p2b,p2c,nrow=1);
  pgL  = cowplot::plot_grid(p1a,pgB,ncol=1);
  pgA = cowplot::plot_grid(pgL,lg,nrow=1,rel_widths=c(10,2)); 
  return(pgA);
}
