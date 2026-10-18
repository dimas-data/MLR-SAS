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

FILENAME REFFILE "&base/graduate_admission1.csv";
PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=work.IMPORT REPLACE;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=work.IMPORT; RUN;

data MLRDATA.GRAD_CLEAN;
	set work.IMPORT(rename=("GRE Score"n=GRE "TOEFL Score"n=TOEFL
		"University Rating"n=UnivRating "Chance of Admit"n=Admit));
	keep GRE TOEFL UnivRating SOP LOR GPA Research Admit;
run;

proc means data=MLRDATA.GRAD_CLEAN NMISS;
	var GRE TOEFL UnivRating SOP LOR GPA Research Admit;
run;
proc means data=MLRDATA.GRAD_CLEAN N MEAN MEDIAN STD MIN MAX MAXDEC=2;
	var GRE TOEFL UnivRating SOP LOR GPA Research Admit;
run;
proc univariate data=MLRDATA.GRAD_CLEAN normal plot;
	var GRE TOEFL SOP LOR GPA Admit;
	histogram / normal;
run;
proc freq data=MLRDATA.GRAD_CLEAN;
	tables UnivRating Research;
run;

proc corr data=MLRDATA.GRAD_CLEAN nosimple;
	var GRE TOEFL UnivRating SOP LOR GPA Research;
run;
proc corr data=MLRDATA.GRAD_CLEAN nosimple best=7;
	var GRE TOEFL UnivRating SOP LOR GPA Research;
	with Admit;
run;
proc sgscatter data=MLRDATA.GRAD_CLEAN;
	matrix Admit Research UnivRating GPA;
run;

proc stdize data=MLRDATA.GRAD_CLEAN out=MLRDATA.GRAD_Z method=std;
	var GRE TOEFL UnivRating SOP LOR GPA;
run;

proc export data=MLRDATA.GRAD_CLEAN(obs=50)
	outfile="&root/data/graduate_admission_sample.csv" dbms=csv replace;
run;