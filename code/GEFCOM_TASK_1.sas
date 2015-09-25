/*
===============================================================================
GEFCOM 2014
Task 1
===============================================================================

Team Members: Jon Farland, Ankur Garg, Joe Wang, Tyler Loggins
Date:    August 21st, 2014

Description:
This code reads in the task 1 traiing data set, examines, and models data.
*/


/*
===============================================================================
Import Training Data Set
===============================================================================
*/

/*Set Data Location - Jon's Desktop for now*/
%let path = C:\Users\jonfar\Documents\Research\GEFCOM2014;

/*Import*/
proc import
	out = training
	datafile = "&path\L1-train-fixed-date2.xlsx" 
	dbmis = excel replace;
	range = "'L1-train$'"; 
	getnames = yes;
	mixed = no;
	scantext = yes;
	usedate = yes;
	scantime = yes;
run;

/*Transform Variables*/
data training0;
	set training;
	format datetime0 datetime.;
	datetime0 = dhms(datetime,0,hour,0);
	load0 = input(load, best12.);
	/*add a time trend*/
	t= _n_;
	avg_weather = sum(w1 -- w25/25);
run;

/*
===============================================================================
Explore Data Set
===============================================================================
*/

/*Summary Stats & Histogram*/
proc univariate
	data = training0;
	histogram/normal;
	var load0;
run;

proc univariate
	data = training0;
	histogram/normal;
	var w1;
run;

proc sgplot
	data = training0;
	series x = datetime0 y = w1;
run;

proc sgplot
	data = training0;
	series x = datetime0 y = load0;
run;

proc sort 
	data =training0;
	by load0;
run;

/*
===============================================================================
Initial Models
===============================================================================
- time series models require ETL package
*/

proc arima
	data = training0;
	identify var = load0 nlag=168;
run; quit;

/*Model Time Trend*/
proc autoreg
	data=training0;
  	 model load0 = t / nlag=168 method=ml;
run;

/*
===============================================================================
Quantile Regression based Models
===============================================================================
Proposed Approach:
(1) Create a univariate time series model for each weather series
(2) Forecast the next month of weather for each time series model
(3) Calculate MAPE for each model and choose lowest or use ensemble methods to produce an average weather forecast
(4) Use weather forecasts as input to the load forecasting model

*/

/* 1 - Create Univariate time series model for weather series*/


%macro mod1(var);
proc forecast
	data = training0
	lead = 744
	method = STEPAR
	outest = est&var
	out = pred&var
	outestall;
	var &var;
run;


data mape&var;
	set est&var;
	where _TYPE_ = "MAPE";
	rename &var = mape;
	format model $3.;
	model = "&var";
	drop _TYPE_;
run;
%mend;

%mod1(w1);%mod1(w2);%mod1(w3);%mod1(w4);%mod1(w5);
%mod1(w6);%mod1(w7);%mod1(w8);%mod1(w9);%mod1(w10);
%mod1(w11);%mod1(w12);%mod1(w13);%mod1(w14);%mod1(w15);
%mod1(w16);%mod1(w17);%mod1(w18);%mod1(w19);%mod1(w20);
%mod1(w21);%mod1(w22);%mod1(w23);%mod1(w24);%mod1(w25);
%mod1(avg_weather);

data stack;
	set mape:;
proc sort;
	by mape;
run;

/*data best_w_mod;*/
/*	set predw14;*/
/*	m=1;*/
/*run;*/

data best_w_mod;
	set predavg_weather;
	m=1;
run;


/*Model Lagged Demand Values*/

data lag;
	set training0;
	lag24  = lag24(load0);
	lag48  = lag48(load0);
	lag72  = lag72(load0);
	lag96  = lag96(load0);
	lag120 = lag120(load0);
	lag144 = lag144(load0);
	lag168 = lag168(load0);


run;


%macro mod2(var);
proc forecast
	data = lag
	lead = 744
	method = stepar
	outest = est&var
	out = pred&var
	outestall;
	var &var;
run;

data pred2&var;
	set pred&var;
	m = 1;
run;


data mape2&var;
	set est&var;
	where _TYPE_ = "MAPE";
	rename &var = mape;
	format model $6.;
	model = "&var";
	drop _TYPE_;
run;
%mend;

%mod2(lag24);%mod2(lag48);%mod2(lag72);
%mod2(lag96);%mod2(lag120);%mod2(lag144);
%mod2(lag168);

%mod2(load0);

data stack2;
	set mape2:;
proc sort;
	by mape;
run;

data best_lag_mod;
	set pred2load0; /*merge pred2:;*/;
/*	by m;*/
	keep load0 m;
run;



/*Create Dates of Out of Sample Period*/

data oct;
	format datetime0 datetime.;
	do datetime0 = '01OCT2010:01:00:00'dt to '01NOV2010:00:00:00'dt by 3600;
	m=1;
		output;
	end;
run;

/*merge datetimes*/
data fct_weather;
	merge best_w_mod (in=in_1)
			   	   best_lag_mod(in=_2)
				  oct (in=in_3);

	by m;
	format date date9. hour time.;
	date = datepart(datetime0);
	hour = timepart(datetime0);
	hour0 = hour(hour);

	%macro lag(n);
	lag&n  = lag&n(load0);
	if missing(lag&n)
		then lag&n = load0;
	%mend;

	%lag(24); %lag(48);%lag(72);
	%lag(96);%lag(120);%lag(144);
	%lag(168);

run;


data training00;
	set training0;
	/*get rid of useless data*/
	if missing(load) then delete;
	lag24  = lag24(load0);
	lag48  = lag48(load0);
	lag72  = lag72(load0);
	lag96  = lag96(load0);
	lag120 = lag120(load0);
	lag144 = lag144(load0);
	lag168 = lag168(load0);
run;

/*Out of Sample Begins*/
%let train_beg = '01JAN2005 01:00:00'dt;
%let test_beg = '01OCT2010 01:00:00'dt;

data forecast_data;
/*	set training00 (keep = load0 hour date w14 datetime0 lag:)*/
/*		   fct_weather(keep = w14 datetime0 date hour hour0 lag:);*/
	set training00 (keep = load0 hour date avg_weather datetime0 lag:)
		   fct_weather(keep = avg_weather datetime0 date hour hour0 lag:);
/*	rename w14 = temp;*/
		   rename avg_weather = temp;
	format month date9. season $6.;

	hour0 = hour(hour);
	month = mdy(month(date),1,year(date));
	month_num = month(date);
	if month_num in (11 12 1 2 3)
		then season = "Winter";
		else season = "Summer";
	dow = weekday(date);

	t=_n_;
	%holiday;

run;

/*proc sort data = forecast_data;*/
/*by season;*/
/*run;*/


/*Quantile Regression using Spline*/
proc quantreg
	data = forecast_data
	ci=sparsity/iid algorithm=interior(tolerance=1.e-4);
/*	by season;*/
	effect sp = spline(temp/  knotmethod=percentiles(20) );
	effect tp = spline(t);
	class month_num dow /*hour0*/;
	model load0 = sp tp temp*t  month_num dow /*t*hour0  tuesday--friday month1--month11 hour1--hour23*/ t*nonworking  /*lag24--lag168*/ /quantile = 0.01 to 0.99 by 0.01;
	output out = predictquant p = predquant;
run;

/*out put ex ante forecasts*/
data forecasts;
	set predictquant;
	if missing(load0) then output;
run;

proc datasets 
	library = work;
	modify forecasts;
	attrib _all_ label="";
run;quit;

%macro export_xls(data);
proc export
  data = &data
  outfile = "&path\forecasts.xlsx"
  dbms = excel
  label replace;
  sheet = "&data";
run;
%mend;

%export_xls(forecasts);


/*
===============================================================================
Plot Results
===============================================================================
*/

proc sort
	data = predictquant;
	by temp;
run;

proc sgplot data = predictquant;
yaxis label = "Predicted Load";
scatter x = temp y = predquant1 ;
scatter x = temp y = predquant20 ;
scatter x = temp y = predquant40 ;
scatter x = temp y = predquant50 ;
scatter x = temp y = predquant60 ;
scatter x = temp y = predquant80 ;
scatter x = temp y = predquant99 ;
run;

proc sort 
	data =predictquant;
	by t;
run;

proc sgplot data = predictquant;
yaxis label = "Predicted Load";
scatter x = t y = predquant1 ;
scatter x = t y = predquant20 ;
scatter x = t y = predquant40 ;
scatter x = t y = predquant50 ;
scatter x = t y = predquant60 ;
scatter x = t y = predquant80 ;
scatter x = t y = predquant99 ;
scatter x = t y = load0;
run;




/*
===============================================================================
Calculate Pinball Loss Function
===============================================================================
- reference: http://www.lokad.com/pinball-loss-function-definition
*/


