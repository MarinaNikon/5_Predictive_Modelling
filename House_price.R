#Assignment_Predictive Modelling using R
#Marina Nikon

#BACKGROUND: The data for modeling contains information on 
#Selling price of each house in million Rs. It also contains 
#Carpet area in square feet, Distance from nearest metro 
#station and Number of schools within 2 km distance. The data 
#has 198 rows and 5 columns.

#Installing packages and importing libraries
install.packages("reshape2") #For Correlation matrix
library(reshape2) 
install.packages("ggplot2") #Correlation matrix
library(ggplot2) 
library(dplyr)
install.packages("GGally") #Correlation matrix
library(GGally) 

library(stats) #Influential observations

install.packages("caret") # for splitting original data into
#training and testing data sets and for K-fold cross validation 
library(caret) 

install.packages("car") # to check Multicollinearity, draw influential plot
library(car) 

install.packages('nortest') #Kolmogorov-Smirnov normality test
library(nortest) 

#QUESTIONS
#1. Import House Price Data. Check the structure of the data.

#Load the dataset
house_pr<-read.csv(file.choose(), header = TRUE)
summary(house_pr) #Summarizing data and checking for missing values
str(house_pr) # Check the structure of the dataset
head(house_pr) # View first 6 rows
dim(house_pr) # Check the dimension of the dataset
anyNA(house_pr) # Check for missing values explicitly

#Correlation matrix using heatmap 
corrmatr <- round(cor(house_pr),2)
melted_corrmatr <- melt(corrmatr)

ggplot(data = melted_corrmatr, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()+
  geom_text(aes(Var1, Var2, label = value), color = "black", size = 4)+
  scale_fill_gradient2(low="red",mid="white",high="blue")
#Observations:
# Strong positive correlation observed between Price and Area.
# Moderate positive correlation with Schools; negative with Distance.


#Graphical representation of the data to understand
#how variables are related to each other
ggpairs(house_pr[, c("Price", "Area", "Distance", "Schools")],
        title = "Scater Plot Matrix", columnLabels = 
          c("Price", "Area", "Distance", "Schools"))
#Observations:
# Strong positive correlation observed between Price and Area.
# Moderate positive correlation with Schools; negative with Distance.


#2 Split the data into Training (80%) and Testing (20%) datasets
set.seed(123) #to use the same traindata
index<-createDataPartition(house_pr$Price, p=0.8, list=FALSE)
head(index)
dim(index)

traindata<-house_pr[index,]
testdata<-house_pr[-index,]

dim(traindata) #dimension of training set
dim(testdata) #dimension of testing set



#3 Build a regression model on training data to estimate selling
#price of a House.
house_pr_model<-lm(Price~Area+Distance+Schools, data=traindata)
house_pr_model
#Coefficients:
#  (Intercept)         Area     Distance      Schools  
#-8.924        0.034       -1.852        1.308 
#Observations:
#The Intercept (-8.924)represents the estimated house Price when
# all predictor variables (Area, Distance, Schools) are zero. 
#(but zero values for these predictors are unrealistic)



#4 List down significant variables and interpret their
#regression coefficients.
#Model summary
summary(house_pr_model) 
#Observations:
# Coefficient for Area is 0.034, indicating a positive
#relationship with the selling Price. For every additional
#square foot of carpet Area, the selling price increases by
#0.034 million Rs, keeping all the other variables constant

# Coefficient for Distance is -1.852, showing a negative
#relationship with the selling Price. For every additional
#kilometer from the nearest metro station, the selling price 
#decreases by 1.852 million Rs, keeping all the other variables constant

# Coefficient for Schools is 1.308, indicating a positive
#relationship with the selling Price. For every additional
#school within 2 km of the house, the selling price increases 
#by 1.308 million Rs, keeping all the other variables constant

#The coefficients for various predictor variables suggest 
#their respective impact on the selling price. Notably, 
#the variable  “Area” has substantial positive effects, 
#while “Distance” has a negative effect. 
#There are no insignificant variables, all independent
#variables in the model are significant.


  
#5 What is the R2 and adjusted R2 of the model? 
#Give interpretation. 
#Multiple R-squared:  0.7839,	
#Adjusted R-squared:  0.7798 (from summary(house_pr_model))
#R-squared is the proportion of variation in the dependent variable
#which is explained by the independent variable.
#The value for R-squared can range from 0 to 1. A value of 0 indicates
#that the response variable cannot be explained by the predictor 
#variable at all. A value of 1 indicates that the response variable 
#can be perfectly explained without error by the predictor variable.
#The closer R-squared is to  1, the better the goodness of fit.
#In the LM Regression Results, the model’s R-squared value 
#is 0.7839, which indicates that approximately 78% of the 
#variability in Price is explained by the model and 22% is unexplained.

#The adjusted R-squared (0.7798) is a modified version of R-squared 
#that has been adjusted for the number of predictors in the model.
#It is always lower than the R-squared. The adjusted R-squared can
#be useful for comparing the fit of the different regression
#models to one another.


  
#6 Is there a multicollinearity problem? 
#If yes, do the necessary steps to remove it.
vif(house_pr_model) #checking Multicollinearity
#Observations:
#Area Distance  Schools 
#1.545118 1.026447 1.564728 
#There is no the multicollinearity problem as 
#all VIF’s are less than 5
#Do not need to do re-modelling to remove multicollinearity


#7 Are there any influential observations in the data?
influ<-influence.measures(house_pr_model)
influ
#Observations:
#If values of Cook's distance are much higher than 1 or 
#other observations, a strong influence could be suggested.
#Higher the cook's distance, more is the influence of
#observation on the model

#some influential observations could be seen.
#17  5.68e-02 0.0793   *
#For example observation #17 has a Cook's distance 0.0568, which is
#substantial, and hat inf is 0.0793, indicating it 
#might be influential.

#Influence plot
influencePlot(house_pr_model,
              id.method = 'identify',
              main = 'Influence Plot',
              sub = "Circle size is proportional to Cook's Distance")
#Observations:
# The influence_plot visually highlights influential points with large 
# Cook's Distance values and high leverage.
# Influential points could significantly impact the regression coefficients
# and model predictions and may indicate issues with the data or model, 
# such as non-linearity or heteroscedasticity. Influential points should 
# be carefully analyzed for their impact on the model's reliability.



#8 Can we assume that errors follow ‘Normal’ distribution?

#Calculate and store the residuals
traindata$resi<-residuals(house_pr_model)

#Check if distribution of errors is “NORMAL”
#QQplot to check if errors are normally distributed
qqnorm(traindata$resi, 
       main = "QQPlot for residuals", col="coral")
qqline(traindata$resi, col= "blue")  
#Observations: The QQ Plot for the residuals mostly shows
#points close to the theoretical line, but at the beginning
#and at the end of the line there is some deviation from the 
#theoretical line, it is indicating possible non-normality


#Shapiro-Wilk normality test
shapiro.test(traindata$resi)
#Observations: W = 0.97169, p-value = 0.002271, 
#p-value is less than 0.05, reject the null hypothesis.  
#Residuals may not follow a normal distribution.

#Lilliefors (Kolmogorov-Smirnov) normality test
lillie.test(traindata$resi)
#Observations: D = 0.077284, p-value = 0.02073, 
#p-value is less than 0.05, reject the null hypothesis.  
#Residuals may not follow a normal distribution.


#Histogram of Residuals for detecting violation 
#of normality assumption.

#A histogram with a density overlay can visually assess normality.
hist(traindata$resi, probability = TRUE, main = "Histogram of Residuals",
     xlab = "Residuals")
lines(density(traindata$resi), col = "blue", lwd = 2)
#Observations: The density plot roughly follows a bell shape,
#although it is slightly skewed to the left.

#Comment: Although normality of errors is not established
#we will proceed to evaluate the model performance



#9 Is there a Heteroscedasticity problem? Check using
#residual vs. predictor plots. 

#Residual Analysis and Scatter Plot
#Assign the fitted values (predicted)
traindata$pred<-fitted(house_pr_model)

#Create a scatter plot of residuals vs. predicted values
plot(traindata$pred,traindata$resi, col="coral",
     main = "Residuals vs Fitted Values",
     xlab = "Fitted Values", ylab = "Residuals")
#Observations: It is observed that residuals are randomly
#distributed and uncorrelated with predicted values, it
#suggests that no pattern exists, supporting the 
#homoscedasticity assumption
#In other words, the coefficients of regression model should be
#trustworthy and we don't need to perform a transformation on the data.
#A funnel shape does not observed, to suggest the presence of heteroscedasticity.



#10 Calculate the RMSE for the Training and Testing
#data. Multiple Linear Regression 

#RMSE of training data
traindata$resi<-residuals(house_pr_model)
RMSEtrain<-sqrt(mean(traindata$resi**2))
RMSEtrain
#Observations:
#> RMSE
#[1] 2.248768

#RMSE of testing data
testdata$pred<-predict(house_pr_model,testdata)
testdata$resi<-(testdata$Price-testdata$pred)
RMSEtest<-sqrt(mean(testdata$resi**2))
RMSEtest
#Observations:
#> RMSEtest
#[1] 1.980458

#Observations :
#The similarity in RMSE between the test and train data 
#suggests that the regression model generalizes reasonably
#well, with consistent prediction accuracy on both datasets.
#This implies that the model is stable and not overfitting
#to the training data.


#K-fold cross validation
kfolds<-trainControl(method="cv",number=4)
kmodel<- train(Price~Area+Distance+Schools,
               data=house_pr, method = "lm", trControl=kfolds)
kmodel
#Observations:
#  RMSE      Rsquared  MAE     
#2.264721  0.79276   1.791917
#RMSE and R squared values using K-fold validation are similar 
#to overall RMSE and R squared values
#The model can be implemented for decision making
