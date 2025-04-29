#--plot estimates and std devs from std file
require(magrittr)
require(rTCSAM02)

#--process par, std dataframes for a single case
#----extract model years
o_x = obj$rep$mc$dims$x;
o_y = obj$rep$mc$dims$y;

dfr_prs = obj$prs
dfr_std = obj$std

#--handle different param_init_ object types differently
dfr_pars

#--extract sdr variables
dfr_sdrs = dfr_std %>% dplyr::filter(name %>% stringr::str_starts(stringr::fixed("sdr")))
uSs = unique(dfr_sdrs$name);
lst = list();
for (uS in uSs){
  #--testing uS=uSs[1];
  if (uS %>% stringr::str_ends("_xy")){
    obj_sdr = dfr_sdrs %>% dplyr::filter(name==uS)
    arr = array(data=)
  } else if (uS %>% stringr::str_ends("_y")){
    dfr_sdr = dfr_sdrs %>% dplyr::filter(name==uS)
    arr = array(data=)
}