#one sample z-stat function
zstat=function(y,u0=0){
  y=na.omit(y)
  yb=mean(y)
  n=length(y)
  s=sd(y)
  zstat=(yb-u0)/(s/sqrt(n))
  zstat
}

#two sample z-stat function
#NA values must be removed prior to using this
zstat2=function(y1,y2,u0=0){
  yb1=mean(y1)
  n1=length(y1)
  s1=sd(y1)
  yb2=mean(y2)
  n2=length(y2)
  s2=sd(y2)
  zstat=((yb1-yb2)-u0)/sqrt(s1^2/n1+s2^2/n2)
  zstat
}

#p-value function for alpha=.05
pval=function(z,twosided=T){
  if (twosided==T) {
    return(2*pnorm(z))
  }
  else
    pnorm(z)
}