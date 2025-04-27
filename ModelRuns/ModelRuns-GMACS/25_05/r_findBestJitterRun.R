#--read in jitter results from several folders

dirThis = dirname(rstudioapi::getActiveDocumentContext()$path);
setwd(dirThis);
base = "JitterRuns";#--base folder name
cases<-c("A","B","C");     #case identifiers
lst = list();
for(case in cases){
  fn<-file.path(paste0(base,case),"jitterResults.csv");
  if (file.exists(fn)){
    dfrp<-readr::read_csv(fn) |>
            dplyr::select(1:5);
    dfrp$case<-case;
    lst[[case]] = dfrp;
    rm(dfrp);
  }
}
dfr = dplyr::bind_rows(lst);
#--sort dataframe on likelihood, then max gradient
dfrp = dfr |> dplyr::arrange(objFun,maxGrad);
write.csv(dfrp,file="allJitterResults.csv");
print(head(dfrp));

require(ggplot2);
nRuns = nrow(dfrp);
blOF = 0.001;#--objective function interval for counting "converged to same"
dOF  = 1.0;   #--width of objective function interval
mnOF = min(dfrp$objFun);
mxOF = min(max(dfrp$objFun),mnOF+dOF)

nMn  = nrow(dfrp |> dplyr::filter(objFun<=mnOF+blOF,abs(maxGrad)<0.1));#--number of runs converged to MLE
tbl = tibble::tibble(objFun=mnOF+5*blOF,maxGrad=dfrp$maxGrad[1],label=paste0(nMn," of ",nRuns));#--label info
p1 = ggplot(mapping=aes(x=objFun,y=maxGrad)) +
      #geom_point(data=dfrp |> dplyr::filter(objFun<=mnOF+10*blOF),alpha=0.3,colour="red") +
      geom_point(data=dfrp,alpha=0.3,colour="red") +
      geom_point(data=dfrp |> dplyr::filter(objFun<=mnOF+   blOF),alpha=1.0,colour="blue") +
      geom_point(data=dfrp[1,],alpha=1.0,colour="green",shape=4,size=3) +
      geom_text(data=tbl,mapping=aes(label=label),colour="green",hjust=0) +
      lims(x=c(mnOF,mxOF),y=c(-0.1,0.1)) +
      labs(x="objective function value",y="max gradient") +
      wtsPlots::getStdTheme();
cat("nMn = ",nMn,"\n")
print(p1);

# mnMMB = (dfrp$MMB[dfrp$objFun==mnOF])[1];
# nMn  = nrow(dfrp |> dplyr::filter(objFun<=mnOF+blOF,abs(MMB-mnMMB)<1));
# tbl = tibble::tibble(objFun=mnOF+5*blOF,MMB=mnMMB,label=paste0(nMn," of ",nRuns))
# p2 = ggplot(mapping=aes(x=objFun,y=MMB)) +
#       geom_point(data=dfrp |> dplyr::filter(objFun<=mxOF),alpha=1.0,colour="red") +
#       geom_point(data=dfrp |> dplyr::filter(objFun<=mnOF+   blOF),alpha=1.0,colour="blue") +
#       geom_point(data=dfrp[1,],alpha=1.0,colour="green",shape=4,size=3) +
#       geom_text(data=tbl,mapping=aes(label=label),colour="green",hjust=0) +
#       lims(x=c(mnOF,mxOF)) +
#       labs(x="objective function value",y="terminal MMB") +
#       wtsPlots::getStdTheme();
#
# pg = cowplot::plot_grid(p1,p2,ncol=1);
# print(pg);
cowplot::ggsave2("runJitterResults.pdf",plot=p1,width=6.5,height=3.5);

# lst = list(nRuns=nRuns,mnOF=mnOF,dfr=dfrp,
#            plots=list(p1=p1,p2=p2,pg=pg));
lst = list(nRuns=nRuns,mnOF=mnOF,dfr=dfrp,
           plots=list(p1=p1));
wtsUtilities::saveObj(lst,"rda_JitterResults.RData");

