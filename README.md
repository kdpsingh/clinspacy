
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clinspacy

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

The goal of clinspacy is to perform biomedical named entity recognition,
Unified Medical Language System (UMLS) concept mapping, and negation
detection using the Python spaCy, scispacy, and medspacy packages.

## Installation

You can install the GitHub version of clinspacy
with:

``` r
remotes::install_github('ML4LHS/clinspacy', INSTALL_opts = '--no-multiarch')
```

## How to load clinspacy

``` r
library(clinspacy)
library(magrittr) # For the pipe %>%
#> Warning: package 'magrittr' was built under R version 3.6.3
```

## Initiating clinspacy

Initiating clinspacy is optional. If you do not initiate the package
using `clinspacy_init()`, it will be automatically initiated without the
UMLS linker. The UMLS linker takes up \~12 GB of RAM, so if you would
like to use the linker, you can initiate clinspacy with the linker. The
linker can still be added on later by reinitiating with the `use_linker`
argument set to
`TRUE`.

``` r
clinspacy_init() # This is optional! The default functionality is to initiatie clinspacy without the UMLS linker
#> Initializing clinspacy using clinspacy_init()...
#> Checking if miniconda is installed...
#> Importing spacy...
#> Importing scispacy...
#> Importing medspacy modules...
#> Loading the en_core_sci_lg language model...
```

## Named entity recognition (without the UMLS linker)

The `clinspacy()` function can take a single string, a character vector,
or a data frame. It can output either a data frame or a file name.

### A single character string as input

``` r
clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#>   |                                                                                                         |                                                                                                 |   0%  |                                                                                                         |=================================================================================================| 100%
#>   id      entity       lemma is_family is_historical is_hypothetical is_negated is_uncertain section_title
#> 1  1     patient     patient     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 2  1    diabetes    diabetes     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 3  1 CKD stage 3 ckd stage 3     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 4  1         HTN         htn     FALSE         FALSE           FALSE       TRUE        FALSE          <NA>
#>   cui confidence
#> 1  NA         NA
#> 2  NA         NA
#> 3  NA         NA
#> 4  NA         NA

clinspacy('HISTORY: He presents with chest pain. PMH: HTN. MEDICATIONS: This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved. ALLERGIES: penicillin.', verbose = FALSE)
#>   |                                                                                                         |                                                                                                 |   0%
#>    id      entity      lemma is_family is_historical is_hypothetical is_negated is_uncertain
#> 1   1  chest pain chest pain     FALSE          TRUE           FALSE      FALSE        FALSE
#> 2   1         PMH        PMH     FALSE         FALSE           FALSE      FALSE        FALSE
#> 3   1         HTN        htn     FALSE         FALSE           FALSE      FALSE        FALSE
#> 4   1 MEDICATIONS medication     FALSE         FALSE           FALSE      FALSE        FALSE
#> 5   1     patient    patient     FALSE         FALSE           FALSE      FALSE        FALSE
#> 6   1    diabetes   diabetes     FALSE         FALSE           FALSE      FALSE        FALSE
#> 7   1  omeprazole omeprazole     FALSE         FALSE           FALSE      FALSE        FALSE
#> 8   1     aspirin    aspirin     FALSE         FALSE           FALSE      FALSE        FALSE
#> 9   1  lisinopril lisinopril     FALSE         FALSE           FALSE      FALSE        FALSE
#> 10  1   albuterol  albuterol     FALSE         FALSE           FALSE       TRUE        FALSE
#> 11  1      asthma     asthma     FALSE         FALSE           FALSE       TRUE        FALSE
#> 12  1   ALLERGIES  allergies     FALSE         FALSE           FALSE      FALSE        FALSE
#> 13  1  penicillin penicillin     FALSE         FALSE           FALSE      FALSE        FALSE
#>           section_title cui confidence
#> 1                  <NA>  NA         NA
#> 2  past_medical_history  NA         NA
#> 3  past_medical_history  NA         NA
#> 4           medications  NA         NA
#> 5           medications  NA         NA
#> 6           medications  NA         NA
#> 7           medications  NA         NA
#> 8           medications  NA         NA
#> 9           medications  NA         NA
#> 10          medications  NA         NA
#> 11          medications  NA         NA
#> 12            allergies  NA         NA
#> 13            allergies  NA         NA
```

### A character vector as input

``` r
clinspacy(c('This pt has CKD and HTN', 'Pt only has CKD but no HTN'),
          verbose = FALSE)
#>   |                                                                                                         |                                                                                                 |   0%
#>   id entity lemma is_family is_historical is_hypothetical is_negated is_uncertain section_title cui
#> 1  1    CKD   ckd     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 2  1    HTN   htn     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 3  2     Pt    pt     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 4  2    CKD   ckd     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 5  2    HTN   htn     FALSE         FALSE           FALSE       TRUE        FALSE          <NA>  NA
#>   confidence
#> 1         NA
#> 2         NA
#> 3         NA
#> 4         NA
#> 5         NA
```

### A data frame as input

``` r
data.frame(text = c('This pt has CKD and HTN', 'Diabetes is present'),
           stringsAsFactors = FALSE) %>%
  clinspacy(df_col = 'text', verbose = FALSE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   |                                                                                                         |                                                                                                 |   0%
#>   id   entity    lemma is_family is_historical is_hypothetical is_negated is_uncertain section_title cui
#> 1  1      CKD      ckd     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 2  1      HTN      htn     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 3  2 Diabetes Diabetes     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>  NA
#> 4  2     <NA>     <NA>        NA            NA              NA         NA           NA          <NA>  NA
#>   confidence
#> 1         NA
#> 2         NA
#> 3         NA
#> 4         NA
```

### Saving the output to file

The `output_file` can then be piped into `bind_clinspacy()` or
`bind_clinspacy_embeddings()`. This saves a lot of time because you can
try different strategies of subsetting in both of these functions
without needing to re-process the original data.

``` r
if (!dir.exists(rappdirs::user_data_dir('clinspacy'))) {
  dir.create(rappdirs::user_data_dir('clinspacy'), recursive = TRUE)
}

mtsamples = dataset_mtsamples()

mtsamples[1:5,]
#>   note_id                                                      description          medical_specialty
#> 1       1 A 23-year-old white female presents with complaint of allergies.       Allergy / Immunology
#> 2       2                         Consult for laparoscopic gastric bypass.                 Bariatrics
#> 3       3                         Consult for laparoscopic gastric bypass.                 Bariatrics
#> 4       4                                             2-D M-Mode. Doppler. Cardiovascular / Pulmonary
#> 5       5                                               2-D Echocardiogram Cardiovascular / Pulmonary
#>                               sample_name
#> 1                       Allergic Rhinitis
#> 2 Laparoscopic Gastric Bypass Consult - 2
#> 3 Laparoscopic Gastric Bypass Consult - 1
#> 4                  2-D Echocardiogram - 1
#> 5                  2-D Echocardiogram - 2
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            transcription
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    SUBJECTIVE:,  This 23-year-old white female presents with complaint of allergies.  She used to have allergies when she lived in Seattle but she thinks they are worse here.  In the past, she has tried Claritin, and Zyrtec.  Both worked for short time but then seemed to lose effectiveness.  She has used Allegra also.  She used that last summer and she began using it again two weeks ago.  It does not appear to be working very well.  She has used over-the-counter sprays but no prescription nasal sprays.  She does have asthma but doest not require daily medication for this and does not think it is flaring up.,MEDICATIONS: , Her only medication currently is Ortho Tri-Cyclen and the Allegra.,ALLERGIES: , She has no known medicine allergies.,OBJECTIVE:,Vitals:  Weight was 130 pounds and blood pressure 124/78.,HEENT:  Her throat was mildly erythematous without exudate.  Nasal mucosa was erythematous and swollen.  Only clear drainage was seen.  TMs were clear.,Neck:  Supple without adenopathy.,Lungs:  Clear.,ASSESSMENT:,  Allergic rhinitis.,PLAN:,1.  She will try Zyrtec instead of Allegra again.  Another option will be to use loratadine.  She does not think she has prescription coverage so that might be cheaper.,2.  Samples of Nasonex two sprays in each nostril given for three weeks.  A prescription was written as well.
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        PAST MEDICAL HISTORY:, He has difficulty climbing stairs, difficulty with airline seats, tying shoes, used to public seating, and lifting objects off the floor.  He exercises three times a week at home and does cardio.  He has difficulty walking two blocks or five flights of stairs.  Difficulty with snoring.  He has muscle and joint pains including knee pain, back pain, foot and ankle pain, and swelling.  He has gastroesophageal reflux disease.,PAST SURGICAL HISTORY:, Includes reconstructive surgery on his right hand 13 years ago.  ,SOCIAL HISTORY:, He is currently single.  He has about ten drinks a year.  He had smoked significantly up until several months ago.  He now smokes less than three cigarettes a day.,FAMILY HISTORY:, Heart disease in both grandfathers, grandmother with stroke, and a grandmother with diabetes.  Denies obesity and hypertension in other family members.,CURRENT MEDICATIONS:, None.,ALLERGIES:,  He is allergic to Penicillin.,MISCELLANEOUS/EATING HISTORY:, He has been going to support groups for seven months with Lynn Holmberg in Greenwich and he is from Eastchester, New York and he feels that we are the appropriate program.  He had a poor experience with the Greenwich program.  Eating history, he is not an emotional eater.  Does not like sweets.  He likes big portions and carbohydrates.  He likes chicken and not steak.  He currently weighs 312 pounds.  Ideal body weight would be 170 pounds.  He is 142 pounds overweight.  If ,he lost 60% of his excess body weight that would be 84 pounds and he should weigh about 228.,REVIEW OF SYSTEMS: ,Negative for head, neck, heart, lungs, GI, GU, orthopedic, and skin.  Specifically denies chest pain, heart attack, coronary artery disease, congestive heart failure, arrhythmia, atrial fibrillation, pacemaker, high cholesterol, pulmonary embolism, high blood pressure, CVA, venous insufficiency, thrombophlebitis, asthma, shortness of breath, COPD, emphysema, sleep apnea, diabetes, leg and foot swelling, osteoarthritis, rheumatoid arthritis, hiatal hernia, peptic ulcer disease, gallstones, infected gallbladder, pancreatitis, fatty liver, hepatitis, hemorrhoids, rectal bleeding, polyps, incontinence of stool, urinary stress incontinence, or cancer.  Denies cellulitis, pseudotumor cerebri, meningitis, or encephalitis.,PHYSICAL EXAMINATION:, He is alert and oriented x 3.  Cranial nerves II-XII are intact.  Afebrile.  Vital Signs are stable.
#> 3 HISTORY OF PRESENT ILLNESS: , I have seen ABC today.  He is a very pleasant gentleman who is 42 years old, 344 pounds.  He is 5'9".  He has a BMI of 51.  He has been overweight for ten years since the age of 33, at his highest he was 358 pounds, at his lowest 260.  He is pursuing surgical attempts of weight loss to feel good, get healthy, and begin to exercise again.  He wants to be able to exercise and play volleyball.  Physically, he is sluggish.  He gets tired quickly.  He does not go out often.  When he loses weight he always regains it and he gains back more than he lost.  His biggest weight loss is 25 pounds and it was three months before he gained it back.  He did six months of not drinking alcohol and not taking in many calories.  He has been on multiple commercial weight loss programs including Slim Fast for one month one year ago and Atkin's Diet for one month two years ago.,PAST MEDICAL HISTORY: , He has difficulty climbing stairs, difficulty with airline seats, tying shoes, used to public seating, difficulty walking, high cholesterol, and high blood pressure.  He has asthma and difficulty walking two blocks or going eight to ten steps.  He has sleep apnea and snoring.  He is a diabetic, on medication.  He has joint pain, knee pain, back pain, foot and ankle pain, leg and foot swelling.  He has hemorrhoids.,PAST SURGICAL HISTORY: , Includes orthopedic or knee surgery.,SOCIAL HISTORY: , He is currently single.  He drinks alcohol ten to twelve drinks a week, but does not drink five days a week and then will binge drink.  He smokes one and a half pack a day for 15 years, but he has recently stopped smoking for the past two weeks.,FAMILY HISTORY: , Obesity, heart disease, and diabetes.  Family history is negative for hypertension and stroke.,CURRENT MEDICATIONS:,  Include Diovan, Crestor, and Tricor.,MISCELLANEOUS/EATING HISTORY:  ,He says a couple of friends of his have had heart attacks and have had died.  He used to drink everyday, but stopped two years ago.  He now only drinks on weekends.  He is on his second week of Chantix, which is a medication to come off smoking completely.  Eating, he eats bad food.  He is single.  He eats things like bacon, eggs, and cheese, cheeseburgers, fast food, eats four times a day, seven in the morning, at noon, 9 p.m., and 2 a.m.  He currently weighs 344 pounds and 5'9".  His ideal body weight is 160 pounds.  He is 184 pounds overweight.  If he lost 70% of his excess body weight that would be 129 pounds and that would get him down to 215.,REVIEW OF SYSTEMS: , Negative for head, neck, heart, lungs, GI, GU, orthopedic, or skin.  He also is positive for gout.  He denies chest pain, heart attack, coronary artery disease, congestive heart failure, arrhythmia, atrial fibrillation, pacemaker, pulmonary embolism, or CVA.  He denies venous insufficiency or thrombophlebitis.  Denies shortness of breath, COPD, or emphysema.  Denies thyroid problems, hip pain, osteoarthritis, rheumatoid arthritis, GERD, hiatal hernia, peptic ulcer disease, gallstones, infected gallbladder, pancreatitis, fatty liver, hepatitis, rectal bleeding, polyps, incontinence of stool, urinary stress incontinence, or cancer.  He denies cellulitis, pseudotumor cerebri, meningitis, or encephalitis.,PHYSICAL EXAMINATION:  ,He is alert and oriented x 3.  Cranial nerves II-XII are intact.  Neck is soft and supple.  Lungs:  He has positive wheezing bilaterally.  Heart is regular rhythm and rate.  His abdomen is soft.  Extremities:  He has 1+ pitting edema.,IMPRESSION/PLAN:,  I have explained to him the risks and potential complications of laparoscopic gastric bypass in detail and these include bleeding, infection, deep venous thrombosis, pulmonary embolism, leakage from the gastrojejuno-anastomosis, jejunojejuno-anastomosis, and possible bowel obstruction among other potential complications.  He understands.  He wants to proceed with workup and evaluation for laparoscopic Roux-en-Y gastric bypass.  He will need to get a letter of approval from Dr. XYZ.  He will need to see a nutritionist and mental health worker.  He will need an upper endoscopy by either Dr. XYZ.  He will need to go to Dr. XYZ as he previously had a sleep study.  We will need another sleep study.  He will need H. pylori testing, thyroid function tests, LFTs, glycosylated hemoglobin, and fasting blood sugar.  After this is performed, we will submit him for insurance approval.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        2-D M-MODE: , ,1.  Left atrial enlargement with left atrial diameter of 4.7 cm.,2.  Normal size right and left ventricle.,3.  Normal LV systolic function with left ventricular ejection fraction of 51%.,4.  Normal LV diastolic function.,5.  No pericardial effusion.,6.  Normal morphology of aortic valve, mitral valve, tricuspid valve, and pulmonary valve.,7.  PA systolic pressure is 36 mmHg.,DOPPLER: , ,1.  Mild mitral and tricuspid regurgitation.,2.  Trace aortic and pulmonary regurgitation.
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     1.  The left ventricular cavity size and wall thickness appear normal.  The wall motion and left ventricular systolic function appears hyperdynamic with estimated ejection fraction of 70% to 75%.  There is near-cavity obliteration seen.  There also appears to be increased left ventricular outflow tract gradient at the mid cavity level consistent with hyperdynamic left ventricular systolic function.  There is abnormal left ventricular relaxation pattern seen as well as elevated left atrial pressures seen by Doppler examination.,2.  The left atrium appears mildly dilated.,3.  The right atrium and right ventricle appear normal.,4.  The aortic root appears normal.,5.  The aortic valve appears calcified with mild aortic valve stenosis, calculated aortic valve area is 1.3 cm square with a maximum instantaneous gradient of 34 and a mean gradient of 19 mm.,6.  There is mitral annular calcification extending to leaflets and supportive structures with thickening of mitral valve leaflets with mild mitral regurgitation.,7.  The tricuspid valve appears normal with trace tricuspid regurgitation with moderate pulmonary artery hypertension.  Estimated pulmonary artery systolic pressure is 49 mmHg.  Estimated right atrial pressure of 10 mmHg.,8.  The pulmonary valve appears normal with trace pulmonary insufficiency.,9.  There is no pericardial effusion or intracardiac mass seen.,10.  There is a color Doppler suggestive of a patent foramen ovale with lipomatous hypertrophy of the interatrial septum.,11.  The study was somewhat technically limited and hence subtle abnormalities could be missed from the study.,
#>                                                                                                                                                                                                                                                                                                                                  keywords
#> 1                                                                                                                                                                                                     allergy / immunology, allergic rhinitis, allergies, asthma, nasal sprays, rhinitis, nasal, erythematous, allegra, sprays, allergic,
#> 2                                                                                                bariatrics, laparoscopic gastric bypass, weight loss programs, gastric bypass, atkin's diet, weight watcher's, body weight, laparoscopic gastric, weight loss, pounds, months, weight, laparoscopic, band, loss, diets, overweight, lost
#> 3                                                                                             bariatrics, laparoscopic gastric bypass, heart attacks, body weight, pulmonary embolism, potential complications, sleep study, weight loss, gastric bypass, anastomosis, loss, sleep, laparoscopic, gastric, bypass, heart, pounds, weight,
#> 4                                                                          cardiovascular / pulmonary, 2-d m-mode, doppler, aortic valve, atrial enlargement, diastolic function, ejection fraction, mitral, mitral valve, pericardial effusion, pulmonary valve, regurgitation, systolic function, tricuspid, tricuspid valve, normal lv
#> 5 cardiovascular / pulmonary, 2-d, doppler, echocardiogram, annular, aortic root, aortic valve, atrial, atrium, calcification, cavity, ejection fraction, mitral, obliteration, outflow, regurgitation, relaxation pattern, stenosis, systolic function, tricuspid, valve, ventricular, ventricular cavity, wall motion, pulmonary artery

clinspacy_output_file = 
  mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description',
            verbose = FALSE,
            output_file = file.path(rappdirs::user_data_dir('clinspacy'),
                                  'output.csv'),
          overwrite = TRUE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   |                                                                                                         |                                                                                                 |   0%

clinspacy_output_file
#> [1] "C:\\Users\\kdpsingh\\AppData\\Local\\clinspacy\\clinspacy/output.csv"
```

## Binding named entities to a data frame (without the UMLS linker)

Negated concepts, as identified by the medspacy cycontext flag, are
ignored by default and do not count towards the frequencies. However,
you can now change the subsetting criteria.

Note that you now need to re-provide the original dataset to the
`bind_clinspacy()` function.

``` r
mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description', verbose = FALSE) %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   |                                                                                                         |                                                                                                 |   0%
#>   note_id                                                      description white female complaint allergy
#> 1       1 A 23-year-old white female presents with complaint of allergies.            1         1       1
#> 2       2                         Consult for laparoscopic gastric bypass.            0         0       0
#> 3       3                         Consult for laparoscopic gastric bypass.            0         0       0
#> 4       4                                             2-D M-Mode. Doppler.            0         0       0
#> 5       5                                               2-D Echocardiogram            0         0       0
#>   consult laparoscopic gastric bypass 2-d m-mode doppler 2-d echocardiogram
#> 1       0                           0          0       0   0              0
#> 2       1                           1          0       0   0              0
#> 3       1                           1          0       0   0              0
#> 4       0                           0          1       1   0              0
#> 5       0                           0          0       0   1              1
```

### We can also store the intermediate result so that bind\_clinspacy() does not need to re-process the text.

``` r
clinspacy_output_data = 
  mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description', verbose = FALSE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   |                                                                                                         |                                                                                                 |   0%

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   note_id                                                      description white female complaint allergy
#> 1       1 A 23-year-old white female presents with complaint of allergies.            1         1       1
#> 2       2                         Consult for laparoscopic gastric bypass.            0         0       0
#> 3       3                         Consult for laparoscopic gastric bypass.            0         0       0
#> 4       4                                             2-D M-Mode. Doppler.            0         0       0
#> 5       5                                               2-D Echocardiogram            0         0       0
#>   consult laparoscopic gastric bypass 2-d m-mode doppler 2-d echocardiogram
#> 1       0                           0          0       0   0              0
#> 2       1                           1          0       0   0              0
#> 3       1                           1          0       0   0              0
#> 4       0                           0          1       1   0              0
#> 5       0                           0          0       0   1              1

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 cs_col = 'entity')
#>   note_id                                                      description white female complaint
#> 1       1 A 23-year-old white female presents with complaint of allergies.            1         1
#> 2       2                         Consult for laparoscopic gastric bypass.            0         0
#> 3       3                         Consult for laparoscopic gastric bypass.            0         0
#> 4       4                                             2-D M-Mode. Doppler.            0         0
#> 5       5                                               2-D Echocardiogram            0         0
#>   allergies Consult laparoscopic gastric bypass 2-D M-Mode Doppler 2-D Echocardiogram
#> 1         1       0                           0          0       0   0              0
#> 2         0       1                           1          0       0   0              0
#> 3         0       1                           1          0       0   0              0
#> 4         0       0                           0          1       1   0              0
#> 5         0       0                           0          0       0   1              1

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 subset = 'is_uncertain == FALSE & is_negated == FALSE')
#>   note_id                                                      description white female complaint allergy
#> 1       1 A 23-year-old white female presents with complaint of allergies.            1         1       1
#> 2       2                         Consult for laparoscopic gastric bypass.            0         0       0
#> 3       3                         Consult for laparoscopic gastric bypass.            0         0       0
#> 4       4                                             2-D M-Mode. Doppler.            0         0       0
#> 5       5                                               2-D Echocardiogram            0         0       0
#>   consult laparoscopic gastric bypass 2-d m-mode doppler 2-d echocardiogram
#> 1       0                           0          0       0   0              0
#> 2       1                           1          0       0   0              0
#> 3       1                           1          0       0   0              0
#> 4       0                           0          1       1   0              0
#> 5       0                           0          0       0   1              1
```

### We can also re-use the output file we had created earlier and pipe this directly into bind\_clinspacy().

``` r
clinspacy_output_file
#> [1] "C:\\Users\\kdpsingh\\AppData\\Local\\clinspacy\\clinspacy/output.csv"

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   note_id                                                      description 2-d 2-d m-mode allergy
#> 1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1
#> 2       2                         Consult for laparoscopic gastric bypass.   0          0       0
#> 3       3                         Consult for laparoscopic gastric bypass.   0          0       0
#> 4       4                                             2-D M-Mode. Doppler.   0          1       0
#> 5       5                                               2-D Echocardiogram   1          0       0
#>   complaint consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1         1       0       0              0                           0            1
#> 2         0       1       0              0                           1            0
#> 3         0       1       0              0                           1            0
#> 4         0       0       1              0                           0            0
#> 5         0       0       0              1                           0            0

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 cs_col = 'entity')
#>   note_id                                                      description 2-D 2-D M-Mode Consult Doppler
#> 1       1 A 23-year-old white female presents with complaint of allergies.   0          0       0       0
#> 2       2                         Consult for laparoscopic gastric bypass.   0          0       1       0
#> 3       3                         Consult for laparoscopic gastric bypass.   0          0       1       0
#> 4       4                                             2-D M-Mode. Doppler.   0          1       0       1
#> 5       5                                               2-D Echocardiogram   1          0       0       0
#>   Echocardiogram allergies complaint laparoscopic gastric bypass white female
#> 1              0         1         1                           0            1
#> 2              0         0         0                           1            0
#> 3              0         0         0                           1            0
#> 4              0         0         0                           0            0
#> 5              1         0         0                           0            0

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 subset = 'is_uncertain == FALSE & is_negated == FALSE')
#>   note_id                                                      description 2-d 2-d m-mode allergy
#> 1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1
#> 2       2                         Consult for laparoscopic gastric bypass.   0          0       0
#> 3       3                         Consult for laparoscopic gastric bypass.   0          0       0
#> 4       4                                             2-D M-Mode. Doppler.   0          1       0
#> 5       5                                               2-D Echocardiogram   1          0       0
#>   complaint consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1         1       0       0              0                           0            1
#> 2         0       1       0              0                           1            0
#> 3         0       1       0              0                           1            0
#> 4         0       0       1              0                           0            0
#> 5         0       0       0              1                           0            0
```

## Binding entity embeddings to a data frame (without the UMLS linker)

With the UMLS linker disabled, 200-dimensional entity embeddings can be
extracted from the scispacy Python package. For this to work, you must
set `return_scispacy_embeddings` to `TRUE` when running `clinspacy()`.
It’s also a good idea to write the output directly to file because the
embeddings can be quite large.

``` r
clinspacy_output_file = 
  mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description',
            return_scispacy_embeddings = TRUE,
            verbose = FALSE,
            output_file = file.path(rappdirs::user_data_dir('clinspacy'),
                                  'output.csv'),
          overwrite = TRUE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   |                                                                                                         |                                                                                                 |   0%

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(mtsamples[1:5, 1:2])
#>   note_id                                                      description    emb_001    emb_002
#> 1       1 A 23-year-old white female presents with complaint of allergies. -0.1959790 0.28813400
#> 2       2                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144
#> 3       3                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144
#> 4       4                                             2-D M-Mode. Doppler. -0.3077586 0.25928350
#>       emb_003     emb_004    emb_005     emb_006      emb_007     emb_008    emb_009    emb_010    emb_011
#> 1  0.09685702 -0.20641684 -0.1554238 -0.01624470  0.027011001  0.05331314 -0.1006668  0.3682853  0.0581439
#> 2 -0.13519235 -0.05496463  0.1488807 -0.19577999  0.052658666 -0.10433200 -0.0763495  0.1199215 -0.1860092
#> 3 -0.13519235 -0.05496463  0.1488807 -0.19577999  0.052658666 -0.10433200 -0.0763495  0.1199215 -0.1860092
#> 4 -0.37220851 -0.06021732  0.0386426 -0.07756314 -0.002676249  0.22511028  0.3279995 -0.2274373 -0.1656060
#>       emb_012   emb_013    emb_014     emb_015     emb_016    emb_017    emb_018    emb_019      emb_020
#> 1 -0.29079599 0.1611375 -0.1118952 -0.03922822  0.06888010 -0.1862742 -0.1454458 0.04115367  0.049065500
#> 2  0.05465447 0.1267057 -0.2041533  0.01984984 -0.01107489  0.1080266  0.1128684 0.23062316 -0.005933613
#> 3  0.05465447 0.1267057 -0.2041533  0.01984984 -0.01107489  0.1080266  0.1128684 0.23062316 -0.005933613
#> 4 -0.30020200 0.5237787 -0.1472114 -0.02312062 -0.11272645 -0.3415540 -0.2255931 0.02385290  0.074861225
#>      emb_021    emb_022     emb_023     emb_024     emb_025   emb_026     emb_027     emb_028     emb_029
#> 1 0.39795328 0.05879098  0.05246135 -0.19981400 -0.03346085 0.1395520  0.01792375 -0.06969561 -0.04942485
#> 2 0.06126638 0.05048515  0.12351524 -0.02489970 -0.26744565 0.3418240 -0.12783451  0.38420413 -0.20168215
#> 3 0.06126638 0.05048515  0.12351524 -0.02489970 -0.26744565 0.3418240 -0.12783451  0.38420413 -0.20168215
#> 4 0.12910485 0.02176433 -0.21616454  0.08218845  0.33230226 0.2420833  0.08455360  0.22111987 -0.57962301
#>       emb_030     emb_031     emb_032     emb_033     emb_034     emb_035     emb_036     emb_037
#> 1  0.06613978  0.08035761 -0.12418544 -0.11839510  0.04266573 -0.04319873  0.06394462  0.02425202
#> 2 -0.06550949  0.26997083 -0.07201438  0.13039007 -0.13608095  0.10342984  0.03349850 -0.06359592
#> 3 -0.06550949  0.26997083 -0.07201438  0.13039007 -0.13608095  0.10342984  0.03349850 -0.06359592
#> 4  0.32054099 -0.26178523 -0.46501200  0.05091595 -0.22430425 -0.07319695 -0.19518739 -0.21279503
#>      emb_038    emb_039      emb_040     emb_041     emb_042      emb_043    emb_044     emb_045
#> 1 -0.2158322 -0.1064802  0.005398401  0.01459978 -0.03936125 -0.216860471 0.01146569 -0.01707370
#> 2 -0.2497478 -0.1312915 -0.068015995  0.12897950  0.20849532 -0.001854315 0.02034700  0.04105476
#> 3 -0.2497478 -0.1312915 -0.068015995  0.12897950  0.20849532 -0.001854315 0.02034700  0.04105476
#> 4 -0.1980325 -0.3900315  0.214830723 -0.03985715  0.32672650 -0.067201529 0.43131340 -0.10445137
#>       emb_046     emb_047     emb_048     emb_049     emb_050   emb_051       emb_052     emb_053
#> 1 -0.08789315 -0.48977432  0.11840488 -0.24063642 -0.23959090 0.1258371 -0.0001312072 -0.15632193
#> 2 -0.26218344  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.1197809521  0.04324770
#> 3 -0.26218344  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.1197809521  0.04324770
#> 4 -0.36873272  0.39958726  0.03923560  0.06519943 -0.12042060 0.1947917  0.5587487221  0.02909975
#>      emb_054     emb_055      emb_056     emb_057      emb_058     emb_059    emb_060     emb_061
#> 1  0.2063196 -0.02019964 -0.002069766 -0.14390510 -0.112056380 -0.12671516 -0.3076788  0.01722672
#> 2 -0.2046735 -0.21317951  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.18907296
#> 3 -0.2046735 -0.21317951  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.18907296
#> 4 -0.1112386 -0.29085600  0.051582206  0.03322158 -0.090760550 -0.01738100  0.4675597 -0.29520441
#>       emb_062     emb_063      emb_064     emb_065    emb_066     emb_067     emb_068   emb_069
#> 1 -0.04037631  0.14633203  0.072336150  0.04734538  0.2444712 0.005439494  0.07232769 0.1972760
#> 2 -0.26335296  0.01884718 -0.009265006 -0.16859459 -0.2767420 0.048937336 -0.35522249 0.1164578
#> 3 -0.26335296  0.01884718 -0.009265006 -0.16859459 -0.2767420 0.048937336 -0.35522249 0.1164578
#> 4  0.62886798 -0.14435785  0.002738898 -0.03027805 -0.4466182 0.080596073  0.29857932 0.2307856
#>       emb_070     emb_071     emb_072    emb_073     emb_074    emb_075    emb_076    emb_077     emb_078
#> 1 0.007281476 -0.03698583 -0.07433472 -0.0170116  0.15559705 -0.0142159 0.03095377 0.14973202 -0.07275485
#> 2 0.345116988 -0.03482347 -0.09575927 -0.1530600 -0.08885341  0.1138750 0.24408367 0.01405296 -0.00684475
#> 3 0.345116988 -0.03482347 -0.09575927 -0.1530600 -0.08885341  0.1138750 0.24408367 0.01405296 -0.00684475
#> 4 0.032678135 -0.02464749 -0.05315572  0.2278580  0.05121428  0.3368990 0.12042545 0.05976460  0.20906300
#>      emb_079    emb_080    emb_081     emb_082    emb_083     emb_084    emb_085     emb_086    emb_087
#> 1 -0.1265165  0.0756736 -0.1064746 -0.04138183  0.1262948 -0.07008250 -0.0581785 -0.08323197 -0.1252120
#> 2 -0.1356777 -0.1306460  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527  0.09356334 -0.2311737
#> 3 -0.1356777 -0.1306460  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527  0.09356334 -0.2311737
#> 4 -0.3898960 -0.2403080 -0.2094990 -0.43718034 -0.2580445 -0.36398449 -0.1863167 -0.38763523  0.1124806
#>       emb_088     emb_089     emb_090    emb_091    emb_092     emb_093     emb_094      emb_095
#> 1  0.10060352 -0.01839051 -0.24945817  0.2108233  0.2314818 -0.07174893  0.03378552  0.002213914
#> 2  0.01929579 -0.18456985  0.16967812 -0.3636869 -0.1134262  0.07241845  0.29899751  0.111884147
#> 3  0.01929579 -0.18456985  0.16967812 -0.3636869 -0.1134262  0.07241845  0.29899751  0.111884147
#> 4 -0.25680842 -0.21670937 -0.02249805  0.2278338 -0.1409704  0.17529125 -0.05521812 -0.186143875
#>       emb_096    emb_097      emb_098     emb_099     emb_100     emb_101     emb_102    emb_103
#> 1  0.22163883 0.30331765  0.009472401 -0.14205784  0.12607630 -0.19062089 -0.08417289 -0.0868922
#> 2 -0.04911397 0.05792167 -0.125230156 -0.27682150 -0.03230023  0.09556636 -0.01811487  0.2020687
#> 3 -0.04911397 0.05792167 -0.125230156 -0.27682150 -0.03230023  0.09556636 -0.01811487  0.2020687
#> 4  0.54336450 0.13775243 -0.269951746  0.01101355  0.12618919  0.24217032  0.19674813  0.1094553
#>       emb_104       emb_105   emb_106     emb_107    emb_108     emb_109     emb_110     emb_111
#> 1  0.08520973  0.1095840322 0.0911104 -0.11639215 -0.1988509 -0.02318672 -0.03355397  0.06281934
#> 2 -0.28405397 -0.2379808277 0.0503400  0.07255385 -0.3391048  0.29906577 -0.28191616  0.04745353
#> 3 -0.28405397 -0.2379808277 0.0503400  0.07255385 -0.3391048  0.29906577 -0.28191616  0.04745353
#> 4 -0.02718710 -0.0006717525 0.1023474  0.30398776  0.0299391  0.38101604 -0.07525725 -0.19109026
#>       emb_112    emb_113     emb_114     emb_115     emb_116     emb_117     emb_118     emb_119
#> 1  0.09064088 -0.1812218 -0.08294683  0.09746995  0.16949679 0.001256246 -0.09206300 -0.27094193
#> 2 -0.04532966 -0.1529041  0.04579017  0.02364063 -0.31116034 0.160783665 -0.07702465 -0.02175729
#> 3 -0.04532966 -0.1529041  0.04579017  0.02364063 -0.31116034 0.160783665 -0.07702465 -0.02175729
#> 4 -0.09757482 -0.3430861  0.07392349 -0.34514988 -0.05409198 0.021575954  0.24660901 -0.25714830
#>      emb_120    emb_121     emb_122    emb_123     emb_124     emb_125     emb_126     emb_127    emb_128
#> 1  0.1914412 0.10522338  0.01736773 -0.1658078 -0.24409867 -0.20621473 -0.35578349  0.19991713 -0.1075110
#> 2 -0.1156647 0.01362599 -0.20085029  0.3362202 -0.03874875 -0.02545092  0.21585878 -0.04820869  0.1341518
#> 3 -0.1156647 0.01362599 -0.20085029  0.3362202 -0.03874875 -0.02545092  0.21585878 -0.04820869  0.1341518
#> 4 -0.3096262 0.14711675 -0.09584628 -0.2465328  0.02228437 -0.05287175  0.04758008  0.13082074 -0.4366458
#>       emb_129    emb_130     emb_131     emb_132    emb_133     emb_134     emb_135     emb_136    emb_137
#> 1 0.050961102 0.08590268 -0.07344585 -0.11005830  0.2082962 -0.03440777 -0.15951183  0.04417117 -0.1002716
#> 2 0.084913827 0.21485816 -0.26201880 -0.04661880  0.1594945  0.24577541 -0.04687785  0.02120483 -0.2707188
#> 3 0.084913827 0.21485816 -0.26201880 -0.04661880  0.1594945  0.24577541 -0.04687785  0.02120483 -0.2707188
#> 4 0.002557264 0.30628723 -0.24981013 -0.01674807 -0.3169997  0.12056302 -0.09506032 -0.01222125 -0.4409042
#>       emb_138     emb_139      emb_140     emb_141     emb_142     emb_143     emb_144    emb_145
#> 1 -0.07090355 -0.09013366  0.004567102 -0.04074124 -0.09970398 -0.07412403  0.08118367 0.04151318
#> 2 -0.05038439 -0.21531074 -0.214246295  0.12730155  0.04358483 -0.04084410  0.08556246 0.37193301
#> 3 -0.05038439 -0.21531074 -0.214246295  0.12730155  0.04358483 -0.04084410  0.08556246 0.37193301
#> 4  0.23120450  0.01691840  0.127434801  0.19368662  0.02984041 -0.14155845 -0.15326020 0.02936405
#>       emb_146     emb_147    emb_148    emb_149    emb_150     emb_151    emb_152     emb_153     emb_154
#> 1  0.01023637 -0.02712608  0.1120797 0.07420963  0.2022959 -0.02539130 -0.1542052  0.09878749  0.11210436
#> 2 -0.23297635  0.16786779 -0.1552295 0.13361997  0.4047717 -0.07385027  0.2168649  0.08279617  0.02853568
#> 3 -0.23297635  0.16786779 -0.1552295 0.13361997  0.4047717 -0.07385027  0.2168649  0.08279617  0.02853568
#> 4  0.05187999  0.06006772  0.0758267 0.04905358 -0.0133047  0.25728051  0.2761333 -0.10433040 -0.02122432
#>       emb_155    emb_156    emb_157     emb_158     emb_159    emb_160     emb_161     emb_162
#> 1 0.190853971 -0.2355878  0.1032905 -0.21532827  0.09456767 -0.1445503 -0.33522494  0.15268593
#> 2 0.007983398 -0.2673024 -0.3518553  0.07097678  0.08358909 -0.1986835 -0.29901644 -0.01896982
#> 3 0.007983398 -0.2673024 -0.3518553  0.07097678  0.08358909 -0.1986835 -0.29901644 -0.01896982
#> 4 0.066375951 -0.3625118 -0.2547615  0.13501658 -0.28645951 -0.1917117 -0.01892012 -0.02507000
#>        emb_163    emb_164     emb_165   emb_166     emb_167    emb_168     emb_169    emb_170    emb_171
#> 1 -0.001686232  0.2152747 -0.10312133 0.1135696 -0.02624894  0.1098730  0.09047928 0.12684340 -0.0694985
#> 2 -0.052200415  0.1262764  0.10607937 0.0321700 -0.25643115 -0.1073976  0.26462262 0.03679075 -0.2173935
#> 3 -0.052200415  0.1262764  0.10607937 0.0321700 -0.25643115 -0.1073976  0.26462262 0.03679075 -0.2173935
#> 4 -0.031375002 -0.2519416  0.08888888 0.3796148 -0.25476800 -0.1437821 -0.15589955 0.23368900  0.1311810
#>       emb_172    emb_173     emb_174     emb_175    emb_176    emb_177     emb_178     emb_179     emb_180
#> 1 -0.11949543  0.2164041 -0.29396720 -0.16588253 -0.1348005 -0.1148055 -0.08968537  0.05097483  0.09355133
#> 2  0.07656907 -0.1012526 -0.02410151 -0.02048860 -0.1179298  0.2362113  0.30876314 -0.22625668  0.07487945
#> 3  0.07656907 -0.1012526 -0.02410151 -0.02048860 -0.1179298  0.2362113  0.30876314 -0.22625668  0.07487945
#> 4  0.52442150 -0.0487657  0.25153150  0.02299049 -0.1953604 -0.1572996  0.29195935 -0.05653973 -0.12341889
#>        emb_181    emb_182    emb_183     emb_184     emb_185     emb_186    emb_187     emb_188
#> 1  0.008875800  0.1106400 -0.1088511 -0.02326688  0.17733055 -0.07351807  0.0222525 -0.12066887
#> 2  0.008851715 -0.1024263 -0.2249113 -0.06455390  0.07631866  0.01623236 -0.1098196 -0.04689731
#> 3  0.008851715 -0.1024263 -0.2249113 -0.06455390  0.07631866  0.01623236 -0.1098196 -0.04689731
#> 4 -0.312314242 -0.1885454 -0.2873893 -0.02149600 -0.16462975  0.14877875  0.2350687  0.36260483
#>        emb_189    emb_190     emb_191      emb_192     emb_193     emb_194     emb_195    emb_196
#> 1 -0.179350998 0.01909462  0.13228424  0.024832169  0.05002003 -0.20531311 -0.00853500  0.0639337
#> 2 -0.033685058 0.16270872 -0.05825762  0.069446986 -0.05563271 -0.17479033 -0.13635058  0.1291080
#> 3 -0.033685058 0.16270872 -0.05825762  0.069446986 -0.05563271 -0.17479033 -0.13635058  0.1291080
#> 4  0.004200405 0.20571376  0.09558415 -0.006550124 -0.30820300  0.01686265 -0.05414012 -0.1694009
#>       emb_197     emb_198     emb_199     emb_200
#> 1  0.29886368  0.01618892 -0.08192083 -0.37027851
#> 2 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 3 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 4 -0.13313706 -0.15822850  0.14830773 -0.34555282
#>  [ reached 'max' / getOption("max.print") -- omitted 1 rows ]
```

## Adding the UMLS linker

The UMLS linker can be turned on (and off) even if `clinspacy_init()`
has already been called. The first time you turn it on, it takes a while
because the linker needs to be loaded into memory. On subsequent removal
and addition, this occurs much more quickly because the linker is only
removed/added to the pipeline and does not need to be reloaded into
memory.

``` r
clinspacy_init(use_linker = TRUE)
#> Loading the UMLS entity linker... (this may take a while)
#> Adding the UMLS entity linker to the spacy pipeline...
#> NULL
```

## Named entity recognition (with the UMLS linker)

By turning on the UMLS linker, you can restrict the results by semantic
type. In general, restricting the result in `clinspacy()` is not a good
idea because you can always subset the results later within
`bind_clinspacy()` and `bind_clinspacy_embeddings()`.

``` r
clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#>   |                                                                                                         |                                                                                                 |   0%  |                                                                                                         |=================================================================================================| 100%
#>   id      cui             semantic_type                     definition      entity       lemma is_family
#> 1  1 C0011847       Disease or Syndrome                       Diabetes    diabetes    diabetes     FALSE
#> 2  1 C0011849       Disease or Syndrome              Diabetes Mellitus    diabetes    diabetes     FALSE
#> 3  1 C0020538       Disease or Syndrome           Hypertensive disease         HTN         htn     FALSE
#> 4  1 C0030705 Patient or Disabled Group                       Patients     patient     patient     FALSE
#> 5  1 C1578481           Idea or Concept     Mail Claim Party - Patient     patient     patient     FALSE
#> 6  1 C1578483           Idea or Concept        Report source - Patient     patient     patient     FALSE
#> 7  1 C1578486      Intellectual Product Disabled Person Code - Patient     patient     patient     FALSE
#> 8  1 C1705908                  Organism             Veterinary Patient     patient     patient     FALSE
#> 9  1 C2316787       Disease or Syndrome Chronic kidney disease stage 3 CKD stage 3 ckd stage 3     FALSE
#>   is_historical is_hypothetical is_negated is_uncertain section_title        confidence
#> 1         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 2         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 3         FALSE           FALSE       TRUE        FALSE          <NA>                 1
#> 4         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 5         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 6         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 7         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 8         FALSE           FALSE      FALSE        FALSE          <NA>                 1
#> 9         FALSE           FALSE      FALSE        FALSE          <NA> 0.999999940395355

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Pharmacologic Substance')
#>   |                                                                                                         |                                                                                                 |   0%  |                                                                                                         |=================================================================================================| 100%
#>   id      cui           semantic_type definition     entity      lemma is_family is_historical
#> 1  1 C0001927 Pharmacologic Substance  Albuterol  albuterol  albuterol     FALSE         FALSE
#> 2  1 C0004057 Pharmacologic Substance    Aspirin    aspirin    aspirin     FALSE         FALSE
#> 3  1 C0028978 Pharmacologic Substance Omeprazole omeprazole omeprazole     FALSE         FALSE
#> 4  1 C0065374 Pharmacologic Substance Lisinopril lisinopril lisinopril     FALSE         FALSE
#>   is_hypothetical is_negated is_uncertain section_title confidence
#> 1           FALSE       TRUE        FALSE          <NA>          1
#> 2           FALSE      FALSE        FALSE          <NA>          1
#> 3           FALSE      FALSE        FALSE          <NA>          1
#> 4           FALSE      FALSE        FALSE          <NA>          1

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Disease or Syndrome')
#>   |                                                                                                         |                                                                                                 |   0%  |                                                                                                         |=================================================================================================| 100%
#>   id      cui       semantic_type        definition   entity    lemma is_family is_historical
#> 1  1 C0004096 Disease or Syndrome            Asthma   asthma   asthma     FALSE         FALSE
#> 2  1 C0011847 Disease or Syndrome          Diabetes diabetes diabetes     FALSE         FALSE
#> 3  1 C0011849 Disease or Syndrome Diabetes Mellitus diabetes diabetes     FALSE         FALSE
#>   is_hypothetical is_negated is_uncertain section_title confidence
#> 1           FALSE       TRUE        FALSE          <NA>          1
#> 2           FALSE      FALSE        FALSE          <NA>          1
#> 3           FALSE      FALSE        FALSE          <NA>          1
```

## Binding UMLS concept unique identifiers to a data frame (with the UMLS linker)

This function binds columns containing concept unique identifiers with
which scispacy has 99% confidence of being present with values
containing frequencies. Negated concepts, as identified by the medspacy
cycontext is\_negated flag, are ignored and do not count towards the
frequencies. However, this behavior can be changed using the `subset`
argument.

Note that by turning on the UMLS linker, you can restrict the results by
semantic type.

``` r
clinspacy_output_file = 
  mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description',
            return_scispacy_embeddings = TRUE, # only so we can retrieve these below
            verbose = FALSE,
            output_file = file.path(rappdirs::user_data_dir('clinspacy'),
                                  'output.csv'),
          overwrite = TRUE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   |                                                                                                         |                                                                                                 |   0%

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   note_id                                                      description C0009818 C0013516 C0020517
#> 1       1 A 23-year-old white female presents with complaint of allergies.        0        0        1
#> 2       2                         Consult for laparoscopic gastric bypass.        1        0        0
#> 3       3                         Consult for laparoscopic gastric bypass.        1        0        0
#> 4       4                                             2-D M-Mode. Doppler.        0        0        0
#> 5       5                                               2-D Echocardiogram        0        1        0
#>   C0554756 C1705052 C2243117 C3864418 C4039248
#> 1        0        0        0        1        0
#> 2        0        0        0        0        1
#> 3        0        0        0        0        1
#> 4        1        0        0        0        0
#> 5        0        1        1        0        0

clinspacy_output_file %>%  
  bind_clinspacy(
    mtsamples[1:5, 1:2],
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   note_id                                                      description C0013516 C0554756
#> 1       1 A 23-year-old white female presents with complaint of allergies.       NA       NA
#> 2       2                         Consult for laparoscopic gastric bypass.       NA       NA
#> 3       3                         Consult for laparoscopic gastric bypass.       NA       NA
#> 4       4                                             2-D M-Mode. Doppler.        0        1
#> 5       5                                               2-D Echocardiogram        1        0
```

## Binding concept embeddings to a data frame (with the UMLS linker)

The default embeddings are from the scispacy R package. If you want to
use the cui2vec embeddings (only available with the linker enabled), you
ned to set the `type` arguement to `cui2vec`. Up to 500-dimensional
embeddings can be returned.

Note that by turning on the UMLS linker, you can restrict the results by
semantic type (with either type of embedding).

### Scispacy embeddings (with the UMLS linker)

With the UMLS linker enabled, you can restrict by semantic type when
obtaining scispacy embeddings.

Note: The mean embeddings may be slightly different than if the linker
was disabled because entities may be captured twice (as entities may map
to multiple concepts). Thus, if you do not need to restrict by semantic
type, the recommended setting is to turn the UMLS linker off by
re-running `clinspacy_init(use_linker = FALSE)` (note that `use_linker =
FALSE` is the default in `clinspacy_init()`).

``` r
clinspacy_output_file %>%  
  bind_clinspacy_embeddings(mtsamples[1:5, 1:2])
#>   note_id                                                      description    emb_001    emb_002
#> 1       1 A 23-year-old white female presents with complaint of allergies. -0.3446915 0.31240000
#> 2       2                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144
#> 3       3                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144
#> 4       4                                             2-D M-Mode. Doppler. -0.4044230 0.21798199
#>      emb_003     emb_004    emb_005    emb_006     emb_007    emb_008    emb_009    emb_010    emb_011
#> 1  0.1075445 -0.33388351 -0.2601905  0.0535597 -0.10873150  0.1320575 -0.1354880  0.4432590  0.1181515
#> 2 -0.1351923 -0.05496463  0.1488807 -0.1957800  0.05265867 -0.1043320 -0.0763495  0.1199215 -0.1860092
#> 3 -0.1351923 -0.05496463  0.1488807 -0.1957800  0.05265867 -0.1043320 -0.0763495  0.1199215 -0.1860092
#> 4 -0.4359590 -0.05181420 -0.0757723 -0.0336005 -0.18084100  0.2608000  0.4181560 -0.2046540 -0.2572890
#>       emb_012   emb_013    emb_014     emb_015     emb_016    emb_017    emb_018    emb_019      emb_020
#> 1 -0.30079700 0.2334445 -0.2894081 -0.15739120  0.11580539 -0.1948899 -0.1432592  0.0556385 -0.031388000
#> 2  0.05465447 0.1267057 -0.2041533  0.01984984 -0.01107489  0.1080266  0.1128684  0.2306232 -0.005933613
#> 3  0.05465447 0.1267057 -0.2041533  0.01984984 -0.01107489  0.1080266  0.1128684  0.2306232 -0.005933613
#> 4 -0.42502299 0.7310580 -0.1249990 -0.05637670 -0.29954299 -0.2941060 -0.2478460 -0.0287432  0.067911699
#>      emb_021     emb_022    emb_023    emb_024    emb_025  emb_026     emb_027    emb_028     emb_029
#> 1 0.52729550  0.09813235  0.0519441 -0.2893885 -0.1591689 0.137926  0.02760765 -0.1450516 -0.06989193
#> 2 0.06126638  0.05048515  0.1235152 -0.0248997 -0.2674457 0.341824 -0.12783451  0.3842041 -0.20168215
#> 3 0.06126638  0.05048515  0.1235152 -0.0248997 -0.2674457 0.341824 -0.12783451  0.3842041 -0.20168215
#> 4 0.02872950 -0.02079800 -0.2892080  0.2813420  0.6255990 0.428111  0.20646299  0.2296980 -0.74650902
#>       emb_030    emb_031     emb_032    emb_033     emb_034    emb_035    emb_036     emb_037    emb_038
#> 1  0.09941450  0.0392500 -0.08009610 -0.1375820 -0.01676415 -0.0351500  0.1037932 -0.02565445 -0.3248623
#> 2 -0.06550949  0.2699708 -0.07201438  0.1303901 -0.13608095  0.1034298  0.0334985 -0.06359592 -0.2497478
#> 3 -0.06550949  0.2699708 -0.07201438  0.1303901 -0.13608095  0.1034298  0.0334985 -0.06359592 -0.2497478
#> 4  0.35579199 -0.4108430 -0.54899400  0.0451901 -0.21988800  0.0889601 -0.3470430 -0.21991500 -0.1619850
#>       emb_039     emb_040     emb_041     emb_042      emb_043     emb_044     emb_045    emb_046
#> 1  0.05966525  0.05429485  0.09499401 -0.06116135 -0.296921458 -0.02334439 -0.06502713 -0.1429356
#> 2 -0.13129150 -0.06801600  0.12897950  0.20849532 -0.001854315  0.02034700  0.04105476 -0.2621834
#> 3 -0.13129150 -0.06801600  0.12897950  0.20849532 -0.001854315  0.02034700  0.04105476 -0.2621834
#> 4 -0.53598398  0.34043500 -0.04835180  0.36741400 -0.088588104  0.66488600 -0.06560100 -0.5937040
#>       emb_047     emb_048     emb_049     emb_050   emb_051    emb_052    emb_053    emb_054     emb_055
#> 1 -0.71644598  0.16538925 -0.30862515 -0.25367035 0.1443906 -0.1032781 -0.2251650  0.2475160 -0.06773985
#> 2  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.1197810  0.0432477 -0.2046735 -0.21317951
#> 3  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.1197810  0.0432477 -0.2046735 -0.21317951
#> 4  0.62876701  0.06133320  0.02835000 -0.15147001 0.2244480  0.5867410  0.0381370 -0.1356160 -0.38449201
#>        emb_056     emb_057      emb_058     emb_059    emb_060    emb_061     emb_062     emb_063
#> 1 -0.002459399 -0.26274151 -0.220535394 -0.08746599 -0.2091489  0.0749556  0.01780554  0.22492170
#> 2  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.1890730 -0.26335296  0.01884718
#> 3  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.1890730 -0.26335296  0.01884718
#> 4 -0.047390901  0.03690350 -0.155994996 -0.24829200  0.5008110 -0.0982668  0.71681201 -0.03416720
#>        emb_064     emb_065    emb_066    emb_067     emb_068   emb_069    emb_070     emb_071     emb_072
#> 1  0.059806552 -0.01448655  0.3338105 0.13260875  0.06791649 0.2872636 0.07534922  0.02147550 -0.14045776
#> 2 -0.009265006 -0.16859459 -0.2767420 0.04893734 -0.35522249 0.1164578 0.34511699 -0.03482347 -0.09575927
#> 3 -0.009265006 -0.16859459 -0.2767420 0.04893734 -0.35522249 0.1164578 0.34511699 -0.03482347 -0.09575927
#> 4 -0.025456199  0.01503300 -0.5353000 0.21822900  0.51192403 0.4966770 0.00565767 -0.34957999 -0.05733940
#>       emb_073     emb_074     emb_075   emb_076    emb_077     emb_078    emb_079    emb_080    emb_081
#> 1  0.03324185  0.16221935 -0.00452085 0.0184159 0.20710600 -0.21259950 -0.1720180  0.0717411 -0.1796850
#> 2 -0.15305997 -0.08885341  0.11387503 0.2440837 0.01405296 -0.00684475 -0.1356777 -0.1306460  0.2395754
#> 3 -0.15305997 -0.08885341  0.11387503 0.2440837 0.01405296 -0.00684475 -0.1356777 -0.1306460  0.2395754
#> 4  0.16006000  0.00709061  0.29393500 0.1932350 0.09904870  0.10269100 -0.4426980 -0.3044060 -0.3246080
#>       emb_082    emb_083     emb_084    emb_085     emb_086    emb_087     emb_088     emb_089    emb_090
#> 1 -0.06183449  0.2513945 -0.18532750 -0.1602775 -0.11268520 -0.1774700  0.14524100 -0.09946284 -0.2221755
#> 2 -0.24276201  0.1975068 -0.03769429 -0.2019527  0.09356334 -0.2311737  0.01929579 -0.18456985  0.1696781
#> 3 -0.24276201  0.1975068 -0.03769429 -0.2019527  0.09356334 -0.2311737  0.01929579 -0.18456985  0.1696781
#> 4 -0.62308598 -0.2460820 -0.24843900 -0.0256765 -0.51446497  0.2091200 -0.39628500 -0.38479400  0.0601322
#>      emb_091    emb_092     emb_093   emb_094     emb_095     emb_096    emb_097     emb_098    emb_099
#> 1  0.2077670  0.3808290 -0.04224389 0.1085374  0.01000665  0.12158050 0.37730700  0.04429795 -0.2286055
#> 2 -0.3636869 -0.1134262  0.07241845 0.2989975  0.11188415 -0.04911397 0.05792167 -0.12523016 -0.2768215
#> 3 -0.3636869 -0.1134262  0.07241845 0.2989975  0.11188415 -0.04911397 0.05792167 -0.12523016 -0.2768215
#> 4  0.1881050  0.0293956  0.15106900 0.1575840 -0.18849900  0.55679601 0.15977401 -0.21990800  0.0361496
#>       emb_100     emb_101     emb_102    emb_103    emb_104      emb_105    emb_106     emb_107    emb_108
#> 1  0.09848770 -0.20470151 -0.05364895 -0.0236020  0.1021609  0.175601797 0.02127385 -0.14714350 -0.2512595
#> 2 -0.03230023  0.09556636 -0.01811487  0.2020687 -0.2840540 -0.237980828 0.05034000  0.07255385 -0.3391048
#> 3 -0.03230023  0.09556636 -0.01811487  0.2020687 -0.2840540 -0.237980828 0.05034000  0.07255385 -0.3391048
#> 4  0.09506090  0.31184199  0.47269401  0.1894800  0.0198733 -0.000530505 0.25474501  0.38338101  0.0516758
#>      emb_109    emb_110     emb_111     emb_112    emb_113     emb_114     emb_115    emb_116     emb_117
#> 1 -0.1770465 -0.1702297  0.26335400  0.11386510 -0.2920690 -0.01711050  0.17906115  0.1373065 -0.08328408
#> 2  0.2990658 -0.2819162  0.04745353 -0.04532966 -0.1529041  0.04579017  0.02364063 -0.3111603  0.16078367
#> 3  0.2990658 -0.2819162  0.04745353 -0.04532966 -0.1529041  0.04579017  0.02364063 -0.3111603  0.16078367
#> 4  0.6453670  0.1093270 -0.20991200 -0.21882400 -0.5041480 -0.10509700 -0.50537401 -0.0655120  0.12734701
#>       emb_118     emb_119    emb_120    emb_121    emb_122    emb_123     emb_124     emb_125      emb_126
#> 1 -0.12518050 -0.33978799  0.2326025 0.09054590  0.0554755 -0.3234170 -0.33884700 -0.20802350 -0.378833994
#> 2 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.2008503  0.3362202 -0.03874875 -0.02545092  0.215858780
#> 3 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.2008503  0.3362202 -0.03874875 -0.02545092  0.215858780
#> 4  0.44890201 -0.50497001 -0.3773840 0.10423600 -0.2221160 -0.0152136 -0.13729800 -0.11480500 -0.000516588
#>       emb_127    emb_128    emb_129   emb_130    emb_131    emb_132    emb_133   emb_134     emb_135
#> 1  0.18743195 -0.1760265 0.04850590 0.1650389 -0.0869168 -0.1351280  0.3553796 0.0439451 -0.14388600
#> 2 -0.04820869  0.1341518 0.08491383 0.2148582 -0.2620188 -0.0466188  0.1594945 0.2457754 -0.04687785
#> 3 -0.04820869  0.1341518 0.08491383 0.2148582 -0.2620188 -0.0466188  0.1594945 0.2457754 -0.04687785
#> 4  0.27843499 -0.5077260 0.00681453 0.3277110 -0.4575990  0.0445853 -0.2659470 0.1689170 -0.03073480
#>      emb_136    emb_137     emb_138    emb_139     emb_140     emb_141     emb_142     emb_143     emb_144
#> 1 0.18447500 -0.1728330 -0.07085245 -0.1352220 -0.01319685 -0.04477785 -0.22785043 -0.04604255  0.03854025
#> 2 0.02120483 -0.2707188 -0.05038439 -0.2153107 -0.21424630  0.12730155  0.04358483 -0.04084410  0.08556246
#> 3 0.02120483 -0.2707188 -0.05038439 -0.2153107 -0.21424630  0.12730155  0.04358483 -0.04084410  0.08556246
#> 4 0.05147280 -0.5484980  0.29294801  0.0126988  0.23700000  0.24597199  0.00283213 -0.32100201 -0.10307100
#>        emb_145    emb_146    emb_147    emb_148    emb_149   emb_150     emb_151    emb_152     emb_153
#> 1 -0.001207002  0.0199298 -0.0356609  0.1774600 0.05504915 0.3614325 -0.10194990 -0.1231980  0.09042259
#> 2  0.371933013 -0.2329763  0.1678678 -0.1552295 0.13361997 0.4047717 -0.07385027  0.2168649  0.08279617
#> 3  0.371933013 -0.2329763  0.1678678 -0.1552295 0.13361997 0.4047717 -0.07385027  0.2168649  0.08279617
#> 4  0.053842101  0.1416480 -0.0917289  0.2749980 0.23646900 0.0516106  0.31944901  0.2596070 -0.20201600
#>       emb_154     emb_155    emb_156    emb_157     emb_158     emb_159    emb_160    emb_161     emb_162
#> 1  0.05251455 0.206383746 -0.3278625  0.1507888 -0.24059631  0.13328750 -0.1542910 -0.4659765  0.24411549
#> 2  0.02853568 0.007983398 -0.2673024 -0.3518553  0.07097678  0.08358909 -0.1986835 -0.2990164 -0.01896982
#> 3  0.02853568 0.007983398 -0.2673024 -0.3518553  0.07097678  0.08358909 -0.1986835 -0.2990164 -0.01896982
#> 4 -0.03634640 0.132135004 -0.4019700 -0.3961210  0.22471200 -0.28615400 -0.2248820  0.0843519  0.12150900
#>       emb_163    emb_164    emb_165  emb_166     emb_167    emb_168    emb_169    emb_170     emb_171
#> 1 -0.02086000  0.0724380 -0.2592130 0.023408  0.08613185  0.0379848  0.1708320 0.10344110  0.05256875
#> 2 -0.05220042  0.1262764  0.1060794 0.032170 -0.25643115 -0.1073976  0.2646226 0.03679075 -0.21739347
#> 3 -0.05220042  0.1262764  0.1060794 0.032170 -0.25643115 -0.1073976  0.2646226 0.03679075 -0.21739347
#> 4  0.07793430 -0.3778230  0.1211260 0.322682 -0.25913599 -0.0354177 -0.0709271 0.28492600 -0.01546810
#>       emb_172    emb_173     emb_174     emb_175    emb_176    emb_177    emb_178    emb_179     emb_180
#> 1 -0.24780465  0.1541627 -0.29331779 -0.20218500 -0.2854457 -0.2098115 -0.0575373  0.0933315 -0.02847625
#> 2  0.07656907 -0.1012526 -0.02410151 -0.02048860 -0.1179298  0.2362113  0.3087631 -0.2262567  0.07487945
#> 3  0.07656907 -0.1012526 -0.02410151 -0.02048860 -0.1179298  0.2362113  0.3087631 -0.2262567  0.07487945
#> 4  0.70878100  0.0050526  0.35008600 -0.00414608 -0.2252000 -0.0747713  0.4789120 -0.0237339  0.00665774
#>        emb_181     emb_182    emb_183     emb_184     emb_185     emb_186     emb_187     emb_188
#> 1  0.056193449  0.14986500 -0.0199960  0.03433951  0.29836451 -0.06596650 -0.03161745 -0.14970050
#> 2  0.008851715 -0.10242634 -0.2249113 -0.06455390  0.07631866  0.01623236 -0.10981955 -0.04689731
#> 3  0.008851715 -0.10242634 -0.2249113 -0.06455390  0.07631866  0.01623236 -0.10981955 -0.04689731
#> 4 -0.295183003  0.00914423 -0.4879910 -0.01199450 -0.19777000  0.25575000  0.21581100  0.49597701
#>       emb_189      emb_190     emb_191    emb_192     emb_193    emb_194     emb_195     emb_196
#> 1 -0.26550250 -0.008331001  0.18572189 0.01427650  0.06334415 -0.4169105  0.03094655  0.07673699
#> 2 -0.03368506  0.162708722 -0.05825762 0.06944699 -0.05563271 -0.1747903 -0.13635058  0.12910799
#> 3 -0.03368506  0.162708722 -0.05825762 0.06944699 -0.05563271 -0.1747903 -0.13635058  0.12910799
#> 4  0.05313870  0.218498006  0.12104800 0.04292490 -0.46514499 -0.0659737 -0.16488799 -0.23377600
#>       emb_197     emb_198     emb_199     emb_200
#> 1  0.44684301  0.07616243 -0.06888550 -0.47865451
#> 2 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 3 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 4 -0.20433401 -0.31397000  0.16799000 -0.57338899
#>  [ reached 'max' / getOption("max.print") -- omitted 1 rows ]

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(
    mtsamples[1:5, 1:2],
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   note_id                                                      description   emb_001  emb_002   emb_003
#> 1       1 A 23-year-old white female presents with complaint of allergies.        NA       NA        NA
#> 2       2                         Consult for laparoscopic gastric bypass.        NA       NA        NA
#> 3       3                         Consult for laparoscopic gastric bypass.        NA       NA        NA
#> 4       4                                             2-D M-Mode. Doppler. -0.404423 0.217982 -0.435959
#>      emb_004    emb_005    emb_006   emb_007 emb_008  emb_009   emb_010   emb_011   emb_012  emb_013
#> 1         NA         NA         NA        NA      NA       NA        NA        NA        NA       NA
#> 2         NA         NA         NA        NA      NA       NA        NA        NA        NA       NA
#> 3         NA         NA         NA        NA      NA       NA        NA        NA        NA       NA
#> 4 -0.0518142 -0.0757723 -0.0336005 -0.180841  0.2608 0.418156 -0.204654 -0.257289 -0.425023 0.731058
#>     emb_014    emb_015   emb_016   emb_017   emb_018    emb_019   emb_020   emb_021   emb_022   emb_023
#> 1        NA         NA        NA        NA        NA         NA        NA        NA        NA        NA
#> 2        NA         NA        NA        NA        NA         NA        NA        NA        NA        NA
#> 3        NA         NA        NA        NA        NA         NA        NA        NA        NA        NA
#> 4 -0.124999 -0.0563767 -0.299543 -0.294106 -0.247846 -0.0287432 0.0679117 0.0287295 -0.020798 -0.289208
#>    emb_024  emb_025  emb_026  emb_027  emb_028   emb_029  emb_030   emb_031   emb_032   emb_033   emb_034
#> 1       NA       NA       NA       NA       NA        NA       NA        NA        NA        NA        NA
#> 2       NA       NA       NA       NA       NA        NA       NA        NA        NA        NA        NA
#> 3       NA       NA       NA       NA       NA        NA       NA        NA        NA        NA        NA
#> 4 0.281342 0.625599 0.428111 0.206463 0.229698 -0.746509 0.355792 -0.410843 -0.548994 0.0451901 -0.219888
#>     emb_035   emb_036   emb_037   emb_038   emb_039  emb_040    emb_041  emb_042    emb_043  emb_044
#> 1        NA        NA        NA        NA        NA       NA         NA       NA         NA       NA
#> 2        NA        NA        NA        NA        NA       NA         NA       NA         NA       NA
#> 3        NA        NA        NA        NA        NA       NA         NA       NA         NA       NA
#> 4 0.0889601 -0.347043 -0.219915 -0.161985 -0.535984 0.340435 -0.0483518 0.367414 -0.0885881 0.664886
#>     emb_045   emb_046  emb_047   emb_048 emb_049  emb_050  emb_051  emb_052  emb_053   emb_054   emb_055
#> 1        NA        NA       NA        NA      NA       NA       NA       NA       NA        NA        NA
#> 2        NA        NA       NA        NA      NA       NA       NA       NA       NA        NA        NA
#> 3        NA        NA       NA        NA      NA       NA       NA       NA       NA        NA        NA
#> 4 -0.065601 -0.593704 0.628767 0.0613332 0.02835 -0.15147 0.224448 0.586741 0.038137 -0.135616 -0.384492
#>      emb_056   emb_057   emb_058   emb_059  emb_060    emb_061  emb_062    emb_063    emb_064  emb_065
#> 1         NA        NA        NA        NA       NA         NA       NA         NA         NA       NA
#> 2         NA        NA        NA        NA       NA         NA       NA         NA         NA       NA
#> 3         NA        NA        NA        NA       NA         NA       NA         NA         NA       NA
#> 4 -0.0473909 0.0369035 -0.155995 -0.248292 0.500811 -0.0982668 0.716812 -0.0341672 -0.0254562 0.015033
#>   emb_066  emb_067  emb_068  emb_069    emb_070  emb_071    emb_072 emb_073    emb_074  emb_075  emb_076
#> 1      NA       NA       NA       NA         NA       NA         NA      NA         NA       NA       NA
#> 2      NA       NA       NA       NA         NA       NA         NA      NA         NA       NA       NA
#> 3      NA       NA       NA       NA         NA       NA         NA      NA         NA       NA       NA
#> 4 -0.5353 0.218229 0.511924 0.496677 0.00565767 -0.34958 -0.0573394 0.16006 0.00709061 0.293935 0.193235
#>     emb_077  emb_078   emb_079   emb_080   emb_081   emb_082   emb_083   emb_084    emb_085   emb_086
#> 1        NA       NA        NA        NA        NA        NA        NA        NA         NA        NA
#> 2        NA       NA        NA        NA        NA        NA        NA        NA         NA        NA
#> 3        NA       NA        NA        NA        NA        NA        NA        NA         NA        NA
#> 4 0.0990487 0.102691 -0.442698 -0.304406 -0.324608 -0.623086 -0.246082 -0.248439 -0.0256765 -0.514465
#>   emb_087   emb_088   emb_089   emb_090  emb_091   emb_092  emb_093  emb_094   emb_095  emb_096  emb_097
#> 1      NA        NA        NA        NA       NA        NA       NA       NA        NA       NA       NA
#> 2      NA        NA        NA        NA       NA        NA       NA       NA        NA       NA       NA
#> 3      NA        NA        NA        NA       NA        NA       NA       NA        NA       NA       NA
#> 4 0.20912 -0.396285 -0.384794 0.0601322 0.188105 0.0293956 0.151069 0.157584 -0.188499 0.556796 0.159774
#>     emb_098   emb_099   emb_100  emb_101  emb_102 emb_103   emb_104      emb_105  emb_106  emb_107
#> 1        NA        NA        NA       NA       NA      NA        NA           NA       NA       NA
#> 2        NA        NA        NA       NA       NA      NA        NA           NA       NA       NA
#> 3        NA        NA        NA       NA       NA      NA        NA           NA       NA       NA
#> 4 -0.219908 0.0361496 0.0950609 0.311842 0.472694 0.18948 0.0198733 -0.000530505 0.254745 0.383381
#>     emb_108  emb_109  emb_110   emb_111   emb_112   emb_113   emb_114   emb_115   emb_116  emb_117
#> 1        NA       NA       NA        NA        NA        NA        NA        NA        NA       NA
#> 2        NA       NA       NA        NA        NA        NA        NA        NA        NA       NA
#> 3        NA       NA       NA        NA        NA        NA        NA        NA        NA       NA
#> 4 0.0516758 0.645367 0.109327 -0.209912 -0.218824 -0.504148 -0.105097 -0.505374 -0.065512 0.127347
#>    emb_118  emb_119   emb_120  emb_121   emb_122    emb_123   emb_124   emb_125      emb_126  emb_127
#> 1       NA       NA        NA       NA        NA         NA        NA        NA           NA       NA
#> 2       NA       NA        NA       NA        NA         NA        NA        NA           NA       NA
#> 3       NA       NA        NA       NA        NA         NA        NA        NA           NA       NA
#> 4 0.448902 -0.50497 -0.377384 0.104236 -0.222116 -0.0152136 -0.137298 -0.114805 -0.000516588 0.278435
#>     emb_128    emb_129  emb_130   emb_131   emb_132   emb_133  emb_134    emb_135   emb_136   emb_137
#> 1        NA         NA       NA        NA        NA        NA       NA         NA        NA        NA
#> 2        NA         NA       NA        NA        NA        NA       NA         NA        NA        NA
#> 3        NA         NA       NA        NA        NA        NA       NA         NA        NA        NA
#> 4 -0.507726 0.00681453 0.327711 -0.457599 0.0445853 -0.265947 0.168917 -0.0307348 0.0514728 -0.548498
#>    emb_138   emb_139 emb_140  emb_141    emb_142   emb_143   emb_144   emb_145  emb_146    emb_147
#> 1       NA        NA      NA       NA         NA        NA        NA        NA       NA         NA
#> 2       NA        NA      NA       NA         NA        NA        NA        NA       NA         NA
#> 3       NA        NA      NA       NA         NA        NA        NA        NA       NA         NA
#> 4 0.292948 0.0126988   0.237 0.245972 0.00283213 -0.321002 -0.103071 0.0538421 0.141648 -0.0917289
#>    emb_148  emb_149   emb_150  emb_151  emb_152   emb_153    emb_154  emb_155  emb_156   emb_157  emb_158
#> 1       NA       NA        NA       NA       NA        NA         NA       NA       NA        NA       NA
#> 2       NA       NA        NA       NA       NA        NA         NA       NA       NA        NA       NA
#> 3       NA       NA        NA       NA       NA        NA         NA       NA       NA        NA       NA
#> 4 0.274998 0.236469 0.0516106 0.319449 0.259607 -0.202016 -0.0363464 0.132135 -0.40197 -0.396121 0.224712
#>     emb_159   emb_160   emb_161  emb_162   emb_163   emb_164  emb_165  emb_166   emb_167    emb_168
#> 1        NA        NA        NA       NA        NA        NA       NA       NA        NA         NA
#> 2        NA        NA        NA       NA        NA        NA       NA       NA        NA         NA
#> 3        NA        NA        NA       NA        NA        NA       NA       NA        NA         NA
#> 4 -0.286154 -0.224882 0.0843519 0.121509 0.0779343 -0.377823 0.121126 0.322682 -0.259136 -0.0354177
#>      emb_169  emb_170    emb_171  emb_172   emb_173  emb_174     emb_175 emb_176    emb_177  emb_178
#> 1         NA       NA         NA       NA        NA       NA          NA      NA         NA       NA
#> 2         NA       NA         NA       NA        NA       NA          NA      NA         NA       NA
#> 3         NA       NA         NA       NA        NA       NA          NA      NA         NA       NA
#> 4 -0.0709271 0.284926 -0.0154681 0.708781 0.0050526 0.350086 -0.00414608 -0.2252 -0.0747713 0.478912
#>      emb_179    emb_180   emb_181    emb_182   emb_183    emb_184  emb_185 emb_186  emb_187  emb_188
#> 1         NA         NA        NA         NA        NA         NA       NA      NA       NA       NA
#> 2         NA         NA        NA         NA        NA         NA       NA      NA       NA       NA
#> 3         NA         NA        NA         NA        NA         NA       NA      NA       NA       NA
#> 4 -0.0237339 0.00665774 -0.295183 0.00914423 -0.487991 -0.0119945 -0.19777 0.25575 0.215811 0.495977
#>     emb_189  emb_190  emb_191   emb_192   emb_193    emb_194   emb_195   emb_196   emb_197  emb_198
#> 1        NA       NA       NA        NA        NA         NA        NA        NA        NA       NA
#> 2        NA       NA       NA        NA        NA         NA        NA        NA        NA       NA
#> 3        NA       NA       NA        NA        NA         NA        NA        NA        NA       NA
#> 4 0.0531387 0.218498 0.121048 0.0429249 -0.465145 -0.0659737 -0.164888 -0.233776 -0.204334 -0.31397
#>   emb_199   emb_200
#> 1      NA        NA
#> 2      NA        NA
#> 3      NA        NA
#> 4 0.16799 -0.573389
#>  [ reached 'max' / getOption("max.print") -- omitted 1 rows ]
```

### Cui2vec embeddings (with the UMLS linker)

These are only available with the UMLS linker enabled.

``` r
clinspacy_output_file %>% 
  bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                            type = 'cui2vec')
#>   note_id                                                      description     emb_001    emb_002
#> 1       1 A 23-year-old white female presents with complaint of allergies. -0.02252676 0.00981737
#>         emb_003     emb_004    emb_005    emb_006    emb_007     emb_008    emb_009      emb_010
#> 1 -7.112366e-17 -0.01571537 0.00204883 0.02170382 0.01609939 0.003568635 0.02458248 1.977585e-16
#>       emb_011      emb_012     emb_013      emb_014   emb_015   emb_016    emb_017      emb_018   emb_019
#> 1 -0.05962307 -0.008812967 -0.05095455 -0.007019787 0.4848431 0.2194544 -0.6475081 1.717376e-16 0.1277355
#>      emb_020     emb_021   emb_022    emb_023     emb_024    emb_025     emb_026    emb_027     emb_028
#> 1 0.04418587 -0.04027616 0.0224725 0.02733842 -0.05324886 0.03197106 -0.05140098 0.02976971 -0.01658289
#>       emb_029    emb_030      emb_031     emb_032    emb_033     emb_034     emb_035       emb_036
#> 1 -0.01727859 0.01355219 0.0004027671 0.007869617 0.01808029 6.07717e-15 -0.01680331 -2.575197e-15
#>      emb_037     emb_038     emb_039     emb_040    emb_041     emb_042    emb_043   emb_044     emb_045
#> 1 0.02488002 -0.05193516 -0.05083492 -0.03398615 -0.0304396 -0.01846804 0.02507359 0.0274111 -0.08868074
#>     emb_046  emb_047   emb_048      emb_049     emb_050   emb_051     emb_052      emb_053     emb_054
#> 1 0.5189593 -0.23715 0.0272105 8.193099e-15 -0.09418647 0.1057138 -0.03374484 5.385449e-15 0.004169957
#>      emb_055     emb_056   emb_057      emb_058    emb_059    emb_060     emb_061    emb_062     emb_063
#> 1 0.02916454 0.000767252 -0.023877 5.698567e-16 0.03225596 0.01607688 -0.03766193 0.04989472 -0.06102908
#>       emb_064    emb_065      emb_066    emb_067   emb_068    emb_069    emb_070    emb_071    emb_072
#> 1 -0.05750962 0.02694655 1.700029e-15 0.01284977 0.0564261 0.04328977 0.06140459 -0.1313167 0.02708954
#>       emb_073      emb_074     emb_075     emb_076     emb_077       emb_078     emb_079     emb_080
#> 1 -0.09223539 9.874046e-15 -0.08319119 -0.01526813 -0.07021844 -9.965986e-16 -0.04869493 0.006768264
#>       emb_081    emb_082    emb_083     emb_084     emb_085      emb_086    emb_087       emb_088
#> 1 -0.09788984 0.03958838 0.01583116 0.005023461 -0.02341873 6.383782e-16 0.04267045 -9.714451e-17
#>      emb_089     emb_090     emb_091     emb_092    emb_093    emb_094     emb_095    emb_096   emb_097
#> 1 0.01116146 -0.06577457 -0.02950314 -0.06745406 -0.1829168 0.07381102 2.13242e-14 0.02173384 0.1598195
#>        emb_098    emb_099   emb_100    emb_101     emb_102     emb_103       emb_104    emb_105    emb_106
#> 1 3.476386e-15 0.01861779 -0.062215 0.03379738 -0.03003185 -0.04093144 -1.540911e-14 -0.0582552 0.01874226
#>        emb_107     emb_108     emb_109      emb_110     emb_111      emb_112    emb_113   emb_114  emb_115
#> 1 3.941075e-15 0.003131358 -0.06099596 -5.71522e-14 -0.03669359 -0.007576985 0.01756546 0.1284883 0.113703
#>      emb_116    emb_117    emb_118    emb_119    emb_120   emb_121   emb_122     emb_123       emb_124
#> 1 -0.0238271 0.09462345 0.04085265 0.03767805 -0.1051924 0.1604939 0.1353456 0.005841483 -6.225784e-13
#>     emb_125     emb_126    emb_127    emb_128      emb_129    emb_130     emb_131      emb_132    emb_133
#> 1 0.1115687 -0.09071953 -0.1412847 0.04848182 3.645695e-14 0.03299475 -0.04259208 -4.44228e-14 0.02351978
#>       emb_134    emb_135     emb_136     emb_137     emb_138       emb_139      emb_140    emb_141
#> 1 -0.07342256 0.05125837 -0.02233626 -0.04252563 0.002613812 -5.011616e-14 -0.004584951 0.07821294
#>       emb_142     emb_143    emb_144     emb_145    emb_146   emb_147       emb_148   emb_149    emb_150
#> 1 -0.01524519 0.009835264 -0.1024103 -0.01618703 0.05178624 -0.122875 -3.362533e-13 0.2116649 0.09871158
#>         emb_151   emb_152     emb_153     emb_154      emb_155    emb_156   emb_157      emb_158
#> 1 -3.753942e-14 0.0542951 -0.02123913 0.009087746 6.542371e-13 -0.1118374 -0.042367 -0.005429649
#>       emb_159    emb_160     emb_161    emb_162     emb_163     emb_164   emb_165    emb_166       emb_167
#> 1 -0.03997963 0.02529487 -0.07262923 0.09202077 6.41826e-15 -0.01385535 0.3111068 -0.1649014 -6.451471e-13
#>     emb_168   emb_169    emb_170    emb_171      emb_172   emb_173   emb_174  emb_175       emb_176
#> 1 0.1299173 0.1610336 -0.1404372 0.07697108 1.090031e-13 0.2931891 0.1876497 0.075052 -1.667208e-13
#>    emb_177       emb_178     emb_179   emb_180     emb_181    emb_182    emb_183       emb_184  emb_185
#> 1 0.115734 -0.0007481341 -0.01577043 0.1431122 -0.05766787 0.03475884 -0.1093477 -1.619687e-12 0.386924
#>      emb_186    emb_187    emb_188       emb_189    emb_190   emb_191   emb_192    emb_193       emb_194
#> 1 0.09828006 -0.1381044 -0.2125747 -4.596133e-13 0.03605011 0.0320109 0.0259981 0.01226001 -4.061855e-13
#>     emb_195     emb_196   emb_197    emb_198    emb_199      emb_200    emb_201   emb_202     emb_203
#> 1 0.0165447 -0.06744392 0.1435013 -0.1109321 -0.1028112 1.887427e-13 0.07968394 0.0751175 0.004766901
#>         emb_204     emb_205    emb_206       emb_207    emb_208    emb_209   emb_210      emb_211
#> 1 -0.0004119858 -0.03802628 0.05789085 -3.663111e-13 0.01678592 0.02710287 0.2343711 -0.002354262
#>      emb_212   emb_213       emb_214    emb_215       emb_216     emb_217     emb_218       emb_219
#> 1 -0.1581578 0.1010161 -1.338513e-13 0.05365102 -1.850377e-13 -0.03349012 -0.07603876 -7.044122e-13
#>    emb_220   emb_221    emb_222    emb_223  emb_224    emb_225       emb_226    emb_227   emb_228
#> 1 0.200557 -0.197757 -0.1426113 -0.2378831 0.202263 -0.1696606 -6.143402e-13 0.05760328 0.1018192
#>     emb_229   emb_230      emb_231   emb_232   emb_233      emb_234     emb_235    emb_236    emb_237
#> 1 0.2497763 0.1092847 -2.48624e-13 0.2455612 0.1465039 1.093941e-12 -0.02328777 -0.2314412 -0.0438067
#>         emb_238   emb_239     emb_240      emb_241    emb_242    emb_243     emb_244    emb_245
#> 1 -1.318785e-12 0.1924455 -0.02946334 9.410181e-14 0.01914939 -0.2166271 -0.09922424 0.07917902
#>        emb_246     emb_247     emb_248    emb_249    emb_250    emb_251      emb_252    emb_253
#> 1 1.117179e-13 -0.04181635 -0.02326105 -0.2053453 -0.1043094 0.06921736 1.651977e-13 0.02899378
#>       emb_254       emb_255   emb_256    emb_257     emb_258      emb_259     emb_260    emb_261   emb_262
#> 1 -0.05111182 -2.322604e-13 0.0643626 -0.1239991 -0.02485159 3.495121e-13 -0.02591409 0.05876728 0.1267387
#>     emb_263    emb_264    emb_265    emb_266      emb_267    emb_268    emb_269   emb_270   emb_271
#> 1 0.1697931 0.04425644 0.06932541 0.08447763 4.105744e-13 0.06852518 7.4072e-13 0.3007398 0.1579384
#>        emb_272    emb_273     emb_274     emb_275     emb_276    emb_277    emb_278   emb_279    emb_280
#> 1 1.556563e-12 0.05393523 -0.01604795 -0.03712245 -0.09491087 0.03609613 -0.2231043 0.2157738 0.08175604
#>        emb_281    emb_282    emb_283     emb_284     emb_285   emb_286      emb_287     emb_288   emb_289
#> 1 2.959365e-12 0.06861465 0.08550272 -0.09220862 -0.04629147 0.1017743 3.535314e-13 -0.01340135 0.1893037
#>       emb_290   emb_291     emb_292      emb_293   emb_294     emb_295    emb_296   emb_297      emb_298
#> 1 -0.05125827 0.1924633 1.19612e-12 0.0008553113 0.1083906 -0.02867893 -0.2015106 0.1560092 1.417973e-12
#>      emb_299     emb_300    emb_301     emb_302   emb_303   emb_304       emb_305    emb_306       emb_307
#> 1 0.02863877 -0.04337675 -0.0081157 -0.06920189 0.1312242 0.1081507 -1.102479e-12 -0.1477602 -1.895359e-13
#>      emb_308    emb_309      emb_310    emb_311    emb_312     emb_313      emb_314    emb_315     emb_316
#> 1 0.03814512 0.03845589 6.182173e-13 0.03576535 -0.1532176 -0.03636131 -0.007627942 0.06031904 -0.06655534
#>       emb_317    emb_318     emb_319    emb_320       emb_321     emb_322     emb_323      emb_324
#> 1 -0.07489772 -0.1516626 0.003793281 0.04073214 -1.811211e-12 -0.07503901 -0.01189371 1.366615e-14
#>      emb_325   emb_326      emb_327     emb_328    emb_329      emb_330    emb_331      emb_332
#> 1 0.03970591 -0.128616 5.490235e-13 0.001528091 0.08797088 3.158081e-13 -0.1069969 -0.001063149
#>        emb_333   emb_334      emb_335      emb_336    emb_337   emb_338    emb_339       emb_340
#> 1 -0.005434974 0.1420723 1.122465e-12 -0.005527229 0.07377412 0.0362955 0.03584002 -5.913603e-13
#>      emb_341     emb_342   emb_343    emb_344    emb_345      emb_346     emb_347   emb_348       emb_349
#> 1 0.05666617 1.37685e-12 0.1219644 0.06781911 0.05703174 7.353701e-13 -0.06970177 0.1073669 -1.002653e-12
#>       emb_350    emb_351     emb_352     emb_353    emb_354     emb_355    emb_356      emb_357
#> 1 -0.03433839 0.04959829 -0.01152345 -0.03008883 0.01355744 -0.04858236 0.07594777 4.642875e-13
#>       emb_358  emb_359       emb_360    emb_361      emb_362    emb_363    emb_364     emb_365
#> 1 -0.01485394 0.033302 -1.618592e-13 0.08298598 1.546975e-11 0.05168612 0.08176525 -0.03674358
#>        emb_366      emb_367    emb_368       emb_369     emb_370     emb_371    emb_372       emb_373
#> 1 5.973659e-13 -0.004125437 -0.0819908 -5.833528e-14 -0.07765797 -0.06267873 0.02645854 -3.526366e-13
#>       emb_374     emb_375   emb_376     emb_377      emb_378    emb_379     emb_380     emb_381
#> 1 -0.03718981 0.008616062 0.0224653 -0.03520099 -4.68711e-13 -0.0292268 -0.06056906 -0.07928749
#>       emb_382     emb_383      emb_384      emb_385    emb_386    emb_387     emb_388       emb_389
#> 1 -0.02646825 0.007329379 -0.005763795 7.593232e-14 0.05582895 0.01061154 -0.03703419 -3.829072e-13
#>       emb_390       emb_391     emb_392    emb_393     emb_394    emb_395      emb_396     emb_397
#> 1 -0.01169879 -8.778742e-14 -0.06417041 0.02386562 -0.01780184 0.09558607 3.355354e-13 -0.01448336
#>       emb_398     emb_399     emb_400    emb_401       emb_402     emb_403     emb_404       emb_405
#> 1 -0.01587016 -0.05017494 -0.02272941 0.08855266 -7.273587e-13 -0.02213536 0.009579723 -1.349598e-12
#>       emb_406   emb_407       emb_408     emb_409    emb_410    emb_411     emb_412    emb_413     emb_414
#> 1 -0.06046628 0.0222808 -1.162896e-12 -0.02611316 0.04627582 0.06567198 0.005200619 0.07800706 0.007994711
#>        emb_415     emb_416      emb_417    emb_418       emb_419    emb_420    emb_421      emb_422
#> 1 3.491497e-11 -0.00302457 -9.01992e-12 0.03000403 -2.323254e-11 0.08292666 0.06809955 4.825933e-08
#>       emb_423     emb_424     emb_425     emb_426      emb_427     emb_428    emb_429      emb_430
#> 1 0.004738483 -0.02087908 -0.06877249 -0.03153641 1.491751e-06 0.009662701 0.03880813 2.841172e-06
#>     emb_431   emb_432     emb_433    emb_434    emb_435      emb_436     emb_437    emb_438     emb_439
#> 1 0.1177402 0.1259503 -0.01493607 0.03456909 0.03802679 -0.009059252 -0.02631128 0.06807823 -0.05522543
#>      emb_440    emb_441     emb_442      emb_443     emb_444    emb_445     emb_446    emb_447     emb_448
#> 1 -0.0745836 -0.0211531 0.005163625 -0.003816484 0.007895069 -0.0364456 -0.02535755 0.07281245 -0.00296777
#>        emb_449    emb_450     emb_451    emb_452     emb_453     emb_454     emb_455    emb_456
#> 1 -0.000181102 0.06233121 -0.01770128 0.01265782 -0.01279358 -0.01044367 -0.03101999 0.02740463
#>         emb_457 emb_458     emb_459     emb_460   emb_461    emb_462     emb_463    emb_464     emb_465
#> 1 -0.0001330363 0.10753 -0.01484507 -0.07349805 0.0204221 0.02640545 -0.07045606 0.02300039 0.009929864
#>      emb_466    emb_467    emb_468     emb_469    emb_470    emb_471     emb_472    emb_473     emb_474
#> 1 -0.0440257 0.06819039 0.06415205 -0.03816748 0.03239364 0.01815103 0.008630568 -0.0256615 -0.02014205
#>       emb_475    emb_476    emb_477     emb_478    emb_479      emb_480   emb_481     emb_482   emb_483
#> 1 -0.09551212 0.02999266 0.01480565 -0.02303127 0.06804205 -0.003071631 0.1401947 0.001857697 0.0619581
#>      emb_484      emb_485    emb_486    emb_487     emb_488    emb_489    emb_490    emb_491     emb_492
#> 1 0.01584125 -0.005346804 0.01145756 0.08401278 -0.03810937 0.03734662 -0.0611351 -0.0580643 -0.04283529
#>       emb_493    emb_494     emb_495     emb_496    emb_497     emb_498     emb_499     emb_500
#> 1 -0.04707387 0.06412033 0.001128669 -0.01307035 0.04326674 0.001324095 -0.04199037 -0.01633916
#>  [ reached 'max' / getOption("max.print") -- omitted 4 rows ]

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(
    mtsamples[1:5, 1:2],
    type = 'cui2vec',
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   note_id                                                      description emb_001 emb_002 emb_003 emb_004
#> 1       1 A 23-year-old white female presents with complaint of allergies.      NA      NA      NA      NA
#>   emb_005 emb_006 emb_007 emb_008 emb_009 emb_010 emb_011 emb_012 emb_013 emb_014 emb_015 emb_016 emb_017
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_018 emb_019 emb_020 emb_021 emb_022 emb_023 emb_024 emb_025 emb_026 emb_027 emb_028 emb_029 emb_030
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_031 emb_032 emb_033 emb_034 emb_035 emb_036 emb_037 emb_038 emb_039 emb_040 emb_041 emb_042 emb_043
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_044 emb_045 emb_046 emb_047 emb_048 emb_049 emb_050 emb_051 emb_052 emb_053 emb_054 emb_055 emb_056
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_057 emb_058 emb_059 emb_060 emb_061 emb_062 emb_063 emb_064 emb_065 emb_066 emb_067 emb_068 emb_069
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_070 emb_071 emb_072 emb_073 emb_074 emb_075 emb_076 emb_077 emb_078 emb_079 emb_080 emb_081 emb_082
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_083 emb_084 emb_085 emb_086 emb_087 emb_088 emb_089 emb_090 emb_091 emb_092 emb_093 emb_094 emb_095
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_096 emb_097 emb_098 emb_099 emb_100 emb_101 emb_102 emb_103 emb_104 emb_105 emb_106 emb_107 emb_108
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_109 emb_110 emb_111 emb_112 emb_113 emb_114 emb_115 emb_116 emb_117 emb_118 emb_119 emb_120 emb_121
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_122 emb_123 emb_124 emb_125 emb_126 emb_127 emb_128 emb_129 emb_130 emb_131 emb_132 emb_133 emb_134
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_135 emb_136 emb_137 emb_138 emb_139 emb_140 emb_141 emb_142 emb_143 emb_144 emb_145 emb_146 emb_147
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_148 emb_149 emb_150 emb_151 emb_152 emb_153 emb_154 emb_155 emb_156 emb_157 emb_158 emb_159 emb_160
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_161 emb_162 emb_163 emb_164 emb_165 emb_166 emb_167 emb_168 emb_169 emb_170 emb_171 emb_172 emb_173
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_174 emb_175 emb_176 emb_177 emb_178 emb_179 emb_180 emb_181 emb_182 emb_183 emb_184 emb_185 emb_186
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_187 emb_188 emb_189 emb_190 emb_191 emb_192 emb_193 emb_194 emb_195 emb_196 emb_197 emb_198 emb_199
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_200 emb_201 emb_202 emb_203 emb_204 emb_205 emb_206 emb_207 emb_208 emb_209 emb_210 emb_211 emb_212
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_213 emb_214 emb_215 emb_216 emb_217 emb_218 emb_219 emb_220 emb_221 emb_222 emb_223 emb_224 emb_225
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_226 emb_227 emb_228 emb_229 emb_230 emb_231 emb_232 emb_233 emb_234 emb_235 emb_236 emb_237 emb_238
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_239 emb_240 emb_241 emb_242 emb_243 emb_244 emb_245 emb_246 emb_247 emb_248 emb_249 emb_250 emb_251
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_252 emb_253 emb_254 emb_255 emb_256 emb_257 emb_258 emb_259 emb_260 emb_261 emb_262 emb_263 emb_264
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_265 emb_266 emb_267 emb_268 emb_269 emb_270 emb_271 emb_272 emb_273 emb_274 emb_275 emb_276 emb_277
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_278 emb_279 emb_280 emb_281 emb_282 emb_283 emb_284 emb_285 emb_286 emb_287 emb_288 emb_289 emb_290
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_291 emb_292 emb_293 emb_294 emb_295 emb_296 emb_297 emb_298 emb_299 emb_300 emb_301 emb_302 emb_303
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_304 emb_305 emb_306 emb_307 emb_308 emb_309 emb_310 emb_311 emb_312 emb_313 emb_314 emb_315 emb_316
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_317 emb_318 emb_319 emb_320 emb_321 emb_322 emb_323 emb_324 emb_325 emb_326 emb_327 emb_328 emb_329
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_330 emb_331 emb_332 emb_333 emb_334 emb_335 emb_336 emb_337 emb_338 emb_339 emb_340 emb_341 emb_342
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_343 emb_344 emb_345 emb_346 emb_347 emb_348 emb_349 emb_350 emb_351 emb_352 emb_353 emb_354 emb_355
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_356 emb_357 emb_358 emb_359 emb_360 emb_361 emb_362 emb_363 emb_364 emb_365 emb_366 emb_367 emb_368
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_369 emb_370 emb_371 emb_372 emb_373 emb_374 emb_375 emb_376 emb_377 emb_378 emb_379 emb_380 emb_381
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_382 emb_383 emb_384 emb_385 emb_386 emb_387 emb_388 emb_389 emb_390 emb_391 emb_392 emb_393 emb_394
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_395 emb_396 emb_397 emb_398 emb_399 emb_400 emb_401 emb_402 emb_403 emb_404 emb_405 emb_406 emb_407
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_408 emb_409 emb_410 emb_411 emb_412 emb_413 emb_414 emb_415 emb_416 emb_417 emb_418 emb_419 emb_420
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_421 emb_422 emb_423 emb_424 emb_425 emb_426 emb_427 emb_428 emb_429 emb_430 emb_431 emb_432 emb_433
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_434 emb_435 emb_436 emb_437 emb_438 emb_439 emb_440 emb_441 emb_442 emb_443 emb_444 emb_445 emb_446
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_447 emb_448 emb_449 emb_450 emb_451 emb_452 emb_453 emb_454 emb_455 emb_456 emb_457 emb_458 emb_459
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_460 emb_461 emb_462 emb_463 emb_464 emb_465 emb_466 emb_467 emb_468 emb_469 emb_470 emb_471 emb_472
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_473 emb_474 emb_475 emb_476 emb_477 emb_478 emb_479 emb_480 emb_481 emb_482 emb_483 emb_484 emb_485
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_486 emb_487 emb_488 emb_489 emb_490 emb_491 emb_492 emb_493 emb_494 emb_495 emb_496 emb_497 emb_498
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_499 emb_500
#> 1      NA      NA
#>  [ reached 'max' / getOption("max.print") -- omitted 4 rows ]
```

# UMLS CUI definitions

``` r
cui2vec_definitions = dataset_cui2vec_definitions()
head(cui2vec_definitions)
#>        cui                         semantic_type                         definition
#> 1 C0000005       Amino Acid, Peptide, or Protein     (131)I-Macroaggregated Albumin
#> 2 C0000005               Pharmacologic Substance     (131)I-Macroaggregated Albumin
#> 3 C0000005 Indicator, Reagent, or Diagnostic Aid     (131)I-Macroaggregated Albumin
#> 4 C0000039                      Organic Chemical 1,2-Dipalmitoylphosphatidylcholine
#> 5 C0000039               Pharmacologic Substance 1,2-Dipalmitoylphosphatidylcholine
#> 6 C0000052       Amino Acid, Peptide, or Protein  1,4-alpha-Glucan Branching Enzyme
```
