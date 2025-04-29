#--load required packages
require(magrittr);
require(rCompTCMs);
require(rTCSAM02);
require(tables);
source("r_TableFunctions.OFCs.R")
source("r_TableFunctions.Params.R")

#-load models
topDir<-"~/Work/StockAssessments-Crab/Assessments/TannerCrab/2021-09_TannerCrab/ModelRuns";
models<-list();
caseInfo<-matrix(byrow = TRUE,ncol = 2,
                 data=c("20.07", "20_07/best_results",
                        "20.07u","20_07u/best_results",
                        "21.22", "21_22/best_results",
                        "21.24", "21_24/best_results",
                        "21.22a","21_22a/run_new_results"));
for (rw in 1:nrow(caseInfo)){
  fn = file.path(topDir,caseInfo[rw,2],"Results.RData");
  message("Loading ",fn)
  load(file=fn);
  models[[caseInfo[rw,1]]]<-obj;
  rm(obj);
}
compare<-names(models);

#if (!dir.exists('results')) dir.create("results");

################################################################################
#--GENERATE AND SAVE REQUIRED TABLES                                           #
################################################################################
################################################################################
#--extract parameter-related tables
#----parameters at bounds
dfr.PsAtBs<-rCompTCMs::extractMDFR.Results.ParametersAtBounds(models[compare]);
tbl = doTable.PsAtBs(dfr.PsAtBs);
write.csv(tbl,file="tbl01_ParamsAtBounds.csv")
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl01_ParamsAtBounds.pdf"),
                              pageheight=5.5,pagewidth=10.5,cleanup=TRUE);

#----parameter values
dfr.PVs = rCompTCMs::extractMDFR.Results.ParameterValues(models[compare[c(2,3,5)]]);
readr::write_csv(dfr.PVs,"tbl02_ParamValues.csv");
#------recruitment, natural mortality, growth parameters
tbl = doTable.ParamVals(dfr.PVs,param_type="number",
                        ctgs=c("population processes"),
                        prcs=c("recruitment","natural mortality","growth"));
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02a_ParamVals_PopProcesses.pdf"),
                              pageheight=4.,pagewidth=14,cleanup=TRUE);

#------rec devs
#-------historical recruitment period
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("population processes"),
                        prcs=c("recruitment"),
                        lbls="historical recruitment period");
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02b_ParamVals_PopProcesses.RecDevsHist.pdf"),
                              pageheight=5.4,pagewidth=11.7,cleanup=TRUE);
#-------current recruitment period
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("population processes"),
                        prcs=c("recruitment"),
                        lbls="current recruitment period");
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02c_ParamVals_PopProcesses.RecDevsCurr.pdf"),
                              pageheight=8.4,pagewidth=12,cleanup=TRUE);

#------terminal molt parameters
tbl = doTable.ParamVals(dfr.PVs,param_type="vector",
                        ctgs=c("population processes"),
                        prcs=c("maturity"));
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02d_ParamVals_PopProcesses.pdf"),
                              pageheight=5.3,pagewidth=13,cleanup=TRUE);

#------non-devs fishery and survey parameters, as well as D-M parameters
tbl = doTable.ParamVals(dfr.PVs,param_type="number",
                        ctgs=c("fisheries","surveys","likelihood"),
                        prcs=c("fisheries","surveys","Dirichlet-Multinomial"));
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02e_ParamVals_FshSrvsLL.pdf"),
                              pageheight=7,pagewidth=14.5,cleanup=TRUE);

#------fishery devs
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("fisheries"),
                        prcs=c("fisheries"),
                        lbls="TCF: 1965-1984, 1987-1996, 2005-2009, 2013-2015, 2017-2018");
rowLabels(tbl)<-rowLabels(tbl)[,4];
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02f_ParamVals_FshDevs.TCF.pdf"),
                              pageheight=7.5,pagewidth=8,cleanup=TRUE);
#--
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("fisheries"),
                        prcs=c("fisheries"),
                        lbls="SCF: 1992+");
rowLabels(tbl)<-rowLabels(tbl)[,4];
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02g_ParamVals_FshDevs.SCF.pdf"),
                              pageheight=6,pagewidth=8,cleanup=TRUE);
#--
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("fisheries"),
                        prcs=c("fisheries"),
                        lbls="RKF: 1992+");
rowLabels(tbl)<-rowLabels(tbl)[,4];
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02h_ParamVals_FshDevs.RKF.pdf"),
                              pageheight=6,pagewidth=8,cleanup=TRUE);
#--
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("fisheries"),
                        prcs=c("fisheries"),
                        lbls="GF.AllGear: 1973+");
rowLabels(tbl)<-rowLabels(tbl)[,4];
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02i_ParamVals_FshDevs.GF.pdf"),
                              pageheight=9,pagewidth=8,cleanup=TRUE);

#------selectivity parameters
#--pS1
tbl = doTable.ParamVals(dfr.PVs,param_type="number",
                        ctgs=c("selectivity"),
                        prcs=c("selectivity"),
                        nams="pS1");
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02j_ParamVals_SelParams.pS1.pdf"),
                              pageheight=8,pagewidth=13,cleanup=TRUE);
#--pS2
tbl = doTable.ParamVals(dfr.PVs,param_type="number",
                        ctgs=c("selectivity"),
                        prcs=c("selectivity"),
                        nams="pS2");
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02k_ParamVals_SelParams.pS2.pdf"),
                              pageheight=8,pagewidth=13,cleanup=TRUE);
#--pS3, pS4
tbl = doTable.ParamVals(dfr.PVs,param_type="number",
                        ctgs=c("selectivity"),
                        prcs=c("selectivity"),
                        nams=c("pS3","pS4"));
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02l_ParamVals_SelParams.pS3S4.pdf"),
                              pageheight=2.75,pagewidth=14.5,cleanup=TRUE);

#--selectivity devs
tbl = doTable.ParamVals(dfr.PVs,param_type="devs",
                        ctgs=c("selectivity"),
                        prcs=c("selectivity"),
                        nams="pDevsS1");
rowLabels(tbl)<-rowLabels(tbl)[,4];
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl02m_ParamVals_SelDevs.pdf"),
                              pageheight=4,pagewidth=8,cleanup=TRUE);

################################################################################
#--extract objective function-related tables
#----extract data-related components by category
surveys<-c("NMFS M","NMFS F","SBS BSFRF males","SBS BSFRF females");#--not including SBS NMFS components since not fit
fisheries<-c("TCF","SCF","RKF","GF All");
dfrOFCs<-rTCSAM02::getMDFR.OFCs.DataComponents(models[compare],categories="all");
#----objective function values
#------surveys and fisheries
tbl1<-makeTable.OFCs.DCs(dfrOFCs,fleets=c(surveys,fisheries),
                        categories=c("surveys data","fisheries data"),
                        fun.aggregate=wtsUtilities::Sum,value.var="objfun");
#------growth & maturity ogive data
tbl2<-makeTable.OFCs.DCs(dfrOFCs,fleets=c(surveys,fisheries),
                        categories=c("growth data","maturity ogive data"),
                        fun.aggregate=wtsUtilities::Sum,value.var="objfun");
readr::write_csv(rbind(tbl1,tbl2), path="tbl04_OFCs.DCs.ObjFuns.csv");
#----rmses and harmonic mean effective N's
tmp<-dfrOFCs %>% subset(data.type!="n.at.z")
tbl1<-makeTable.OFCs.DCs(tmp,fleets=c(surveys,fisheries),
                        categories=c("surveys data","fisheries data"),
                        fun.aggregate=wtsUtilities::Sum,value.var="rmse");
tmp<-dfrOFCs %>% subset(data.type=="n.at.z")
tbl2<-makeTable.OFCs.DCs(tmp,fleets=c(surveys,fisheries),
                        categories=c("surveys data","fisheries data"),
                        fun.aggregate=wtsUtilities::HarmMean,value.var="rmse");#--"rmse" a bit of a misnomer here, really pearson's residuals
tmp<-dfrOFCs %>% subset(data.type!="n.at.z")
tbl3<-makeTable.OFCs.DCs(tmp,fleets=c(surveys,fisheries),
                        categories=c("growth data","maturity ogive data"),
                        fun.aggregate=wtsUtilities::Sum,value.var="rmse");    #--"rmse" a bit of a misnomer here, really pearson's residuals
readr::write_csv(rbind(tbl1,tbl2,tbl3), path="tbl04_OFCs.DCs.RMSEs-EffNs.csv");


#----extract non-data-related components by category
dfr<-rTCSAM02::getMDFR.OFCs.NonDataComponents(models[compare],categories="all");
tbl<-makeTable.OFCs.NDCs(dfr);
readr::write_csv(tbl, path="tbl05_OFCs.NDCs.ObjFuns.csv");

################################################################################
#--extract natural mortality estimates
tmp     = rTCSAM02::getMDFR.Pop.NaturalMortality(models[compare],type="M_cxm");
tblLkUp = dplyr::bind_rows(tibble::tibble(pc=1,y="typical"),
                           tibble::tibble(pc=2,y="typical"),
                           tibble::tibble(pc=3,y="typical"),
                           tibble::tibble(pc=4,y="elevated"),
                           tibble::tibble(pc=5,y="elevated"));
dfrNMs = tmp %>%  dplyr::mutate(y=factor(tblLkUp$y[as.numeric(pc)],levels=c("typical","elevated")),
                                x=tolower(x),
                                m=tolower(m),
                                x=ifelse(x=="all_sex","all",x),
                                case=factor(case,levels=compare));
tbl = tables::tabular(Factor(case)~
                        Factor(m)*Factor(x)*Factor(y)*
                          Heading("estimate")*val*mean*Format(digits=2,nsmall=2)*
                          DropEmpty(empty="--",which=c("cell","col")),
                      data=dfrNMs);
colLabels(tbl)=colLabels(tbl)[c(2,4,6),];
tex = tables::toLatex(tbl)$text;
wtsUtilities::writeTableToPDF(tex,pdf_name =file.path("tbl06a_NaturalMortalityEstimates.pdf"),
                              pageheight=1.5,pagewidth=4.0,cleanup=TRUE);
readr::write_csv(dfrNMs,path="tbl06a_NaturalMortalityEstimates.csv");
rm(tmp,tbl,tex);

################################################################################
#--fits to survey biomass
tmp = extractMDFR.Fits.BiomassData(models[compare],fleet.type="survey",catch.type="index") %>%
        dplyr::filter(!((type=="observed")&(case!=compare[2]))) %>%  #--filter out multiple copies of "observed", include current survey
        dplyr::mutate(case=factor(case,levels=compare));
getInfo<-function(tmp1){
  dst  = tmp1 %>% dplyr::filter(type=="observed") %>% dplyr::distinct(y,x,m,s);
  tmp2 = tmp1 %>% dplyr::inner_join(dst,by=c("y","x","m","s"));
  tbl = tables::tabular(Factor(y,name="year")~
                          Factor(type)*Factor(case)*
                          Heading("estimate")*val*mean*Format(digits=2,nsmall=2)*
                            DropEmpty(empty="--",which=c("cell","col")),
                        data=tmp2);
  colLabels(tbl)=colLabels(tbl)[c(2,4),];
  colLabels(tbl)[2,1]=NA;
  tex = tables::toLatex(tbl)$text;
  return(list(tbl=tbl,tex=tex));
}
#----NMFS EBS, males
lst = getInfo(tmp %>% dplyr::filter(fleet=="NMFS M"));
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06b_SurveyBiomassComparison.NMFS_AM.pdf"),
                              pageheight=8.5,pagewidth=4.0,cleanup=TRUE);
write.csv(lst$tbl,file="tbl06b_SurveyBiomassComparison.NMFS_AM.csv");
rm(lst);
#----NMFS EBS, mature females
lst = getInfo(tmp %>% dplyr::filter(fleet=="NMFS F",m=="mature"));
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06b_SurveyBiomassComparison.NMFS_MF.pdf"),
                              pageheight=8.5,pagewidth=4.0,cleanup=TRUE);
write.csv(lst$tbl,file="tbl06b_SurveyBiomassComparison.NMFS_MF.csv");
rm(lst);
#----NMFS EBS, immature females
lst = getInfo(tmp %>% dplyr::filter(fleet=="NMFS F",m=="immature"));
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06b_SurveyBiomassComparison.NMFS_IF.pdf"),
                              pageheight=8.5,pagewidth=4.0,cleanup=TRUE);
write.csv(lst$tbl,file="tbl06b_SurveyBiomassComparison.NMFS_IF.csv");
rm(lst,tmp,getInfo);

################################################################################
#--comparison of estimates of mature biomass-at-mating by sex
tmp <-extractMDFR.Pop.MatureBiomass(models[compare]);
getInfo<-function(tmp1){
  tbl = tables::tabular(Factor(y,name="year")~
                          Factor(x)*Factor(case)*val*mean*Format(digits=2,nsmall=2,scientific=FALSE)*
                              DropEmpty(empty="--",which=c("cell","col")),
                        data=tmp1);
  colLabels(tbl)=colLabels(tbl)[c(2,4),];
  tex = tables::toLatex(tbl)$text;
  return(list(tbl=tbl,tex=tex));
}
lst = getInfo(tmp %>% dplyr::filter(as.numeric(y)<=1980))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06c1.MMB.pdf"),
                              pageheight=8.5,pagewidth=8.5,cleanup=TRUE);
lst = getInfo(tmp %>% dplyr::filter(1981<=as.numeric(y)))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06c2_MMB.pdf"),
                              pageheight=8.5,pagewidth=8.5,cleanup=TRUE);
readr::write_csv(tmp %>% subset(x=="male"),  path="Table_MMBComparison.csv");
readr::write_csv(tmp %>% subset(x=="female"),path="Table_MFBComparison.csv");
rm(tmp,lst,getInfo);

################################################################################
#----extract population sizes (should zip this one up)
dfr<-extractMDFR.Pop.Abundance(models[c("20.07u","21.22a")],cast="y+x+m+s+z");
readr::write_csv(dfr,file="Table_PredictedAnnualPopulationSizeStructure.csv");

################################################################################
#----comparison of estimated recruitment
tmp <-extractMDFR.Pop.Recruitment(models[compare]);
getInfo<-function(tmp1){
  tbl = tables::tabular(Factor(y,name="year")~
                          Factor(case)*val*mean*Format(digits=2,nsmall=2,scientific=FALSE)*
                              DropEmpty(empty="--",which=c("cell","col")),
                        data=tmp1);
  colLabels(tbl)=colLabels(tbl)[2,];
  tex = tables::toLatex(tbl)$text;
  return(list(tbl=tbl,tex=tex));
}
lst = getInfo(tmp %>% dplyr::filter(as.numeric(y)<=1980))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06d1.Recriutment.pdf"),
                              pageheight=6,pagewidth=3.75,cleanup=TRUE);
lst = getInfo(tmp %>% dplyr::filter(1981<=as.numeric(y)))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06d2.Recriutment.pdf"),
                              pageheight=7.5,pagewidth=3.75,cleanup=TRUE);
readr::write_csv(tmp,file="Table_RecruitmentComparison.csv");
avgRecLast10 = mean((tmp %>% dplyr::filter(case=="21.22a",dplyr::between(y,2009,2018)))$val);
avgRecLast10 = mean((tmp %>% dplyr::filter(case=="21.22a",dplyr::between(y,2009,2018)))$val);
rm(tmp,lst,getInfo);

################################################################################
#----comparison of estimated exploitation rates
tmp<-extractMDFR.ExploitationRates(models[compare]);
getInfo<-function(tmp1){
  tbl = tables::tabular(Factor(y,name="year")~
                          Factor(case)*val*mean*Format(digits=2,nsmall=2,scientific=FALSE)*
                              DropEmpty(empty="--",which=c("cell","col")),
                        data=tmp1);
  colLabels(tbl)=colLabels(tbl)[2,];
  tex = tables::toLatex(tbl)$text;
  return(list(tbl=tbl,tex=tex));
}
lst = getInfo(tmp %>% dplyr::filter(as.numeric(y)<=1980))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06e1.ExploitationRates.pdf"),
                              pageheight=6,pagewidth=3.75,cleanup=TRUE);
lst = getInfo(tmp %>% dplyr::filter(1981<=as.numeric(y)))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tbl06e2.ExploitationRates.pdf"),
                              pageheight=7.5,pagewidth=3.75,cleanup=TRUE);
readr::write_csv(tmp,file="Table_ExploitationRatesComparison.csv");

################################################################################
#----estimated annual total abundance and biomass, by sex from preferred model
prefMod = "21.22a";
tmpA<-extractMDFR.Pop.Abundance(models[prefMod]) %>%  #--aggregates by year, sex by default
        dplyr::select(y,x,val) %>% dplyr::mutate(type="abundance",units="(millions)")
tmpB<-extractMDFR.Pop.Biomass(models[prefMod]) %>%  #--aggregates by year, sex by default
        dplyr::select(y,x,val) %>% dplyr::mutate(type="biomass",units="(1000's t)")
tmp = dplyr::bind_rows(tmpA,tmpB) %>% dplyr:select(y,x,type,units,val);
getInfo<-function(tmp1){
  tmp2 = tmp1 %>% dplyr::group_by(y,type,units) %>% 
                  dplyr::summarize(val=sum(val)) %>%
                  dplyr::ungroup() %>%
                  dplyr::mutate(x="total");
  tmp1 = dplyr::bind_rows(tmp1,tmp2);
  tbl = tables::tabular(Factor(y,name="year")~
                          Factor(type)*Factor(x)*Factor(units)*val*sum*Format(digits=2,nsmall=2,scientific=FALSE,big.mark=",")*
                              DropEmpty(empty="--",which=c("cell","col")),
                        data=tmp1);
  colLabels(tbl)=colLabels(tbl)[c(2,4,6),];
  tex = tables::toLatex(tbl)$text;
  return(list(tbl=tbl,tex=tex));
}
lst = getInfo(tmp %>% dplyr::filter(as.numeric(y)<=1980))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tblABa.PopAbundanceBiomass.pdf"),
                              pageheight=6,pagewidth=5.1,cleanup=TRUE);
lst = getInfo(tmp %>% dplyr::filter(1981<=as.numeric(y)))
wtsUtilities::writeTableToPDF(lst$tex,pdf_name =file.path("tblABb.PopAbundanceBiomass.pdf"),
                              pageheight=7.5,pagewidth=5.1,cleanup=TRUE);
write.csv.tabular(lst$tbl,file="Table_PopAbundanceBiomass.csv");

################################################################################
#--extract OFL-related tables
dfr.OFLs<-rTCSAM02::getMDFR.OFLResults(models[compare],verbose=TRUE);
if (!is.null(dfr.OFLs)){
  dfr.OFLs$avgRec<-dfr.OFLs$avgRecM + dfr.OFLs$avgRecF;
  dfr.OFLs<-wtsUtilities::deleteCols(dfr.OFLs,cols=c("avgRecM","avgRecF"),debug=TRUE);
  dfr.OFLs<-dfr.OFLs[,c("case","objFun","maxGrad","avgRec","B100","Bmsy","curB","Fmsy","MSY","Fofl","OFL","prjB")];
  readr::write_csv(dfr.OFLs,path="tbl07_oflResults.TableInText.csv")
  tmp = dfr.OFLs %>% dplyr::mutate(`status ratio`=prjB/Bmsy) %>%
                    dplyr::select(case,avgRec,Bmsy,curB,Fmsy,MSY,Fofl,OFL,prjB,`status ratio`);
  readr::write_csv(tmp,file="tbl07_OFL_Comparisons.csv");
  
}

