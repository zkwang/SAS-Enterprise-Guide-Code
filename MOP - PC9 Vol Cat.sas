/*
Author:  Kevin Wang (Advanced Analytics)
Program:  Import Statistical Forecast Values + Errors as a Library to Run SQL Code and Analyses
Original Creation Date:  3/22/2017

Create table in WORK to sum up reconciled forecast volumes for the next 6 months
Establish the initial PC9 categorization by volume
*/

%let projectName = LSA_LWB;

/* 
Step 1:  Aggregate forward 6 months of volume by Planning Group / PC9
Ensure data is sorted by Planning Group and RecFore6Mnths to ensure ranking function works
Ensure dates are "updated" to the most current
*/
PROC SQL;
	create table WORK.Pc9Cat_S1 as
	select FF.PC9,
		FF.affiliate_ch,
		sum(FF.PREDICT) as RecFore6Mnths
	from &projectName..FINALFOR as FF
	where FF.date between 20695 and 20876
	group by FF.PC9,
		FF.affiliate_ch
	order by affiliate_ch asc, RecFore6Mnths desc;
QUIT;

/*
Step 2:  Rank PC9s within the data set and produce a new table with ranking information
*/
PROC RANK data=WORK.Pc9Cat_S1 out=WORK.Pc9Cat_S2 ties=low descending;
	by affiliate_ch;
	var RecFore6Mnths;
	ranks RecFore6MnthsRank;
RUN;

/*
Step 3:  Compute the % sum by Planning Group for each PC9
*/
PROC SQL;
	create table WORK.Pc9Cat_S3 as
	select 
		Pc9Cat_S2.PC9,
		Pc9Cat_S2.affiliate_ch,
		Pc9Cat_S2.RecFore6Mnths,
		Pc9Cat_S2.RecFore6Mnths / PGTotal.PGTotal6Mnths as RecPrctOfTotal
	from Pc9Cat_S2 inner join
		(select affiliate_ch,
			sum(RecFore6Mnths) as PGTotal6Mnths
		from Pc9Cat_S2
		group by affiliate_ch) as PGTotal
		on (Pc9Cat_S2.affiliate_ch = PGTotal.affiliate_ch);
QUIT;

/*
Step 4:  Compute the cumulative % total by Planning Group for each PC9
*/

DATA WORK.Pc9Cat_S4;
	set WORK.Pc9Cat_S3;
	by affiliate_ch notsorted;
	if first.affiliate_ch then SumOfRecPrctOfTotal = 0;
		SumOfRecPrctOfTotal + RecPrctOfTotal;
RUN;

/*
Step 5:  Categorize PC9s into the appropriate volume bucket
*/

PROC SQL;
	create table Pc9Cat_S5_&projectName as
	select 
		Pc9,
		affiliate_ch,
		RecFore6Mnths,
		case when SumOfRecPrctOfTotal < 0.8 then 'High'
			when SumOfRecPrctOfTotal >= 0.95 then 'Low'
			else 'Medium' end as Pc9VolCategorization
	from Pc9Cat_S4
QUIT;

