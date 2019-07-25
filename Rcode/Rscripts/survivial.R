t <- c(6,6,6,6,7,9,10,10,11,13,16,17,19,20,22,23,25,32,32,34,35)
delta <- c(1,1,1,0,1,0,1,0,0,1,1,0,0,0,1,1,0,0,0,0,0)
x <- rep(1,21)

fit <- survfit(Surv(t, delta)~x ,conf.type="plain")
plot(fit,xlab="t",ylab="S(t)")
summary(fit)

fit <- survfit(Surv(timedeath, death)~1,type="kaplan-meier" ,conf.type="plain",data=sur2)
plot(fit,xlab="t",ylab="S(t)")
summary(fit)


survdiff(Surv(timedeath, death)~group,data=sur2)