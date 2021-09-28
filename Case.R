install.packages("readxl");install.packages("forecast");install.packages("fpp2")
library ("readxl");library ("forecast");library ("ggplot2"); library("fpp2"); library('tseries')

### Load data
gersalesdata <- read_excel("F:/_Magdeburg/Uni_Magde/ORBA/BF/R/Business Forecasting/R/DataFiles/GER_retail_sales.xlsx")
head(gersalesdata)
### Time Series
tsgersales <- ts(gersalesdata[, 2], start = c(2000, 1), frequency = 12)
autoplot(tsgersales) + ylab("Sales") + xlab("Year/month") + ggtitle("GER Monthly Retail Sales")
frequency(tsgersales)
### Estimation & Hold-out samples
salestrain <- window (tsgersales, start = c(2000,1), end = c(2015,12))
salestest <- window (tsgersales, start = c(2016,1), end = c(2020,3))

### Decomposition
decomgersales <- decompose(tsgersales, type = c("additive", "multiplicative"), filter = NULL)
plot(decomgersales)  ##### seasonality component is clearly evident
adf.test(tsgersales) ##### p-value= 0.2772

### Seasonality plot
ggseasonplot(tsgersales)
ggseasonplot(tsgersales, polar = TRUE)

### Check Decomposition with ETS   
## ETS(A,N,A) alpha = 0.1913 ,gamma = 1e-04, RMSE= 909.3162
etssales <- ets(salestrain)
summary(etssales)
plot(etssales)
checkresiduals(etssales)  ### p-value < 2.2e-16

### Benchmark methods
### Naive    
fcgersales <- naive(tsgersales, h=9)
autoplot(fcgersales)
summary(fcgersales)
checkresiduals(fcgersales)  ###  p-value < 2.2e-16  Spikes at lag 12, 24 and 36 points to a seasonality
### Seasonal Naive, 
ssgersales <- snaive(tsgersales, h=9)
autoplot(ssgersales)
summary(ssgersales)
checkresiduals(ssgersales)
########## p-value < 2.2e-16 is very small. Not resembling white noise.

### SES   ###  alpha = 0.0875 
gerses <- ses(salestrain, initial="simple", h = 51)    ### Point Forecast (origin : Train set ends)
summary(gerses)
autoplot(gerses)
autoplot(gerses) + autolayer(fitted(gerses))
accuracy (gerses, tsgersales)

# ### LES/ Holt's local method
gerlesholt <- holt(salestrain, initial="simple", h = 51)
summary(gerlesholt)
autoplot(gerlesholt)
accuracy (gerlesholt, tsgersales)
checkresiduals(gerlesholt)

# ### LES-damped
gerdamped <- holt(salestrain, damped=TRUE, h=51)
summary(gerdamped)
autoplot(gerdamped)
accuracy (gerdamped, tsgersales)
checkresiduals(gerdamped)

#### Holt-Winters Additive
fchw.a <- hw (salestrain, seasonal = "additive", initial="simple", h = 51)
summary (fchw.a)
checkresiduals(fchw.a)
accuracy (fchw.a, tsgersales)
autoplot(fchw.a) + autolayer(fitted(fchw.a), na.rm= TRUE)
############ RMSE Train = 971.26, RMSE Test= 2635.00
############   alpha = 0.1424 , beta  = 0.147 , gamma = 0.3471

#### Holt-Winters Additive damped
hwd.a <- hw (salestrain, damped= TRUE, seasonal = "additive", initial="optimal", h = 51)
summary(hwd.a)
checkresiduals(hwd.a)
accuracy (hwd.a, tsgersales)
autoplot(hwd.a) + autolayer(fitted(hwd.a), na.rm= TRUE)
############ RMSE Train = 897.017, RMSE Test= 2647.47

#### Holt-Winters Multiplicative
fchw.m <- hw (salestrain, seasonal = "multiplicative", initial="simple", h = 51)
summary (fchw.m)
checkresiduals(fchw.m)
accuracy (fchw.m, tsgersales)
autoplot(fchw.m) + autolayer(tsgersales)
autoplot(fchw.m) + autolayer(fitted(fchw.m), na.rm= TRUE)
############ RMSE= 967.63, RMSE Test= 2202.21
#### alpha = 0.1452 , beta  = 0.1375 , gamma = 0.344 

#### Holt-Winters Multiplicative- Damped
hwd.m <- hw (salestrain,damped =TRUE,  seasonal = "multiplicative", initial="simple", h = 51)
summary (hwd.m)
checkresiduals(hwd.m)
accuracy (hwd.m, tsgersales)
autoplot(hwd.m) + autolayer(tsgersales)
autoplot(hwd.m) + autolayer(fitted(hwd.m), na.rm= TRUE)

### Rolling forecast for H-W Multiplicative:

forecastfc <- function(x,h){forecast(hw(x,seasonal = "multiplicative", initial="simple", alpha=0.1452, beta=0.1375, gamma=0.344, h=h))}
fce <- tsCV(tsgersales, forecastfunction = forecastfc, h = 1)
testfce <- subset(fce, start=length(fce)-51)
testmse <- mean(testfce^2, na.rm = TRUE)
testrmse <- sqrt(testmse)
testmae <- mean(abs(testfce), na.rm=TRUE)
testmape <- 100*mean(abs(testfce)/lag(tsgersales,k=1), na.rm=TRUE)
testme <- mean(testfce, na.rm = TRUE )
######## Piping H-W Multiplicative
tsgersales %>% tsCV(forecastfunction=forecastfc, h=1) %>% subset(start=193-1) -> testfce
testfce^2 %>% mean(na.rm=TRUE) %>% sqrt() -> testrmse
forecastfsnaive<-function(x,h){forecast(naive(tsgersales, h=h))}
tsgersales %>% tsCV(forecastfunction=forecastfsnaive, h=1) %>% subset(start=193-1) -> testfcenaive
(sum(abs(testfce),na.rm=TRUE))/(sum(abs(testfcenaive),na.rm=TRUE)) -> testrelmae


### Rolling forecast for H-W ADDITIVE:

forecastfc.A <- function(x,h){forecast(hw(x,seasonal = "additive", initial="simple", alpha=0.1424, beta=0.147, gamma=0.3471, h=h))}
fce.A <- tsCV(tsgersales, forecastfunction = forecastfc.A, h = 1)
testfce.A <- subset(fce.A, start=length(fce.A)-51)
testmse.A <- mean(testfce.A^2, na.rm = TRUE)
testrmse.A <- sqrt(testmse.A)
testmae.A <- mean(abs(testfce.A), na.rm=TRUE)
testmape.A <- 100*mean(abs(testfce.A)/lag(tsgersales,k=1), na.rm=TRUE)
testme.A <- mean(testfce.A, na.rm = TRUE )
######## Piping H-W ADDITIVE
tsgersales %>% tsCV(forecastfunction=forecastfc.A, h=1) %>% subset(start=193-1) -> testfce.A
testfce.A^2 %>% mean(na.rm=TRUE) %>% sqrt() -> testrmse.A
forecastfsnaive <-function(x,h){forecast(naive(tsgersales, h=h))}
tsgersales %>% tsCV(forecastfunction=forecastfsnaive, h=1) %>% subset(start=193-1) -> testfcenaive.A
(sum(abs(testfce.A),na.rm=TRUE))/(sum(abs(testfcenaive.A),na.rm=TRUE)) -> testrelmae.A

#######################################################################################################

### STAGES OF ARIMA MODELING

## IDENTIFY KEY FEATURES
ggAcf(salestrain)
ggPacf(salestrain)
ndiffs(salestrain)
nsdiffs(salestrain)      ###### nsdiffs = 1  so seasonal differencing is required.

## TRANSFORM/DIFFERENCE DATA TOWARDS STATIONARITY 
Dsalestrain <- diff(salestrain, lag = 12, difference=1)
summary(Dsalestrain)
nsdiffs(Dsalestrain)      ###### nsdiffs = 0 so no further differencing required.
autoplot(Dsalestrain) + ylab("D Sales") + xlab("Year")
ggAcf(Dsalestrain)
ggPacf(Dsalestrain)
checkresiduals(Dsalestrain)   #### almost funnel shaped histogram, ACF shows damping of the spikes as seasonal lag increases

adf.test(salestrain)         ##### p-value = 0.01  Lag order = 5, #P-value < 0.05 .. shows Stationary data
adf.test(salestrain, k=12)   #### Used lag=12 here for the Seasonal data
adf.test(Dsalestrain)        ##### p-value = 0.371 , 
###PLots reveal ARIMA (2,1,0)(0,1,1)[12]

###  ARIMA Model selection
salesARIMA111.110 <- Arima(salestrain, order = c(1,1,1),seasonal = c(1,1,0))
summary (salesARIMA111.110)  #### AIC=3011.26   AICc=3011.49   BIC=3024.01  #RMSE= 1019.273
salesARIMA111.011 <- Arima(salestrain, order = c(1,1,1),seasonal = c(0,1,1))
summary(salesARIMA111.011)  #### AIC=2984.86   AICc=2985.09   BIC=2997.61   #RMSE= 927.9741 
salesARIMA111.111 <- Arima(salestrain, order = c(1,1,1),seasonal = c(1,1,1))
summary(salesARIMA111.111)  #### AIC=2984.88   AICc=2985.23   BIC=3000.82    #RMSE= 922.4903


salesARIMA210.011 <- Arima(salestrain, order = c(2,1,0),seasonal = c(0,1,1))
summary(salesARIMA210.011)  #### AIC=2964.29   AICc=2964.52   BIC=2977.04    #RMSE= 879.762
salesARIMA211.011 <- Arima(salestrain, order = c(2,1,1),seasonal = c(0,1,1))
summary(salesARIMA211.011)  #### AIC=2961.72   AICc=2962.06   BIC=2977.65    #RMSE= 869.4495
salesARIMA212.011 <- Arima(salestrain, order = c(2,1,2),seasonal = c(0,1,1))
summary(salesARIMA212.011)  #### AIC=2956.14   AICc=2956.63   BIC=2975.27    #RMSE= 850.5822     #### lowest AICc

salesARIMA210.111 <- Arima(salestrain, order = c(2,1,0),seasonal = c(1,1,1))
summary(salesARIMA210.111)  #### AIC=2966.09   AICc=2966.44   BIC=2982.03    #RMSE= 879.3005
salesARIMA211.111 <- Arima(salestrain, order = c(2,1,1),seasonal = c(1,1,1))
summary(salesARIMA211.111)  #### AIC=2962.49   AICc=2962.98   BIC=2981.62    #RMSE= 866.5023
salesARIMA212.111 <- Arima(salestrain, order = c(2,1,2),seasonal = c(1,1,1))
summary(salesARIMA212.111)  #### AIC=2957.23   AICc=2957.88   BIC=2979.54    #RMSE= 848.222     #### lowest RMSE 


### Selecting ARIMA(2,1,2)(0,1,1) as the appropriate  model 
summary(salesARIMA212.011)
checkresiduals(salesARIMA212.011)  #####  p-value = 0.003179,  meaning it is not resembling with white noise

### Auto ARIMA model
salesautoarima  <- auto.arima(salestrain)    #### ARIMA(2,1,2)(0,1,1)[12] 
summary(salesautoarima)                      #### AIC=2956.14   AICc=2956.63   BIC=2975.27  RMSE= 850.5822
checkresiduals(salesautoarima)               ####  p-value = 0.003179

### Comparison of ARIMA forecats with alternative method (Seasonal Naive) 
# Forecast error ARIMA212.011 (Test Dataset)
forecastarima <- function(x,h){forecast(x,model= salesARIMA212.011, h=h)}
tsgersales%>%tsCV(forecastarima,h=12)%>%window(start= c(2016,1))-> testfcearima
mean(testfcearima^2,na.rm=TRUE)%>%sqrt() -> testrmsearima                    #RMSE = 1077.131

# Forecast error Seasonal Naive
forecastsnaive <- function(x, h){forecast(snaive(x), h=h)}
tsgersales %>% tsCV(forecastfunction = forecastsnaive, h = 12) %>% window(start= c (2016,1)) -> testfcesnaive
mean(testfcesnaive^2, na.rm = TRUE) %>% sqrt() -> testrmsesnaive            #RMSE = 1596.53

# Forecast error Seasonal Naive

### Point forecast of ARIMA: 
forecastarima2<-function(x,h){forecast(Arima(tsgersales, model = salesARIMA212.011, h=12))}
summary(forecastarima2())
plot(forecastarima2())

forecastarima2test<-function(x,h){forecast(Arima(salestest, model = salesARIMA212.011, h=12))}
plot(forecastarima2test())

#### Using different estimation samples to check performance
### Estimation & Hold-out samples             #original Train set start = c(2000,1), end = c(2015,12)
train1 <- window (tsgersales, start = c(2005,1), end = c(2010,12))
train2 <- window (tsgersales, start = c(2004,1), end = c(2012,12))
train3 <- window (tsgersales, start = c(2008,1), end = c(2016,12))

ARIMAtrain1 <- Arima(train1, order = c(2,1,2),seasonal = c(0,1,1))
ARIMAtrain2 <- Arima(train2, order = c(2,1,2),seasonal = c(0,1,1))
ARIMAtrain3 <- Arima(train3, order = c(2,1,2),seasonal = c(0,1,1))

forecastARIMAtrain1<-function(x,h){forecast(Arima(tsgersales, model = ARIMAtrain1, h=12))}
summary(forecastARIMAtrain1())

forecastARIMAtrain2<-function(x,h){forecast(Arima(tsgersales, model = ARIMAtrain2, h=12))}
summary(forecastARIMAtrain2())

forecastARIMAtrain3<-function(x,h){forecast(Arima(tsgersales, model = ARIMAtrain3, h=12))}
summary(forecastARIMAtrain3())

