/*
Author:  Kevin Wang (Advanced Analytics)
Name:  PC9 Volume Categorization
Program:  Import PC9 information and categorize each PC9 into the appropriate volume buckets
Original Creation Date:  4/3/2017

Key Considerations in the Code:
1.  Looks @ forward 6 months of forecasts to determine best volume categorization
2.  Compute the trailing 6 months of forecast error to determine best model accuracy
3.  Volume categorizations will be determined for the MOP
*/

%let IPprojectName = IP_LWB;
%let MOPprojectName = MOP_LWB;
%let highVolThreshold = 0.8;
%let lowVolThreshold = 0.95;
%let highRiskThreshold = 0.4;
%let lowRiskThreshold = 0.1;

/*
Categorize PC9 into appropriate volume buckets

Step 1:  Aggregate forward 6 months of volume by Affiliate Channel / PC9
Ensure data is sorted by Planning Group and RecFore6Mnths to ensure ranking function works
*/

PROC SQL;
	create table WORK.Pc9Cat_S1 as
	select 
		FF.PC9,
		FF.affiliate_ch,
		sum(FF.PREDICT) as RecFore6Mnths
	from 
		&MOPprojectName..FINALFOR as FF,
		(select min(FF.date) as FirstForecastDate
		from &MOPprojectName..FINALFOR as FF) as FFD
	where 
		FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
	group by 
		FF.PC9, FF.affiliate_ch
	order by 
		affiliate_ch asc, RecFore6Mnths desc;
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
	from 
		Pc9Cat_S2 inner join
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
	create table Pc9Cat_S5_&MOPprojectName as
	select 
		Pc9,
		affiliate_ch,
		RecFore6Mnths,
		case when SumOfRecPrctOfTotal < &highVolThreshold then 'High'
			when SumOfRecPrctOfTotal >= &lowVolThreshold then 'Low'
			else 'Medium' end as Pc9VolCategorization
	from Pc9Cat_S4;
QUIT;

/*
Compute trailing 6 months of forecast error

Step 1:  Aggregate past 6 months of forecasts by Planning Group / PC9
Ensure dates are "updated" to the most current
*/
PROC SQL;
	create table WORK.Pc9HistoricError_S1 as
	select 
		RF.PC9,
		RF.affiliate_ch,
		sum(RF.PREDICT) as RecFore6Mnths,
		sum(RF.ACTUAL) as Actual6Mnths,
		sum(abs(RF.ERROR)) as AbsoluteError6Mnths,
		case when sum(RF.ACTUAL) <= 0 then 0 else sum(abs(RF.ERROR)) / (sum(RF.ACTUAL)) end as MAPE6Mnths,
		sum(RF.ERROR) as AlgBias6Mnths
	from 
		&MOPprojectName..RECFOR as RF,
		(select min(FF.date) as FirstForecastDate
		from &MOPprojectName..FINALFOR as FF) as FFD
	where 
		RF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
	group by 
		RF.PC9,
		RF.affiliate_ch
	order by 
		affiliate_ch asc, RecFore6Mnths desc;
QUIT;

/*
Step 2:  Classify each PC9 per Planning Group into the appropriate category
*/

PROC SQL;
	create table WORK.Pc9HistoricError_S2_&MOPprojectName as
	select 
		Pc9,
		affiliate_ch,
		case when AlgBias6Mnths < 0 then 'Under Bias'
			when AlgBias6Mnths > 0 then 'Over Bias'
			else 'No Bias' end as BiasFlag,
		case when MAPE6Mnths > 0.4 then 'High'
			when MAPE6Mnths <= 0.1 then 'Low'
			else 'Medium' end as PriorityFlag
	from Pc9HistoricError_S1;
QUIT;

/*
Compare MOP to Item Plan

Step 1:  Aggregate Item Plan forecasts to a affiliate/channel and PC9 level of detail
*/

PROC SQL;
	create table IP_AGG_S1 as 
	select 
		OF.mid_name_5 as Class,
		OF.mid_name_6 as SubClass,
		OF.mid_7 as PC5,
		OF.affiliate_ch,
		OF.PC9,
		sum(OF.PREDICT) as ForePrediction,
		sum(RF.PREDICT) as RecPrediction,
		sum(FF.PREDICT) as FinalPrediction
	from
		&IPprojectName..OUTFOR as OF 
		inner join &IPprojectName..RECFOR as RF on 
			(OF.PC9 = RF.PC9 and OF.date = RF.date and OF.planning_group_desc = RF.planning_group_desc and OF.affiliate_ch = RF.affiliate_ch)
		inner join &IPprojectName..FINALFOR as FF on
			(OF.PC9 = FF.PC9 and OF.date = FF.date and OF.planning_group_desc = FF.planning_group_desc and OF.affiliate_ch = FF.affiliate_ch),
		(select min(FF.date) as FirstForecastDate
		from &IPprojectName..FINALFOR as FF) as FFD
	where 
		OF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
	group by 
		OF.mid_name_5,
		OF.mid_name_6,
		OF.mid_7,
		OF.affiliate_ch,
		OF.PC9;
QUIT;

/*
Step 2:  Aggregate MOP forecasts to a affiliate/channel and PC9 level of detail
*/

PROC SQL;
	create table MOP_AGG_S1 as 
	select 
		OF.mid_name_5 as Class,
		OF.mid_name_6 as SubClass,
		OF.mid_7 as PC5,
		OF.affiliate_ch,
		OF.PC9,
		sum(OF.PREDICT) as ForePrediction,
		sum(RF.PREDICT) as RecPrediction,
		sum(FF.PREDICT) as FinalPrediction
	from
		&MOPprojectName..OUTFOR as OF 
		inner join &MOPprojectName..RECFOR as RF on 
			(OF.PC9 = RF.PC9 and OF.date = RF.date and OF.affiliate_ch = RF.affiliate_ch)
		inner join &MOPprojectName..FINALFOR as FF on
			(OF.PC9 = FF.PC9 and OF.date = FF.date and OF.affiliate_ch = FF.affiliate_ch),
		(select min(FF.date) as FirstForecastDate
		from &MOPprojectName..FINALFOR as FF) as FFD
	where 
		OF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
	group by 
		OF.mid_name_5,
		OF.mid_name_6,
		OF.mid_7,
		OF.affiliate_ch,
		OF.PC9;
QUIT;

/*
Step 3:  Merge the IP and MOP Aggregate files into a single table
*/

PROC SQL;
	create table MOP_IP_MERGE as
	select 
		IP.Class,
		IP.SubClass,
		IP.PC5,
		IP.affiliate_ch,
		IP.PC9 as IP_PC9,
		IP.ForePrediction as IP_ForePrediction,
		IP.RecPrediction as IP_RecPrediction,
		IP.FinalPrediction as IP_FinalPrediction,
		MOP.PC9 as MOP_PC9,
		MOP.ForePrediction as MOP_ForePrediction,
		MOP.RecPrediction as MOP_RecPrediction,
		MOP.FinalPrediction as MOP_FinalPrediction
	from 
		IP_AGG_S1 as IP
		left join MOP_AGG_S1 as MOP on
			(IP.PC9 = MOP.PC9 and IP.affiliate_ch = MOP.affiliate_ch);
QUIT;