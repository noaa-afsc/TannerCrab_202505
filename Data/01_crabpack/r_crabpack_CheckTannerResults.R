#--test crabpack, R package for NMFS crab survey data
require(crabpack);
require(ggplot2);

#--get TCSAM02 Tanner crab survey results----
dirTC = "~/Work/StockAssessments-Crab/Assessments/TannerCrab/2024-09_TannerCrab/AssessmentData/Data_Surveys_NMFS";
lstTC = wtsUtilities::getObj(file.path(dirTC,"rda_SrvData.NMFS.DBI.RData"));

#--Tanner crab data for crabpack----
if (FALSE){
  lstCP = get_specimen_data(species="TANNER",
                         region="EBS",
                         channel="API");
  wtsUtilities::saveObj(lstCP,"rda_crabpack_specimen_data.TannerCrab.RData");
} else {
  lstCP = wtsUtilities::getObj("rda_crabpack_specimen_data.TannerCrab.RData");
}


#--Biomass and abundance----
##--get TCSAM02 biomass/abundance time series
dfrT_ABs = lstTC$lstABs$ABs$EBS |> 
              dplyr::select(y=YEAR,x=SEX,m=MATURITY,
                            abd=totABUNDANCE,abdCV=cvABUNDANCE,
                            bio=totBIOMASS,bioCV=cvBIOMASS) |> 
              dplyr::mutate(type="asmt",
                            abd=1000000*abd);

##--get crabpack biomass/abundance time series----
dfrC_ABMs = calc_bioabund(lstCP,
                        species="TANNER",
                        region="EBS",
                        years=1975:2024,
                        sex="male",
                        size_min=24.5,
                        spatial_level="region") |> 
        dplyr::select(y=YEAR,
                      abd=ABUNDANCE,abdCV=ABUNDANCE_CV,
                      bio=BIOMASS_MT,bioCV=BIOMASS_MT_CV) |> 
        dplyr::mutate(x="MALE",m="UNDETERMINED",type="crabpack");
head(dfrC_ABMs);
dfrC_ABFIs = calc_bioabund(lstCP,
                        species="TANNER",
                        region="EBS",
                        years=1975:2024,
                        sex="female",
                        crab_category="immature_female",
                        female_maturity="morphometric",
                        size_min=24.5,
                        spatial_level="region") |> 
              dplyr::select(y=YEAR,
                            abd=ABUNDANCE,abdCV=ABUNDANCE_CV,
                            bio=BIOMASS_MT,bioCV=BIOMASS_MT_CV) |> 
              dplyr::mutate(x="FEMALE",m="IMMATURE",type="crabpack");
head(dfrC_ABFIs);
dfrC_ABFMs = calc_bioabund(lstCP,
                        species="TANNER",
                        region="EBS",
                        years=1975:2024,
                        sex="female",
                        crab_category="mature_female",
                        female_maturity="morphometric",
                        size_min=24.5,
                        spatial_level="region") |> 
              dplyr::select(y=YEAR,
                            abd=ABUNDANCE,abdCV=ABUNDANCE_CV,
                            bio=BIOMASS_MT,bioCV=BIOMASS_MT_CV) |> 
              dplyr::mutate(x="FEMALE",m="MATURE",type="crabpack");
head(dfrC_ABFMs);
##--combine datafraames
dfrABs = dplyr::bind_rows(dfrT_ABs,dfrC_ABMs,dfrC_ABFIs,dfrC_ABFMs);
head(dfrABs);

#--plot abundance comparisons----
p1 = ggplot(dfrABs |> dplyr::mutate(abd=abd/1000000,xm=tolower(paste(m,x))),
            aes(x=y,y=abd,ymin=abd*(1-abdCV),ymax=abd*(1+abdCV),colour=type,fill=type,shape=type)) + 
     geom_ribbon(alpha=0.3,colour=NA) + geom_line() + geom_point(fill=NA,size=3) + 
     scale_fill_manual(values=c("gold","blue"),aesthetics=c("colour","fill")) + 
     scale_shape_manual(values=c(24,25)) + 
     facet_grid(xm~.) + 
     labs(y="Abundance (millions)") + 
     wtsPlots::getStdTheme() + 
     theme(axis.title.x=element_blank(),
           legend.title=element_blank(),
           legend.position="inside",
           legend.position.inside=c(0.99,0.99),
           legend.justification=c(1,1));
print(p1);

dfrABsp = dfrABs |> dplyr::select(y,x,m,abd,type) |> 
            tidyr::pivot_wider(names_from="type",values_from="abd") |> 
            dplyr::mutate(diff=asmt-crabpack,
                          pdif=2*100*diff/(asmt+crabpack));
p1 = ggplot(dfrABsp |> dplyr::mutate(diff=diff/1000000,xm=tolower(paste(m,x))),
            aes(x=y,y=diff)) + 
     geom_line() + geom_point(fill=NA,size=3) + 
     scale_fill_manual(values=c("gold","blue"),aesthetics=c("colour","fill")) + 
     scale_shape_manual(values=c(24,25)) + 
     facet_grid(xm~.) + 
     labs(y="Abundance Difference (millions)") + 
     wtsPlots::getStdTheme() + 
     theme(axis.title.x=element_blank(),
           legend.title=element_blank(),
           legend.position="inside",
           legend.position.inside=c(0.99,0.99),
           legend.justification=c(1,1));
print(p1);

p2 = ggplot(dfrABsp |> dplyr::mutate(xm=tolower(paste(m,x))),
            aes(x=y,y=pdif)) + 
     geom_line() + geom_point(fill=NA,size=3) + 
     scale_fill_manual(values=c("gold","blue"),aesthetics=c("colour","fill")) + 
     scale_shape_manual(values=c(24,25)) + 
     facet_grid(xm~.) + 
     labs(y="% Difference in Abundance") + 
     wtsPlots::getStdTheme() + 
     theme(axis.title.x=element_blank(),
           legend.title=element_blank(),
           legend.position="inside",
           legend.position.inside=c(0.99,0.99),
           legend.justification=c(1,1));
print(p2);

require(tables);
isHTM = TRUE;
tblr = tabular(Factor(y,name="year") ~ Factor(xm)*pdif*mean,
               data=dfrABsp |> dplyr::mutate(xm=tolower(paste(m,x)),
                                             pdif=round(pdif,1)));
colLabels(tblr) = colLabels(tblr)[2,];
kbl = tblr |> wtsQMD::convert_tblr_to_kbl(col_spec=c(1),isHTM,
                                          ltx_font_size=7,replaceNAs="--",adjColSpacing=-4);

#--check maturity
dfrMat<-get_male_maturity(channel=lst,       # <-must be a channel, does not work with rds
                          species="TANNER",
                          region="EBS",
                          district="ALL");
