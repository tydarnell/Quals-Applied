#####################################
# Q1: MS Exam Applied 2017
# Student: Ann Marie Weideman
# Date: 6/9/19
# Updated: 7/22/19
#####################################

#import data
df_perio<-read.table(file="C:\\Users\\anndo\\Documents\\MS_qual_practice\\2017\\application\\data\\motor.txt",header=T)

#view data to check if import successful
#View(df_perio)

#------------------------------------
# Prelim: Check data for errors
#------------------------------------

#convert '.' to NA
df_perio$PD_post<-as.numeric(as.character(df_perio$PD_post))

summary(df_perio)

#convert kg to lb for better understanding
summary(df_perio$bweight*2.2/1000)

#Variable check
#ID - good
#Group - good
#GA_ultra - data error GA=73, not possible gestation
#GA_est - good
#bweight - very low weight at 1.276 lb, but 
#possible due to prematurity, so leave
#sex - good
#ppnum -good
#PD_pre - good
#PD_post - good

#decision to set value with GA_ultra=73 to missing
ind<- which(df_perio$GA_ultra==73)
df_perio$GA_ultra[ind]<-NA

summary(df_perio)

#------------------------------------
# Part a)
#------------------------------------

#mean number of pregnancies per woman rounded to 2 dec. places
mean_preg<-round(mean(df_perio$ppnum),2)

#------------------------------------
# Part b)
#------------------------------------

#probability 
expected<-(1-ppois(3,1.5))*nrow(df_perio)
#[1] 29.73603 -> 30 women

which(df_perio$ppnum>=4)
#integer(0)
#thus, p_hat2=0

#------------------------------------
# Part c)
#------------------------------------

#Shapiro-Wilk test for normality
shapiro.test(df_perio$GA_ultra)
#Shapiro-Wilk normality test
#data:  df_perio$GA_ultra
#W = 0.74326, p-value < 2.2e-16

#q-q plot
qqnorm(df_perio$GA_ultra)

#------------------------------------
# Part d)
#------------------------------------

#Classify both versions of gestational age into 3 intervals, 
#(0,37), [37,40), and [40,inf)
cut.points<-c(0,37,40,'inf')
GA_est_factor<-cut(df_perio$GA_est,cut.points,right=F)
GA_ult_factor<-cut(df_perio$GA_ultra,cut.points,right=F)

#Cohen's Kappa test for agreement
require(fmsb)
Kappa.test(GA_est_factor,GA_ult_factor)
# data:  GA_est_factor and GA_ult_factor
# Z = 16.66, p-value < 2.2e-16
# 95 percent confidence interval:
#   0.6276458 0.7519282
# sample estimates:
#   [1] 0.689787

#------------------------------------
# Part e)
#------------------------------------
#dichotomize data to define preterm birth
df_perio_preterm<-df_perio[which(df_perio$GA_ultra<37),]

#preterm counts for each pregnancy category (0,1,2, or 3)
freq_pre0<-nrow(df_perio_preterm[which(df_perio_preterm$ppnum==0),])
freq_pre1<-nrow(df_perio_preterm[which(df_perio_preterm$ppnum==1),])
freq_pre2<-nrow(df_perio_preterm[which(df_perio_preterm$ppnum==2),])
freq_pre3<-nrow(df_perio_preterm[which(df_perio_preterm$ppnum==3),])

#total counts in each prengancy category
freq0<-nrow(df_perio[which(df_perio$ppnum==0),])
freq1<-nrow(df_perio[which(df_perio$ppnum==1),])
freq2<-nrow(df_perio[which(df_perio$ppnum==2),])
freq3<-nrow(df_perio[which(df_perio$ppnum==3),])

#test for trend
prop.trend.test(c(freq_pre0,freq_pre1,freq_pre2,freq_pre3),c(freq0,freq1,freq2,freq3))
#Chi-squared Test for Trend in Proportions
#
#data:  c(freq_pre0, freq_pre1, freq_pre2, freq_pre3) out of c(freq0, freq1, freq2, freq3) ,
#using scores: 1 2 3 4
#X-squared = 5.8412e-05, df = 1, p-value = 0.9939

#------------------------------------
# Part f)
#------------------------------------

#create identifier for preterm birth (should have done this earlier, idiot)
df_perio$preterm<-ifelse(df_perio$GA_ultra<37,"preterm","fullterm")

#contingency table
tbl_f<-table(df_perio$group,df_perio$preterm)

#chi-squared test
chisq.test(tbl_f)
#X-squared = 0.42615, df = 1, p-value = 0.5139

#------------------------------------
# Part g)
#------------------------------------

df_perio_1<-df_perio[which(df_perio$group==1),]

#by hand
xbar_diff<-mean(na.exclude(df_perio_1$PD_pre-df_perio_1$PD_post))
#[1] 0.00337733
sd_diff<-sd(na.exclude(df_perio_1$PD_pre-df_perio_1$PD_post))
#[1] 0.4993049

t.test(df_perio_1$PD_pre,df_perio_1$PD_post,paired=T)
#Paired t-test
#
#data:  df_perio_1$PD_pre and df_perio_1$PD_post
#t = 0.089735, df = 175, p-value = 0.9286
#alternative hypothesis: true difference in means is not equal to 0
#95 percent confidence interval:
#  -0.07090259  0.07765725
#sample estimates:
#  mean of the differences 
#0.00337733 

#------------------------------------
# Part h)
#------------------------------------

df_perio_prenatal<-df_perio[which(df_perio$group==1),]
df_perio_postpartum<-df_perio[which(df_perio$group==2),]
diff1<-na.exclude(df_perio_prenatal$PD_pre-df_perio_prenatal$PD_post)
diff2<-na.exclude(df_perio_postpartum$PD_pre-df_perio_postpartum$PD_post)
t.test(diff1,diff2,paired=F)
#Welch Two Sample t-test
#
#data:  diff1 and diff2
#t = 3.6257, df = 345.94, p-value = 0.0003314
#alternative hypothesis: true difference in means is not equal to 0
#95 percent confidence interval:
#  0.08070992 0.27209443
#sample estimates:
#  mean of x   mean of y 
#0.00337733 -0.17302484

#by hand
t=(mean(diff1)-mean(diff2))/sqrt(var(diff1)/length(diff1)+var(diff2)/length(diff2))
#[1] 3.625745