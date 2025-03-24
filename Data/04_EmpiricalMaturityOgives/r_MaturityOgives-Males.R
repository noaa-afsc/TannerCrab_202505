#--read male maturity ogive data
require(ggplot2);

#--set working directory----
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);
setwd(dirThs);

#--read in male maturity ogive data from Jon Richar----
dfr = readr::read_csv(file.path(dirThs,"TannerCrab_MaleMaturityOgives.csv")) |>
        dplyr::mutate(yf=factor(year),
                      N=as.integer(N));

p0 = ggplot(dfr,aes(x=size,y=prMature,size=N,colour=yf,fill=yf)) +
      geom_point() + geom_line(size=1) +
      scale_size_area() +
      wtsPlots::getStdTheme();
print(p0);

#--fit size-specific "smooth" model with RE factor smooths by year----
require(mgcv)
mdl = mgcv::gam(prMature~s(size,k=5) + ti(size,yf,bs="fs",k=5),family=binomial(),
                data=dfr,weights=N,
                method="REML");
summary(mdl);

#--check residuals patterns
simResMdl = DHARMa::simulateResiduals(mdl);
plot(simResMdl);

#--predict response by year for all survey years---
##--years not included in model fit are represented by mean
phat = predict(mdl,type="response",se.fit=TRUE,unconditional=TRUE);
dfr$fit = phat$fit;
dfr$se  = phat$se.fit;
p1 = ggplot(dfr,aes(x=size,y=fit,colour=yf,fill=yf)) +
      geom_ribbon(mapping=aes(ymin=fit-se,ymax=fit+se,colour=NULL),alpha=0.2) +
      geom_point(data=dfr,mapping=aes(x=size,y=prMature,size=N,colour=yf,fill=yf),inherit.aes=FALSE) +
      geom_line() +
      scale_size_area() +
      wtsPlots::getStdTheme();
print(p1);

dfrp = tidyr::expand_grid(yf=factor(1975:2024),
                          size=seq(27.5,182.5,5));
xphat = predict(mdl,newdata=dfrp,type="response",se.fit=TRUE,unconditional=TRUE)
dfrp$fit = as.numeric(xphat$fit);
dfrp$se  = as.numeric(xphat$se.fit);
dfrp$y   = as.numeric(as.character(dfrp$yf));
p2 = ggplot(dfrp |> dplyr::filter(y %in% dfr$year),aes(x=size,y=fit,colour=yf,fill=yf)) +
      geom_point(data=dfr,mapping=aes(y=prMature,colour=yf,fill=yf,size=N)) +
      scale_size_area(guide="none") +
      geom_ribbon(data=dfrp |> dplyr::filter((!(y %in% dfr$year))),
                  mapping=aes(x=size,ymin=fit-se,ymax=fit+se),colour=NA,alpha=0.3,inherit.aes=FALSE) +
      geom_line(data=dfrp |> dplyr::filter((!(y %in% dfr$year))),
                mapping=aes(x=size,y=fit),linewidth=1,inherit.aes=FALSE) +
      geom_line(data=dfrp |> dplyr::filter(y %in% dfr$year)) +
      labs(x="size (mm CW)",y="Pr(mature)",colour="observed\nyear",fill="observed\nyear") +
      wtsPlots::getStdTheme() +
      theme(legend.position="inside",
            legend.position.inside=c(0.01,0.99),
            legend.justification.inside=c(0.01,0.99));
print(p2);

#--extract relevant results and export to csv----
dfrTmp = dfrp |> dplyr::select(y,z=size,p=fit) |>
           dplyr::mutate(z=z-2.5) |>                         #--adjust to lefthand cutpoint
           tidyr::pivot_wider(names_from=z,values_from=p);
readr::write_csv(dfrTmp,file=file.path(dirThs,"csv_MaturityOgives-MalesPredicted.csv"));

