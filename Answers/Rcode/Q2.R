###########################
#Question 2
#MS Applied Exam, 2018
#Ann Marie Weideman
###########################

#import data
df<-read.table("C:\\Users\\anndo\\Documents\\MS_qual_practice\\2018\\application\\data\\t2d.txt",
               header=T)

#part d)
logit_d<-glm(Outcome~Intervention*Sex,data=df,family='binomial')
summary(logit_d)
#Coefficients:
#                   Estimate Std. Error z value Pr(>|z|)  
#(Intercept)        -0.6931     0.3273  -2.118   0.0342 *
#Intervention        0.6444     0.4525   1.424   0.1545  
#SexM               -1.0296     0.5855  -1.758   0.0787 .
#Intervention:SexM   0.2029     0.7630   0.266   0.7903  

#part e)
logit_e<-glm(Outcome~Intervention+Sex,data=df,family='binomial')
summary(logit_e)
#Coefficients:
#                Estimate Std. Error z value Pr(>|z|)  
#(Intercept)     -0.7310     0.2967  -2.464   0.0137 *
#  Intervention   0.7165     0.3634   1.972   0.0487 *
#  SexM          -0.9112     0.3741  -2.435   0.0149 *
