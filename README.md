
This project was developed for the 'Data Management and Analytics using SAS' course, part of the MSc in Data Analytics at the University of Glasgow in 2024. It contains a comprehensive analysis of loan default risk using data from loan applications. The objective of the analysis is to assess various factors—such as annual income, marital status, house and vehicle ownership, occupation, and more—that might influence an applicant's likelihood of defaulting on a loan.

## Project Context
The primary goal of the project was to demonstrate proficiency in using SAS for data management and analytics, adhering to standard statistical methodologies outlined in the course (t-tests, ANOVA, ANCOVA, linear regression, and logistic regression). The emphasis was placed not on achieving the most optimal analytical results but on showcasing these specific methods in action.

## Dataset
The dataset, `loaninfo.sas7bdat`, encompasses 100,000 records, each representing an individual loan application, with 13 variables that include:
- **Applicant_ID**: Numeric, ID of the applicant.
- **Annual_Income**: Numeric, applicant's annual income in USD.
- **Applicant_Age**: Numeric, age of the applicant.
- **Work_Experience**: Numeric, total years of work experience.
- **Marital_Status**: Character, marital status (single or married).
- **House_Ownership**: Character, property status (rented, owned, or neither).
- **Vehicle_Ownership**: Character, indicates if the applicant owns a vehicle.
- **Occupation**: Character, applicant's occupation.
- **Residence_City**: Character, city of residence.
- **Residence_State**: Character, state of residence.
- **Years_in_Current_Employment**: Numeric, years in the current job.
- **Years_in_Current_Residence**: Numeric, years in the current residence.
- **Loan_Default_Risk**: Numeric, risk of loan default (1 = Yes, 0 = No).

## Analysis Objectives
The analysis addresses the following questions:
1. The difference in mean annual income between applicants who own a vehicle and those who do not.
2. The association between applicants' annual income and their house ownership status.
3. Regression analysis with "Annual_Income" as the response variable, excluding "Applicant_ID" or "Loan_Default_Risk".
4. Regression analysis with "Loan_Default_Risk" as the response variable, considering all variables except "Applicant_ID" or "Applicant_Age".
5. Regression analysis exploring the predictive power of "Applicant_Age" on "Loan_Default_Risk", compared to the more comprehensive model of question 4.

## Analysis Sections
The entire analysis is conducted in a single SAS script file, which includes code, comments, and interpretation of results. The script is organized into the following sections:
- **Introduction**: Background on the dataset and outline of the analysis objectives.
- **Exploratory Analysis**: Initial impressions of relationships between variables and any data manipulation performed.
- **Formal Analysis**: Detailed statistical analysis, including tests and model fitting, with thorough interpretation of results.
- **Conclusion**: Summary of main findings, addressing the analysis objectives.
