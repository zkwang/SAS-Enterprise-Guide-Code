/*
Author:  Kevin Wang (Advanced Analytics)
Program:  Import Statistical Forecast Values + Errors as a Library to Run SQL Code and Analyses
Original Creation Date:  4/4/2017

Create table in WORK to sum up reconciled forecast volumes for the next 6 months
Establish the initial PC9 categorization by volume
*/

%let projectName = LMB_LSA;

/* 
Step 1:  Aggregate past 6 months of forecasts by Planning Group / PC9
Ensure dates are "updated" to the most current
*/
PROC SQL;
	create table WORK.Pc9HistoricError_S1 as
	select RF.PC9,
		RF.planning_group_desc,
		sum(RF.PREDICT) as RecFore6Mnths,
		sum(RF.ACTUAL) as Actual6Mnths,
		sum(abs(RF.ERROR)) as AbsoluteError6Mnths,
		case when sum(RF.ACTUAL) <= 0 then 0 else sum(abs(RF.ERROR)) / sum(RF.ACTUAL) end as MAPE6Mnths,
		sum(RF.ERROR) as AlgBias6Mnths
	from &projectName.RECFOR as RF,
		(select min(FF.date) as FirstForecastDate
		from LMB_LSA.FINALFOR as FF) as FFD
	where RF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
	group by RF.PC9,
		RF.planning_group_desc
	order by planning_group_desc asc, RecFore6Mnths desc;
QUIT;
