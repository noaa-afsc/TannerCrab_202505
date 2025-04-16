#--
require(ggplot2);
require(wtsGMACS);
fnAllOut = file.path("zz_test_old","Gmacsall.out");
iln = 1;
lstAll<-wtsGMACS::readGmacsAllout(fnAllOut)

sexes = c("male","female");
dfrObsGrowth = lstAll$growth_data |>
                 dplyr::mutate(sex=sexes[as.integer(sex)],
                               `premolt size`=as.numeric(premolt_size),
                               observed=as.numeric(obs_postmolt_size),
                               predicted=as.numeric(prd_postmolt_size),
                               nll=as.numeric(nll),
                               .keep="none");
ggplot(dfrObsGrowth,aes(x=`premolt size`)) +
  geom_point(aes(y=observed)) + geom_line(aes(y=predicted)) +
  facet_grid(sex~.) +
  geom_abline(slope=1,linetype=3) +
  wtsPlots::getStdTheme();
