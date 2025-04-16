#--read model files and create R object
require(wtsGMACS);

dirPrj = rstudioapi::getActiveProject();
#--identify relative (from project folder) path and name for each model
fldrs = c("G25_02"="ModelRuns/ModelRuns-GMACS/25_02/run"
         );
cases = names(fldrs);#--model names
#--create full paths, reassign model names
fldrs=file.path(dirPrj,fldrs); names(fldrs) = cases;
#--read model results (returns a `gmacs_reslst` object)
resLst = wtsGMACS::readModelResults(fldrs);

dirThs = dirname(rstudioapi::getActiveDocumentContext()$path);
wtsUtilities::saveObj(resLst,file.path(dirThs,"rda_ModelsResLst.GMACS.RData"));

