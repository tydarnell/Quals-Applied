#####################################
# Q2: MS Exam Applied 2017
# Student: Ann Marie Weideman
# Date: 6/10/19
#####################################

#import data
df_cancer<-read.table("C:/Users/anndo/Documents/MS_qual_practice/2017/application/data/subtype.txt",
                      header=T)

#view data
View(df_cancer)

#-----------------------------------
# a), Part ii)
#-----------------------------------

df_cancer_chemo<-df_cancer[which(df_cancer$treatment==1),]

#this allows us to relevel an ordered variable
df_cancer_chemo$clin_sub <- factor(df_cancer_chemo$clin_sub, levels=c("1","2"))

#-1 codes for cell means (without -1 it's reference cell)
lm_aii<-lm(response~relevel(clin_sub,"1")-1, data=df_cancer_chemo)
summary(lm_aii)

#post hoc test
TukeyHSD(aov(response~relevel(clin_sub,"1")-1,data=df_cancer_chemo))
#$`relevel(clin_sub, "1")`
#         diff     lwr      upr p adj
#2-1 26.75166 17.22934 36.27399 1e-07

#-----------------------------------
# a), Part iii)
#-----------------------------------
require(car)
leveneTest(y=df_cancer_chemo$response,group=df_cancer_chemo$clin_sub)
#Levene's Test for Homogeneity of Variance (center = median)
#       Df F value Pr(>F)
#group   1  0.8171 0.3673
#      166 

#-----------------------------------
#a), Part iv)
#-----------------------------------

require(car)
linearHypothesis(lm_aii,c(2,-1))
#Res.Df    RSS Df Sum of Sq      F    Pr(>F)    
#1    167 155323                                  
#2    166 130712  1     24611 31.255 9.125e-08 ***

#-----------------------------------
# a), Part v)
#-----------------------------------

#variance-covariance matrix, which is MSE*SSCP
vcov(lm_aii)
#relevel(clin_sub, "1")1                6.507635                  0.0000
#relevel(clin_sub, "1")2                0.000000                 16.7537

#--------------------------------------
# b), Part i)
# NOTE: Unbalanced design, use Type 3
#--------------------------------------

#convert clinical subtype to a factor and recode the levels
df_cancer$clin_sub<-factor(df_cancer$clin_sub,
                            levels=c(1,2),
                            labels=c('HR+','HR-'))

#convert treatment to a factor and recode the levels
df_cancer$treatment<-factor(df_cancer$treatment,
                           levels=c(0,1),
                           labels=c('Hormone','Chemo'))

options(contrasts = c("contr.sum","contr.poly"))

#two-way anova (type III due to unbalanced design)
aov_bi<-aov(response~treatment+clin_sub+treatment:clin_sub,data=df_cancer)
car::Anova(aov_bi, type = "III")

summary(aov_bi)

#multiple comparisons via Tukey HSD (honest signficant differences)
TukeyHSD(aov_bi)

#--------------------------------------
# b), Part ii)
# NOTE: Unbalanced design, use Type 3
#--------------------------------------

#get R^2 from previous model in part i)
lm_bi<-lm(response~treatment+clin_sub+treatment*clin_sub,data=df_cancer)
summary(lm_bi)

#convert molecular subtype to a factor and recode the levels
df_cancer$molecular_sub<-factor(df_cancer$molecular_sub,
                                levels=c(1,2,3,4),
                                labels=c('Luminal A', 'Luminal B', 'Basal', 'Claudin-low'))

options(contrasts = c("contr.sum","contr.poly"))

#two-way anova (type III due to unbalanced design)
aov_bii<-aov(response~treatment+molecular_sub+treatment:molecular_sub,data=df_cancer)
car::Anova(aov_bii, type = "III")

summary(aov_bii)

#multiple comparisons via Tukey HSD (honest signficant differences)
TukeyHSD(aov_bii)

#get R^2
lm_bii<-lm(response~treatment+molecular_sub+treatment*molecular_sub,data=df_cancer)
summary(lm_bii)

#compare the two non-nested models
AIC(aov_bi,aov_bii)
