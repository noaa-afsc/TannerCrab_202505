#--small crab success/failure
require(ggplot2);

#--set working directory----
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);
setwd(dirThs);

  #--get spatial data----
  smos = list();
  maxColdPoolTemp = 2;#--deg C
  smos$maxColdPoolTemp = maxColdPoolTemp;

  ##--get map data----
  smos$latlon = TRUE;
  if (smos$latlon){
   crs  = wtsGIS::get_crs("NAD83");
  } else {
   crs  = wtsGIS::get_crs("AlaskaAlbers");
  }
  bbox = wtsGIS::getStandardBBox("EBS");
  bbox["ymin"] = 53.5;
  bbox = bbox |> wtsGIS::transformBBox(crs);
  sf_land = wtsGIS::getPackagedLayer("Alaska") |>
              sf::st_transform(crs) |>
              sf::st_crop(bbox);
  sf_bath = wtsGIS::getPackagedLayer("ShelfBathymetry") |>
              sf::st_transform(crs) |>
              sf::st_crop(bbox);
  smos$crs = crs;
  smos$bbox = bbox;
  smos$sf_land = sf_land;
  smos$sf_bath = sf_bath;

  ##--get ADFG stat area polygons (crs is NAD83)----
  smos$sfSAs = wtsGIS::getPackagedLayer("ADFG_StatAreas") |>
                  sf::st_transform(smos$crs);

  ##--create line indicating 166W longitude----
  tbl = tibble::tibble(x=-166+0*seq(-89,89,0.01),
                       y=seq(-89,89,0.01),
                       id="166W")
  smos$sf166W = sf::st_sf(sfheaders::sfc_linestring(tbl,x="x",y="y",linestring_id="id")) |>
                   sf::st_set_crs(wtsGIS::get_crs("NAD83")) |>
                   sf::st_transform(smos$crs) |>
                   sf::st_crop(smos$bbox);
  rm(tbl);

  ##--create basemap layers using survey grid, survey bottom temperatures----
  ###--get survey grid layers (crs is WGS84)----
  lstSrvGrids = tcsamSurveyData::gisGetSurveyGridLayers();
  lstSrvGrids$grid     = lstSrvGrids$grid |> sf::st_transform(smos$crs);
  lstSrvGrids$stations = lstSrvGrids$stations |> sf::st_transform(smos$crs);
  smos$lstSrvGrids = lstSrvGrids;

  ###--get survey basemap layers----
  bmls = tcsamSurveyData::gg_GetBasemapLayers(sf_land   = smos$sf_land,
                                              sf_bathym = smos$sf_bath,
                                              sfs_survey= smos$lstSrvGrids,
                                              final_crs = smos$crs,
                                              bbox = smos$bbox,
                                              bw=TRUE);

  ###--adjust theme----
  bmls$theme = bmls$theme +
                  theme(panel.background=element_rect(fill="white"),
                        panel.border = element_rect(colour="black",fill=NA),
                        panel.grid=element_blank());
  smos$bmls = bmls;

  ###--plot basemap with survey grid and 166W longitude to check layout----
  ggplot() + bmls$land + bmls$bathym +bmls$grid +
          geom_sf(data=smos$sf166W,colour="green",linetype=2,size=2) +
          geom_sf(data=smos$sfSAs,colour="darkblue",fill=NA,linetype=1,size=0.1) +
          bmls$map_scale + bmls$theme;

  ################################################################################
  #--get TCSAM02 Tanner crab survey results----
  dirHD = "~/Work/StockAssessments-Crab/Assessments/TannerCrab/2024-09_TannerCrab/AssessmentData/Data_Surveys_NMFS";
  lstHD = wtsUtilities::getObj(file.path(dirHD,"rda_SrvData.NMFS.HD.RData"));
  lstDBI = wtsUtilities::getObj(file.path(dirHD,"rda_SrvData.NMFS.DBI.RData"));

  n = 5;
  dfrGrps = tibble::tibble(year=c(2003:2007,2008:2012,2017:2021),
                           grp=c(rep("2003-2007",n),rep("2008-2012",n),rep("2017-2021",n)),
                           order=factor(c(1:n,1:n,1:n)));
  dfrZCs = lstDBI$lstZCs$EBS |>
             dplyr::select(year=YEAR,z=SIZE,totAbd=totABUNDANCE) |>
             dplyr::group_by(year,z) |>
             dplyr::summarize(totAbd=sum(totAbd)) |>
             dplyr::ungroup() |>
             dplyr::left_join(dfrGrps,by="year") |>
             dplyr::mutate(yf=factor(year));
  p = ggplot(dfrZCs |> dplyr::filter(!is.na(grp)),aes(x=z,y=totAbd,colour=order,fill=order,group=yf)) +
        geom_step() +
        facet_wrap(~grp,ncol=1) +
        wtsPlots::getStdTheme();
  print(p)

  ##--create dataframe with environmental data from survey----
  smos$sfED = tcsamSurveyData::calcEnvData.ByStation(lstHD$dfrSD,lstHD$dfrHD) |>
                  dplyr::select(year=YEAR,GIS_STATION,depth=BOTTOM_DEPTH,temp=BOTTOM_TEMP) |>
                  dplyr::left_join(smos$lstSrvGrids$grid,by=c("GIS_STATION"="STATION_ID")) |>
                  dplyr::filter(!is.na(temp)) |>
                  sf::st_as_sf();
  ##--extract cold pool (<2 deg C) for use as background----
  smos$sfCP = smos$sfED |>
                  dplyr::filter(temp<=maxColdPoolTemp) |>
                  dplyr::group_by(year) |>
                  dplyr::summarize(temp=mean(temp),do_union=TRUE) |>  #--need to do a summarize to union features by group
                  dplyr::ungroup();

  ##--calculate CPUE by haul for "large" Tanner crab
  dfrLTC = tcsamSurveyData::calcCPUE.ByHaul(lstHD$dfrHD,
                                            lstHD$dfrID |> dplyr::filter(SIZE>=100),
                                            bySex=FALSE,
                                            byMaturity=FALSE,
                                            byShellCondition=FALSE,
                                            bySize=FALSE) |>
             dplyr::rename(year=YEAR,
                           numCPUE_LTC=numCPUE,
                           wgtCPUE_LTC=wgtCPUE);
  ##--calculate CPUE by haul for "small" Tanner crab
  dfrSTC = tcsamSurveyData::calcCPUE.ByHaul(lstHD$dfrHD,
                                            lstHD$dfrID |> dplyr::filter(SIZE<=40),
                                            bySex=FALSE,
                                            byMaturity=FALSE,
                                            byShellCondition=FALSE,
                                            bySize=FALSE) |>
             dplyr::rename(year=YEAR,
                           numCPUE_STC=numCPUE,
                           wgtCPUE_STC=wgtCPUE) |>
             dplyr::inner_join(dfrLTC |> dplyr::select(HAULJOIN,numCPUE_LTC,wgtCPUE_LTC),
                               by="HAULJOIN") |>
             dplyr::inner_join(lstHD$dfrHD |> dplyr::select(HAULJOIN,temp=GEAR_TEMPERATURE,depth=BOTTOM_DEPTH),
                               by="HAULJOIN") |>
             dplyr::mutate(yf5=factor(5*floor(year/5)),
                           yf=factor(year));

  #--Explore differences in the spatial distribution of small male crab in the NMFS survey,
  #--to identify if the distribution of small crab encountered in 2003-2005 and 2008-2010,
  #--which successfully propagated to larger sizes, showed differences in habitat use compared
  #--with the cohort first observed in 2017-2019, which did not propagate to larger sizes.
  #--Likewise, the SSC recommends that a comparison of environmental conditions experienced by
  #--small crabs during these periods may help to elucidate why some cohorts appear to propagate and others do not.

  #--plot small TC abundance vs. bottom temperature and large TC abundance
  ggplot(dfrSTC,aes(x=temp,y=numCPUE_STC)) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2003:2005,numCPUE_STC>0),colour="blue",alpha=0.5) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2008:2010,numCPUE_STC>0),colour="green",alpha=0.5) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2017:2019,numCPUE_STC>0),colour="red",alpha=0.5) +
    scale_y_log10() +
    wtsPlots::getStdTheme();
  ggplot(dfrSTC,aes(x=numCPUE_LTC,y=numCPUE_STC)) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2003:2005,numCPUE_STC>0),colour="blue",alpha=0.5) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2008:2010,numCPUE_STC>0),colour="green",alpha=0.5) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2017:2019,numCPUE_STC>0),colour="red",alpha=0.5) +
    scale_y_log10() +
    scale_x_log10(limits=c(NA,10000)) +
    wtsPlots::getStdTheme();
  ggplot(dfrSTC,aes(x=1/numCPUE_LTC,y=numCPUE_STC)) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2003:2005,numCPUE_STC>0),colour="blue",alpha=0.5) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2008:2010,numCPUE_STC>0),colour="green",alpha=0.5) +
    geom_point(data=dfrSTC |> dplyr::filter(year %in% 2017:2019,numCPUE_STC>0),colour="red",alpha=0.5) +
    #scale_y_log10() +
    #scale_x_log10(limits=c(NA,10000)) +
    wtsPlots::getStdTheme();

#--plot 2-d histograms of small TC abundance vs large TC abundance and bottom temperature
p1 = wtsPlots::ggMarginal_Hist2D(dfrSTC |> dplyr::filter(year %in% 2003:2005),
                                  x=numCPUE_LTC,y=temp,weight=numCPUE_STC,
                                  xparams=list(limits=c(0,10000)),
                                  yparams=list(limits=c(-2,10)),
                                  addValues=FALSE)
p2 = wtsPlots::ggMarginal_Hist2D(dfrSTC |> dplyr::filter(year %in% 2008:2010),
                            x=numCPUE_LTC,y=temp,weight=numCPUE_STC,
                            xparams=list(limits=c(0,10000)),
                            yparams=list(limits=c(-2,10)),
                            addValues=FALSE)
p3 = wtsPlots::ggMarginal_Hist2D(dfrSTC |> dplyr::filter(year %in% 2017:2019),
                            x=numCPUE_LTC,y=temp,weight=numCPUE_STC,
                            xparams=list(limits=c(0,10000)),
                            yparams=list(limits=c(-2,10)),
                            addValues=FALSE)
cowplot::plot_grid(p1,
                   p2,
                   p3,ncol=1)

#--plot spatial patterns of small TC and cold pool for relevant years
years = c(2003:2005,2008:2010,2017:2019);
sfSTC = dfrSTC |>
          dplyr::group_by(year) |>
          dplyr::mutate(nrmCPUE_STC=numCPUE_STC/sum(numCPUE_STC),
                        nrmCPUE_LTC=numCPUE_LTC/sum(numCPUE_LTC)) |>
          dplyr::left_join(smos$lstSrvGrids$grid,by=c("GIS_STATION"="STATION_ID")) |>
          sf::st_as_sf();
  p1 = ggplot() + bmls$land + bmls$bathym +
         geom_sf(data=sfSTC |> dplyr::filter(year %in% years,nrmCPUE_STC>0),
                          mapping=aes(colour=nrmCPUE_STC,fill=nrmCPUE_STC)) +
         geom_sf(data=smos$sfCP |> dplyr::filter(year %in% years),
                           colour="black",fill=NA,linewidth=1) +
         scale_fill_viridis_c(name="small crab CPUE\n(normalized)",option="plasma",
                              limits=c(0,NA),oob=scales::squish,direction=-1,
                              aesthetics=c("colour","fill")) +
         facet_wrap(~year,ncol=3,scales="fixed") +
         bmls$map_scale + bmls$theme +
         theme(legend.position="top",
               #legend.position.inside=c(0.01,0.01),
               legend.justification.top=c(0,0),
               legend.direction="horizontal");
  dims = wtsUtilities::gg_FixOnePlotDim(p1,width,fitWidth=TRUE);
