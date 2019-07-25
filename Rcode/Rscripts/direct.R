dat%<>%mutate(p.h=n.h/N.h,p.c=n.c/N.c)

dat2=dat %>%
mutate(varProph = p.h*(1-p.h)/N.h,
varPropc = p.c*(1-p.c)/N.c,
weights = N.total/sum(N.total))

ans=dat2%>% summarize(stdProph = sum(p.h*weights),
          stdPropc = sum(p.c*weights),
          adjDiff = stdProph-stdPropc,       #age-adjusted difference (see pg 16)
          varAdjDiff = sum(weights^2*(varProph+varPropc))/sum(weights)^2,   #variance of difference (see pg 22)
          Z = (adjDiff)/sqrt(varAdjDiff),            #test statistic (see pg 22) 
          pValue = pnorm(Z)) 

stdh=ans$stdProph*100000
stdc=ans$stdPropc*100000