#--3-parameter double normal
mfexp<-function(x){return(exp(x))}
square<-function(x){return(x*x)}
elem_prod<-function(x,y){return(x*y)}
pdubnorm<-function(x, sL=NULL, s50=NULL, sR=NULL,parvec=NULL){
  if (!is.null(parvec)){
    sL  = parvec[1];
    s50 = parvec[2];
    sR  = parvec[3];
  }
  slp  = 5.0;#--use pretty steep slope for join
  selLH = mfexp(-0.5*square((x-s50)/sL));# ascending limb
  selRH = mfexp(-0.5*square((x-s50)/sR));# descending limb
  join  = 1.0/(1.0+exp(-slp*(x-s50)));   # 0 for x<s50, 1 for x>s50
  selex = elem_prod(elem_prod(1.0-join,selLH) + join,
                      elem_prod(    join,selRH) + (1.0-join));
  return( selex)
}
z = seq(27,182,5)
pv1 = c(1.83964933657,4.65229716150,1.83964933657)
pdubnorm(z,parvec=pv1)
pdubnorm(z,parvec=exp(pv1))
dfrDN = tibble::tibble(x=z,y=pdubnorm(z,parvec=exp(pv1)))
ggplot(dfrDN,aes(x=x,y=y)) + geom_line();

tmp =  dfrSel |> dplyr::filter(fleet %in% "SCF",type=="capture",x=="male",case=="gmacs",y %in% c(1948,1997,2005))
