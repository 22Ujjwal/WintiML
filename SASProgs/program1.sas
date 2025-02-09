
proc import datafile="/home/u64129970/SAS_PROGRAMMER_INTERN_ASSESSMENT_01.07.25.xlsx"
    out=work.schedule_data /* storing imported data from 'Schedule' tab into schedule_data */
    dbms=xlsx
    replace; /*Overwrites dataset if pre-existed*/
    sheet="Schedule";
run;


data work.modified_schedule; /*modified_schedule database is created*/
    set work.schedule_data;  /*Reads from schedule_data into modified_schedule*/
    
    /* COURSE_MODALITY_LOCATION condition (-Online) */
    if MODALITY = "Online" then
        COURSE_MODALITY_LOCATION = catx('-', 'COURSE NAME'n, MODALITY);  /* Without Campus for Online */
    else
        COURSE_MODALITY_LOCATION = catx('-', 'COURSE NAME'n, MODALITY, Campus);  /* With Campus for non-Online */
run;


proc sql; /*SQL in Action!*/
    create table work.production_schedule as /*Dataset_created for data manipulation*/
    select 
        'COURSE NAME'n as 'COURSE NAME'n, 
        MODALITY, 
        sum('Seats Used'n) as 'Seats Used'n,  /*Taking Sum*/
        School, 
        Department, 
        Subject, 
        Campus,
        
        /*  # of Closed and Open Sections */
        sum(case when 'Sec Available Status'n = 'Clsd' then 1 else 0 end) as 'Num of Closed Sections (Full)'n,
        sum(case when 'Sec Available Status'n = 'Open' then 1 else 0 end) as 'Num of Open Sections'n,
        
        /* Ensuring unique COURSE_MODALITY_LOCATION */
        case 
            when MODALITY = "Online" then catx('-', 'COURSE NAME'n, MODALITY)
            else catx('-', 'COURSE NAME'n, MODALITY, Campus)
        end as COURSE_MODALITY_LOCATION,
        
        /* Using mean to take average */
        mean('Section Capacity'n) as Ave_Section_Capacity,
        
        /*  if  Sec Available Status is Open >>> then sum of Section Utilization else 0% */
        sum(case when 'Sec Available Status'n = 'Open' then 'Section Utilization %'n else 0 end) as 'Sum Section Utilization Open'n,
        
        /* RUN_DATE from schedule tab to SCHEDULE Run Date in MM/DD/YY*/
        max(RUN_DATE) as 'SCHEDULE Run Date'n format=MMDDYY8. /*8 is width of date including forward slash*/
       
    from work.modified_schedule /*Source dataset*/
    group by 'COURSE NAME'n, MODALITY, School, Department, Subject, Campus; /* Our precious Group*/
quit;


data work.final_schedule;
    set work.production_schedule;
    
    length 'Action Flag'n $ 50; /*To store string character of len 50*/
    
    '80% of AVG Section Cap'n = 0.8 * Ave_Section_Capacity; /* 80% of Average Section Capacity */
    
    /* Projected Sections = ( Sum of Seats Used / 80% of Average Section Capacity) */
    'Projected Section'n = 'Seats Used'n / '80% of AVG Section Cap'n;
    
    
    'Projected Sections'n = ceil('Projected Section'n); /* Round up to the nearest whole number */
    
    /* 'Num of Additional Sections' variable */
    'Num of Additional Sections'n = 'Projected Sections'n - 'Num of Closed Sections (Full)'n - 'Num of Open Sections'n;
    
    /* 'Open Sections Fill Rate' variable */
    if 'Num of Open Sections'n > 0 then 
        'Open Sections Fill Rate'n = ('Sum Section Utilization Open'n /( 'Num of Open Sections'n * 100));
    else 
        'Open Sections Fill Rate'n = .; /* If no open sections >>> blank */
    
    /* Constructing Action Flag based on Open Sections Fill Rate conditions */
   if missing('Open Sections Fill Rate'n) then
        'Action Flag'n = "Build More Sections"; /* If Fill Rate is missing >>> Build more */
    else if 'Open Sections Fill Rate'n < 0.50 then
        'Action Flag'n = "No Action";
    else if 0.50 <= 'Open Sections Fill Rate'n <= 0.70 then
        'Action Flag'n = "Watch-list, closely monitor to build more sections.";
    else if 'Open Sections Fill Rate'n > 0.70 then
        'Action Flag'n = "Build More Sections";
run;

	/* Reordering variables */
proc sql;
    create table work.final_daily_schedule as 
    select 
        COURSE_MODALITY_LOCATION, 
        MODALITY, 
        School, 
        Department, 
        Subject, 
        'COURSE NAME'n, 
        Campus,
        'Seats Used'n, 
        'Num of Closed Sections (Full)'n, 
        'Num of Open Sections'n,
        'Projected Sections'n,
        'Num of Additional Sections'n,
        'Open Sections Fill Rate'n,
        'Action Flag'n,
        'SCHEDULE Run Date'n, 
         Ave_Section_Capacity, 
        '80% of AVG Section Cap'n
    from work.final_schedule;
quit;

	/* Exporting the final dataset */
proc export data=work.final_daily_schedule
    outfile="/home/u64129970/AssessmentQuestion1.xlsx"
    dbms=xlsx 	/*excel file!!*/
    replace;
run;
