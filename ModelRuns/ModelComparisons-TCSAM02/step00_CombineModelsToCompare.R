#----
dirPrj = rstudioapi::getActiveProject();
if (is.null(dirPrj)) stop("No active project. Open desired project.")

#-load models to compare
models<-list();
topDir = file.path(dirPrj,"ModelRuns/ModelRuns-TCSAM02");
cases<-dplyr::bind_rows(
             tibble::tibble(case="22.03d5", dir="2024_22_03d5/best_results"),
             tibble::tibble(case="25_01",dir="2025_25_01/run_results"),
             tibble::tibble(case="25_01a",dir="2025_25_01a/run_results"),
             tibble::tibble(case="25_02",dir="2025_25_02/run_results")
             );
for (rw in 1:nrow(cases)){
  fn = file.path(topDir,cases$dir[rw],"Results.RData")
  if (file.exists(fn)){
    cat("Reading",fn,"\n")
    models[[cases$case[rw]]]<-wtsUtilities::getObj(fn);
  } else {
    stop(paste0("--Cannot read ",fn,"\n\tFile does not exist. Check path."));
  }
}
compare<-names(models);

dirThis = dirname(rstudioapi::getActiveDocumentContext()$path);
wtsUtilities::saveObj(models,file.path(dirThis,"rda_Models.RData"));
