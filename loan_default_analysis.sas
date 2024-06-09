
ods escapechar='^';
options nodate colorprinting=yes;
ods graphics / reset=all height=4in width=6in;

proc odstext;
   p "Data Management and Analytics using SAS" / style=[fontweight=bold fontsize=12pt just=c];
   p "Lab Report - I'll pay you back" / style=[fontweight=bold fontsize=12pt just=c];
   p 'Introduction ^{newline 2}' / style=[fontweight=bold fontsize=12pt];
   p 'Background Context ^{newline 2}' / style=[fontweight=bold fontsize=11pt];
   p "The process of applying for and being granted a loan is intricate and deeply rooted in the assessment of risk. 
This risk, primarily the risk of defaulting on a loan, represents a significant concern for financial institutions 
worldwide. In India, the dynamics of this process are particularly complex, given the country's diverse economic 
landscape, which ranges from rural areas with agrarian economies to bustling urban centers with a variety of 
industries. Factors such as annual income, marital status, property ownership, and even the presence of a vehicle 
can offer insights into an applicant's financial stability and reliability. Understanding these variables' influence 
on loan default risk is crucial for banks to make informed decisions, minimizing financial losses and fostering a 
healthy lending environment. ^{newline 2}" / style=[fontsize=10pt];
   p 'Dataset Summary ^{newline 2}' / style=[fontweight=bold fontsize=11pt];
   p "The dataset at hand comprises 100,000 independent records related to loan applications 
within India. It contains 13 variables that provide a comprehensive view of the applicants' financial and personal 
circumstances. These variables include the Applicant ID, Annual Income, Applicant Age, Work Experience, Marital Status, 
House Ownership, Vehicle Ownership, Occupation, Residence City, Residence State, Years in Current Employment, Years in 
Current Residence, and Loan Default Risk. The variables are a mix of numeric (e.g., Annual Income, Applicant Age) and 
character types (e.g., Marital Status, House Ownership), offering a multifaceted perspective on what might influence 
an applicant's likelihood of defaulting on a loan. ^{newline 2}" / style=[fontsize=10pt];
   p 'Questions of Interest ^{newline 2}' / style=[fontweight=bold fontsize=11pt];
   p "This report aims to address several key questions of interest that can elucidate the relationship between applicant 
characteristics and loan default risk:" / style=[fontsize=10pt];
   list / style={liststyletype="decimal" fontsize=10pt};
   item "Is there evidence of a difference in the mean annual income of an applicant between those that own a vehicle and 
those that do not?" / style=[fontsize=10pt];
   item "Is there evidence of a difference in the mean annual income of applicants having different house ownership 
statuses?" / style=[fontsize=10pt];
   item "Fit a regression model with the variable 'Annual_Income' as the response and consider the other variables in 
the dataset as potential explanatory variables, excluding 'Applicant_ID' and 'Loan_Default_Risk'." / style=[fontsize=10pt];
   item "Fit a regression model with the variable 'Loan_Default_Risk' as the response and consider the other variables in 
the dataset as potential explanatory variables, excluding 'Applicant_ID' and 'Applicant_Age'." / style=[fontsize=10pt];
   item "Fit a regression model with 'Loan_Default_Risk' as the response and 'Applicant_Age' as the only explanatory 
variable. How does this model compare to the model from question 4) in terms of out-of-sample predictive 
performance?" / style=[fontsize=10pt];
   end;
   p "Through these analyses, the report aims to offer insights into the factors that significantly affect an applicant's 
income and their risk of defaulting on a loan, providing a basis for more nuanced risk assessment strategies for banks in 
India. ^{newline 2}" / style=[fontsize=10pt];
run;
proc odstext;
   p 'Exploratory Data Analysis ^{newline 2}' / style=[fontweight=bold fontsize=12pt];
   p "Before launching into statistical tests and modelling to answer the questions of interest, it is imperative that we 
first lay the groundwork by analysing the data at hand. Exploring the available variables will point to potentially required 
pre-processing steps, while also providing insights on what modelling choices are appropriate and offering context for 
interpreting our final results. ^{newline 2}" / style=[fontsize=10pt];
run;

/* Importing the dataset */
libname mydata "/courses/dc36fc35ba27fe300/DMASAssessments";
data loan_data;
	set mydata.loaninfo;
run;

%let foot_color = navy;

proc odstext;
   p 'Variable Overview ^{newline 2}' / style=[fontweight=bold fontsize=11pt];
   p "Ensuring the integrity and usability of our dataset is the first step in our exploratory analysis. 
^{newline 2}" / style=[fontsize=10pt];
   p "First of all, we confirm there are no missing values in our data (tables 1–2). ^{newline 2}" / style=[fontsize=10pt];
run;

/* Check for missing values */
proc iml;
   /* Reading Numerical Variables */
   title 'Missing Values Check';
   title2 'Numerical Variables';
   footnote c=&foot_color 'Table 1';
   use loan_data;
   read all var _NUM_ into x[colname=nNames];
   nmiss = countmiss(x, "col");
   n = countn(x, "col");
   close loan_data;
   /* Creating table for numerical variables */
   numCnt = nmiss // n;
   rNames = {"Missing", "Not Missing"};
   print numCnt[r=rNames c=nNames label=""];
run;
proc iml;
   /* Reading Categorical Variables */
   title 'Missing Values Check';
   title2 'Categorical Variables';
   footnote c=&foot_color 'Table 2';
   use loan_data;
   read all var _CHAR_ into x[colname=cNames];
   cmiss = countmiss(x, "col");
   c = countn(x, "col");
   close loan_data;
   /* Creating table for categorical variables */
   catCnt = cmiss // c;
   rNames = {"Missing", "Not Missing"};
   print catCnt[r=rNames c=cNames label=""];
run;

proc odstext;
   p "Next, we inspect the format of the available variables, specifically their type and granularity (table 3). 
^{newline 2}" / style=[fontsize=10pt];
run;

/* Generate table of variable types */
proc contents data=loan_data out=var_types(keep=name type) noprint;
run;

/* Convert type numbers to meaningful type names */
proc sql;
    create table var_types_cleaned as
    select name,
           case
               when type=1 then 'num'
               when type=2 then 'char'
               else 'unknown'
           end as Type
    from var_types;
quit;

/* Generate table with the number of distinct values for each variable */
ods select nlevels;
ods exclude all;
ods output NLevels=var_levels;
proc freq data=loan_data nlevels;
    tables _ALL_ / missing;
run;
ods output close;
ods exclude none; 

/* Clean up the var_levels table to have matching variable names */
proc sql;
    create table var_levels_cleaned as
    select TableVar as name,
           NLevels
    from var_levels;
quit;

/* Join the tables to get a single table with names, types, and number of distinct values */
proc sql;
    create table final_table as
    select a.name,
           a.Type,
           b.NLevels
    from var_types_cleaned as a
    left join var_levels_cleaned as b
    on a.name = b.name;
quit;

/* Display the final table */
title 'Variable Types & Number of Distinct Values';
footnote c=&foot_color 'Table 3';
proc print data=final_table noobs label;
    var name Type NLevels;
run;

/* Clean up */
proc datasets lib=work nolist;
    delete var_types var_types_cleaned var_levels var_levels_cleaned final_table;
quit;

proc odstext;
   p "There are three main points deducted from this inspection:" / style=[fontsize=10pt];
   list / style={liststyletype="decimal" fontsize=10pt};
   item "Since 'Loan_Default_Risk' only has two possible values representing 'yes' or 'no', we will convert it to a 
categorical variable." / style=[fontsize=10pt];
   item "Since 'Applicant_ID' is unique for each data entry and is not relevant to any of the questions of interest, we 
will exclude it from our dataset." / style=[fontsize=10pt];
   item "'Occupation', 'Residence_City', and 'Residence_State' have too many distinct levels to be leveraged for modelling 
purposes, so we will need to bin their levels. Since these variables are nominal, it is not possible to follow a 
thresholding approach. Thus, we will have to look into binning their levels with respect to other variables of interest. 
^{newline 2}" / style=[fontsize=10pt];
   end;
   p "Addressing the first two points is quite straightforward. A sample of the resulting dataset after doing so can be 
seen below (tables 4–5). ^{newline 2}" / style=[fontsize=10pt];
run;

/* Convert binary numeric variable to categorical */
data loan_data;
    /* Rename numerical_var to old_numerical_var */
    set loan_data(rename=(Loan_Default_Risk=Num_Loan_Default_Risk));
    /* Convert old numerical variable to new categorical variable with original name */
    if Num_Loan_Default_Risk = 1 then Loan_Default_Risk = 'Yes';
    else if Num_Loan_Default_Risk = 0 then Loan_Default_Risk = 'No';
run;

/* Remove ID variable */
data loan_data;
    set loan_data;
run;

/* Initial inspection of variables */
title 'Sample of Numerical Variables';
footnote c=&foot_color 'Table 4';
data temp_loan_data(drop=Num_Loan_Default_Risk Applicant_ID);
    set loan_data;
run;
proc print data=temp_loan_data(obs=5) noobs;
   var _NUMERIC_;
run;
title 'Sample of Categorical Variables';
footnote c=&foot_color 'Table 5';
proc print data=loan_data(obs=5) noobs;
   var _CHAR_;
run;

proc odstext;
   p "Next, we will seek to bin 'Occupation', 'Residence_City', and 'Residence_State'. Since these variables are nominal, 
thresholding their levels is not an appropriate approach. Instead, we will apply Greenacre's method to each of the variables with 
respect to our two response variables of interest: 'Annual_Income' and 'Loan_Default_Risk'. Before doing so, it is important to 
consider that the transformation of our data should only use knowledge we can obtain during the preparation and training phases of 
our study. We need to keep a portion of our data unseen to be able to perform accurate model evaluation later on. For this reason, 
we divide our data to two subsets, one for training (80% of the data) and one for testing (20%), and apply Greenacre's clustering 
analysis on the training data alone. We do this twice, once for each response variable, to ensure the training and testing splits 
are stratified correctly. ^{newline 2}" / style=[fontsize=10pt];
   p "We proceed to merge levels of our categorical variables step-by-step in the order indicated by Greenacre's results (tables 6–11), 
as long as R-Square remains greater than 0.8. ^{newline 2}" / style=[fontsize=10pt];
run;

/* Greenacre's method macro */
%macro greenacre_binning(dataset, train_data, variable, cat_variable, footnote);
	/* 	Do clustering analysis */
	proc means data=&train_data noprint nway;
		class &cat_variable;
		var &variable;
	    output out=summary mean=prop;
	run;
	%let cat_name = %sysfunc(tranwrd(&cat_variable, _, %str( )));
	%let tar_name = %sysfunc(tranwrd(%sysfunc(tranwrd(&variable, %quote(Num_), %str( ))), _, %str( )));
	title "Clustering &cat_name levels";
	title2 "with respect to &tar_name";
	footnote c=&foot_color &footnote;
	ods exclude All;  
	ods output clusterhistory=cluster_table;
	proc cluster data=summary method=ward plots (maxpoints=400)=dendrogram(vertical height=rsq) outtree=tree;
		freq _freq_;
		var prop;
	    id &cat_variable;
	run;
	ods output close;
	ods exclude None;
	/* 	Show last entries of cluster history */
	data _null_;
	    if 0 then set cluster_table nobs=nobs;
	    call symputx('nobs', nobs);
	run;
	data last100;
	    set cluster_table nobs=nobs;
	    if _N_ > nobs - 50 then output last100;
	run;
	%if &nobs > 50 %then %do;
	   footnote2 "(total entries &nobs, only the last 50 shown)";
	%end;
	proc print data=last100 noobs;
	run;
	/* 	Create mapping */
	data mapping;
	    set cluster_table;
	    ICluster = cats('CL', put(NumberOfClusters, best.));
	    keep ICluster Idj1 Idj2;
	    if RSquared > 0.8 then do;
	        output;
	    end;
	run;
	/* 	Generate mapping format dynamically */
	proc sql noprint;
	    select catx(' = ', quote(trim(Idj1)), quote(trim(ICluster)))
	    into :format1 separated by ' '
	    from mapping;
	quit;
	proc sql noprint;
	    select catx(' = ', quote(trim(Idj2)), quote(trim(ICluster)))
	    into :format2 separated by ' '
	    from mapping;
	quit;
	%let format_pairs = &format1 &format2;
	proc format;
	    value $clusterf (default=16) &format_pairs;
	run;
	/* 	Apply the format */
	%let new_cat_var = %sysfunc(cats(&cat_variable, _, %sysfunc(scan(&variable, -1, '_'))));
	data new_dataset;
	    set &dataset;
	    &new_cat_var = put(&cat_variable, $clusterf.);
	run;	
	%macro repeat_update(times);
	    %do i = 1 %to &times;
			data new_dataset;
			    set new_dataset;
			    &new_cat_var = put(&new_cat_var, $clusterf.);
			run;
	    %end;
	%mend repeat_update;
	%let MaxNSteps=0;
	proc sql noprint;
	    select count(*)
	    into :MaxNSteps
	    from mapping;
	quit;
	%repeat_update(&MaxNSteps);
	/* 	Replace the dataset */
	data &dataset;
		set new_dataset;
	run;
	/* 	Clean up */
	proc datasets lib=work nolist;
	    delete summary cluster_table updated_data mapping tree new_dataset;
	quit;
%mend greenacre_binning;

/* Divide dataset to train and test for Income response */
proc sort data=loan_data out=loan_data_sort;
	by Annual_Income;
run;
proc surveyselect noprint data=loan_data_sort samprate=.7 outall out=loan_data_sampling;
	strata Annual_Income;
run;
data train(drop=selected SelectionProb SamplingWeight) test(drop=selected SelectionProb SamplingWeight);
	set loan_data_sampling;
	if selected then output train;
	else output test;
run;

/* Apply Greenacre's method */
%greenacre_binning(dataset=loan_data, train_data=train, variable=Annual_Income, cat_variable=Residence_State, footnote='Table 6');
%greenacre_binning(dataset=loan_data, train_data=train, variable=Annual_Income, cat_variable=Occupation, footnote='Table 7');
%greenacre_binning(dataset=loan_data, train_data=train, variable=Annual_Income, cat_variable=Residence_City, footnote='Table 8');

/* Do the same train-test division on the aggregated dataset */
proc sort data = loan_data;
	by Applicant_ID;
run;
proc sort data = loan_data_sampling;
	by Applicant_ID;
run;
data loan_data;
	merge loan_data loan_data_sampling (keep=Applicant_ID selected);
	by Applicant_ID;
run;
data train_income test_income;
	set loan_data;
	if selected then output train_income;
	else output test_income;
	drop selected;
run;
data loan_data;
	set loan_data;
	drop selected;
run;

/* Divide dataset to train and test for Risk response */
proc sort data=loan_data out=loan_data_sort;
	by Loan_Default_Risk;
run;
proc surveyselect noprint data=loan_data_sort samprate=.7 
outall out=loan_data_sampling;
	strata Loan_Default_Risk;
run;
data train(drop=selected SelectionProb SamplingWeight) test(drop=selected SelectionProb SamplingWeight);
	set loan_data_sampling;
	if selected then output train;
	else output test;
run;

/* Apply Greenacre's method */
%greenacre_binning(dataset=loan_data, train_data=train, variable=Num_Loan_Default_Risk, cat_variable=Residence_State, footnote='Table 9');
%greenacre_binning(dataset=loan_data, train_data=train, variable=Num_Loan_Default_Risk, cat_variable=Occupation, footnote='Table 10');
%greenacre_binning(dataset=loan_data, train_data=train, variable=Num_Loan_Default_Risk, cat_variable=Residence_City, footnote='Table 11');

/* Do the same train-test division on the aggregated dataset */
proc sort data = loan_data;
	by Applicant_ID;
run;
proc sort data = loan_data_sampling;
	by Applicant_ID;
run;
data loan_data;
	merge loan_data loan_data_sampling (keep=Applicant_ID selected);
	by Applicant_ID;
run;
data train_risk test_risk;
	set loan_data;
	if selected then output train_risk;
	else output test_risk;
	drop selected;
run;
data loan_data;
	set loan_data;
	drop selected;
run;

/* 	Clean up */
proc datasets lib=work nolist;
    delete loan_data_sort loan_data_sampling train test last100;
quit;

proc odstext;
   p "Finally, we can visualize the distribution of each of our final variables (figures 1–15). There are no visible outliers that 
would require our attention, so we can move on to the next part of our exploratory analysis. ^{newline 2}" / style=[fontsize=10pt];
run;

/* Visualizing the distribution of variables */
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Histogram of Annual Income';
	footnote c=&foot_color 'Figure 1';
	proc sgplot data=loan_data;
		histogram Annual_Income / binwidth=10000;
		xaxis label='Annual Income';
		yaxis label='Frequency';
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Histogram of Applicant Age';
	footnote c=&foot_color 'Figure 2';
	proc sgplot data=loan_data;
		histogram Applicant_Age / binstart=20 binwidth=5;
		xaxis label='Applicant Age';
		yaxis label='Frequency';
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Histogram of Work Experience';
	footnote c=&foot_color 'Figure 3';
	proc sgplot data=loan_data;
		histogram Work_Experience / binwidth=1;
		xaxis label='Work Experience' min=-1 max=21;
		yaxis label='Frequency';
	run;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Histogram of Years in Current Employment';
	footnote c=&foot_color 'Figure 4';
	proc sgplot data=loan_data;
		histogram Years_in_Current_Employment / binwidth=1;
		xaxis label='Years in Current Employment' min=-1 max=15;
		yaxis label='Frequency';
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Histogram of Years in Current Residence';
	footnote c=&foot_color 'Figure 5';
	proc sgplot data=loan_data;
		histogram Years_in_Current_Residence / binstart=10 binwidth=1;
		xaxis label='Years in Current Residence' integer min=9 max=15;
		yaxis label='Frequency' integer max=23;
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Countplot of Loan Default Risk';
	footnote c=&foot_color 'Figure 6';
	proc freq data=loan_data noprint;
	   tables Loan_Default_Risk / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Loan_Default_Risk / response=Percent;
	   xaxis label='Loan Default Risk';
	   yaxis label='Percentage';
	run;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Countplot of Marital Status';
	footnote c=&foot_color 'Figure 7';
	proc freq data=loan_data noprint;
	   tables Marital_Status / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Marital_Status / response=Percent;
	   xaxis label='Marital Status';
	   yaxis label='Percentage';
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Countplot of House Ownership Status';
	footnote c=&foot_color 'Figure 8';
	proc freq data=loan_data noprint;
	   tables House_Ownership / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar House_Ownership / response=Percent;
	   xaxis label='House Ownership';
	   yaxis label='Percentage';
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Countplot of Vehicle Ownership Status';
	footnote c=&foot_color 'Figure 9';
	proc freq data=loan_data noprint;
	   tables Vehicle_Ownership / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Vehicle_Ownership / response=Percent;
	   xaxis label='Vehicle Ownership';
	   yaxis label='Percentage';
	run;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Countplot of Occupation';
	title2 'binned with respect to Annual Income';
	footnote c=&foot_color 'Figure 10';
	proc freq data=loan_data noprint;
	   tables Occupation_Income / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Occupation_Income / response=Percent;
	   xaxis label='Occupation bin';
	   yaxis label='Percentage';
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Countplot of Residence State';
	title2 'binned with respect to Annual Income';
	footnote c=&foot_color 'Figure 11';
	proc freq data=loan_data noprint;
	   tables Residence_State_Income / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Residence_State_Income / response=Percent;
	   xaxis label='Residence State bin';
	   yaxis label='Percentage';
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Countplot of Residence City';
	title2 'binned with respect to Annual Income';
	footnote c=&foot_color 'Figure 12';
	proc freq data=loan_data noprint;
	   tables Residence_City_Income / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Residence_City_Income / response=Percent;
	   xaxis label='Residence City bin';
	   yaxis label='Percentage';
	run;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Countplot of Occupation';
	title2 'binned with respect to Default Risk';
	footnote c=&foot_color 'Figure 13';
	proc freq data=loan_data noprint;
	   tables Occupation_Risk / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Occupation_Risk / response=Percent;
	   xaxis label='Occupation bin';
	   yaxis label='Percentage';
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Countplot of Residence State';
	title2 'binned with respect to Default Risk';
	footnote c=&foot_color 'Figure 14';
	proc freq data=loan_data noprint;
	   tables Residence_State_Risk / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Residence_State_Risk / response=Percent;
	   xaxis label='Residence State bin';
	   yaxis label='Percentage';
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Countplot of Residence City';
	title2 'binned with respect to Default Risk';
	footnote c=&foot_color 'Figure 15';
	proc freq data=loan_data noprint;
	   tables Residence_City_Risk / out=var_counts;
	run;
	proc sgplot data=var_counts;
	   vbar Residence_City_Risk / response=Percent;
	   xaxis label='Residence City bin';
	   yaxis label='Percentage';
	run;
ods layout end;
footnote;

/* Clean up */
proc datasets lib=work nolist;
    delete temp_loan_data var_counts;
quit;

proc odstext;
   p 'Variable Relationships ^{newline 2}' / style=[fontweight=bold fontsize=11pt];
   p "We will now move on to investigating the relationships between our response and exploratory variables. There are 
two response variables, 'Annual_Income' and 'Default_Loan_Risk', dictated by the questions of interest, and each of these 
will need to be studied against the rest of their relevant explanatory variables. We will use the training datasets for the 
following analysis, again to make sure the testing data remain unseen. ^{newline 2}" / style=[fontsize=10pt];
   p "We employ Spearman and Hoeffding correlation metrics to inspect the relationship of 'Annual Income' with the numerical 
explanatory variables (tables 12–13 and figure 16). 'Work_Experience' and 'Years_in_Current_Employment' show significant Spearman 
and Hoeffding correlation, indicating they have monotonic association to 'Annual_Income'. 'Applicant_Age' show significant 
Hoeffding correlation but insignificant Spearman correlation, indicating that it has non-monotonic association to 'Annual_Income'. 
Finally, 'Years_in_Current_Residence' shows insignificant Spearman correlation and marginally significant Hoeffding correlation, 
indicating it has weak non-monotonic association to 'Annual_Income'. ^{newline 2}" / style=[fontsize=10pt];
run;

/* Correlation analysis */
title "Correlation of Annual Income";
title2 "with the numerical explanatory variables";
footnote c=&foot_color 'Tables 12–13';
%let varNames=Applicant_Age Work_Experience Years_in_Current_Employment Years_in_Current_Residence;
ods output spearmancorr=spearman hoeffdingcorr=hoeffding;
ods select SpearmanCorr HoeffdingCorr;
proc corr data=train_income spearman hoeffding;
	var Annual_Income;
	with &varNames;
run;
proc sort data=spearman;
	by variable;
run;
proc sort data=hoeffding;
	by variable;
run;
data coefficients;
    merge spearman(rename=(Annual_Income=scoef PAnnual_Income=spvalue))
          hoeffding(rename=(Annual_Income=hcoef PAnnual_Income=hpvalue));
	by variable;
	scoef_abs=abs(scoef);
	hcoef_abs=abs(hcoef);
run;
proc rank data=coefficients out=coefficients_rank;
	var scoef_abs hcoef_abs;
	ranks ranksp rankho;
run;
/* proc print data=coefficients_rank; */
/* 	var variable ranksp rankho scoef spvalue hcoef hpvalue; */
/* run; */
title "Ranking of the correlation between Annual Income";
title2 "and the numerical explanatory variables";
footnote c=&foot_color 'Figure 16';
proc sgplot data=coefficients_rank;
	scatter y=ranksp x=rankho/datalabel=variable;
    xaxis label="Ranking of abs(hoeffding_coeff)" integer;
    yaxis label="Ranking of abs(spearman_coeff)" integer;
run;

proc odstext;
   p "To inspect the relationship of 'Annual_Income' with the categorical explanatory variables, we construct boxplots (figures 17–22). 
Each boxplot shows the distribution of 'Annual_Income' values for the distinct levels of a relevant categorical variable. There are no 
observable differences for different levels of 'Vehicle_Ownership' and 'Marital_Status', indicating these variables are likely not 
correlated to 'Annual_Income'. For the rest of the variables ('House_Ownership', and the binned 'Occupation', 'Resident_State', and 
'Resident_City'), some levels seem to differ with one another, indicating these are likely correlated to 'Annual_Income'. ^{newline 2}" / style=[fontsize=10pt];
run;

title;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Annual Income by Vehicle Ownership';
	footnote c=&foot_color 'Figure 17';
	proc sgplot data=train_income;
		vbox Annual_Income / category=Vehicle_Ownership;
		xaxis label="Vehicle Ownership";
	    yaxis label="Annual Income";
	run;
	footnote;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Annual Income by House Ownership';
	footnote c=&foot_color 'Figure 18';
	proc sgplot data=train_income;
		vbox Annual_Income / category=House_Ownership;
		xaxis label="House Ownership";
	    yaxis label="Annual Income";
	run;
	footnote;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Annual Income by Marital Status';
	footnote c=&foot_color 'Figure 19';
	proc sgplot data=train_income;
		vbox Annual_Income / category=Marital_Status;
		xaxis label="Marital Status";
	    yaxis label="Annual Income";
	run;
quit;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Annual Income by binned Occupation';
	footnote c=&foot_color 'Figure 20';
	proc sgplot data=train_income;
		vbox Annual_Income / category=Occupation_Income;
		xaxis label="Occupation bin";
	    yaxis label="Annual Income";
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Annual Income by binned Resident City';
	footnote c=&foot_color 'Figure 21';
	proc sgplot data=train_income;
		vbox Annual_Income / category=Residence_City_Income;
		xaxis label="Resident City bin";
	    yaxis label="Annual Income";
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Annual Income by Residence State';
	footnote c=&foot_color 'Figure 22';
	proc sgplot data=train_income;
		vbox Annual_Income / category=Residence_State_Income;
		xaxis label="Residence State bin";
	    yaxis label="Annual Income";
	run;
quit;
ods layout end;
footnote;

proc odstext;
   p "Moving on to 'Loan_Default_Risk', which is our second response variable (categorical, in constrast to 'Annual_Income'), we construct 
boxplots to inspect its relationship with the numerical explanatory variables (figures 23–27). There are no observable differences for 
different levels of 'Annual_Income', 'Applicant_Age', and 'Years_in_Current_Residence', indicating these variables are likely not correlated 
to 'Loan_Default_Risk'. There are however barely observable differences between the levels of 'Work_Experience' and 'Years_in_Current_Employment', 
indicating these variables might be correlated to 'Loan_Default_Risk'. ^{newline 2}" / style=[fontsize=10pt];
run;

ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Loan Default Risk by Annual Income';
	footnote c=&foot_color 'Figure 23';
	proc sgplot data=train_risk;
		hbox Annual_Income / category=Loan_Default_Risk;
		xaxis label="Annual Income";
	    yaxis label="Loan Default Risk";
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Loan Default Risk by Applicant Age';
	footnote c=&foot_color 'Figure 24';
	proc sgplot data=train_risk;
		hbox Applicant_Age / category=Loan_Default_Risk;
		xaxis label="Applicant Age";
	    yaxis label="Loan Default Risk";
	run;
ods region row=1 column=3 width=3.5in height=3.5in;
	title 'Loan Default Risk by Work Experience';
	footnote c=&foot_color 'Figure 25';
	proc sgplot data=train_risk;
		hbox Work_Experience / category=Loan_Default_Risk;
		xaxis label="Work Experience";
	    yaxis label="Loan Default Risk";
	run;
quit;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3.5in height=3.5in;
	title 'Loan Default Risk by Years in Current Employment';
	footnote c=&foot_color 'Figure 26';
	proc sgplot data=train_risk;
		hbox Years_in_Current_Employment / category=Loan_Default_Risk;
		xaxis label="Years_in_Current_Employment";
	    yaxis label="Loan Default Risk";
	run;
ods region row=1 column=2 width=3.5in height=3.5in;
	title 'Loan Default Risk by Years in Current Residence';
	footnote c=&foot_color 'Figure 27';
	proc sgplot data=train_risk;
		hbox Years_in_Current_Residence / category=Loan_Default_Risk;
		xaxis label="Years in Current Residence";
	    yaxis label="Loan Default Risk";
	run;
quit;
ods layout end;
footnote;

proc odstext;
   p "Finally, to inspect the relationship of 'Loan_Default_Risk' with the categorical explanatory variables, we construct heatmaps of 
their pairwise contingency tables (figures 28–33). There are no observable differences for different levels of 'Marital_Status' and 'House_Ownership', 
so these variables are likely not correlated to 'Loan_Default_Risk'. On the other hand, there seems to be a slight difference for the levels of 
'Vehicle_Ownership', and more observable differences for the levels of the binned variables (binned 'Occupation', 'Residence_State', and 'Residence_City'), 
so these variables are likely correlated to 'Loan_Default_Risk'. ^{newline 2}" / style=[fontsize=10pt];
run;

/* Heatmaps of contingency */
%macro contigency_table(dataset, target, explanatory);
	proc freq data=&dataset noprint;
	    tables &target*&explanatory / out=FreqOut;
	run;
	proc sql;
	    create table TotalCounts as
	    select &target, sum(Count) as TotalCount
	    from FreqOut
	    group by &target;
	quit;
	proc sql;
	    create table PercentOut as
	    select a.&target, a.&explanatory, a.Count,
	           (a.Count/b.TotalCount)*100 as Percentage
	    from FreqOut as a
	    inner join TotalCounts as b
	    on a.&target = b.&target;
	quit;
%mend contigency_table;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3in height=4in;
	title "Contingency";
	title2 "Default Risk vs Marital Status";
	footnote c=&foot_color 'Figure 28';
	%contigency_table(dataset=train_risk, target=Loan_Default_Risk, explanatory=Marital_Status);
	proc sgplot data=PercentOut;
	    heatmap x=Loan_Default_Risk y=Marital_Status / colorresponse=Percentage;
	    xaxis label='Loan Default Risk';
	    yaxis label='Marital Status';
	    gradlegend / title='Percentage across Risk';
	run;
ods region row=1 column=2 width=3in height=4in;
	title "Contingency";
	title2 "Default Risk vs House Ownership";
	footnote c=&foot_color 'Figure 29';
	%contigency_table(dataset=train_risk, target=Loan_Default_Risk, explanatory=House_Ownership);
	proc sgplot data=PercentOut;
	    heatmap x=Loan_Default_Risk y=House_Ownership / colorresponse=Percentage;
	    xaxis label='Loan Default Risk';
	    yaxis label='House Ownership';
	    gradlegend / title='Percentage across Risk';
	run;
ods region row=1 column=3 width=3in height=4in;
	title "Contingency";
	title2 "Default Risk vs Vehicle Ownership";
	footnote c=&foot_color 'Figure 30';
	%contigency_table(dataset=train_risk, target=Loan_Default_Risk, explanatory=Vehicle_Ownership);
	proc sgplot data=PercentOut;
	    heatmap x=Loan_Default_Risk y=Vehicle_Ownership / colorresponse=Percentage;
	    xaxis label='Loan Default Risk';
	    yaxis label='Vehicle Ownership';
	    gradlegend / title='Percentage across Risk';
	run;
quit;
ods layout end;
footnote;
ods layout Start columns=3 rows=1 column_gutter=.1in;
ods region row=1 column=1 width=3in height=4in;
	title "Contingency";
	title2 "Default Risk vs binned Occupation";
	footnote c=&foot_color 'Figure 31';
	%contigency_table(dataset=train_risk, target=Loan_Default_Risk, explanatory=Occupation_Risk);
	proc sgplot data=PercentOut;
	    heatmap x=Loan_Default_Risk y=Occupation_Risk / colorresponse=Percentage;
	    xaxis label='Loan Default Risk';
	    yaxis label='Occupation bin';
	    gradlegend / title='Percentage across Risk';
	run;
ods region row=1 column=2 width=3in height=4in;
	title "Contingency";
	title2 "Default Risk vs binned Residence State";
	footnote c=&foot_color 'Figure 32';
	%contigency_table(dataset=train_risk, target=Loan_Default_Risk, explanatory=Residence_State_Risk);
	proc sgplot data=PercentOut;
	    heatmap x=Loan_Default_Risk y=Residence_State_Risk / colorresponse=Percentage;
	    xaxis label='Loan Default Risk';
	    yaxis label='Residence State bin';
	    gradlegend / title='Percentage across Risk';
	run;
ods region row=1 column=3 width=3in height=4in;
	title "Contingency";
	title2 "Default Risk vs binned Residence City";
	footnote c=&foot_color 'Figure 33';
	%contigency_table(dataset=train_risk, target=Loan_Default_Risk, explanatory=Residence_City_Risk);
	proc sgplot data=PercentOut;
	    heatmap x=Loan_Default_Risk y=Residence_City_Risk / colorresponse=Percentage;
	    xaxis label='Loan Default Risk';
	    yaxis label='Residence City bin';
	    gradlegend / title='Percentage across Risk';
	run;
quit;
ods layout end;
footnote;

proc odstext;
   p "It is worth noting that we already expected to observe correlation between the binned variables and the response 
variable that was used for their binning. This is because the merging of their levels was driven by the said variable. 
^{newline 2}" / style=[fontsize=10pt];
run;

/* Clean up */
proc datasets lib=work nolist;
    delete coefficients coefficients_rank spearman hoeffding FreqOut TotalCounts PercentOut;
quit;

proc odstext;
   p 'Formal Analysis ^{newline 2}' / style=[fontweight=bold fontsize=12pt];
   p "Before attempting to answer the questions of interest we should discuss the independence of our data observations; an 
   assumption which all of the methods that will be employed later on have in common. In order to check whether this assumption is 
   reasonable, we consider our study design. The dataset contains information on different loan applicants, therefore the assumption 
   of independence between observations seems reasonable. Some methods will assume that the groups of our categorical variables are 
   independent as well. It is safe to consider that each applicant has a single marital status, house and vehicle ownership 
   status, occupation, and resident city and state. The levels of these variables are distinct and more than one cannot be valid 
   at the same time, so the assumption of independence between groups also appears reasonable. ^{newline 2}" / style=[fontsize=10pt];
   p "We now move on to our questions of interest. ^{newline 2}" / style=[fontsize=10pt];
   p 'Question 1:' / style=[fontweight=bold fontsize=11pt];
   p 'Is there evidence of a difference in the mean annual income of an applicant between those that own a vehicle and those that 
do not? ^{newline 2}' / style=[fontsize=11pt];
   p "Since there are two groups of applicants we are interested in comparing (two distinct levels of 'Vehicle_Ownership'), 
performing a two-sample T-test or a two-way ANOVA seem to be appropriate approaches. However, both of these methods operate on the 
assumption that the group populations are normally distributed. Plotting the group distributions (figure 34) makes it apparent that this 
assumption does not hold. Applying log or square-root transformations does not remedy this either (figures 35–36). ^{newline 2}" / style=[fontsize=10pt];
run;

/* try to normalize the income with common transformations */
data loan_data;
	set loan_data;
	log_Annual_Income = log(Annual_Income);
	sqrt_Annual_Income = sqrt(Annual_Income);
	inv_Annual_Income = 1 / Annual_Income;
run;

/* plot the income distributions */
ods graphics / width=8in height=3in;
title 'Annual Income distribution for Vehicle Ownership groups';
footnote c=&foot_color 'Figure 34';
proc sgpanel data=loan_data;
    panelby Vehicle_Ownership / rows=1 columns=2 onepanel;
    histogram Annual_Income;
    density Annual_Income / type=kernel;
    colaxis label='Annual Income';
run;
title 'Annual Income distribution for Vehicle Ownership groups';
title2 'after log transformation';
footnote c=&foot_color 'Figure 35';
proc sgpanel data=loan_data;
    panelby Vehicle_Ownership / rows=1 columns=2 onepanel;
    histogram log_Annual_Income;
    density log_Annual_Income / type=kernel;
    colaxis label='log of Annual Income';
run;
title 'Annual Income distribution for Vehicle Ownership groups';
title2 'after square-root transformation';
footnote c=&foot_color 'Figure 36';
proc sgpanel data=loan_data;
    panelby Vehicle_Ownership / rows=1 columns=2 onepanel;
    histogram sqrt_Annual_Income;
    density sqrt_Annual_Income / type=kernel;
    colaxis label='sqrt of Annual Income';
run;
ods graphics / reset;

proc odstext;
	p "We will thus opt to perform a Kruskal-Wallis H test (tables 14–16), the non-parametric alternative to ANOVA that does not assume any 
underlying distribution for the populations of interest. Kruskal-Wallis assumptions include: 1) the independence of observations, which 
we have already accepted to be true, and 2) similarly shaped group distributions, which, according to the above plots, 
is also close enough to the truth. ^{newline 2}" / style=[fontsize=10pt];
run;

/*perform Kruskal-Wallis test*/
ods graphics off;
title 'Kruskal-Wallis H test';
title2 'H^{unicode '2082'x}0: Annual Income independent of Vehicle Ownership';
footnote c=&foot_color 'Tables 14–16';
proc npar1way data=loan_data wilcoxon;
    class Vehicle_Ownership;
    var Annual_Income;
run;
ods graphics on;

proc odstext;
	p "The p-value returned from the Kruskal-Wallis test (table 16) is 0.0052 (the Wilcoxon Two-Sample Test shown in table 15 is exactly the same test 
as 'Vehicle_Ownership' contains two groups). Since this value is less than the significance level (considered 0.05), we reject the null hypothesis that 
the mean 'Annual_Income' is the same for all groups of 'Vehicle_Ownership'. This means we have sufficient evidence to conclude that the mean annual 
income is significantly different between those applicants that own a vehicle and those that do not. ^{newline 2}" / style=[fontsize=10pt];
run;

proc odstext;
   p 'Question 2:' / style=[fontweight=bold fontsize=11pt];
   p 'Is there evidence of a difference in the mean annual income of applicants having different house ownership statuses? 
^{newline 2}' / style=[fontsize=11pt];
   p "Since there are three potential house ownership statuses (three distinct levels of 'House_Ownership'), we can consider performing 
a three-way ANOVA test. However, we again observe that the group populations are not normally distributed (figure 37), and common transformations do  
not manage to remedy this (figures 38–39). ^{newline 2}" / style=[fontsize=10pt];
run;

/* plot the income distributions */
ods graphics / width=8in height=3in;
title 'Annual Income distribution for House Ownership groups';
footnote c=&foot_color 'Figure 37';
proc sgpanel data=loan_data;
    panelby House_Ownership / rows=1 columns=3 onepanel;
    histogram Annual_Income;
    density Annual_Income / type=kernel;
run;
title 'Annual Income distribution for House Ownership groups';
title2 'after log transformation';
footnote c=&foot_color 'Figure 38';
proc sgpanel data=loan_data;
    panelby House_Ownership / rows=1 columns=3 onepanel;
    histogram log_Annual_Income;
    density log_Annual_Income / type=kernel;
run;
title 'Annual Income distribution for House Ownership groups';
title2 'after square-root transformation';
footnote c=&foot_color 'Figure 39';
proc sgpanel data=loan_data;
    panelby House_Ownership / rows=1 columns=3 onepanel;
    histogram sqrt_Annual_Income;
    density sqrt_Annual_Income / type=kernel;
run;
ods graphics / reset;

proc odstext;
	p "Therefore, as in the previous question, we will opt to perform a Kruskal-Wallis H test (tables 17–18). Again, its assumptions 
are met since (by our study design) the observations between groups are independent, and (according to the above plots) they seem to 
follow similarly shaped distributions. ^{newline 2}" / style=[fontsize=10pt];
run;

/*perform Kruskal-Wallis test*/
ods graphics off;
title 'Kruskal-Wallis H test';
title2 'H^{unicode '2082'x}0: Annual Income independent for House Ownership groups';
footnote c=&foot_color 'Tables 17–18';
proc npar1way data=loan_data wilcoxon;
    class House_Ownership;
    var Annual_Income;
run;
ods graphics on;

proc odstext;
	p "The p-value returned from the Kruskal-Wallis test (table 18) is <0.0001. Since this is less than the significance level, we reject the 
null hypothesis that the mean 'Annual_Income' is the same for all groups of 'House_Ownership'. This means we have sufficient evidence to conclude 
that the mean annual income is significantly different for applicants with different house ownership statuses. ^{newline 2}" / style=[fontsize=10pt];
    p "To find out which group pairs contribute to this statistical difference, we perform the Dwass, Steel, Critchlow-Fligner (DSCF) multiple comparison 
test (table 19). ^{newline 2}" / style=[fontsize=10pt];
run;

/*perform DSCF*/
title 'DSCF multiple comparison';
title2 'Annual Income of House Ownership groups';
footnote c=&foot_color 'Table 19';
proc npar1way data=loan_data dscf;
    class House_Ownership;
    var Annual_Income;
run;

proc odstext;
    p "The DSCF results indicate that the mean annual income is significantly different between 'rented' and 'norent_n', as well as between 'norent_n' 
and 'owned', since the corresponding p-values are <0.0001, which is lower than the significance level. However, the same cannot be said for the 
comparison between 'rented' and 'owned', since that p-value is 0.8466, which is greater than the significance level. ^{newline 2}" / style=[fontsize=10pt];
run;

proc odstext;
   p 'Question 3:' / style=[fontweight=bold fontsize=11pt];
   p "Fit a regression model with the variable 'Annual_Income' as the response and consider the other variables in the dataset as 
potential explanatory variables, excluding 'Applicant_ID' and 'Loan_Default_Risk'. ^{newline 2}" / style=[fontsize=11pt];
   p "Since we are interested to perform regression for a continuous numerical variable, we can consider fitting a linear regression model (table 22). To 
find the subset of explanatory variables that better explain the response, we perform stepwise model selection (tables 20–21). ^{newline 2}" / style=[fontsize=10pt];
run;

/* Fit regression model to predict Annual_Income */
title "Linear regression for Annual Income response";
%let incomeVars = Applicant_Age Work_Experience Years_in_Current_Residence Years_in_Current_Employment;
%let incomeVarsCat = Marital_Status House_Ownership Vehicle_Ownership Occupation_Income Residence_City_Income Residence_State_Income;	
footnote c=&foot_color 'Tables 20–21';		
ods select SelectionSummary StopDetails;
proc glmselect data=train_income;
	class &incomeVarsCat;
	model Annual_Income=&incomeVars &incomeVarsCat / selection=stepwise showpvalues;
run;

proc odstext;
   p "Examining the stepwise selection summary (tables above), we can see the selected explanatory variables are: 'Residence_City', 'Occupation', and 
'House_Ownership'. The rest of the variables ('Applicant_Age', 'Work_Experience', 'Years_in_Current_Residence', 'Years_in_Current_Employment', 'Marital_Status', 
'Vehicle_Ownership', and 'Residence_State') have been excluded from the model based on the Schwarz's Bayesian information (SBC) criterion. ^{newline 2}" / style=[fontsize=10pt];
   p "It is also worth examining the p-values of the parameter estimates of the selected model (table below). All parameters, except from 'House_Ownership owned' 
(using 'House_Ownership rented' as a baseline, since its parameter estimate is 0), have p-values lower than the significance level, which indicates they are 
contributing to the regression significantly. ^{newline 2}" / style=[fontsize=10pt];
run;

footnote c=&foot_color 'Table 22';		
ods select ParameterEstimates;
proc glmselect data=train_income;
	class &incomeVarsCat;
	model Annual_Income=&incomeVars &incomeVarsCat / selection=stepwise showpvalues;
run;

proc odstext;
   p "There are two main points worth noticing from comparing the regression's results with the results of the statistical tests that were 
performed in the previous questions of interest:" / style=[fontsize=10pt];
   list / style={fontsize=10pt};
   item "Even though in question 1 we concluded that 'Annual_Income' is significantly different for distinct values of 'Vehicle_Ownership', 
'Vehicle_Ownership' was excluded as insignificant in the 'Annual_Income' model selection we just performed." / style=[fontsize=10pt];
   item "In aggreement with the conclusions of question 2, 'House_Ownership' is included in the regression model as significant, and the 
difference between its distinct levels is deemed significant with the exception of 'owned' vs 'rented'." / style=[fontsize=10pt];
   end;
   p "The first contradiction gives us reason to doubt the results of our regression analysis." / style=[fontsize=10pt];
run;
  
proc odstext;   
   p "We should not forget that there are some general assumptions we need to consider when fitting a linear regression model. The residual errors 
of the model should be independent, which is true according to the observation independence of our study design, but we also need to ensure that 
the errors are normally distributed, with zero mean and constant variance. According to our regression diagnostics (figures 40–42), this is 
far from the truth. ^{newline 2}" / style=[fontsize=10pt];
run;

ods graphics / width=4in height=3in;
title "Linear Regression Diagnostics";
footnote c=&foot_color 'Figures 40–42';
ods select QQPlot ResidualHistogram ResidualByPredicted;
proc glm data=train_income plots(maxpoints=None)=diagnostics(unpack);
	class &incomeVarsCat;
	model Annual_Income=&incomeVars &incomeVarsCat;
run;
quit;
ods graphics / reset;

proc odstext;
   p "Examining the plot of the residuals against the predicted values (figure 40), the residuals' mean seems to approximate zero, but the variance is not 
constant, indicating heteroscedasticity. This inconsistency in variance, and the discernible pattern within the residuals, suggest that our model may not fully 
capture the underlying relationship between the response and the explanatory variables, possibly overlooking a nonlinear association or missing key variables. 
Other than that, the QQ-plot (figure 41), while closely aligned with the diagonal, exhibits heavy tails. This deviation from the expected normal distribution, 
suggests our residuals do not meet the normality assumption. This is further confirmed by the plot of the residuals' distribution (figure 42), which appears 
more uniform-like rather than normal. Based on these observations, the suitability of linear regression to answer our question of interest is questionable. 
It might be useful to explore model adjustments (for example, variable transformations and alternative model selection methods), or to opt for an altogether 
different modelling solution. ^{newline 2}" / style=[fontsize=10pt];
run;

proc odstext;
   p 'Question 4:' / style=[fontweight=bold fontsize=11pt];
   p "Fit a regression model with the variable 'Loan_Default_Risk' as the response and consider the other variables in the dataset as potential explanatory 
variables, excluding 'Applicant_ID' and 'Applicant_Age'. ^{newline 2}" / style=[fontsize=11pt];
   p "Since our response variable in this case is categorical, we can consider fitting a logistic regression model (table 24). To find the subset of 
explanatory variables that better explain the response, we perform stepwise model selection (table 23). ^{newline 2}" / style=[fontsize=10pt];
run;

/* Fit logistic regression model to predict Loan_Default_Risk + Evaluate ROC */
title "Logistic regression for Loan Default Risk response";
title2 'considering all explanatory variables except Applicant Age';
footnote c=&foot_color 'Tables 23–24';
%let incomeVars = Annual_Income Work_Experience Years_in_Current_Residence Years_in_Current_Employment;
%let incomeVarsCat = Marital_Status House_Ownership Vehicle_Ownership Occupation_Risk Residence_City_Risk Residence_State_Risk;	
ods select ModelBuildingSummary CLOddsPL;		   /* ROCCurve */
proc logistic data=train_risk plots(only)=(oddsratio);          /* roc */
	class &incomeVarsCat;
	model Loan_Default_Risk(ref='Yes')=&incomeVars &incomeVarsCat / clodds=pl selection=stepwise;
	score data=test_risk out=testAssess(rename=(p_Yes=p_complex));
run;

proc odstext;
   p "Examining the stepwise selection summary (table 23), we can see the selected explanatory variables are: 'Residence_City', 'Occupation', 'Vehicle_Ownership', 
'House_Ownership', 'Marital_Status', 'Work_Experience', 'Years_in_Current_Employment', and 'Residence_State'. In other words, only 'Annual_Income' and 
'Years_in_Current_Residence' have been excluded from the model, based on the chi-square statistic. ^{newline 2}" / style=[fontsize=10pt];
   p "It is also worth examining the odds ratio estimates and the corresponding confidence intervals (table 24). From the odds ratio estimates we can draw 
conclusions like: applicants who own their home are ~1.6 times more likely to not default on their loan compared to those who rent, applicants who do not own a 
vehicle are ~0.6 times less likely to not default on their loan, etc. Morevoer, we can observe that, of all the confidence intervals, only 
'Residence_State_Risk CL7 vs CL8' contains 1, indicating that an applicant coming from the 'CL8' group of residence states rather than the 'CL7' might not be 
significant in predicting whether they will default on their loan. ^{newline 2}" / style=[fontsize=10pt];
run;

proc odstext;
   p 'Question 5:' / style=[fontweight=bold fontsize=11pt];
   p "Fit a regression model with 'Loan_Default_Risk' as the response and 'Applicant_Age' as the only explanatory variable. How does this model compare to the model 
from question 4) in terms of out-of-sample predictive performance? ^{newline 2}" / style=[fontsize=11pt];
   p "To address this question, we shall again fit a logistic regression model, this time using 'Applicant_Age' as the only explanatory variable (tables 25–26). 
^{newline 2}" / style=[fontsize=10pt];
run;

/* Fit another logistic regression model to predict Loan_Default_Risk + Evaluate ROC */
title "Logistic regression for Loan Default Risk response (only Applicant Age)";
footnote c=&foot_color 'Tables 25–26';
ods select ParameterEstimates CLOddsPL;		
proc logistic data=train_risk plots(only)=(oddsratio);
	model Loan_Default_Risk(ref='Yes')=Applicant_Age / clodds=pl;
	score data=testAssess out=testAssess(rename=(p_Yes=p_simple));
run;

proc odstext;
   p "Based on the returned chi-square p-value of 'Applicant_Age' (table 25), which is <0.0001 and thus lower than the significance level, this variable seems to 
be significant in predicting the response. The same is indicated by the corresponding confidence interval, since it does not contain 1 (table 26). ^{newline 2}" / style=[fontsize=10pt];
   p "Furthermore, examining the odds ratio of 'Applicant_Age', which is found to be 1.004, we can conclude that for every one-year increase in applicant age, 
the odds of defaulting on their loan increase by a factor of 1.004. This is very close to having the same likelihood of defaulting regardless of age, so we can 
expect that 'Applicant_Age' is not a strong predictor of 'Loan_Default_Risk' on its own (even though it is still likely to contribute valuable information). ^{newline 2}" / style=[fontsize=10pt];
run;

proc odstext;
   p "We will finish our analysis by comparing the out-of-sample predictive performance of the simple model we just fitted with the more complex 
'Loan_Default_Risk' model we fitted in the previous question of interest. To do this, we construct and examine their ROC (Receiver Operating Characteristic) 
curve plots (figure 43) and perform a ROC contrast chi-square test (table 27). ^{newline 2}" / style=[fontsize=10pt];
run;

/* Compare ROCs for the two logistic regression models */
title "Comparing the two logistic regression models";
footnote c=&foot_color 'Figure 43 & Table 27';
%let _ROCOVERLAY_ENTRYTITLE = ROC Curves for the Models;
ods select ROCContrastTest ROCOverlay;		
proc logistic data=testAssess;
	model Loan_Default_Risk(ref='Yes')=p_complex p_simple / nofit;
	roc "Complex Model" p_complex;
	roc "Simple Model" p_simple;
/* 	  ods select ROCOverlay; */
	roccontrast "Comparing Models";
run;
%symdel _ROCOVERLAY_ENTRYTITLE;

proc odstext;
   p "We can observe that the p-value returned by the chi-square test (above table) is <0.0001, which is lower than the significance level, indicating that 
there is a significant difference in the performance of the two models. Furthermore, the AUC (Area Under Curve) value for the more complex model is 0.6586 while 
the AUC for the simple model is 0.5182 (above figure), indicating that the complex model performs better on the test dataset. ^{newline 2}" / style=[fontsize=10pt];
run;

/* Clean up */
proc datasets lib=work nolist;
    delete testAssess _SGSRT2_;
quit;

proc odstext;
   p 'Conclusion ^{newline 2}' / style=[fontweight=bold fontsize=12pt];
   p "In this lab report we delved into the complex process of loan application and risk assessment. Our study aimed to unravel the relationship between 
applicant characteristics and the risk of loan default, employing a comprehensive dataset of 100,000 loan application records in India. Through an extensive 
exploratory data analysis and formal statistical testing, we pursued answers to five critical questions concerning applicants' annual income, house and vehicle 
ownership status, and the factors influencing their loan default risk. ^{newline 2}" / style=[fontsize=10pt];
   p "Our findings reveal significant insights into the financial behavior and risk profile of loan applicants. Firstly, we uncovered a discernible difference 
in the mean annual income between applicants based on vehicle ownership, with vehicle owners showcasing a higher income level. Similarly, applicants' house 
ownership status was found to significantly affect their annual income, indicating variances in financial stability across different ownership categories. 
Further, our regression analyses shed light on the factors affecting annual income and loan default risk. The model predicting annual income pinpointed 
residence city, occupation, and house ownership as significant predictors, albeit with a notable exclusion of vehicle ownership contrary to our initial 
findings. This discrepancy suggests complexities in the relationship between vehicle ownership and annual income that the regression model could not capture. 
On the other hand, the logistic regression model for loan default risk identified a broader set of explanatory variables, emphasizing the multifaceted nature of 
default risk beyond mere financial metrics. The comparison between models predicting the loan default risk highlighted applicant age as a weak predictor when 
considered in isolation. Incorporating more explanatory variables, the predictive performance notably improved, as evidenced by the ROC curve analysis. This 
underscores the importance of a multidimensional approach in assessing loan default risk, where individual characteristics interplay to form a comprehensive risk 
profile. ^{newline 2}" / style=[fontsize=10pt];
   p "In conclusion, our study underscores the pivotal role of data analytics in financial risk assessment, providing valuable insights for banks to refine their 
loan approval processes. The distinct impact of house and vehicle ownership on applicants' financial profiles, along with the multifactorial nature of loan default 
risk, calls for a nuanced approach in evaluating loan applications. By integrating these findings, financial institutions can enhance their risk management 
strategies, fostering a more stable and inclusive lending environment. ^{newline 2}" / style=[fontsize=10pt];
run;

ods _all_ close;
