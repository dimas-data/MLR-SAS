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

proc reg data=MLRDATA.GRAD_CLEAN;
	model Admit = GRE TOEFL UnivRating SOP LOR GPA Research;
run; quit;

/* Multicollinearity: iterative removal */
proc reg data=MLRDATA.GRAD_CLEAN;
	model Admit = GRE TOEFL UnivRating SOP LOR GPA Research / VIF COLLIN;
run; quit;
proc corr data=MLRDATA.GRAD_CLEAN nosimple best=7;
	var GRE TOEFL UnivRating SOP LOR GPA Research; with Admit;
run;
proc reg data=MLRDATA.GRAD_CLEAN;
	model Admit = GRE UnivRating SOP LOR GPA Research / VIF COLLIN;
run; quit;
proc corr data=MLRDATA.GRAD_CLEAN nosimple best=6;
	var GRE UnivRating SOP LOR GPA Research; with Admit;
run;
proc reg data=MLRDATA.GRAD_CLEAN;
	model Admit = UnivRating SOP LOR GPA Research / VIF COLLIN;
run; quit;
proc corr data=MLRDATA.GRAD_CLEAN nosimple best=5;
	var UnivRating SOP LOR GPA Research; with Admit;
run;
proc reg data=MLRDATA.GRAD_CLEAN;
	model Admit = UnivRating LOR GPA Research / VIF COLLIN;
run; quit;

/* PCA */
ods graphics on / reset=index imagename="pca_variance_scree" imagefmt=png width=800px;
ods listing gpath="&root/reports";
ods output Eigenvectors=work.pca_vec;
proc princomp data=MLRDATA.GRAD_Z n=2 plots=scree;
	var GRE TOEFL UnivRating SOP LOR GPA Research;
run;
ods listing close;
ods graphics off;

/* Factor analysis */
ods output OrthRotFactPat=work.fa_load;
proc factor data=MLRDATA.GRAD_Z method=principal rotate=varimax nfactors=2;
	var GRE TOEFL UnivRating SOP LOR GPA Research;
run;

data work.loadings;
	length Method $4;
	set work.pca_vec(in=a rename=(Prin1=C1 Prin2=C2))
	    work.fa_load(rename=(Factor1=C1 Factor2=C2));
	Method = ifc(a, 'PCA', 'FA');
	keep Method Variable C1 C2;
run;
proc export data=work.loadings outfile="&root/models/factor_loadings.csv" dbms=csv replace;
run;

/* Final MLR */
proc reg data=MLRDATA.GRAD_CLEAN outest=MLRMODEL.regression_fit;
	FINAL: model Admit = UnivRating LOR GPA Research;
run; quit;