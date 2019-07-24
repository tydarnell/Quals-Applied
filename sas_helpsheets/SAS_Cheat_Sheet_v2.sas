/* SAS Cheat Sheet for Quals #2
Code: SAS_Cheat_Sheet_v2.SAS
--> Codes/Notes from Regression and ANOVA by Muller and Fetterman

*/

/*********************************************
Chapter 2: Statement of the Model, Estimation, and Testing

Notes:
----------
-> Y_{Nx1}=X_{Nxq}\beta_{qx1}+e_{Nx1} 
		X first column 1 obvi for intercept
		\beta parameters are fixed unknown contstants
-> Assumptions HILE, Gaussian Errors Assumption Example 2.2 pg 14
-> Reg code has identical results as proc iml, iml is long way

Key Words:
----------
Generalized Linear Models (GLM)
RSS/SSE, SSH distribution
Contrasts Intro
Estimability
Distributions under the Null/Alt

*********************************************/

*proc reg;
proc reg data=libref.FILEF;
model fev1=height weight age /p; *p option prints predicted values and residuals;
run;

*proc iml;

proc iml;
use libref.filef;
read all var "fev1" into y; *creates the response matrix;
read all var {height weight age } into X; *creat a predictor matrix;
N=nrow(X); *create a X matrix (no intercept);
one=j(N,1,1);
X=one || x; *concat one vector with base X;
bhat=inv(X`*X)*X`*y; *\hat{\beta}=(X'X)^{-1}X'y;
yhat=X*bhat; *Y=X\beta-> \hat{y}=X\hat{\beta}=X*inv(X'*X)*X'*y; 
ehat=y-yhat;
q=ncol(x);
df=N-q;
sse=y`*y-bhat`*X`*y;
mse=sse/df;
quit;
run;



*testing height weight and age as predictors have equal sloopes. 
H_0: [\beta_1-\beta_2 \beta_1-\beta_3]'=0 
-> C=[0 1 -1 0] 
     [0 1 0 -1];


*proc iml;
proc iml;
*add proc iml code from above;
C={0 1 -1 0, 0 1 0 -1};
M=C*inv(X`*X)*C`;
thetahat=C*bhat;
ssh=thetahat`*inv(M)*thetahat;
f_obs=(ssh/nrow(thetahat))/mse;
p=1-probf(f_obs,2,67);
run;



*proc reg;

proc reg data=libref.FILEF;
model fev1=height weight age;
test height-weight=0, height-age=0;
run;

/*********************************************
Chapter 3: Some Distributions for the GLM

Notes:
----------
-> multivariate gaussian, scaled chi-square and F
-> chapter assumes all assumptions hold
-> estimated covariances 
-> contrasts
-> jackknifing residuals 'most valuable tool in evaluating the validity of GLM assumptions'

Key Words:
----------
Generalized Linear Models
multivariate normal
estimated covariance matrix (\beta,\theta,y,\epsilon)
conditional mean of predicted values
jackknifing
*********************************************/

*proc iml;
*estimated covariance matrix of \hat{\beta} and \hat{\theta};

proc iml;
use libref.FILFEF;
read all var "fev1" into y; *create response matrix;
read all var {height weight age} into X; *predicitor matrix with predictors;
N=nrow(X); *adding the intercept column onto X;
one=j(N,1,1);
X=one ||X;
print y X;

*calculate the parameter;
q=ncol(X);
XpXinv=inv(X`*X);
betahat=XpXinv*X`*y;
yhat=X*betahat;
ehat=y-yhat;
sse=ehat`*ehat;
mse=sse/(N-q);

*calculate covariance matrix of \hat{\beta};
covbhat=XpXinv # mse; *# is element wise multiplication;

*estimated covariance matrix of \hat{\theta};
C={0 1 -1 0, 0 1 0 -1};
covthat=mse*C*inv(X`*X) * C`;

*estimated covariance matrix of \hat{y};
H=X*XpXinv*X`; *calculate H matrix;
covyhat=mse # H; *element wise multi of mse and H matrix;
covyhat5= covyhat[1:5,1:5]; *subset of the first five row and columns

*estimated covariance matrix of \hat{e}, residuals;
covehat=mse # (I(N)-H);

*calculating standardized residuals;
h_i=vecdiag(H);
r_i=ehat/(sqrt(mse#(1-h_i))); 

*calculating studentized residuals;
r_i2=r_i # r_i;
r_mi=r_i # sqrt((N-q-1)/(N-q-r_i2));

quit;
run;

*proc reg--alternative;
proc reg data=libref.FILEF;
model fev1=height weight age/r; */r is the option needed to calculate the residual;
run;



/*********************************************
Chapter 4: Multiple Regression: General Considerations

Notes:
----------
-> continuous interval scale response with linear combinations of one or more continuous interval scale predictors
-> models with an intercept allow for corrected SS to be calculated
-> corrected SS do not vary wrt location shift of response or predictors (proof/code not included but example on page 52)
-> intercept only model--model predicts the same value for all subjects--reduces to a horizontal line (slope 0 and intercept \mu_y)
-> null model--predicts the same value for all subjects (slope 0, intercept 0)
-> MultReg one or more continuous predictors usually assume X is full rank (rank(X)==q)
-> ANOVA goal: to determine if the predictors reduce the variability of the model
-> option ADJRSQ proc reg to bias corrected value

Key Words:
----------
basic sums of squares (corrected sums of squares, uncorrected sums of squares)
ANOVA pg 56 
Intercept only model (grand mean model) pg 53
Null model pg 55
uncorrected / Corrected Overall test
Usual corrected and uncorrected R^2

*********************************************/


*proc iml;
*calculating the uncorrected sums of squares;
proc iml;
use libref.FILEF;
read all var "fev1" into y; *response matrix;
read all var {height weight age} into X; * predictor matrix without intercept column;

*add column for intercept;
N=nrow(X);
one = j(N,1,1); 
X=one || X; *cbind to create full predictor matrix;

*calculate the parameter estimates;
q=ncol(X);
XpXinv=inv(X`*X);*end the color';
H=X*XpXinv*X`;
betahat=XpXinv*X`*y;
yhat=X*betahat;
ehat=y-yhat;

*uncorrected SS and SSE;
uss_t=y`*y;
uss_m=y`*H*y;
sse_u=uss_t - uss_m;

*calculating corrected sums of squares;
css_t=y`*(I(N)-(one*one`)/N)*y;
css_m=y`*(H-(one*one`)/N)*y;
sse_c=css_t-css_m;
quit;

 
*proc glm: calculating uncorrected SS;
*note: not interchangeable with proc reg;
proc glm data=libref.FILEF;
model fev1=height weight age/int;
run;

*proc glm:calculating corrected sums of squares;
*note: is interchangable with proc reg;
proc glm data=libref.FILEF;
model fev1=height weight age;
run;

*proc reg: null  model for corrected overall test for regression;
* use null model below and calculate 
Fobs=\frac{\frac{SSE_{red}-SSE_{full}}{df_{red}-df_{full}}}{SSE_{full}/df_{full}} 
which rejection region is >= F^{-1}_F(1-\alpha, q-1,N-q)=f_{crit};
*note: interchangable with proc glm;
proc reg data=libref=FILEF;
model fev1=;
run;


/*********************************************
Chapter 5: Testing Hypotheses in Multiple Regression

Notes:
----------
-> Overall tests measure the contribution of the entire set of predictors
-> addition of one variable measure the contribution of a single predictor
-> intercept tests indicate the value of a column of 1's in predicting the response
-> addition of a group of variables measure ....
-> General Linear Hypothesis (GLH) otherwise pg 69,91/2


Key Words:
----------
added last test pg 70,78,83,86
add in order test pg 71,80,84
corrected overall test pg 73 
uncorrected overall test pg 75--rarely appropriate

*********************************************/

*added last test;
*example: FILEF data  model is FEV1_i=\beta_0 + \beta_1*height_i + \beta_2*weight_i + \beta_3*age_i + e_i;
proc reg data=libref.FILEF;
m_0: model fev1=height weight age /noint;
m_1: model fev1=weight age;
m_2: model fev1=height age;
full: model fev1=height weight age;
run;

*add in order test;
proc reg data = libref.FILEF;
null: model fev1 = /noint;
m0: model fev1 = ;
m1: model fev1 = height;
m2: model fev1 = height weight;
full: model fev1 = height weight age;
run;

*group added last test;
*example: pg 88, H_0: \beta_1=\beta_2=0;
proc glm data=libref.FILEF;
model fev1=age;
run;

proc reg data=libref.FILEF;
full: model fev1= height weight age;
group_added_last: test height=0, weight=0;
run;

proc glm data=libref.FILEF;
model fev1=height weight age;
contrast 'group added-last' 
	height 1, weight 1;
*contrast 'group added -last' intercept 0 height 1 weight 0 age 0,
							  intercept 0 height 0 weight 1 age 0;
run;

*group add in order;
*example: pg 90,  H_0: \beta_1=\beta_2=0;
proc glm data=libref.FILEF;
model fev1=height weight;
run;

proc reg data=libref.FILEF;
m2: model fev1=height weight;
group_added_in_order: test height=0, weight=0;
run;

proc glm data=libref.FILEF;
model fev1 = height weight;
contrast 'group added in order' height 1, weight 1;
run;


/*********************************************
Chapter 6: Correlations

Notes:
----------

Key Words:
----------
corrected \rho^2
uncorrected \rho^2
correlation formulas
sample correlation
partial correlation
*********************************************/

*uncorrected sums of squares;
*way 1: still need to calculate after output;
proc glm data=libref.FILEF;
model fev1=height weight age /int; *need int option;
run;

*way 2: uncorrected calculated in SAS;
data one;
set libref.FILEF;
intercept=1;
run;

proc glm data=one;
model fev1=intercept height weight age /noint;
run;

*sample correlation matrix;
proc corr data=libref.FILEF nosimple noprob; *restrict output to only the correlation matrix;
var fev1 height weight age;
run;

*full partial correlation;
*example: calculating the full correlation between fev1 and height controlling for age;
*r[(y,x_1)|x_3]=r[(FEV1,HEIGHT)|AGE]=r[(y|x_1),(x_3|x_1)]=r[(fev1|height),(age|height)];

*way 1;
proc corr data=libref.FILEF nosimple /*noprob*/;
var fev1 height;
partial age;
run;

*way 2;
proc reg data=libref.FILEF;
model fev1=age height/pcorr1 pcorr2; *important that height leads last;
run;

*way 3;
proc glm data=libref.FILEF noprint;
model fev1 height =age;
manova/printe;
run;

*way 4;
proc glm data=libref.FILEF noprint; *finding residuals \hat{e_{fev1}};
model fev1=age;
output out=one r = e_fev1;
run;

proc glm data=libref.FILEF noprint; *finding residuals \hat{e_{height}};
model height=age;
output out=two r=e_ht;
run;

proc sort data=one;
by subject;
run;

proc sort data=two;
by subject;
run;

data three;
merge one two;
by subject;
run;

proc corr noprob nosimple data=three;
var e_fev1 e_ht;
run;

*semipartial correlation;
*example: calculating the semipartial correlation between fev1 and height controlling for height and weight;
*way1;
proc reg data=libref.FILEF;
model fev1=weight height/scorr1 scorr2;
run;

*way2;
proc glm data=libref.FILEF noprint;
model height=weight;
output out=four residual=e_ht;
run;

proc corr data=four nosimple noprob;
var fev1 e_ht;
run;


*multiple partial correlations;
*way 1:r[(y,x1)|{x1,x3}];
proc corr data=libref.FILEF nosimple /*noprob*/;
var fev1 height;
partial weight age;
run;

*way2: r(e_{iy},e_{ix_1});
proc glm data=libref.FILEF;
model fev1 height = weight age;
manova /printe;
run;

*multiple semipartial correlation;
*way 1: r[y,x_1|{x_1,x_3}];
proc glm data=libref.FILEF noprint;
model height =weight age;
output out=e residual=e_ht;
run;

proc corr data=e nosimple noprob;
var fev1 e_ht;
run;


/*********************************************
Chapter 7: GLM Assumption Diagnostics

Notes:
----------
-> diagnostics in terms of multiple regression
-> Level 0 : sampling units-- plausible ranges
   Level 1 : display first 5 obs, check missing/unusual values
   Level 2 : mean, sd, percentiles, histograms, boxplots, evaluate normality
   Level 3 : basic correlations between response and predictors
-> residual analysis-- testing HILE Gau assumptions of e corresponding to Y|X

Key Words:
----------
"getting to know your data"
residual analysis
outliers
*********************************************/

*evaluating heterogeneity and linearity;
*plotting r_{-1} vs. {\hat{y_i}}, R/P plot;
*examples of incorrect models/plots pg 139;

proc glm data =fileref.FILEF noprint;
model fev1= height weight age;
output out=one predicted =y_hat rstudent=r_i;
run;

proc plot data=one;
plot r_i*y_hat/vref=0;
run;


proc reg data=fileref.FILEF;
model fev1 = height weight age;
paint rstudent. <-3.52 or rstudent. > 3.52 / symbol='*';
plot rstudent.*predicted.;
run;


*evaluating gaussian distribution and extreme residuals;
*wording on how to analyze and report results on page 144;
proc univariate data=one plot normal;
var r_i;
run;


*outlier analysis;
*leverage pg 147;
*interpretation depends on the nature of the predictors;


proc glm data =fileref.FILEF noprint;
model fev1= height weight age;
output out=one predicted =y_hat rstudent=r_i h=leverage;
run;

proc sort data=one;
by descending leverage;
run;

data two;
set one (obs=5);
q=4; *data specific;
N=71; *data specific;
F=((leverage -(1/N)/(q-1))) / (1-leverage)/(N-q));
pvalue=1-probf(F,q-1,N-q); *important to state distribution in write up;
if pvalue <= 0.05 / N then Bonf='*';
					else Bonf=" " ; *bonferoni correction--creates flag;
label Bonf="Signif at 0.05/N?";
run;

proc print- data=two uniform label noobs;
var subject height weight age leverage F pvalue Bonf;
format age 5.1 leverage 5.2 F 5.1 pvalue 8.6;
run;


*Mahalanobis Distance;
*deviance of a particular observations predictor from the center of the predictor space;

proc iml;
use fileref.FILEF;
read all var "fev1" into y;*create a response matrix;
read all var {height weight age} into X; *predictor matrix minus the 1 vector;

*calculating Mahalanobis Distance using X excluding intercept;
N=nrow(X);
one=j(N,1,1);
x_bar=X`*one/N;
C=(X`*X)/N - (x_bar*x_bar`);
sigmahat= C#N/(N-1);
M=j(N,1,0);
do i =1 to N;
	M[i]=((X[i,])`-x_bar)` *inv(Sigmahat)* ((X[i,]`-x_bar);
	end;
read all var "subject" into subject;
 create three {subject m};
 append;

*equivalence of leverages and mahalanobis distance;
 h_test=1/N + 1/(N-1)*M;
 compare= h || h_test;
 names = {`* h from H matrix *`, `*h calculated from M *`};
 print compare [colname=names];

 quit;
 run;


 proc univariate plot data=three;
 id subject;
 var m;
 run;

*cooks statistic;
*measures the influence of a single observation, the standardized shift in predicted values;
 *mulitplying the cooks d by (N-q) and comparing to critical values of table B9 in book;
proc glm data =fileref.FILEF noprint;
model fev1= height weight age;
output out=one predicted =y_hat rstudent=r_i h=leverage cookd=Cooks_D;
run;


/*********************************************
Chapter 8: GLM Computation Diagnostics
Notes:
----------
-> reducing locatio and scale disparities  
-> conditional number >30 implies large colinearity

Key Words:
----------
collinearity
SSCP
PCA

*********************************************/


*calculating the sscp matrix (Sums of Squares and cross products;
data one;
set libref.FILEF;
intercept=1;
run;
proc corr data=one sscp nosimple nocorr noprob;
var intercept height weight age;
run;

*covariance / correlation  matrix;
proc corr data=libref.FILEF cov nosimple noprob;
var height weight age;
run;


*centering variables;
proc standard data=libref.FILEF (keep=subject height weight age fev1)
	out=three (rename=(height=ht=_cs weight=wt_cs age=age_cs fev1=fev1_cs))
	m=0 std=1 vardef=n;
	var fev1 height weight age;
run;

*eigenanalysis of correlation matrix for X;
proc princomp data=fileref.FILEF; 
var height weight age;
run;

*average SSCP;
proc princomp data=one noint cov vardef=n;
var intercept height weight age;
run;

*scaled SSCP;
proc princomp data=one noint;
var intercept height weight age;
run;

*covariance matrix-- cov option;
proc princomp data=one cov vardef=n;
var height weight age;
run;

*tolerance and VIF;
proc reg data=fileref.FILEF;
model fev1=height weight age/tol vif;
run;


/*********************************************
Chapter 9: Polynomial Regression

Notes:
----------
-> LOF test compares a polynomial degree d-1 to the full model

Key Words:
----------
orthogonal polynomials
lack of fit tests

*********************************************/

*natural cubic polynomials with centered predictors;
proc standard data=libref.FILEF
			   out=two(rename=(height=ht_c weight=weight_c)
			   m=0;
var height weight;
run;

data three;
wt_c2=wt_c**2;
wt_c3=wt_c**3;
run;

proc reg data=three;
model fev1=ht_c wt_c wt_c2 wt_c3 / tol vif ss1 pcorr1;
run;

*fitting orthogonal polynomials;
proc iml;
use libref.FILEF;
read all var "weight" into weight;
read all var "subject" into subject;
poly=orpol(weight,3);
lqc=subject||poly[,2:4];
create four var {subject wt_orp1 wt_orp2 wt_orp3};
append from lqc;
close four;
quit;
run;

proc sort data=four;
by subject;
run;

proc sort data=two;
by subject;
run;

data five;
merge two four;
by subject;
run;

proc reg data=five;
model fev1=ht_c wt_orp1 wt_orp2 wt_orp3 / tol vif ss1 pcorr1;
run;


/*********************************************
Chapter 10: Transformations

Notes:
----------

Key Words:
----------

*********************************************/


*transformation of the response;
data one;
set libref.filee;
ppm_tol2=ppm_tolu**2;
ppm_tol3=ppm_tolu**3;
run;

*fit initial model and check the R/P plot;
proc reg data=one lineprinter;
model braintol = ppm_tolu ppm_tol2 ppm_tol3;
plot rstudent.*predicted.; *R/P plot: fan shape -> violation of homogeneity;
run;

data two;
set one;
br_ln=log(braintol);
br_sqrt=1/sqrt(braintol);
br_recip=1/braintol;
br_3_2=1/(sqrt(braintol**3));
run;

proc reg data=three lineprinter;
model br_ln br_sqrt br_recip br_3_2=ppm_tolu ppm_tol2 ppm_tol3; *r/p plots for each one of the transformations;
plot rstudent.*predicted.; *avoid fan shape;
quit;
run;

/*********************************************
Chapter 11: Selecting the Best Model

Notes:
----------
-> steps mentioned: (1) Specify the max model (2) specify the criterion (3) specify a strategy
(4) conduct the analysis (5) evaluate reproducibility
-> adding variables NEVER increases sse(p) or R_p^2, ALWAYS increases F_p.
-> deleting variables tends to yield C_p > p+1
-> describing model pools can be helpful to do plots of q vs. {C_p, R^2, \frac{C_p}{p+1}}
-> among a set of models all of size p, the smallest C_p and largest R^2_p is best

Key Words:
----------
C_p mallows criteria
nested models comparison
backwards elimination pg 230,240
forward selection pg 230
stepwise selection pg 231
groupwise selection pg232

*********************************************/
*check for extreme values;
proc univariate plot data=libref.FILE0;
id subject;
var infpat1-inpat4 redpat1-redpat4 valhyp1-valhyp4 invhyp1-invhyp4 time1-time4 satm satv male;
run;

*subject 35;
proc print data=libref.FILE0;
where subject=35;
run;

*backwards elimination by group;
proc reg data=libref.FILE0;
model sat = 
{male} 
{ipat_tot rpat_tot vhyp_tot ihyp_tot} 
{trialimp rpat_imp ihyp_imp} 
{time_imp} 
{sumtime} / selection=backwards sls=0.00000000000001 details 
groupnames= 'male' 'performance' 'trialsImp' 'TimeIMP' 'Time';
run;

*backawards elimination single;
proc reg data=libref.FILE0;
model sat=ipat_tot rpat_tot vhyp_tot ihyp_tot / selection=backward sls=0.00000001 details;
quit;
run;

*regression diagnostics;
proc reg data=libref.FILE0 outest=parms1;
model sat=ipat_tot rpat_tot vhyp_tot ihyp_tot / collinoint tol vif;
output out=expresid p=yhat rstudent=jack_res cookd=cooks_d h=leverage;
plot rstudent.*predicted.;
run;

proc univariate data=expresid plot;
id subject;
var jack_res cooks_d leverage;
run;

*check influence of a potential outlier;
*for example, say subject 96 then do;

proc reg data=libref.FILE0;
model sat = ipat_tot rpat_tot ihyp_tot;
where subject ne 96;
run;


/*********************************************
Chapter 12: Coding Schemes for Regression

Notes:
----------
-> GLM with categorical predictors (mostly ANOVA "depends on author def")

Key Words:
----------
Reference Cell Coding
Cell Mean Coding
Classic ANOVA Coding
Effect Coding
Polynomial Coding 
Essence Matrix
*********************************************/

*reference cell coding design matrix;
*trivial example 3 doses so obvi 3-1 groups;

data one;
set libref.FILEJ;
one=1;
if dosage=3 then x_3=1; else x_3=0;
if dosage=6 then x_6=1; else x_6=0;
run;


*cell mean coding design matrix;
*G groups -> G indicator vars....no intercept;
*again..trivia but;
data two;
set libref.FILEJ;
if doseage=0 then x_1=1; else x_1=0;
if doseage=3 then x_3=1; else x_3=0;
if doseage=6 then x_6=1; else x_6=0;
run;


*classic anova coding design matrix;
*less than full rank, G indicator vars + intercept (1_vector);
*example is three dose treatment protocol--placebo (0), low dose (3) , high (6);

data three;
set libref.FILEJ;
one=1;
if doseage=0 then x_1=1; else x_1=0;
if doseage=3 then x_3=1; else x_3=0;
if doseage=6 then x_6=1; else x_6=0;
run;

*effect coding design matrix;
*full rank, column of 1's and G-1 variables for G groups;

data four;
set libref.FILEJ;
one=1;
x_3=0; if dosage=0 then x_3=-1; if dosage=3 then x_3=1;
x_6=0; if dosage=0 then x_6=-1; if dosage=6 then x_6=1;
run;

/*********************************************
Chapter 13: One Way ANOVA

Notes:
----------
-> gaussian parametric approach 
-> testing whether two or more group means are equal
-> HELPFUL TABLE PAGE 325
-> Assumptions HILE Gauss
-> Following H_0 are all equal for usual overall test:
   H_0: \mu_A = \mu_B = \mu_C (cell means)
   H_0: \delta_B = \delta_C=0 (reference cell)
   H_0: \zeta_B = \zeta_C=0 (effect)
-> trend tests
   example of orthogonal contrasts;
   equal spacing/cell size between variables otw does not make sense

Key Words:
----------
Usual Overall Test
Differences between cell means

*********************************************/

*usual overall test;
data one;
set libref.FILEJ;
one=1;
if dosage=3 then x_3=1; else x_3=0;
if dosage=6 then x_6=1; else x_6=0;
run;

*way 1: glm using reference cell coding;
proc glm data=one;
class dosage;
model lhour283=dosage /solution;
run;

*way 2: contrast using reference cell coding;
proc glm data=one;
model lhour283=one x_3 x_6 / noint;
contrast 'Usual Overall Test'
one 0 x_3 1 x_6 0,
pme 0 x_3 0 x_6 1;
run;

*way 3: glm using effect coding;
data two;
set libref.FILEJ;
one=1;
if dosage=0 then x_3eff=-1;
else if dosage=3 then x_3eff=1;
else x_3eff=0;

if dosage=0 then x_6eff =-1;
else if dosage=6 then x_6eff=1;
else x_6eff=0;
run;

proc glm data=two;
model lhour283=x_3eff x_6eff;
run;


*way 4: contrast using effect coding;
proc glm data=two;
model lhour283=one x_3eff x_6eff /noint;
contrast 'usual overall test'
one 0 x_3eff 1 x_6eff 0,
one 0 x_3eff 0 x_6eff 1;
run;

*way 5: glm using cell means coding contrast;
data three;
set libref.FILEJ;
if dosage=0 then x_0=1;else x_0=0;
if dosage=3 then x_3=1;else x_3=0;
if dosage=6 then x_6=1;else x_6=0;
run;

proc glm data=three;
model lhour283=x_0 x_3 x_6 /noint;
contrast 'usual overall test'
x_0 1 x_3 -1 x_6 0,
x_0 1 x_3  0 x_6 -1;
run;


*if overall hypo is rejected next step is to find which ne;
*G choose 2 possible (G(G-1)/2) pairwise comparisons;
*differences between cell means example coding: see above for OG coding;
*H_0: \mu_A=\mu_B ; 
*H_0: \mu_A=\mu_C ; 
*H_0: \mu_B=\mu_C ; 

*reference cell;
proc glm data=one;
model lhour283=one x_3 x_6 / noint;
contrast 'MuA-MuB' one 0 x_3 1  x_6  0;
contrast 'MuA-MuC' one 0 x_3 0  x_6  1;
contrast 'MuB-MuC' one 0 x_3 1  x_6 -1;
run;

*effect coding;
proc glm data=two;
model lhour283=one x_3eff x_6eff /noint;
contrast 'MuA-MuB' one 0 x_3eff 2  x_6eff  1;
contrast 'MuA-MuC' one 0 x_3eff 1  x_6eff  2;
contrast 'MuB-MuC' one 0 x_3eff 1  x_6eff -1;

run;


*cell means coding;
proc glm data=three;
model lhour283=x_0 x_3 x_6 /noint;
contrast 'MuA-MuB' x_0 1 x_3 -1 x_6  0;
contrast 'MuA-MuC' x_0 1 x_3 0  x_6 -1;
contrast 'MuB-MuC' x_0 0 x_3 1  x_6 -1;
run;

*multiple comparison testing;
*unadjusted, bonferroni, sidak-adjusted;
*see table 13.7.1 on page 332 for techniques when etc;
proc glm data=two;
class dosage;
model lhour283=dosage;
lsmeans dosage/pdiff adjust=bon; *planned comparisons;
lsmeans dosage/pdiff adjust=sidak; *unplanned;
run;

/*********************************************
Chapter 14: Complete, two-way factorial ANOVA

Notes:
----------
-> modeling a response variable as a function of two categorical predictors
-> if factor A has G_A groups, and factor B has G_B groups then two way factorial contains G_A*G_B cells
-> table 14.2.2 on page 341 is really helpful for marginal means vs overall etc
-> sme tests tests equality of cell means within a row or equality of cell means within a column
   evaluates one effect while holding the other constant

Key Words:
----------
contrast matrices for marginal means
balanced source table pg 349*****important 
unbalanced data
step down tests
missing data pg 380
simple main effects test (sme)
*********************************************/


*cell means coding;
*example is dose and male;
data cellmean;
set libref.filej;
*create indicators for combos;
x_m0=(male and dosage=0));
x_m3=(male and dosage=3));
x_m6=(male and dosage=6));
x_f0=(not male and dosage=0));
x_f3=(not male and dosage=3));
x_f6=(not male and dosage=6));
run;


proc glm data=cellmean;
model lhour283=x_m0 x_f0 x_m3 x_f3 x_m6 x_f6/noint solution;
*marginal and grand means;
estimate 'Grand Mean' 			 x_m0 1 x_f0 1 x_m3 1 x_f3 1 x_m6 1 x_f6 1 /divisor=6;
estimate 'Marginal Mean: Male' 	 x_m0 1 x_f0 0 x_m3 1 x_f3 0 x_m6 1 x_f6 0 /divisor=3;
estimate 'Marginal Mean: Female' x_m0 0 x_f0 1 x_m3 0 x_f3 1 x_m6 0 x_f6 1 /divisor=3;
estimate 'Marginal Mean: Dose 0' x_m0 1 x_f0 1 x_m3 0 x_f3 0 x_m6 0 x_f6 0 /divisor=2;
estimate 'Marginal Mean: Dose 3' x_m0 0 x_f0 0 x_m3 1 x_f3 1 x_m6 0 x_f6 0 /divisor=2;
estimate 'Marginal Mean: Dose 6' x_m0 0 x_f0 0 x_m3 0 x_f3 0 x_m6 1 x_f6 1 /divisor=2;
*tests of main effects and interactions;
contrast 'Main Effect Gender' x_m0 1 x_f0 -1 x_m3  1  x_f3 -1 x_m6  1 x_f6 -1 ; 
contrast 'Main Effect Dose  ' x_m0 1 x_f0  1 x_m3 -1  x_f3 -1 x_m6  0 x_f6  0 ,
							  x_m0 1 x_f0  1 x_m3  0  x_f3  0 x_m6 -1 x_f6 -1 ; 
contrast 'Interaction  G*D  ' x_m0 1 x_f0 -1 x_m3 -1  x_f3  1 x_m6  0 x_f6  0 ,
							  x_m0 1 x_f0 -1 x_m3  0  x_f3  0 x_m6 -1 x_f6  1 ;
*simple main effects test--note multiple comparison do bonferoni see pg 378;
contrast 'SME Gender at Dose 0' x_m0 1 x_f0 -1 x_m3  0  x_f3  0  x_m6  0 x_f6  0; 
contrast 'SME Gender at Dose 3' x_m0 0 x_f0  0 x_m3  1  x_f3 -1  x_m6  0 x_f6  0; 
contrast 'SME Gender at Dose 6' x_m0 0 x_f0  0 x_m3  0  x_f3  0  x_m6  1 x_f6 -1; 
contrast 'SME Dose at Males   ' x_m0 0 x_f0  0 x_m3 -1  x_f3  0  x_m6  0 x_f6  0,
								x_m0 0 x_f0  0 x_m3  0  x_f3  0  x_m6 -1 x_f6  0; 
contrast 'SME Dose at Females ' x_m0 0 x_f0  1 x_m3  0  x_f3 -1  x_m6  0 x_f6  0,
								x_m0 0 x_f0  1 x_m3  0  x_f3  0  x_m6  0 x_f6 -1; 
*step down tests for SME--final step to determine which means differ;
contrast 'Step down SME at Male: D0 vs D3' x_m0 1 x_f0 0 x_m3 -1  x_f3  0  x_m6  0 x_f6  0; 
contrast 'Step down SME at Male: D0 vs D6' x_m0 1 x_f0 0 x_m3  0  x_f3  0  x_m6 -1 x_f6  0; 
contrast 'Step down SME at Male: D3 vs D6' x_m0 0 x_f0 0 x_m3  1  x_f3  0  x_m6 -1 x_f6  0; 


run;



*reference cell coding--same example;

data refcell;
set libref.filej;
one=1;
a_f=(not male);
b_3=(dosage=3);
b_6=(dosage=6);
g_f3=a_f*b_3;
g_f6=a_f*b_6;
run;

proc glm data=refcell;
model lhour283= one a_f b_3 b_6 g_f3 g_b6/noint solution;
*marginal and grand means;
estimate 'Grand Mean' 			 one 6  a_f 3 b_3 2 b_6 2 g_f3 1 g_fb 1 /divisor=6;
estimate 'Marginal Mean: Male' 	 one 3  a_f 0 b_3 1 b_6 1 g_f3 0 g_fb 0 /divisor=3;
estimate 'Marginal Mean: Female' one 3  a_f 3 b_3 1 b_6 1 g_f3 1 g_fb 1 /divisor=3;
estimate 'Marginal Mean: Dose 0' one 2  a_f 1 b_3 0 b_6 0 g_f3 0 g_fb 0 /divisor=2;
estimate 'Marginal Mean: Dose 3' one 2  a_f 1 b_3 2 b_6 0 g_f3 1 g_fb 0 /divisor=2;
estimate 'Marginal Mean: Dose 6' one 2  a_f 1 b_3 0 b_6 2 g_f3 0 g_fb 1 /divisor=2;
*tests of main effects and interactions;
contrast 'Main Effect Gender' one 0  a_f 3 b_3 0 b_6 0 g_f3 1 g_fb 1; 
contrast 'Main Effect Dose  ' one 0  a_f 0 b_3 2 b_6 0 g_f3 1 g_fb 0,
							  one 0  a_f 0 b_3 0 b_6 2 g_f3 0 g_fb 1; 
contrast 'Interaction  G*D  ' one 0  a_f 0 b_3 0 b_6 0 g_f3 1 g_fb 0,
							  one 0  a_f 0 b_3 0 b_6 0 g_f3 0 g_fb 1;
run;

*effect coding--same example;

data effect;
set libref.FILEJ;
one=1;
if (not male) then z_f = 1; else z_f=-1;
if (dosage=0) then n_3 =-1; else n_3=(dosage=3);
if (dosage=0) then n_6 =-1; else n_6=(dosage=6);
t_f3=z_f*n_3;
t_f6=z_f*n_6;
run;

proc glm data=effect;
model lhour283=one z_f n_3 n_6 t_f3 t_f6 / noint solution;
*marginal and grand means;
estimate 'Grand Mean' 			 one 6 z_f  0 n_3  0 n_6  0 t_f3 0 t_f6 0 / divisor=6;
estimate 'Marginal Mean: Male' 	 one 3 z_f -3 n_3  0 n_6  0 t_f3 0 t_f6 0 / divisor=3;
estimate 'Marginal Mean: Female' one 3 z_f  3 n_3  0 n_6  0 t_f3 0 t_f6 0 / divisor=3;
estimate 'Marginal Mean: Dose 0' one 2 z_f  0 n_3 -2 n_6 -2 t_f3 0 t_f6 0 / divisor=2;
estimate 'Marginal Mean: Dose 3' one 2 z_f  0 n_3  2 n_6  0 t_f3 0 t_f6 0 / divisor=2;
estimate 'Marginal Mean: Dose 6' one 2 z_f  0 n_3  0 n_6  2 t_f3 0 t_f6 0 / divisor=2;
*tests of main effects and interactions;
*a test of gender the main effect of gender with dose and gender*dose;
contrast 'Main Effect Gender' one 0 z_f 6 n_3 0 n_6 0 t_f3 0 t_f6 0 ; 
*a test of dose the main effect of dose with gender and gender*dose;
contrast 'Main Effect Dose  ' one 0 z_f 0 n_3 4 n_6 2 t_f3 0 t_f6 0 , 
							  one 0 z_f 0 n_3 2 n_6 4 t_f3 0 t_f6 0 ; 
run;
 
/*********************************************
Chapter 15: Special Cases of Two-Way ANOVA and Random Effects Basics

Notes:
----------
-> example: siblings (each family is a block), pups in a litter (each litter is a block)

Key Words:
----------
Blocking Variables 
Blocking Designs
Random Block Designs
Random Effects Models
*********************************************/

*example dose and gender of rats: gender is fixed and dose is predetermined -fixed block design;

*fixed block reference cell coding;

data refcell;
set libref.filej;
a_f=(not male);
b_3=(dosage=3);
b_6=(dosage=6);
run;

proc glm data=refcell;
model lhour283=one a_f b_3 b_6/noint solution;
*estimates of grand and marginal means;
estimate 'Grand Mean	    ' one 6 a_f 3 b_3 2 b_6 2 / divisor=6;
estimate 'Marg Mean: Male   ' one 3 a_f 0 b_3 1 b_6 1 / divisor=3;
estimate 'Marg Mean: Female ' one 3 a_f 3 b_3 1 b_6 1 / divisor=3;
estimate 'Marg Mean: Dose 0 ' one 2 a_f 1 b_3 0 b_6 0 / divisor=2; 
estimate 'Marg Mean: Dose 3 ' one 2 a_f 1 b_3 2 b_6 0 / divisor=2; 
estimate 'Marg Mean: Dose 6 ' one 2 a_f 1 b_3 0 b_6 2 / divisor=2; 
*test of main effects;
contrast 'Main Effect Gender' one 0 a_f 1 b_3 0 b_6 0;
contrast 'Main Effect Dose  ' one 0 a_f 0 b_3 1 b_6 0,
							  one 0 a_f 0 b_3 0 b_6 1;
*step down tests of main effects;
contrast 'Step Down of Main Effect: D0 vs. D3' one 0 a_f 0 b_3 1 b_6  0 ;
contrast 'Step Down of Main Effect: D0 vs. D6' one 0 a_f 0 b_3 0 b_6  1 ;
contrast 'Step Down of Main Effect: D3 vs. D6' one 0 a_f 0 b_3 1 b_6 -1 ;

run;


*fixed block effect coding;

data effect;
set libref.filej;
one=1;
if (not male) then z_f=1; else z_f=-1;
if (dosage=0) then n_3=-1; else n_3=(dosage=3);
if (dosage=0) then n_6=-1; else n_6=(dosage=6);
run;

proc glm data=effect;
model lhour283=one z_f n_3 n_6/ noint solution;
*estimates of overall and marginal means;
estimate 'Overall Mean      '  one 6 z_f  0 n_3  0 n_6  0 / divisor=6;
estimate 'Marg Mean: Male   '  one 3 z_f -3 n_3  0 n_6  0 / divisor=3;
estimate 'Marg Mean: Female '  one 3 z_f  3 n_3  0 n_6  0 / divisor=3;
estimate 'Marg Mean: Dose 0 '  one 2 z_f  0 n_3 -2 n_6 -2 / divisor=2;
estimate 'Marg Mean: Dose 3 '  one 2 z_f  0 n_3  2 n_6  0 / divisor=2;
estimate 'Marg Mean: Dose 3 '  one 2 z_f  0 n_3  0 n_6  2 / divisor=2;
*test of main effect;
contrast 'Main Effect Gender'  one 0 z_f  1 n_3  0 n_6  0 ;
contrast 'Main Effect Dose  '  one 0 z_f  0 n_3  2 n_6  1 ,
							   one 0 z_f  0 n_3  1 n_6  2 ;
*step down tests of main effects;
contrast 'Step Down of Main Effect: D0 vs. D3' one 0 z_f  0 n_3  2 n_6  1 ;
contrast 'Step Down of Main Effect: D0 vs. D6' one 0 z_f  0 n_3  1 n_6  2 ;
contrast 'Step Down of Main Effect: D3 vs. D6' one 0 z_f  0 n_3  1 n_6 -1 ;


run;



/*********************************************
Chapter 16: The Full Model in Every Cell (ANCOVA as a Special Case)

Notes:
----------
-> focus of chapter is on 'creation, analysis, and interpretation of models with both continuous 
	and categorical predictors'
-> Lots of review of previous chapters and kind of redundant

Key Words:
----------

*********************************************/

*cell mean coding;
*continuous predictor ln_bldtl;

data cellmean;
set libref.FILEE;
*create nominal variable group; 
if      ppm_tolu=50   then group='a';
else if ppm_tolu=100  then group='b';
else if ppm_tolu=500  then group='c';
else if ppm_tolu=1000 then group='d';
one=1;
*create indicator variables; 
one_a=(group='a');
one_b=(group='b');
one_c=(group='c');
one_d=(group='d');
*ln_bldtl by group indicator for cell means;
xa=(group='a')*ln_bldtl;
xb=(group='b')*ln_bldtl;
xc=(group='c')*ln_bldtl;
xd=(group='d')*ln_bldtl;
run;

*given is that grand mean: \bar{x}=1.21;
proc glm data=cellmean;
*MODEL 1: FULL MODEL;
model ln_brntl = one_a one_b one_c one_d xa xb xc xd / noint solution; 

*MODEL 2: ANCOVA--four indicators for group and continuous predictor and continuous response;
model ln_brntl = one_a one_b one_c one_d ln_bldtl / noint solution;

*MODEL 3: Regression--continuous predictor and continuous response;
model ln_brntl = one ln_bldtl / noint solution;

*MODEL 4: ANOVA--four indicators for group and continuous response;
model ln_brntl = one_a one_b one_c one_d / noint solution;

*MODEL 5: Intercept only;
model ln_brntl = one /noint solution;

*estimating of means;
estimate 'Adj Cell Mean Group A '  one_a 1 one_b 0 one_c 0 one_d 0 xa 1.21 xb 0 xc 0 xd 0;
estimate 'Adj Cell Mean Group B '  one_a 0 one_b 1 one_c 0 one_d 0 xa 0 xb 1.21 xc 0 xd 0;
estimate 'Adj Cell Mean Group C '  one_a 0 one_b 0 one_c 1 one_d 0 xa 0 xb 0 xc 1.21 xd 0;
estimate 'Adj Cell Mean Group D '  one_a 0 one_b 0 one_c 0 one_d 1 xa 0 xb 0 xc 0 xd 1.21;

estimate 'Mean of Adj Cell Means'  one_a 1 one_b 1 one_c 1 one_d 1 xa 1.21 xb 1.21 xc 1.21 xd 1.21/ divisor=4;
estimate 'Mean Intercept        '  one_a 1 one_b 1 one_c 1 one_d 1 xa 0 xb 0 xc 0 xd 0 /divisor=4;
estimate 'Mean Slope            '  one_a 0 one_b 0 one_c 0 one_d 0 xa 1 xb 1 xc 1 xd 1 /divisor=4;

*testing strategy 1: adjusted ANOVA
H_0: \mu_{A|\bar{x}}=\mu_{B|\bar{x}}=\mu_{C|\bar{x}}=\mu_{D|\bar{x}};
contrast 'Equal Adj Cell Means'
		 one_a 1 one_b -1 one_c  0 one_d  0 xa 1.21 xb -1.21 xc 0     xd 0,
		 one_a 1 one_b  0 one_c -1 one_d  0 xa 1.21 xb 0     xc -1.21 xd 0,
		 one_a 1 one_b  0 one_c  0 one_d -1 xa 1.21 xb 0     xc 0     xd -1.21;
contrast 'Pairwise Adj Cell Means A vs B'
		 one_a 1 one_b -1 one_c  0 one_d 0  xa 1.21 xb -1.21 xc 0 xd 0;
contrast 'Pairwise Adj Cell Means A vs C'
		 one_a 1 one_b  0 one_c -1 one_d 0  xa 1.21 xb 0 xc -1.21 xd 0;
contrast 'Pairwise Adj Cell Means A vs D'
		 one_a 1 one_b  0 one_c  0 one_d -1 xa 1.21 xb 0 xc 0 xd -1.21;
contrast 'Pairwise Adj Cell Means B vs C'
		 one_a 0 one_b  1 one_c  -1 one_d 0 xa 0  xb 1.21 xc -1.21 xd 0;
contrast 'Pairwise Adj Cell Means B vs D'
		 one_a 0 one_b  1 one_c  0 one_d -1 xa 0  xb 1.21 xc 0 xd -1.21;
contrast 'Pairwise Adj Cell Means C vs D'
		 one_a 0 one_b  0 one_c 1 one_d -1 xa 0  xb 0 xc 1.21 xd -1.21;

*testing strategy 2: GLM testing
H_0: \beta_{0j}=\beta_{0j'} for all j ne j' AND \beta_{1j}=\beta_{1j'};
contrast 'Test of Coincidence'
	one_a 1 one_b -1 one_c  0 one_d  0 xa 0 xb  0 xc  0 xd  0,
	one_a 1 one_b  0 one_c -1 one_d  0 xa 0 xb  0 xc  0 xd  0,
	one_a 1 one_b  0 one_c  0 one_d -1 xa 0 xb  0 xc  0 xd  0,
	one_a 0 one_b  0 one_c  0 one_d  0 xa 1 xb -1 xc  0 xd  0,
	one_a 0 one_b  0 one_c  0 one_d  0 xa 1 xb  0 xc -1 xd  0,
	one_a 0 one_b  0 one_c  0 one_d  0 xa 1 xb  0 xc  0 xd -1;

*top half of Test of Coincidence contrast;
contrast 'Step-down: Equal Intercepts' 
	one_a 1 one_b -1 one_c  0 one_d  0 xa 0 xb  0 xc  0 xd  0,
	one_a 1 one_b  0 one_c -1 one_d  0 xa 0 xb  0 xc  0 xd  0,
	one_a 1 one_b  0 one_c  0 one_d -1 xa 0 xb  0 xc  0 xd  0;

*bottom half of Test of Coincidence contrast;
contrast 'Step-down: Equal Slope'
	one_a 0 one_b  0 one_c  0 one_d  0 xa 1 xb -1 xc  0 xd  0,
	one_a 0 one_b  0 one_c  0 one_d  0 xa 1 xb  0 xc -1 xd  0,
	one_a 0 one_b  0 one_c  0 one_d  0 xa 1 xb  0 xc  0 xd -1;

contrast 'Pair-wise Intercepts A vs. B'
one_a 1 one_b -1 one_c  0 one_d  0 xa 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts A vs. C'
one_a 1 one_b  0 one_c -1 one_d  0 xa 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts A vs. D'
one_a 1 one_b  0 one_c  0 one_d -1 xa 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts B vs. C'
one_a 0 one_b  1 one_c  -1 one_d 0 xa 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts B vs. D'
one_a 0 one_b  1 one_c  0 one_d -1 xa 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts C vs. D'
one_a 0 one_b  0 one_c  1 one_d -1 xa 0 xb  0 xc  0 xd  0;

*testing strategy 3: adjusted ANOVA;
*H_0: \beta_{0A}=\beta_{0B}=\beta_{0C}=\beta_{0D};

contrast 'Equal Intercepts (ANCOVA vs. Regression)'
	one_a 1 one_b  -1 one_c  0 one_d  0 ln_bldtl 0,
	one_a 1 one_b   0 one_c -1 one_d  0 ln_bldtl 0,
	one_a 1 one_b   0 one_c  0 one_d -1 ln_bldtl 0;

*difference of scores in ANCOVA model;
*'no difference in adjusted cell means' ;
*H_0: \mu_{A|\bar{X}}=\mu_{B|\bar{X}}=\mu_{C|\bar{X}}=\mu_{D|\bar{X}};
*equal to test of equal intercepts;

estimate 'Adj Cell Mean: Group A'
	one_a 1 one_b  0 one_c  0 one_d  0 ln_bldtl 1.21;
estimate 'Adj Cell Mean: Group B'
	one_a 0 one_b  1 one_c  0 one_d  0 ln_bldtl 1.21;
estimate 'Adj Cell Mean: Group C'
	one_a 0 one_b  0 one_c  1 one_d  0 ln_bldtl 1.21;
estimate 'Adj Cell Mean: Group D'
	one_a 0 one_b  0 one_c  0 one_d  1 ln_bldtl 1.21;

*comparison of full model to anvoa;
*H_0: \beta_{1A}=\beta_{1B}=\beta_{1C}=\beta_{1D}=0;
contrast 'All Slopes =0 (FULL vs. ANOVA)'
	one_a 0 one_b 0 one_c 0 one_d 0 xa 1 xb 0 xc 0 xd 0,
	one_a 0 one_b 0 one_c 0 one_d 0 xa 0 xb 1 xc 0 xd 0,
	one_a 0 one_b 0 one_c 0 one_d 0 xa 0 xb 0 xc 1 xd 0,
	one_a 0 one_b 0 one_c 0 one_d 0 xa 0 xb 0 xc 0 xd 1;
run;




*reference cell coding;
*same analysis as above just different coding style;
data refcell;
set libref.FILEE;
*group a is the reference cell;
*create nominal variable group; 
if      ppm_tolu=50   then group='a';
else if ppm_tolu=100  then group='b';
else if ppm_tolu=500  then group='c';
else if ppm_tolu=1000 then group='d';
one=1;
*create indicator variables; 
one_b=(group='b');
one_c=(group='c');
one_d=(group='d');
*ln_bldtl by group indicator for cell means;
xb=(group='b')*ln_bldtl;
xc=(group='c')*ln_bldtl;
xd=(group='d')*ln_bldtl;

proc glm data=refcell;
*MODEL 1: FULL MODEL;
model ln_brntl = one one_b one_c one_d ln_bldtl xb xc xd / noint solution; 

*MODEL 2: ANCOVA--four indicators for group and continuous predictor and continuous response;
model ln_brntl = one one_b one_c one_d ln_bldtl / noint solution;

*MODEL 3: Regression--continuous predictor and continuous response;
model ln_brntl = one ln_bldtl / noint solution;

*MODEL 4: ANOVA--four indicators for group and continuous response;
model ln_brntl = one one_b one_c one_d / noint solution;

*MODEL 5: Intercept only;
model ln_brntl = one /noint solution;

*estimating of means;
estimate 'Adj Cell Mean Group A '  one 1 one_b 0 one_c 0 one_d 0 ln_bldtl 1.21 xb 0    xc 0    xd 0;
estimate 'Adj Cell Mean Group B '  one 1 one_b 1 one_c 0 one_d 0 ln_bldtl 0    xb 1.21 xc 0    xd 0;
estimate 'Adj Cell Mean Group C '  one 1 one_b 0 one_c 1 one_d 0 ln_bldtl 0    xb 0    xc 1.21 xd 0;
estimate 'Adj Cell Mean Group D '  one 1 one_b 0 one_c 0 one_d 1 ln_bldtl 0    xb 0    xc 0    xd 1.21;

estimate 'Mean of Adj Cell Means'  one 4 one_b 1 one_c 1 one_d 1 ln_bldtl 4.84 xb 1.21 xc 1.21 xd 1.21/ divisor=4;
estimate 'Mean Intercept        '  one 4 one_b 1 one_c 1 one_d 1 ln_bldtl 0 xb 0 xc 0 xd 0 /divisor=4;
estimate 'Mean Slope            '  one 0 one_b 0 one_c 0 one_d 0 ln_bldtl 4 xb 1 xc 1 xd 1 /divisor=4;

*testing strategy 1: adjusted ANOVA
H_0: \mu_{A|\bar{x}}=\mu_{B|\bar{x}}=\mu_{C|\bar{x}}=\mu_{D|\bar{x}};
contrast 'Equal Adj Cell Means'
		 one 0 one_b  1 one_c  0 one_d  0 ln_bldtl 0 xb 1.21 xc 0     xd 0,
		 one 0 one_b  0 one_c  1 one_d  0 ln_bldtl 0 xb 0    xc 1.21  xd 0,
		 one 0 one_b  0 one_c  0 one_d  1 ln_bldtl 0 xb 0    xc 0     xd 1.21;
contrast 'Pairwise Adj Cell Means A vs B'
		 one 0 one_b  0 one_c  1 one_d  0 ln_bldtl 0 xb 1.21    xc 0  xd 0;
contrast 'Pairwise Adj Cell Means A vs C'
		 one 0 one_b  0 one_c  0 one_d  1 ln_bldtl 0 xb 0    xc 1.21  xd 0;
contrast 'Pairwise Adj Cell Means A vs D'
		 one 0 one_b  0 one_c  0 one_d  1 ln_bldtl 0 xb 0    xc 0     xd 1.21;
contrast 'Pairwise Adj Cell Means B vs C'
		 one 0 one_b  1 one_c -1 one_d 0  ln_bldtl 0 xb 1.21 xc -1.21 xd 0;
contrast 'Pairwise Adj Cell Means B vs D'
		 one 0 one_b  1 one_c  0 one_d -1 ln_bldtl 0 xb 1.21 xc 0     xd -1.21;
contrast 'Pairwise Adj Cell Means C vs D'
		 one 0 one_b  0 one_c  1 one_d -1 ln_bldtl 0 xb 0    xc 1.21  xd -1.21;

*testing strategy 2: GLM testing
H_0: \beta_{0j}=\beta_{0j'} for all j ne j' AND \beta_{1j}=\beta_{1j'};
contrast 'Test of Coincidence'
	one 0 one_b  1 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0,
	one 0 one_b  0 one_c  1 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0,
	one 0 one_b  0 one_c  0 one_d  1 ln_bldtl 0 xb  0 xc  0 xd  0,
	one 0 one_b  0 one_c  0 one_d  0 ln_bldtl 0 xb  1 xc  0 xd  0,
	one 0 one_b  0 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  1 xd  0,
	one 0 one_b  0 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  1;

*top half of Test of Coincidence contrast;
contrast 'Step-down: Equal Intercepts' 
	one 0 one_b  1 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0,
	one 0 one_b  0 one_c  1 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0,
	one 0 one_b  0 one_c  0 one_d  1 ln_bldtl 0 xb  0 xc  0 xd  0;

*bottom half of Test of Coincidence contrast;
contrast 'Step-down: Equal Slope'
	one 0 one_b  0 one_c  0 one_d  0 ln_bldtl 0 xb  1 xc  0 xd  0,
	one 0 one_b  0 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  1 xd  0,
	one 0 one_b  0 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  1;

contrast 'Pair-wise Intercepts A vs. B'
one 0 one_b  1 one_c  0 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts A vs. C'
one 0 one_b  0 one_c  1 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts A vs. D'
one 0 one_b  0 one_c  0 one_d  1 ln_bldtl 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts B vs. C'
one 0 one_b  1 one_c -1 one_d  0 ln_bldtl 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts B vs. D'
one 0 one_b  1 one_c  0 one_d -1 ln_bldtl 0 xb  0 xc  0 xd  0;
contrast 'Pair-wise Intercepts C vs. D'
one 0 one_b  0 one_c  1 one_d -1 ln_bldtl 0 xb  0 xc  0 xd  0;

*testing strategy 3: adjusted ANOVA;
*H_0: \beta_{0A}=\beta_{0B}=\beta_{0C}=\beta_{0D};

contrast 'Equal Intercepts (ANCOVA vs. Regression)'
	one 0 one_b   1 one_c  0 one_d  0 ln_bldtl 0,
	one 0 one_b   0 one_c  1 one_d  0 ln_bldtl 0,
	one 0 one_b   0 one_c  0 one_d  1 ln_bldtl 0;

*difference of scores in ANCOVA model;
*'no difference in adjusted cell means' ;
*H_0: \mu_{A|\bar{X}}=\mu_{B|\bar{X}}=\mu_{C|\bar{X}}=\mu_{D|\bar{X}};
*equal to test of equal intercepts;

estimate 'Adj Cell Mean: Group A'
	one 1 one_b  0 one_c  0 one_d  0 ln_bldtl 1.21;
estimate 'Adj Cell Mean: Group B'
	one 1 one_b  1 one_c  0 one_d  0 ln_bldtl 1.21;
estimate 'Adj Cell Mean: Group C'
	one 1 one_b  0 one_c  1 one_d  0 ln_bldtl 1.21;
estimate 'Adj Cell Mean: Group D'
	one 1 one_b  0 one_c  0 one_d  1 ln_bldtl 1.21;
	
*comparison of full model to anvoa;
*H_0: \beta_{1A}=\beta_{1B}=\beta_{1C}=\beta_{1D}=0;
contrast 'All Slopes =0 (FULL vs. ANOVA)'
	one 0 one_b 0 one_c 0 one_d 0 ln_bldtl 1 xb 0 xc 0 xd 0,
	one 0 one_b 0 one_c 0 one_d 0 ln_bldtl 1 xb 1 xc 0 xd 0,
	one 0 one_b 0 one_c 0 one_d 0 ln_bldtl 1 xb 0 xc 1 xd 0,
	one 0 one_b 0 one_c 0 one_d 0 ln_bldtl 1 xb 0 xc 0 xd 1;
run;


*effect coding done in the book as well;
*confusing to follow because they skip steps and the main dataframe missing with naming convention;
*see page 432-442 if needed;


/*********************************************
Chapter 17: Understanding and Computing Power for the GLM

Notes:
----------
-> Assume Neyman-Pearson approach for hypothesis testing
-> Methods apply to fixed effect GLM w Gaussian predictors (ANOVA, ANCOVA, Multiple Regression)
-> Contains two dimension and three dimension iml code for power curves....
	very specific to example in book see page 454 -455 if needed

Key Words:
----------
Power

*********************************************/

*NO CODE;
