%let base = /home/u64054454/Sem3;
%let root = &base/MLR-SAS;

data _null_;
	a = dcreate('MLR-SAS', "&base");
	b = dcreate('data',    "&root");
	c = dcreate('models',  "&root");
	d = dcreate('reports', "&root");
run;

libname MLRDATA  "&root/data";
libname MLRMODEL "&root/models";

ods graphics on;
ods pdf file="&root/reports/model_diagnostics.pdf" style=journal;

proc reg data=MLRDATA.GRAD_CLEAN;
	model Admit = UnivRating LOR GPA Research / DW;
	output out=work.DiagData p=Predicted r=Residuals;
run; quit;

proc univariate data=work.DiagData normal;
	var Residuals;
	qqplot Residuals / normal(mu=est sigma=est);
run;

proc model data=MLRDATA.GRAD_CLEAN;
	parms B0 B1 B2 B3 B4;
	Admit = B0 + B1*UnivRating + B2*LOR + B3*GPA + B4*Research;
	fit Admit / pagan=(1 UnivRating LOR GPA Research);
run; quit;

proc arima data=work.DiagData;
	identify var=Residuals nlag=20;
run; quit;

data work.DiagObs;
	set work.DiagData;
	obs_num = _N_;
run;
title 'Residuals vs Observation Order (Sequence Plot)';
proc sgplot data=work.DiagObs;
	scatter x=obs_num y=Residuals;
	refline 0 / axis=y lineattrs=(color=red thickness=2);
	xaxis label='Observation number'; yaxis label='Residuals';
run;

title 'Residuals vs Fitted Values';
proc sgplot data=work.DiagData;
	scatter x=Predicted y=Residuals;
	refline 0 / axis=y lineattrs=(color=red thickness=2);
	xaxis label='Predicted Value (Fitted Value)'; yaxis label='Residuals';
run;

title 'Observed vs Fitted Values';
proc sgplot data=work.DiagData;
	scatter x=Predicted y=Admit;
	lineparm x=0 y=0 slope=1 / lineattrs=(color=red thickness=2 pattern=solid);
	xaxis label='Predicted Value'; yaxis label='Observed Value (Chance of Admittance)';
run;

data work.CalcErr;
	set work.DiagData;
	SqError = Residuals**2;
	AbsError = abs(Residuals);
	if Admit = 0 then do; PctError=.; AbsPctError=.; end;
	else do;
		PctError = Residuals/Admit*100;
		AbsPctError = abs(Residuals/Admit)*100;
	end;
run;
proc sql;
	create table work.ErrorSummary as
	select 'RMSE' as Metric length=30, sqrt(mean(SqError)) as Value from work.CalcErr
	union all select 'MAE',  mean(AbsError)    from work.CalcErr
	union all select 'MPE',  mean(PctError)    from work.CalcErr
	union all select 'MAPE', mean(AbsPctError) from work.CalcErr;
quit;
title 'Model Error Measures';
proc print data=work.ErrorSummary noobs label;
	label Metric='Error Measure' Value='Calculated Value';
	format Value best8.6;
run;

proc score data=MLRDATA.GRAD_CLEAN score=MLRMODEL.regression_fit out=work.Scored type=parms predict;
	var UnivRating LOR GPA Research;
run;
title 'Scoring check (first 5 rows): FINAL should equal Predicted';
proc print data=work.Scored(obs=5) noobs; var Admit FINAL; run;

title;
ods pdf close;
ods graphics off;