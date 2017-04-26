
/* Library Locations */

libname LWB_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/LEV_WOM_BOT/hierarchy/PC9";
libname LMB_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/LEV_MEN_BOT/hierarchy/PC9";

libname DMB_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/DOC_MEN_BOT/hierarchy/PC9";

libname DZM_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/DEN_MEN_BOT/hierarchy/PC9";
libname DZW_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/DEN_WOM_BOT/hierarchy/PC9";
libname DZB_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/DEN_BOY_BOT/hierarchy/PC9";

libname SIM_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/SIG_MEN_BOT/hierarchy/PC9";
libname SIW_LSA "/opt/sas/config/Lev1/AppData/SASForecastServer14.2/Projects/SIG_WOM_BOT/hierarchy/PC9";


/* Project Names */

%let projectName_LFW = LWB_LSA;
%let projectName_LFM = LMB_LSA;

%let projectName_DFM = DMB_LSA;

%let projectName_DZM = DZM_LSA;
%let projectName_DZW = DZW_LSA;
%let projectName_DZB = DZB_LSA;

%let projectName_SIM = SIM_LSA;
%let projectName_SIW = SIW_LSA;









PROC SQL;
	create table WORK.TYLYComp_LFW as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths		

	from 
		&projectName_LFW..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_LFW..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;


PROC SQL;
	create table WORK.TYLYComp_LFM as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_LFM..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_LFM..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;


PROC SQL;
	create table WORK.TYLYComp_DFM as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_DFM..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_DFM..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;


PROC SQL;
	create table WORK.TYLYComp_DZM as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_DZM..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_DZM..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;

PROC SQL;
	create table WORK.TYLYComp_DZW as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_DZW..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_DZW..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;
PROC SQL;
	create table WORK.TYLYComp_DZB as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_DZB..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_DZB..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;

PROC SQL;
	create table WORK.TYLYComp_SIM as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_SIM..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_SIM..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;

PROC SQL;
	create table WORK.TYLYComp_SIW as

	select 
		mid_name_1,
		mid_name_2,
		mid_name_3,
		mid_name_4,
		mid_name_5,
		mid_name_6,
		affiliate_ch,
		planning_group_desc,
		substr(PC9,1,5) as PC5,
		PC9,
		sum(case
				when FF.date between FFD.FirstForecastDate and FFD.FirstForecastDate + 180
					then ff.predict
					else 0
				end) as TYfcst,
		sum(case
				when FF.date between FFD.FirstForecastDate - 364 and FFD.FirstForecastDate - 364 + 180
					then ff.actual
					else 0	
				end) as LYactual,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.predict
					else 0
				 end) as Forecast6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.actual
					else 0
				 end) as Actual6Mnths,
		sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end) as AlgError6Mnths,
		abs(sum(case
				when FF.date between FFD.FirstForecastDate - 180 and FFD.FirstForecastDate
					then FF.error
					else 0
				 end)) as AbsError6Mnths
	from 
		&projectName_SIW..RECFOR as FF,
		(select min(FFA.date) as FirstForecastDate
			from &projectName_SIW..FINALFOR as FFA) as FFD

	group by 
		1,2,3,4,5,6,7,8,9,10

	order by  
		TYfcst desc;

QUIT;

PROC SQL;

create table WORK.All_Brands_IP as

	SELECT * FROM WORK.TYLYComp_LFW
	UNION ALL
	SELECT * FROM WORK.TYLYComp_LFM
	UNION ALL
	SELECT * FROM WORK.TYLYComp_DFM
	UNION ALL
	SELECT * FROM WORK.TYLYComp_DZM
	UNION ALL
	SELECT * FROM WORK.TYLYComp_DZW
	UNION ALL
	SELECT * FROM WORK.TYLYComp_DZB
	UNION ALL
	SELECT * FROM WORK.TYLYComp_SIM
	UNION ALL
	SELECT * FROM WORK.TYLYComp_SIW;

QUIT;