#--plot results
resDir = "./run_results";
models = wtsUtilities::getObj(file.path(resDir,"Results.RData"));

#--selectivity----
rCompTCMs::compareResults.Surveys.CaptureProbs(models,
                                               fleets=c("NMFS M",
                                                        "NMFS F",
                                                        "SBS BSFRF M",
                                                        "SBS BSFRF F"));

#-surveys (biomass)--------------------------------------------
mdfr<-rCompTCMs::extractMDFR.Fits.BiomassData(objs=models[compare],
                                              fleets="all",
                                              fleet.type="survey",
                                              catch.type="index",
                                              ci=0.95); 
rCompTCMs::compareFits.BiomassData(objs=models,
                                   fleets=c("NMFS M",
                                            "NMFS F"),
                                   fleet.type="survey",
                                   catch.type="index");
rCompTCMs::compareFits.BiomassData(objs=models,
                                   fleets=c("SBS BSFRF M",
                                            "SBS BSFRF F"),
                                   fleet.type="survey",
                                   catch.type="index");
#-surveys (sie compositions)--------------------------------------------
rCompTCMs::compareFits.MeanSizeComps(models,
                                     fleets=c("NMFS M",
                                             "NMFS F"),
                                     fleet.type="survey",
                                     catch.type="index")
rCompTCMs::compareFits.MeanSizeComps(models,
                                     fleets=c("SBS BSFRF M",
                                            "SBS BSFRF F"),
                                     fleet.type="survey",
                                     catch.type="index")
rCompTCMs::compareFits.SizeComps(models,
                                     fleets=c("NMFS M",
                                             "NMFS F"),
                                     fleet.type="survey",
                                     catch.type="index")

#--fisheries (biomass)--------------------------------------------
mdfr<-rCompTCMs::extractMDFR.Fits.BiomassData(objs=models[compare],
                                              fleets="all",
                                              fleet.type="fishery",
                                              catch.type="capture",
                                              ci=0.95); 
rCompTCMs::compareFits.BiomassData(objs=models,
                                   fleets=c("all"),
                                   fleet.type="fishery",
                                   catch.type="retained");
rCompTCMs::compareFits.BiomassData(objs=models,
                                   fleets=c("all"),
                                   fleet.type="fishery",
                                   catch.type="total");

#--
rCompTCMs::compareResults.sdRep.RecAndSSB(models)
rCompTCMs::compareResults.Pop.Biomass1(models,type="B_yxm",facet_grid=m~x)
