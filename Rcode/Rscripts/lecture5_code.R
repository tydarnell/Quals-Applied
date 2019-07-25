ozone = read.table("ozone.txt", header = T, sep = " ") # space delimited
n = nrow(ozone) # number of rows of ozone (obs)
# manual fitting of linear model
X = model.matrix(~ outdoor + home + time_out, data = ozone) # predictor matrix 
y = ozone$personal # response
head(X)
bhat = solve(t(X) %*% X) %*% t(X) %*% y # from notes
yhat=X%*%bhat; # predicted values
ehat=y-yhat; # residuals
p=ncol(X); # num columns of X
df=n-p; # df
sse = t(y) %*% y - t(bhat) %*% t(X) %*% y # SSE
mse=sse/df; # MSE
print(bhat)
print(mse)

# testing contrasts
C = matrix(c(0,1,-1,0,0,0,1,-1), nrow = 2, byrow = T) # contrast matrix
print(C)
M=C %*% solve(t(X)%*%X)%*%t(C)
thetahat=C%*%bhat
ssh=t(thetahat)%*%solve(M)%*%thetahat
f_obs=(ssh/nrow(thetahat))/mse
p=1-pf(f_obs,2,60) 
print(ssh)
print(f_obs)
print(p)

