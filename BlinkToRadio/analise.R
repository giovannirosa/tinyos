getwd()
setwd('/home/grosa/Dev/tinyos-main/apps/tinyos/BlinkToRadio')

measures <- read.csv('measures.csv')
head(measures)
colnames(measures) <- c('LOCAL','TEMP')
str(measures)

library(ggplot2)

qplot(data=measures, x=LOCAL, y=TEMP)
