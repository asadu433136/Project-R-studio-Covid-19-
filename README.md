# Case-R-studio
Forecasting models including ARIMA.

**Introduction** :

The objective of this case is to perform forecast on German retail sales from April 2020 to December 2020. As part of forecasting, we aim to develop an appropriate forecasting method (additive and multiplicative Holt-Winters and ARIMA) and compare with a benchmark model. Also included are point forecasts and prediction intervals. We also check if chosen method performs better using different estimation and hold-out samples.
1. Primary data analysis
We performed decomposition on the data series from Jan 2002 - Mar 2020 to check the components. Figure 1 shows a prominent seasonal component after decomposition. The consistent peaks and troughs at regular time intervals confirming presence of seasonality in the data. However, the trend remains almost constant and rises from 2015 to 2020.


2. **Forecasting method selection** : 

Since we found seasonality in our data, we focus on methods which take seasonality in consideration. We did not consider Simple Exponential Smoothing (SES) and Linear Exponential Smoothing (LES) because the produced forecasts fail to predict the seasonality. Therefore, we proceeded with the following forecasting methods:
_* Seasonal Naïve (as benchmark)
_* Holt-Winters Additive and Multiplicative (with and without trend)
_* ARIMA
    
We performed Holt’s damped method, Holt-Winters Additive and Multiplicative, both with and without trend. The Holt’s damped method fails to capture the seasonality of the data (Figure A1 in Appendix). The produced plots from H-W (Holt-Winters) additive and multiplicative methods are shown in Figure 2. Both methods produce forecasts that clearly align with the seasonality.
ARIMA: To check the stationarity of the data, we did ndiffs/ nsdiffs and found that one differencing is required. After seasonal differencing, we performed visual diagnostics on ACF and PACF plots and suggested seasonal ARIMA models.

Among the three Information Criteria measures, we chose AICc for performance measure (Table 1). Based on the lowest AICc, we selected ARIMA (2,1,2)(0,1,1).
The residuals of ARIMA (2,1,2) (0,1,1) show bell-shaped histogram which represents normally distributed data. We see very few spikes (crossing the blue line in ACF plot) indicating additional non-seasonal terms could be added in the model (see Figure A2 in Appendix). But this could make the model complex which we do not prefer within our current scope of study.
 

3. **Comparison of performance measures** :

We chose seasonal naïve as the benchmark method since the data has seasonality. We used hold-out sample to perform rolling forecasting error and found the best-performed model by considering lowest root mean squared error (RMSE).
 - Forecasting Method
* RMSE
* MAE
* MAPE
 * Point Forecast
 * Seasonal Naïve

                    Among all the methods, ARIMA (2,1,2) (0,1,1) performs better in terms of lowest RMSE.
 
4. **Using different estimation samples to check forecast performance** :

We used different estimation sample size in ARIMA (2,1,2) (0,1,1) model and found the results tabulated below:

5. **Conclusion** :

Based on the above results, we found ARIMA (2,1,2) (0,1,1) model to be the best-fit for the provided data. We consider this result a reasonable one because adding more terms to the ARIMA model would make it complex one which is not preferred.
 Estimation Sample
  Prediction Interval
 2005 Jan - 2010 Dec
[47778.20, 51497.19]
 2004 Jan - 2012 Dec
[48009.61, 51438.00]
2008 Jan - 2016 Dec
 [48059.82, 51763.15]
         

 **Appendix**
 Figure A1: Forecasting with Holt’s local method
 Figure A2: Residuals from selected model ARIMA(2,1,2)(0,1,1)
