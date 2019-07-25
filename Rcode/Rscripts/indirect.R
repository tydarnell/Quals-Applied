
#INDRECT STANDARDIZATION APPROACH
data %>% 
  mutate(refPop = n.total/N.total,    #reference (urban) proportions (see pg 27) (identical to 'p.urban' column)
         exp=N.h*refPop) %>%   #expected smokers for each age group (see pg 27/29)
  summarize(o = sum(n.h),        #observed overall rural smokers (see pg 27)
            e=sum(exp),           #expected overall rural smokers (see pg 27)
            s = obs/e,          #standardized incidence ratio (SIR) (see pg 27)
            varO = o,         #variance of observed smokers (see pg 28)
            varE = sum((N.h/N.total)^2*n.total),    #variance of expected smokers (see pg 28)
            varS = (varO+s^2*varE)/e^2,   #variance of SIR (see pg 28)
            Z = (s-1)/sqrt(varS),           #test statistic (see pg 28)
            pVal = pnorm(Z))                #p-value

dati=dat %>% 
mutate(refPop = n.total/N.total,
exp=N.h*refPop)

ans2=dati%>% summarize(o = sum(n.h), 
            e=sum(exp),          
            s = o/e,          
            varO = o,         
            varE = sum((N.h/N.total)^2*n.total),
            varS = (varO+s^2*varE)/e^2,   
            Z = (s-1)/sqrt(varS),
            pVal = pnorm(Z))          