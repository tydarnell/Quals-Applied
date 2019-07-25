library(tidyverse)
library(readxl)
library(pracma)
library(matlib)
library(knitr)

mel <- read_csv("USmelanoma.csv")

melplot=ggplot(data=mel,aes(x=latitude,y=mortality))+geom_point()

mod=lm(mortality~latitude,data=mel)

coefficients=mod$coefficients
fitted=mod$fitted.values
residuals=mod$residuals

y = mel$mortality
x = mel$latitude
n = length(y)
ybar = mean(y)
xbar = mean(x)
syy = sum( (y - ybar)^2 )
sxx = sum( (x - xbar)^2 )
sxy = sum( (y - ybar)*(x - xbar) )