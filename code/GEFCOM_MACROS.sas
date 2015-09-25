%macro holiday;

	labor09 = holiday('labor',2009);
		format labor09 date9.;
	labor10 = holiday('labor',2010);
		format labor10 date9.;
	labor11 = holiday('labor',2011);
		format labor11 date9.;
	labor12 = holiday('labor',2012);
		format labor12 date9.;

	july409 = holiday("usindependence",2009);
		format july409 date9.;
	july410 = holiday("usindependence",2010);
		format july410 date9.;
	july411 = holiday("usindependence",2011);
		format july411 date9.;
	july412 = holiday("usindependence",2012);
		format july412 date9.;
	
	newyears09 = holiday("newyear",2009);
		format newyears09 date9.;
	newyears10 = holiday("newyear",2010);
		format newyears10 date9.;
	newyears11 = holiday("newyear",2011);
		format newyears11 date9.;
	newyears12 = holiday("newyear",2012);
		format newyears12 date9.;

	mlk09 = holiday("mlk",2009);
		format mlk09 date9.;
	mlk10 = holiday("mlk",2010);
		format mlk10 date9.;
	mlk11 = holiday("mlk",2011);
		format mlk11 date9.;
	mlk12 = holiday("mlk",2012);
		format mlk12 date9.;

	presidents09 = holiday("uspresidents",2009);
		format presidents09 date9.;
	presidents10 = holiday("uspresidents",2010);
		format presidents10 date9.;
	presidents11 = holiday("uspresidents",2011);
		format presidents11 date9.;
	presidents12 = holiday("uspresidents",2012);
		format presidents12 date9.;


	memorial09 = holiday("memorial",2009);
	 	format memorial09 date9.;
	memorial10 = holiday("memorial",2010);
	 	format memorial10 date9.;
	memorial11 = holiday("memorial",2011);
	 	format memorial11 date9.;
	memorial12 = holiday("memorial",2012);
	 	format memorial12 date9.;

	thanksgiving09 = holiday("thanksgiving",2009);
	 	format thanksgiving09 date9.;
	thanksgiving10 = holiday("thanksgiving",2010);
	 	format thanksgiving10 date9.;
	thanksgiving11 = holiday("thanksgiving",2011);
	 	format thanksgiving11 date9.;
	thanksgiving12 = holiday("thanksgiving",2012);
	 	format thanksgiving12 date9.;

	xmas09 = holiday("christmas",2009);
	 	format xmas09 date9.;
	xmas10 = holiday("christmas",2010);
	 	format xmas10 date9.;
	xmas11 = holiday("christmas",2011);
	 	format xmas11 date9.;
	xmas12 = holiday("christmas",2012);
	 	format xmas12 date9.;

	if weekday(date) in (1 7) then nonworking = 1;

	else if date = labor09 then nonworking =1;
	else if date = labor10 then nonworking =1;
	else if date = labor11 then nonworking =1;
	else if date = labor12 then nonworking =1;

	else if date = july409 then nonworking =1;
	else if date = july410 then nonworking =1;
	else if date = july411 then nonworking =1;
	else if date = july412 then nonworking =1;

	else if date = newyears09 then nonworking =1;
	else if date = newyears10 then nonworking =1;
	else if date = newyears11 then nonworking =1;
	else if date = newyears12 then nonworking =1;

	else if date = mlk09 then nonworking =1;
	else if date = mlk10 then nonworking =1;
	else if date = mlk11 then nonworking =1;
	else if date = mlk12 then nonworking =1;

	else if date = presidents09 then nonworking =1;
	else if date = presidents10 then nonworking =1;
	else if date = presidents11  then nonworking =1;
	else if date = presidents12  then nonworking =1;

	else if date = memorial09 then nonworking =1;
	else if date = memorial10 then nonworking =1;
	else if date = memorial11 then nonworking =1;
	else if date = memorial12 then nonworking =1;

	else if date = thanksgiving09 then nonworking =1;
	else if date = thanksgiving10 then nonworking =1;
	else if date = thanksgiving11 then nonworking =1;
	else if date = thanksgiving12 then nonworking =1;

	else if date = xmas09 then nonworking =1;
	else if date = xmas10 then nonworking =1;
	else if date = xmas11 then nonworking =1;
	else if date = xmas12 then nonworking =1;

	else nonworking = 0;
	
	if month(date) = 1  then month1 = 1; else month1 =0;
	if month(date) = 2  then month2 = 1; else month2 =0;
	if month(date) = 3  then month3 = 1; else month3 =0;
	if month(date) = 4  then month4 = 1; else month4 =0;
	if month(date) = 5  then month5 = 1; else month5 =0;
	if month(date) = 6  then month6 = 1; else month6 =0;
	if month(date) = 7  then month7 = 1; else month7 =0;
	if month(date) = 8  then month8 = 1; else month8 =0;
	if month(date) = 9  then month9 = 1; else month9 =0;
	if month(date) = 10 then month10 = 1; else month10 =0;
	if month(date) = 11 then month11 = 1; else month11 =0;

	weekday = weekday(date);

	if weekday(date) = 1 then monday    = 1; else monday = 0;
	if weekday(date) = 2 then tuesday   = 1; else tuesday = 0;
	if weekday(date) = 3 then wednesday = 1; else wednesday = 0;
	if weekday(date) = 4 then thursday  = 1; else thursday = 0;
	if weekday(date) = 5 then friday    = 1; else friday = 0;

	if hour0 = 1 then hour1 = 1; else hour1 = 0;
	if hour0 = 2 then hour2 = 1; else hour2 = 0;
	if hour0 = 3 then hour3 = 1; else hour3 = 0;
	if hour0 = 4 then hour4 = 1; else hour4 = 0;
	if hour0 = 5 then hour5 = 1; else hour5 = 0;
	if hour0 = 6 then hour6 = 1; else hour6 = 0;
	if hour0 = 7 then hour7 = 1; else hour7 = 0;
	if hour0 = 8 then hour8 = 1; else hour8 = 0;
	if hour0 = 9 then hour9 = 1; else hour9 = 0;
	if hour0 = 10 then hour10 = 1; else hour10 = 0;
	if hour0 = 11 then hour11 = 1; else hour11 = 0;
	if hour0 = 12 then hour12 = 1; else hour12 = 0;
	if hour0 = 13 then hour13 = 1; else hour13 = 0;
	if hour0 = 14 then hour14 = 1; else hour14 = 0;
	if hour0 = 15 then hour15 = 1; else hour15 = 0;
	if hour0 = 16 then hour16 = 1; else hour16 = 0;
	if hour0 = 17 then hour17 = 1; else hour17 = 0;
	if hour0 = 18 then hour18 = 1; else hour18 = 0;
	if hour0 = 19 then hour19 = 1; else hour19 = 0;
	if hour0 = 20 then hour20 = 1; else hour20 = 0;
	if hour0 = 21 then hour21 = 1; else hour21 = 0;
	if hour0 = 22 then hour22 = 1; else hour22 = 0;
	if hour0 = 23 then hour23 = 1; else hour23 = 0;



	drop labor: july4: newyears: mlk: presidents: memorial: thanksgiving: xmas:


%mend;

