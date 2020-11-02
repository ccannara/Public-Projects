#!/usr/bin/env python
# coding: utf-8

# In[1]:


# pip install requests_html
# pip install yahoo_fin
# pip install numpy
# pip install pandas
# pip install pandas_datareader
# pip install sklearn


# In[2]:


import pandas as pd
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.svm import SVR
from sklearn.model_selection import train_test_split

import datetime as dt
import yfinance as yf
from yahoo_fin import stock_info as si

from pandas_datareader import data as pdr

from forex_python.converter import CurrencyRates, CurrencyCodes

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def generateMenuHeader():
    print(f"\n{bcolors.HEADER}Today's date:", dt.date.today().strftime("%B %d, %Y"),f"{bcolors.ENDC}")
    current_time = dt.datetime.now()
    if ((current_time.hour + current_time.minute/60) > 20):
        indicator = f"{bcolors.FAIL}Market is closed{bcolors.ENDC}"
    elif ((current_time.hour + current_time.minute/60) > 16):
        indicator = "Market After-Hours"
    elif ((current_time.hour + current_time.minute/60) > 15.75):
        indicator = "Stock Market Open [About to Close!]"
    elif ((current_time.hour + current_time.minute/60) > 9.50):
        indicator = f"{bcolors.OKGREEN}Stock Market Open{bcolors.ENDC}"
    elif ((current_time.hour + current_time.minute/60) > 9.25):
        indicator = "Pre-Market Open [About to Transition!]"
    elif ((current_time.hour + current_time.minute/60) > 8):
        indicator = "Pre-Market Open"
    else:
        indicator = f"{bcolors.FAIL}Market is closed{bcolors.ENDC}"

    print(current_time.strftime("%H:%M:%S"), "EST :", indicator)

def displayTickerMenu():
    generateMenuHeader()
    print("==========================")
    print("[1] ", "See More Details")
    print("[2] ", "Add Simple Moving Average")
    print("[3] ", "Machine Learning Predictions")
    print("[4] ", "Update Screen (Live Price)")
    print("[5] ", "Forex Conversion")
    print("[6] ", "See Balance Sheet")
    print("[7] ", "See Cash Flow Statement")
    print("[8] ", "See Dividends")
    print("{9} ", "Go Back")

def displayGeneralMenu():
    generateMenuHeader()
    print("==========================")
    print("[1] ", "Check Specific Stock")
    print("[2] ", "Check Top Gainers")
    print("[3] ", "Check Worst Performers")
    print("[4] ", "Check Most Active")
    print("[5] ", "Check Top Crypto")
    print("{9} ", "QUIT")

def MLPred(df):
    df = df[['Adj Close']]
    forecast = int(input("\nEnter forecast amount: "))
    df['Prediction'] = df[['Adj Close']].shift(-forecast)

    X = np.array(df.drop(['Prediction'], 1))
    # print(X)
    # print(X.size)
    if (X.size < forecast + 6):
        print("Can't create accurate r^2 value, setting forecast to", X.size - 6)
        forecast = X.size - 6
        df['Prediction'] = df[['Adj Close']].shift(-forecast)
        
    # print("Forecast: ", forecast)
    X = X[:-forecast]
    y = np.array(df['Prediction'])
    y = y[:-forecast]

    # Split data lists to train and test
    x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    # Create and train SVM (Support Vector Machine)
    svr_rbf = SVR(kernel='rbf', C=1e3, gamma=0.1)

    print("\nTraining SVM...")
    svr_rbf.fit(x_train, y_train)
    svm_confidence = svr_rbf.score(x_test, y_test)

    #  Create and train LRM (Linear Regression Model)
    lr = LinearRegression()
    # Train model
    print("Testing LR...\n")
    lr.fit(x_train, y_train)
    lr_confidence = lr.score(x_test, y_test)

    # Set x_forecast equal to last 30 rows of the original 
    # data set from Adj Close
    x_forecast = np.array(df.drop(['Prediction'], 1))[-forecast:]

    # Print the SVM predictions!!
    svr_rbf_prediction = svr_rbf.predict(x_forecast)
    print(forecast, "Day Prediction via Support Vector Regressor")
    print("SVM Confidence: ", svm_confidence)
    print(svr_rbf_prediction, "\n")

    # Print the LR predictions!!
    lr_prediction = lr.predict(x_forecast)
    print(forecast, "Day Prediction via Linear Regression Model")
    print("LR Confidence: ", lr_confidence)
    print(lr_prediction)

def selectDate(ticker):
    print("Start Date Parameters:")
    startyear = int(input("Enter year: "))
    startmonth = int(input("Enter month: "))
    startday = int(input("Enter day: "))

    try:
        now = dt.datetime.now()
        start = dt.datetime(startyear, startmonth, startday)
        df = pdr.get_data_yahoo(ticker, start, now)
        return df
    except:
        print("This is not a valid date")
        df = pdr.get_data_yahoo(ticker)
        return df

def tickerMenu():
    ticker = input("Enter the stock ticker symbol: ")
    c = CurrencyRates()

    # Get Stock Data
    flag = input("Enter starting date? [y/n]: ")
    if (flag == "y"):
        df = selectDate(ticker)
    else:
        df = pdr.get_data_yahoo(ticker)

    # Print out stock data
    # print("\nCURRENTLY DISPLAYING:", ticker.upper())
    print(f"\n{bcolors.WARNING}CURRENTLY DISPLAYING:{bcolors.ENDC}", ticker.upper())
    print(df, "\n")
    try:
        close_val = float(si.get_live_price(ticker))
        open_val = float(df["Open"][-1])

        delta = (1 - (close_val/open_val)) * -100
        delta = round(delta, 2)
        if (delta > .3):
            print("Live Price:", f"{bcolors.OKGREEN}", close_val, "( ^", delta, "% )", f"{bcolors.ENDC}")
        elif (delta < -.3):
            print("Live Price:", f"{bcolors.FAIL}", close_val, "( v", delta, "% )", f"{bcolors.ENDC}")
        else:
            print("Live Price:", f"{bcolors.WARNING}", close_val, "( ", delta, "% )", f"{bcolors.ENDC}")
    except:
        print("There is no data for", ticker.upper())
        return

    smadf = pdr.get_data_yahoo(ticker)
    flag = 0
    while (flag < 9):
        # return
        displayTickerMenu()
        flag = int(input("Enter number: "))

        if (flag == 1):
            print("\nLoading quote table...")
            quote_table = si.get_quote_table(ticker)
            print()
            for key in quote_table:
                print(key, ': ', quote_table[key])
        elif (flag == 2):
            ma = int(input("Enter Simple Moving Average Amount: "))
            smaString="Sma_" + str(ma)
            smadf[smaString] = smadf.iloc[:,4].rolling(window=ma).mean()
            smadf = smadf.iloc[ma:]
            print(smadf)
        elif (flag == 3):
            MLPred(df)
        elif (flag == 4):
            print(f"\n{bcolors.WARNING}CURRENTLY DISPLAYING:{bcolors.ENDC}", ticker.upper())
            print(df, "\n")
            print("Live Price: ", si.get_live_price(ticker))
        elif (flag == 5):
            base = float(input("\nEnter currency amount: "))
            curr = input("Enter what currency this is: ")
            to_curr = input("Enter the currency to convert to: ")
            try:
                rate = c.get_rate(curr, to_curr)
                print("Rate from ", curr, " to ", to_curr, ": ", rate)
                print(base, curr, " = ", base * rate, to_curr)
            except:
                print("Not a valid conversion. Try again.")
        elif (flag == 6):
            print("\n", si.get_balance_sheet(ticker, yearly = False))
        elif (flag == 7):
            print("\n", si.get_cash_flow(ticker, yearly = False))
        elif (flag == 8):
            print("\n", si.get_dividends(ticker))

def __init__():
    yf.pdr_override()
    
    flag = 0
    while (flag < 6):
        displayGeneralMenu()
        flag = int(input("Enter number: "))

        if (flag == 1):
            tickerMenu()
        elif (flag == 2):
            print("\n", si.get_day_gainers())
        elif (flag == 3):
            print("\n", si.get_day_losers())
        elif (flag == 4):
            print("\n", si.get_day_most_active())
        elif (flag == 5):
            print("\n", si.get_top_crypto())

    print(f"\n{bcolors.OKBLUE}Goodbye!{bcolors.ENDC}\n")
__init__()



# %%
