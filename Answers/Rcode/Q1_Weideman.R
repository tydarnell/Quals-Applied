#####################################
# Q1: MS Exam Applied 2017
# Student: Ann Marie Weideman
# Date: 6/9/19
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

#------------------------------------
# Part e)
#------------------------------------

#dichotomize data to define preterm birth
df_perio_preterm<-df_perio[which(df_perio$GA_ultra<37),]

#test for trend
prop.test(as.numeric(table(df_perio_preterm$ppnum)),as.numeric(table(df_perio$ppnum)))

#------------------------------------
# Part f)
#------------------------------------

#create identifier for preterm birth (should have done this earlier, idiot)
df_perio$preterm<-ifelse(df_perio$GA_ultra<37,"preterm","fullterm")

#contingency table
tbl<-table(df_perio$group,df_perio$preterm)

#chi-squared test
chisq.test(tbl)
#X-squared = 0.42615, df = 1, p-value = 0.5139

#------------------------------------
# Part g)
#------------------------------------

df_perio_1<-df_perio[which(df_perio$group==1),]

t.test(df_perio_1$PD_post,df_perio_1$PD_pre,paired=T)
# Paired t-test
# 
# data:  df_perio_1$PD_post and df_perio_1$PD_pre
# t = -0.089735, df = 175, p-value = 0.9286
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.07765725  0.07090259
# sample estimates:
#   mean of the differences 
# -0.00337733 

#by hand
xbar_diff<-mean(na.exclude(df_perio_1$PD_post-df_perio_1$PD_pre))
#[1] -0.00337733
sd_diff<-sd(na.exclude(df_perio_1$PD_post-df_perio_1$PD_pre))
#[1] 0.4993049

#------------------------------------
# Part h)
#------------------------------------

df_perio_prenatal<-df_perio[which(df_perio$group==1),]
df_perio_postpartum<-df_perio[which(df_perio$group==2),]
diff1<-na.exclude(df_perio_prenatal$PD_post-df_perio_prenatal$PD_pre)
diff2<-na.exclude(df_perio_postpartum$PD_post-df_perio_postpartum$PD_pre)
t.test(diff1,diff2,paired=F)
# Welch Two Sample t-test
# data:  diff1 and diff2
# t = -3.6257, df = 345.94, p-value = 0.0003314
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.27209443 -0.08070992
# sample estimates:
#   mean of x   mean of y 
# -0.00337733  0.17302484 

#by hand
t=(mean(diff1)-mean(diff2))/sqrt(var(diff1)/length(diff1)+var(diff2)/length(diff2))
#[1] -3.625745