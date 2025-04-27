require(ggplot2)
dirObj = "/Users/williamstockhausen/Work/Projects/SBS_SelectivityAnalysis_TannerCrab/Analysis/02_Empirical_Selectivity";
obj = wtsUtilities::getObj(file.path(dirObj,"rda_EmpSelModels.RData"));
dfrM = obj$males$best$prd;
dfrF = obj$females$best$prd;
  dfr = dplyr::bind_rows(
          dfrM |> dplyr::mutate(sex="male"),
          dfrF |> dplyr::mutate(sex="female")
  )
  p1 = ggplot(dfr,aes(x=z,y=emp_sel,ymin=lci,ymax=uci,colour=sex,fill=sex)) +
        geom_line() + geom_ribbon(alpha=0.3) +
        labs(x="size (mm CW)",y="estimated selectivity");
  print(p1)

sM = max(dfrM$emp_sel)
zM = dfrM$z[dfrM$emp_sel==sM];
dfrMp = dfrM |> dplyr::mutate(emp_sel=ifelse(z>zM,sM,emp_sel));
sF = max(dfrF$emp_sel)
zF = dfrF$z[dfrF$emp_sel==sF];
dfrFp = dfrF |> dplyr::mutate(emp_sel=ifelse(z>zF,sF,emp_sel));
dfrp = dplyr::bind_rows(
        dfrMp |> dplyr::mutate(sex="male"),
        dfrFp |> dplyr::mutate(sex="female")
      ) |> dplyr::mutate(se.fit=as.vector(se.fit)); #--se.fit is otherwise a list column

p1 = ggplot(dfr,aes(x=z,y=emp_sel,ymin=lci,ymax=uci,colour=sex,fill=sex)) +
      geom_line() + geom_ribbon(alpha=0.3) + 
      geom_line(data=dfrp,linetype=3,linewidth=1) + 
      labs(x="size (mm CW)",y="estimated selectivity");
print(p1)

dfrEmpSelsH = dfrp |> dplyr::select(sex,z,emp_sel) |> 
               tidyr::pivot_wider(names_from="z",values_from="emp_sel");
dfrEmpSelsSEH = dfrp |> dplyr::select(sex,z,emp_sel,se.fit) |> 
                  dplyr::mutate(se=emp_sel*sqrt(exp(se.fit*se.fit)-1)) |> 
                  dplyr::select(!c(emp_sel,se.fit)) |> 
                  tidyr::pivot_wider(names_from="z",values_from="se");
readr::write_csv(dfrEmpSelsH,file.path("EmpSels.FromSBS.csv"));
readr::write_csv(dfrEmpSelsSEH,file.path("EmpSelsSE.FromSBS.csv"));


