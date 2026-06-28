/* PART 2 EDA  */

/* 			Momen Khaled Hasan Rumash The Numerical & Cost Attributes    */
/* this block of code is for the table that demonstrates the Statistics for Patient Age*/
proc means data=ASSIGN.healthcare_raw 
    N MIN MAX MEAN MEDIAN VAR SKEW P25 P50 P75; 
    VAR Age;
    TITLE "Table 1: Descriptive Statistics for Patient Age";
RUN;




/* this block of code is for the table that demonstrates the Statistics for Billing Amount*/
proc means data=ASSIGN.healthcare_raw 
    N MIN MAX MEAN MEDIAN VAR SKEW P25 P50 P75; 
    VAR 'Billing Amount'n;
    TITLE "Table 2: Descriptive Statistics for Billing Amount";
RUN;




/* this block of code is for the table that demonstrates the Statistics using univariate for Billing Amount & Age*/
proc univariate data=ASSIGN.healthcare_raw;
    VAR Age; 
run ;

proc univariate data=ASSIGN.healthcare_raw ;
    VAR 'Billing Amount'n; 
run;




/* now for the visualization part */
/* age distribution histogram */
/* This visually confirms the Symmetrical/Normal distribution  */
proc sgplot data=ASSIGN.healthcare_raw;
    histogram Age / fillattrs=(color=LIGB) ;
    density Age / type=NORMAL lineattrs=(color=RED THICKNESS=2) ;
    title "Visualization of the Distribution of Patient Age";
    xaxis label="Age (Years)";
    yaxis LABEL="Frequency" ;
RUN ;




/*  billing amount box plot */
/* This is CRUCIAL for showing the negative outliers (-$2008)  */
proc sgplot data=ASSIGN.healthcare_raw ;
    vbox 'Billing Amount'n / datalabel ;
    title "Visualization of Billing Amount Outlier Detection";
    yaxis label="Total Bill Amount ($)" ;
run;









/* 			Ahmed Rudwan The Operations & Quality Attributes       */
/*to see the contents of the dataset*/
proc contents data=ASSIGN.healthcare_raw;

/*To check the correlation between numerical variables*/
proc corr data=ASSIGN.healthcare_raw;
run;    /*end of code*/

/* Create year variable for finding admission trend */
data work.yearly;
    set ASSIGN.healthcare_raw;
    admit_year = year('Date of admission'n);
run; /*end of code*/	

proc sql;  /* to check yearly admission trend*/ 
    create table work.yearly_counts as
    select admit_year, count(*) as admissions
    from work.yearly
    group by admit_year
    order by admit_year;
quit;  /*end of code*/

proc sgplot data=work.yearly_counts;
    series x=admit_year y=admissions / markers;
    xaxis label="Year";
    yaxis label="Number of Admissions";
    title "Yearly Admission Trend";
run;   /*end of code*/

/*the frequencey of insurance provider*/
proc freq data=ASSIGN.healthcare_raw;
    tables 'Insurance Provider'n / nocum;
run; /*end of code*/

/*creates a variable named admit_month for months*/
proc format;
   value month_order
      1 = 'January'   2 = 'February'  3 = 'March'
      4 = 'April'     5 = 'May'       6 = 'June'
      7 = 'July'      8 = 'August'    9 = 'September'
      10 = 'October'  11 = 'November' 12 = 'December';
run;
data work.monthly;
    set ASSIGN.healthcare_raw;
    admit_month = month('Date of admission'n);
run;  /*end of code*/


/*creating a diagram for monthly admission trend*/
proc sql;
    create table work.monthly_counts as
    select admit_month,
           count(*) as admissions
    from work.monthly
    group by admit_month
    order by admit_month;
quit;
proc sgplot data=work.monthly_counts;
    series x=admit_month y=admissions / markers;
    format admit_month month_order.;
    xaxis label="Month" integer values=(1 to 12 by 1);
    yaxis label="Number of Admissions";
    title "Monthly Admission Trend (January–December)";
run;   	/*end of code*/


proc corr data=ASSIGN.healthcare_raw;       /*to see the correlation between date of admission and dicharge date*/
var 'Date of admission'n  'Discharge date'n;
run; 	/*end of code*/

proc sgplot data=ASSIGN.healthcare_raw;    /*admissions per insurance provider*/
    vbar 'Insurance Provider'n;
    xaxis label="Insurance Provider";
    yaxis label="Number of Admissions";
    title "Admissions by Insurance Provider";
run;   /*end of code*/








/* 			Ahmed Samir The Patient Demographic Attributes       */
/* Frequency Analysis */
proc freq data=ASSIGN.healthcare_raw;
    tables Gender 
           'Blood Type'n 
           'Medical Condition'n / nocum;
run;
* Frequency Analysis;


/* Mode Identification */
proc freq data=ASSIGN.healthcare_raw noprint;
    tables 'Medical Condition'n / out=cond_freq;
run;

proc sort data=cond_freq;
    by descending count;
run;

proc print data=cond_freq(obs=1);
run;
* Print Mode;


/* Bar Chart */
proc sgplot data=ASSIGN.healthcare_raw;
    vbar 'Medical Condition'n / datalabel;
    title "Distribution of Medical Conditions";
run;
* Bar Chart;


/* Gender Pie Chart */
proc gchart data=ASSIGN.healthcare_raw;
    pie Gender;
run;
quit;
* Pie Chart;


/* Blood Type Pie Chart */
proc gchart data=ASSIGN.healthcare_raw;
    pie 'Blood Type'n;
run;
quit;
* Pie Chart;












/* 			Shaik Nazeefa The Clinic & Results Attributes      */
proc freq data=ASSIGN.healthcare_raw;
   tables "Admission Type"n;
run;


PROC FREQ DATA=ASSIGN.healthcare_raw;
   TABLES "Test Results"n;
RUN;


Proc sgplot data=ASSIGN.healthcare_raw;
    vbar "Medical Condition"n / group=Medication groupdisplay=stack;
Run;

















/* PART 3 Preprocessing Techniques   */

data ASSIGN.healthcare_step1;
    set ASSIGN.healthcare_raw;
    
    /* FIXING TEXT STUFF - mostly propcase */
    
    Name = propcase(Name);
    Gender = PROPCASE(strip(Gender));
    
    /* Blood type needs to be all caps though */
    'Blood Type'n = upcase(strip('Blood Type'n));
    
    'Medical Condition'n = Propcase(strip('Medical Condition'n));
    Doctor = propcase(strip(Doctor));
    Hospital = PROPCASE(strip(Hospital));
    
    'Insurance Provider'n = propcase(STRIP('Insurance Provider'n));
    'Admission Type'n = Propcase(strip('Admission Type'n));
    Medication = propcase(strip(Medication));
    'Test Results'n = propcase(strip('Test Results'n));
    
    
    /* -- numbers and formatting -- */
    
    'Billing Amount'n = round('Billing Amount'n, 0.01);
    
    /* apply the dollar format */
    FORMAT 'Billing Amount'n DOLLAR12.2;
    
run;



/* Check for missing values in the cleaned dataset */
PROC MEANS DATA=ASSIGN.healthcare_step1 N NMISS;
    TITLE "Missing Value Summary - Cleaned Dataset";
RUN;




/* Now clean the data based on validation rules */
data ASSIGN.healthcare_step2;
    set ASSIGN.healthcare_step1; /* Using the formatted table from the previous step */

    /* 1. Age Outliers: Must be biologically possible (1 to 120) */
    if Age <= 0 or Age > 120 then delete;

    /* 2. Gender Validation: Ensure only Male/Female exists for modeling consistency */
    if not (Gender in ('Male', 'Female')) then delete;

    /* 3. Financial/Infrastructure Logic: Billing and Room must be positive */
    /* This removes the -$2008.49 error identified in the EDA */
    if 'Billing Amount'n <= 0 then delete;
    if 'Room Number'n    <= 0 then delete;

    /* 4. Temporal Logic: Discharge cannot be before Admission */
    if 'Discharge Date'n < 'Date of Admission'n then delete;

run;






/* 		REMOVING DUPLICATE RECORDS		*/
/* LAYER 1: First here we're gonna kill the exact duplicates where every column matches */
proc sort data=ASSIGN.healthcare_step2 
          out=ASSIGN.temp_step1 
          nodupkey;
    by _ALL_;
run;

/* LAYER 2: here we're filtering by Patient Identity & Admission 
   Checking Name, Age, Gender, Date of Admission, and Medical Condition */
PROC SORT DATA=ASSIGN.temp_step1 
          OUT=ASSIGN.temp_step2 
          NODUPKEY;
    by Name Age Gender "Date of Admission"n 'Medical Condition'n;
run;

/* LAYER 3: lastlt, narrowing down by specific admission episode
   Same Name + Admission/Discharge dates + Condition + Hospital */
proc sort data=ASSIGN.temp_step2 
          out=ASSIGN.healthcare_cleaned 
          nodupkey;
    BY Name "Date of Admission"n "Discharge Date"n 'Medical Condition'n Hospital;
run;

/* Cleaning up the library - removing the temp tables used above */
proc datasets library=ASSIGN nolist;
    delete temp_step1 temp_step2;
quit;


















/*==============================================================================
  DATA TRANSFORMATION 
  
  Techniques used here:
  1. Feature Engineering (Analytical Variables)
  2. Label Encoding
  3. Min-Max Normalization
==============================================================================*/

/*		TECHNIQUE 1: FEATURE ENGINEERING (ANALYTICAL VARIABLES)  */
data ASSIGN.healthcare_transformed;
    set ASSIGN.healthcare_cleaned;
    
    /* Calculate Length of Stay */
    Length_of_Stay = intck('DAY', 'Date of Admission'n, 'Discharge Date'n);
    
    /* Sanity check: if they were admitted/discharged same day, 
       set stay to 1 so we don't divide by zero later */
    if Length_of_Stay < 1 then Length_of_Stay = 1;
    
    /* Calculate how much they are being billed per day */
    Billing_Per_Day = 'Billing Amount'n / Length_of_Stay;
    
    label Length_of_Stay = "Length of Stay (Days)"
          Billing_Per_Day = "Daily Billing Rate";
    format Billing_Per_Day dollar12.2;
run;





/*			TECHNIQUE 2: LABEL ENCODING		*/
data ASSIGN.healthcare_transformed;
    set ASSIGN.healthcare_transformed;
    
    /* Gender: Binary encoding - simple 0/1 split */
    if Gender = 'Male' then Gender_Encoded = 0;
    else if Gender = 'Female' then Gender_Encoded = 1;
    
    /* Admission Type: Ordinal encoding (Elective to Emergency) */
    if 'Admission Type'n = 'Elective' then Admission_Encoded = 0;
    else if 'Admission Type'n = 'Urgent' then Admission_Encoded = 1;
    else if 'Admission Type'n = 'Emergency' then Admission_Encoded = 2;
    
    /* Test Results: Ordinal encoding for model consistency */
    if 'Test Results'n = 'Normal' then Test_Encoded = 0;
    else if 'Test Results'n = 'Inconclusive' then Test_Encoded = 1;
    else if 'Test Results'n = 'Abnormal' then Test_Encoded = 2;
run;







/*		TECHNIQUE 3: MIN-MAX NORMALIZATION		*/
/* First, calculate the min and max for Length_of_Stay */
proc means data=ASSIGN.healthcare_transformed noprint;
    var Length_of_Stay;
    output out=WORK.stay_minmax(drop=_TYPE_ _FREQ_)
           min(Length_of_Stay)=Min_Stay 
           max(Length_of_Stay)=Max_Stay;
run;

/* Apply min-max normalization to scale Length_of_Stay to [0,1] range */
data ASSIGN.healthcare_transformed;
    set ASSIGN.healthcare_transformed;
    if _n_=1 then set WORK.stay_minmax;
    
    /* Min-Max Normalization formula: (X - min) / (max - min) */
    Stay_Normalized = (Length_of_Stay - Min_Stay) / (Max_Stay - Min_Stay);
    
    label Stay_Normalized = "Normalized Length of Stay (0-1 scale)";
    
    /* Drop the temporary min/max variables */
    drop Min_Stay Max_Stay;
run;

















/*==============================================================================
  DATA REDUCTION 
  
  Strategy: Remove redundancy and high-cardinality variables
==============================================================================*/
data ASSIGN.healthcare_final;
    set ASSIGN.healthcare_transformed;
    
    keep 
        /* Identifier */
        Name
        
        /* Core numeric variables */
        Age
        'Billing Amount'n
        
        /* New features we built earlier */
        Length_of_Stay           /* Keep original (interpretable) */
        Stay_Normalized          /* Keep normalized (for modeling) */
        Billing_Per_Day
        
        /* Dates */
        'Date of Admission'n
        
        /* Originals (not encoded yet) */
        'Blood Type'n
        'Medical Condition'n
        'Insurance Provider'n
        Hospital
        
        /* Numeric encodings (dropping original text for these) */
        Gender_Encoded
        Admission_Encoded
        Test_Encoded
    ;
run;













