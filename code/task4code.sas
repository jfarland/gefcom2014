PROC IMPORT OUT= WORK.train0 
            DATAFILE= "C:\Users\jonfar\Documents\Research\GEFCOM2014\L5-train.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


data time0;
	 format datehour datetime.;
  	do datehour='01JAN2011:01:00:00'dt to '01FEB2011:00:00:00'dt by 3600;
		output time0;
	end;
run;

data time;
	set time0;
	t=_n_;
run;

data train00;
	set train0;
	t=_n_;
run;

data train;
	merge train00(in=in_1)
				  time(in=in_2);;
	by t;
	format date date9.;
	hour = hour(datehour);
	date = datepart(datehour);
	dow = weekday(date);

	drop zoneid timestamp;
run; 

/*
===============================================================================
Plot each weather series
===============================================================================
*/

%macro plot(var);
	proc sgplot
		data = train;
		series x = datehour y = load /group = dow;
		series x = datehour y = &var/group = dow;
	run;
%mend;

%plot(w1);
%plot(w2);
%plot(w3);
%plot(w4);
%plot(w5);
%plot(w6);
/*
===============================================================================
Determine linear correlation
===============================================================================
*/

ods graphics on;
title 'Load and Weather Data';
proc corr data=train nomiss plots(maxpoints=5000000)=matrix(histogram) outp=corr_out;
   var load w: ;
 run;
ods graphics off;	

proc anova
	data = train;
	class hour;
	model load = hour;
	means hour /tukey;
run;

/*
===============================================================================
Modeling
===============================================================================
*/
