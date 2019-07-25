##### US State map melanoma example
# if not already installed, run the following to install the needed packages
# install.packages(c("ggplot2","ggmap","maps","mapdata","HSAUR2"))

# load the packages
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(HSAUR2)

# get US state map
states <- map_data("state")

# Melanoma data pre-loaded by the HSAUR2 package as data frame USmelanoma
# Make sure melanoma data in same order as states in the "states" map object 
mortality = USmelanoma[match(states$region, tolower(rownames(USmelanoma))),1]

# now make the plot, plotting the US map but filling by the mortality data
ggplot() + geom_polygon(data = states, aes(x=long, y = lat, group = group, fill = mortality)) + 
  coord_fixed(1.3)

##### Now lets run the melanoma regression example

# if you want to read in directly frlom the file, use read.table below and the appropriate file path
USmelanoma =  read.table(file = "USmelanoma.csv", header = TRUE, sep = "\t", row.names = 1)

plot(USmelanoma[,2], USmelanoma[,1], 
     ylab = "Mortality (Deaths per Million)", 
     xlab = "Latitude"
)

out = lm(mortality ~ latitude, data = USmelanoma) # or,
out = lm(USmelanoma[,1] ~ USmelanoma[,2])

summary(out)

residuals = out$residuals
fitted = out$fitted.values
coefficients = out$coefficients 

plot(fitted, residuals)

y = USmelanoma$mortality
x = USmelanoma$latitude
n = length(y)
ybar = mean(y)
xbar = mean(x)
SYY = sum( (y - ybar)^2 )
SXX = sum( (x - xbar)^2 )
SXY = sum( (y - ybar)*(x - xbar) )

coefficients
SXY/SXX # beta_1 hat
ybar - (SXY/SXX)*xbar  # beta_0 hat

RSS = sum( (y - fitted)^2 )
s2_hat = RSS/(n - 2) # sigma_squared hat
s2_hat
sqrt(s2_hat*(1/n + xbar^2/SXX)) # se of beta_0 hat
sqrt(s2_hat/SXX) # se of beta_1 hat
round(vcov(out),3) # covariance matrix of beta_0 hat, beta_1 hat

t = -9.994
p.value  = 2*(1 - pt(abs(t), n-2))
p.value