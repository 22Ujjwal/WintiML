	/* Importing Data */
proc import datafile="/home/u64129970/SAS_PROGRAMMER_INTERN_ASSESSMENT_01.07.25.xlsx" 
    out=retention_data     /*Find & Change the above file location, Thanks!*/
    dbms=xlsx
    replace;
    sheet="Retention"; 
    getnames=yes;      /* Using the first row as column names */
run;

	/*Data Cleaning*/
data retention_cleaned;
    set retention_data;
    if cmiss(of _all_) = 0; /* Keep rows where no missing values exist */
run;

	/*Data Manipulation */
data retention_prepared;
    set retention_cleaned;

    /* Converting to binary */
    if FIRST_YEAR_RETENTION = "Y" then FIRST_YEAR_RETENTION_BINARY = 1;
    else if FIRST_YEAR_RETENTION = "N" then FIRST_YEAR_RETENTION_BINARY = 0;

    if TRANSFER_STUDENT = "Y" then TRANSFER_BINARY = 1;
    else if TRANSFER_STUDENT = "N" then TRANSFER_BINARY = 0;

    if FIRST_GENERATION = "Y" then FIRSTGEN_BINARY = 1;
    else if FIRST_GENERATION = "N" then FIRSTGEN_BINARY = 0;

    if PELL_ELIGIBILITY = "Y" then PELL_BINARY = 1;
    else if PELL_ELIGIBILITY = "N" then PELL_BINARY = 0;

    if GENDER = "Female" then GENDER_BINARY = 1; 
    else if GENDER = "Male" then GENDER_BINARY = 0;

 
    FAMILY_INCOME = input(FAMILY_INCOME, 8.); /*8 is width*/

    /* curtailed school_names (for ease) */
    select (SCHOOL);
        when ("School of Technology") Schools = "Tech";
        when ("School of Business") Schools = "Business";
        when ("School of Liberal Arts") Schools = "libA";
        when ("School of Health Science") Schools = "healthS";
        when ("School of Math&Science") Schools = "mathS";
        when ("School of Engineering") Schools = "engr";
        otherwise Schools = "Other";
    end;
run;

	/* Ordering variables */
data retention_final;
    set retention_prepared;
    keep Schools FIRST_TERM_GPA FAMILY_INCOME HIGH_SCHOOL_GPA 
         TRANSFER_BINARY FIRSTGEN_BINARY PELL_BINARY GENDER_BINARY 
         FIRST_YEAR_RETENTION_BINARY ;
run;

	/*Data Delivered*/
	
	/*Statistical Analysis*/
	
	/* Linear Regression with 
		FIRST_TERM_GPA 
		FAMILY_INCOME 
		HIGH_SCHOOL_GPA >>> */
	
proc reg data=retention_final;
    model FIRST_YEAR_RETENTION_BINARY = FIRST_TERM_GPA FAMILY_INCOME HIGH_SCHOOL_GPA;
    title "Linear Regression: FIRST_YEAR_RETENTION_BINARY --- FIRST_TERM_GPA, FAMILY_INCOME, HIGH_SCHOOL_GPA";
    output out=reg_output predicted=pred_reg;
run;

proc sgscatter data=retention_final;
    compare y=FIRST_YEAR_RETENTION_BINARY x=(FIRST_TERM_GPA FAMILY_INCOME HIGH_SCHOOL_GPA) / reg;
    title "Scatter Plots with Regression Lines: Numerical Predictors vs. Retention";
run;

	/* Logistic Regression with 
		TRANSFER_BINARY 
		FIRSTGEN_BINARY 
		PELL_BINARY 
		GENDER_BINARY >>> */
		
	
	/*Initial Logistic Regression for Prediction*/	
proc logistic data=retention_final;
    model FIRST_YEAR_RETENTION_BINARY(event='1') = TRANSFER_BINARY FIRSTGEN_BINARY PELL_BINARY GENDER_BINARY;
    title "Logistic Regression: FIRST_YEAR_RETENTION_BINARY --- TRANSFER_BINARY, FIRSTGEN_BINARY, PELL_BINARY, GENDER_BINARY ";
    output out=logit_output predicted=pred;
run;


	/* Logistic Regression for ORs&D : Odds Ratios and Diagnostics */

proc logistic data=retention_final;
    model FIRST_YEAR_RETENTION_BINARY(event='1') = TRANSFER_BINARY FIRSTGEN_BINARY PELL_BINARY GENDER_BINARY;
    ods output OddsRatios=odds_ratios;
    ods output ParameterEstimates=param_estimates; 
run;


proc print data=odds_ratios;
    title "Odds Ratios Table: Logistic Regression";
run;

proc print data=param_estimates;
    title "Parameter Estimates Table: Logistic Regression";
run;


	/*Final Logistic Regression for a Different Predict Output Variable*/
proc logistic data=retention_final;
    model FIRST_YEAR_RETENTION_BINARY(event='1') = TRANSFER_BINARY FIRSTGEN_BINARY PELL_BINARY GENDER_BINARY;
    output out=logit_output predicted=pred_prob; /*Here*/
run;


	/* Bar Charts : Logistic Regression */
proc sgplot data=logit_output;
    vbar TRANSFER_BINARY / response=pred_prob group=FIRST_YEAR_RETENTION_BINARY stat=mean datalabel;
    title " Logistic Regression: Average Predicted Probability by TRANSFER_BINARY";
run;

proc sgplot data=logit_output;
    vbar FIRSTGEN_BINARY / response=pred_prob group=FIRST_YEAR_RETENTION_BINARY stat=mean datalabel;
    title " Logistic Regression: Average Predicted Probability by FIRSTGEN_BINARY";
run;

proc sgplot data=logit_output;
    vbar PELL_BINARY / response=pred_prob group=FIRST_YEAR_RETENTION_BINARY stat=mean datalabel;
    title " Logistic Regression: Average Predicted Probability by PELL_BINARY";
run;

proc sgplot data=logit_output;
    vbar GENDER_BINARY / response=pred_prob group=FIRST_YEAR_RETENTION_BINARY stat=mean datalabel;
    title " Logistic Regression: Average Predicted Probability by GENDER_BINARY";
run;

	/* Concise combined Report of 35 observations */
proc print data=reg_output (obs=35);
    title "Linear Regression Predicted Values (First 35 Observations)";
run;

proc print data=logit_output (obs=35);
    title "Logistic Regression Predicted Probabilities (First 35 Observations)";
run;


/* Export Final Dataset to Excel */
proc export data=retention_final
    outfile="/home/u64129970/AssessmentQ2_Final.xlsx"
    dbms=xlsx 	/* Excel file */
    replace;
run;
