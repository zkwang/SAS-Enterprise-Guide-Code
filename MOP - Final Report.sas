/*
Author:  Kevin Wang (Advanced Analytics)
Program:  Merge the Volume Analysis + the Error Analysis
Original Creation Date:  4/4/2017

Create table in WORK to sum up reconciled forecast volumes for the next 6 months
Establish the initial PC9 categorization by volume
*/

%let projectName = LSA_LWB;

PROC SQL;
	create table WORK.&projectName._FINAL_REPORT as
	select 
		CAT.PC9,
		CAT.affiliate_ch,
		CAT.PC9VolCategorization,
		HIS.BiasFlag,
		HIS.PriorityFlag,
		CAT.RecFore6Mnths
	from	
		WORK.PC9CAT_S5_&projectName as CAT
		inner join WORK.PC9HISTORICERROR_S2_&projectName as HIS on 
			(CAT.PC9 = HIS.PC9 and CAT.affiliate_ch = HIS.affiliate_ch);
QUIT;