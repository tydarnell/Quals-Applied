etable=function(exposure,disease){
  t=table(exposure,disease)[2:1,2:1]
  rownames(t)=c('E+','E-')
  colnames(t)=c('D+','D-')
  t
}

riskratio=function(a,b,c,d){
  e=a/(a+b)
  f=c/(c+d)
  c(e,f,e/f)
}


ciriskr=function(ecases,enoncases,uecases,uenoncases){
  a=ecases
  b=enoncases
  c=uecases
  d=uenoncases
  e=a/(a+b)
  f=c/(c+d)
  rr=e/f
  z=c(-1.96,1.96)
  se=sqrt(1/a-1/(a+b)+
            1/c-1/(c+d))
  ci=exp(log(rr)+z*se)
  c("Risk Ratio"=rr,"95 CI"=ci)
}


rateratio=function(cases,noncases,pyrcases,pyrnoncases){
  a=cases
  b=noncases
  p=pyrcases
  q=pyrnoncases
  (a/p)/(b/q)
}


cirater=function(cases,noncases,pyrcases,pyrnoncases){
  a=cases
  b=noncases
  p=pyrcases
  q=pyrnoncases
  rr=(a/p)/(b/q)
  se=sqrt(1/a+1/b)
  z=c(-1.96,1.96)
  ci=exp(log(rr)+z*se)
  c("Rate Ratio"=rr,"95 CI"=ci)
}


cioddsr=function(ecases,enoncases,uecases,uenoncases){
  a=ecases
  b=enoncases
  c=uecases
  d=uenoncases
  or=(a/c)*(d/b)
  se=sqrt(1/a+1/b+1/c+1/d)
  z=c(-1.96,1.96)
  ci=exp(log(or)+z*se)
  c("Odds Ratio"=or,"95 CI"=ci)
}


etable2=function(exposure,disease){
  t=table(exposure,disease)[2:1,2:1]
  rownames(t)=c('E+','E-')
  colnames(t)=c('D+','D-')
  addmargins(t)
}