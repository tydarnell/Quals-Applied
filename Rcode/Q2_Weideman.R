#####################################
# Q2: MS Exam Applied 2017
# Student: Ann Marie Weideman
# Date: 6/10/19
# Revised: 7/22/19
#####################################

#import data
df_cancer<-read.table("C:/Users/anndo/Documents/MS_qual_practice/2017/application/data/subtype.txt",
                      header=T)

#view data
View(df_cancer)

#-----------------------------------
# a), Part ii)
#-----------------------------------

####################################
#METHOD 1: Use contrast statements
####################################
df_cancer_chemo<-df_cancer[which(df_cancer$treatment==1),]

#fit linear model (make sure to convert clin_sub to a factor)
#-1 to convert from reference cell to cell means coding
lm_aii_full<-lm(response~factor(clin_sub)-1,data=df_cancer_chemo)

#-----------------------------------------
#METHOD 1 A) - using the multcomp package
#-----------------------------------------
require(multcomp)
#create contrast matrix
#want to test if beta1=beta2 -> beta1-beta2=0
#-> C=[1,-1] (no intercept in cell means)
contrast_aii=matrix(c(1,-1),nrow=1)

#glht stands for general linear hypothesis testing
result_aii=glht(lm_aii_full,linfct=contrast_aii)
summary(result_aii)
# Simultaneous Tests for General Linear Hypotheses
# 
# Fit: lm(formula = response ~ factor(clin_sub) - 1, data = df_cancer_chemo)
# 
# Linear Hypotheses:
#          Estimate Std. Error t value Pr(>|t|)    
# 1 == 0  -26.752      4.823  -5.547 1.13e-07 ***
#   ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# (Adjusted p values reported -- single-step method)

#-----------------------------------------
#METHOD 2 A) - using the car package
#-----------------------------------------
require(car)

linearHypothesis(lm_aii_full,hypothesis.matrix=contrast_aii)
# Linear hypothesis test
# 
# Hypothesis:
#   factor(clin_sub)1 - factor(clin_sub)2 = 0
# 
# Model 1: restricted model
# Model 2: response ~ factor(clin_sub) - 1
# 
# Res.Df    RSS Df Sum of Sq      F    Pr(>F)    
# 1    167 154938                                  
# 2    166 130712  1     24226 30.766 1.128e-07 ***

############################################
#METHOD 2: Compare full and reduced models
############################################

#full model is above

#reduced model (intercept only)
lm_aii_reduced<-lm(response~1,data=df_cancer_chemo)

#compare (if you square your t from last method, it will match
#the F returned in this method)
anova(lm_aii_reduced,lm_aii_full)
# Analysis of Variance Table
# 
# Model 1: response ~ 1
# Model 2: response ~ factor(clin_sub) - 1
#     Res.Df  RSS Df   Sum of Sq    F    Pr(>F)    
# 1    167 154938                                  
# 2    166 130712  1     24226 30.766 1.128e-07 ***

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
linearHypothesis(lm_aii_full,c(2,-1))
#Res.Df    RSS Df Sum of Sq      F    Pr(>F)    
#1    167 155323                                  
#2    166 130712  1     24611 31.255 9.125e-08 ***

#-----------------------------------
# a), Part v)
#-----------------------------------

#variance-covariance matrix, which is MSE*inv(SSCP)
vcov(lm_aii_full)
#relevel(clin_sub, "1")1                6.507635                  0.0000
#relevel(clin_sub, "1")2                0.000000                 16.7537

#off-diagonal entry
vcov(lm_aii_full)[1,2]
#[1] 0

#--------------------------------------
# b), Part i)
#--------------------------------------

#----------------------------------------------------------
#METHOD 1: Simply looking at interaction term in full model
#----------------------------------------------------------
lm_bi_full<-lm(response~factor(clin_sub)*treatment,data=df_cancer)
#NOTE: In R, factor(clin_sub)*treatment is equivalent to 
#factor(clin_sub)+treatment+factor(clin_sub):treatment

summary(lm_bi_full)
# Coefficients:
#                              Estimate Std. Error t value Pr(>|t|)    
# (Intercept)                   82.333      3.329  24.729  < 2e-16 ***
# factor(clin_sub)2             -2.641      4.149  -0.637    0.525    
# treatment                    -19.013      3.923  -4.847 2.03e-06 ***
# factor(clin_sub)2:treatment   29.393      5.710   5.147 4.82e-07 ***
#   ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Residual standard error: 22.83 on 296 degrees of freedom
# Multiple R-squared:   0.17,	Adjusted R-squared:  0.1615 
# F-statistic:  20.2 on 3 and 296 DF,  p-value: 6.129e-12

#----------------------------------------------------------
# METHOD 2: Comparing full (w/ interaction) and reduced
# (w/out interaction) models
#----------------------------------------------------------

lm_bi_reduced<-lm(response~factor(clin_sub)+treatment,data=df_cancer)
anova(lm_bi_reduced,lm_bi_full)
# Analysis of Variance Table
# 
# Model 1: response ~ factor(clin_sub) + treatment
# Model 2: response ~ factor(clin_sub) * treatment
# Res.Df    RSS Df Sum of Sq      F   Pr(>F)    
# 1    297 168020                                 
# 2    296 154216  1     13805 26.497 4.82e-07 ***

#oh look, the F here is equal to the t^2 from Method 1 (suprise suprise!)

#----------------------------------------------------------------
# METHOD 3: Supplying contrast statement and using car package
#----------------------------------------------------------------

contrast_bi<-matrix(c(0,0,0,1),nrow=1)

car::linearHypothesis(lm_bi_full,hypothesis.matrix=contrast_bi)
# Linear hypothesis test
# 
# Hypothesis:
#   factor(clin_sub)2:treatment = 0
# 
# Model 1: restricted model
# Model 2: response ~ factor(clin_sub) * treatment
# 
# Res.Df    RSS Df Sum of Sq      F   Pr(>F)    
# 1    297 168020                                 
# 2    296 154216  1     13805 26.497 4.82e-07 ***

#multiple comparisons via Tukey HSD (honest signficant differences)
#Note: Need to specify an anova model for tukey's test to work in R

#convert molecular subtype to a factor and recode the levels
df_cancer$clin_sub2<-factor(df_cancer$clin_sub,
                                levels=c(1,2),
                                labels=c('HR+','HR-'))

df_cancer$treatment2<-factor(df_cancer$treatment,
                             levels=c(0,1),
                             label=c('hormone','chemo'))

lm_bi_aov<-aov(response~clin_sub2*treatment2,data=df_cancer) 
TukeyHSD(lm_bi_aov)

#--------------------------------------
# b), Part ii)
# NOTE: Unbalanced design, use Type 3
#--------------------------------------

#get R^2 from previous model in part i)
summary(lm_bi_full)$r.squared
#[1] 0.1699612

#get R^2 from model using molecular subtype
lm_bii_full<-lm(response~factor(molecular_sub)*treatment,data=df_cancer)
summary(lm_bii_full)$r.squared
#[1] 0.5752786

#compare the two non-nested models
AIC(lm_bi_full,lm_bii_full)
#            df      AIC
#lm_bi_full   5 2734.061
#lm_bii_full  9 2541.049
#
