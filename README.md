
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clinspacy

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
<!-- badges: end -->

The goal of clinspacy is to perform biomedical named entity recognition,
Unified Medical Language System (UMLS) concept mapping, and negation
detection using the Python spaCy, scispacy, and medspacy packages.

## Installation

You can install the GitHub version of clinspacy
    with:

    remotes::install_github('ML4LHS/clinspacy', INSTALL_opts = '--no-multiarch')

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
#> Clinspacy has already been initialized. Set the use_linker argument to turn the linker on or off.
#> NULL
```

## Named entity recognition (without the UMLS linker)

The `clinspacy()` function can take a single string, a character vector,
or a data frame. It can output either a data frame or a file name.

### A single character string as input

``` r
clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#>   |                                                                                                                             |                                                                                                                     |   0%  |                                                                                                                             |=====================================================================================================================| 100%
#>   clinspacy_id      entity       lemma is_family is_historical is_hypothetical is_negated is_uncertain section_title
#> 1            1     patient     patient     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 2            1    diabetes    diabetes     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 3            1 CKD stage 3 ckd stage 3     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 4            1         HTN         htn     FALSE         FALSE           FALSE       TRUE        FALSE          <NA>

clinspacy('HISTORY: He presents with chest pain. PMH: HTN. MEDICATIONS: This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved. ALLERGIES: penicillin.', verbose = FALSE)
#>    clinspacy_id     entity      lemma is_family is_historical is_hypothetical is_negated is_uncertain        section_title
#> 1             1 chest pain chest pain     FALSE          TRUE           FALSE      FALSE        FALSE                 <NA>
#> 2             1        PMH        PMH     FALSE         FALSE           FALSE      FALSE        FALSE past_medical_history
#> 3             1        HTN        htn     FALSE         FALSE           FALSE      FALSE        FALSE past_medical_history
#> 4             1    patient    patient     FALSE         FALSE           FALSE      FALSE        FALSE          medications
#> 5             1   diabetes   diabetes     FALSE         FALSE           FALSE      FALSE        FALSE          medications
#> 6             1 omeprazole omeprazole     FALSE         FALSE           FALSE      FALSE        FALSE          medications
#> 7             1    aspirin    aspirin     FALSE         FALSE           FALSE      FALSE        FALSE          medications
#> 8             1 lisinopril lisinopril     FALSE         FALSE           FALSE      FALSE        FALSE          medications
#> 9             1  albuterol  albuterol     FALSE         FALSE           FALSE       TRUE        FALSE          medications
#> 10            1     asthma     asthma     FALSE         FALSE           FALSE       TRUE        FALSE          medications
#> 11            1 penicillin penicillin     FALSE         FALSE           FALSE      FALSE        FALSE            allergies
```

### A character vector as input

``` r
clinspacy(c('This pt has CKD and HTN', 'Pt only has CKD but no HTN'),
          verbose = FALSE)
#>   clinspacy_id entity lemma is_family is_historical is_hypothetical is_negated is_uncertain section_title
#> 1            1    CKD   ckd     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 2            1    HTN   htn     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 3            2     Pt    pt     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 4            2    CKD   ckd     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 5            2    HTN   htn     FALSE         FALSE           FALSE       TRUE        FALSE          <NA>
```

### A data frame as input

``` r
data.frame(text = c('This pt has CKD and HTN', 'Diabetes is present'),
           stringsAsFactors = FALSE) %>%
  clinspacy(df_col = 'text', verbose = FALSE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   clinspacy_id   entity    lemma is_family is_historical is_hypothetical is_negated is_uncertain section_title
#> 1            1      CKD      ckd     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 2            1      HTN      htn     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 3            2 Diabetes Diabetes     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
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
#>   clinspacy_id note_id                                                      description 2-d 2-d m-mode allergy complaint
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1         1
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0         0
#> 5            5       5                                               2-D Echocardiogram   1          0       0         0
#>   consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1       0       0              0                           0            1
#> 2       1       0              0                           1            0
#> 3       1       0              0                           1            0
#> 4       0       1              0                           0            0
#> 5       0       0              1                           0            0
```

### We can also store the intermediate result so that bind\_clinspacy() does not need to re-process the text.

``` r
clinspacy_output_data = 
  mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description', verbose = FALSE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   clinspacy_id note_id                                                      description 2-d 2-d m-mode allergy complaint
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1         1
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0         0
#> 5            5       5                                               2-D Echocardiogram   1          0       0         0
#>   consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1       0       0              0                           0            1
#> 2       1       0              0                           1            0
#> 3       1       0              0                           1            0
#> 4       0       1              0                           0            0
#> 5       0       0              1                           0            0

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 cs_col = 'entity')
#>   clinspacy_id note_id                                                      description 2-D 2-D M-Mode Consult Doppler
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       0       0
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       1       0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       1       0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0       1
#> 5            5       5                                               2-D Echocardiogram   1          0       0       0
#>   Echocardiogram allergies complaint laparoscopic gastric bypass white female
#> 1              0         1         1                           0            1
#> 2              0         0         0                           1            0
#> 3              0         0         0                           1            0
#> 4              0         0         0                           0            0
#> 5              1         0         0                           0            0

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 subset = 'is_uncertain == FALSE & is_negated == FALSE')
#>   clinspacy_id note_id                                                      description 2-d 2-d m-mode allergy complaint
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1         1
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0         0
#> 5            5       5                                               2-D Echocardiogram   1          0       0         0
#>   consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1       0       0              0                           0            1
#> 2       1       0              0                           1            0
#> 3       1       0              0                           1            0
#> 4       0       1              0                           0            0
#> 5       0       0              1                           0            0
```

### We can also re-use the output file we had created earlier and pipe this directly into bind\_clinspacy().

``` r
clinspacy_output_file
#> [1] "C:\\Users\\kdpsingh\\AppData\\Local\\clinspacy\\clinspacy/output.csv"

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   clinspacy_id note_id                                                      description 2-d 2-d m-mode allergy complaint
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1         1
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0         0
#> 5            5       5                                               2-D Echocardiogram   1          0       0         0
#>   consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1       0       0              0                           0            1
#> 2       1       0              0                           1            0
#> 3       1       0              0                           1            0
#> 4       0       1              0                           0            0
#> 5       0       0              1                           0            0

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 cs_col = 'entity')
#>   clinspacy_id note_id                                                      description 2-D 2-D M-Mode Consult Doppler
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       0       0
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       1       0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       1       0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0       1
#> 5            5       5                                               2-D Echocardiogram   1          0       0       0
#>   Echocardiogram allergies complaint laparoscopic gastric bypass white female
#> 1              0         1         1                           0            1
#> 2              0         0         0                           1            0
#> 3              0         0         0                           1            0
#> 4              0         0         0                           0            0
#> 5              1         0         0                           0            0

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 subset = 'is_uncertain == FALSE & is_negated == FALSE')
#>   clinspacy_id note_id                                                      description 2-d 2-d m-mode allergy complaint
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.   0          0       1         1
#> 2            2       2                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 3            3       3                         Consult for laparoscopic gastric bypass.   0          0       0         0
#> 4            4       4                                             2-D M-Mode. Doppler.   0          1       0         0
#> 5            5       5                                               2-D Echocardiogram   1          0       0         0
#>   consult doppler echocardiogram laparoscopic gastric bypass white female
#> 1       0       0              0                           0            1
#> 2       1       0              0                           1            0
#> 3       1       0              0                           1            0
#> 4       0       1              0                           0            0
#> 5       0       0              1                           0            0
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

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(mtsamples[1:5, 1:2])
#>   clinspacy_id note_id                                                      description    emb_001    emb_002     emb_003
#> 1            1       1 A 23-year-old white female presents with complaint of allergies. -0.1959790 0.28813400  0.09685702
#> 2            2       2                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144 -0.13519235
#> 3            3       3                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144 -0.13519235
#> 4            4       4                                             2-D M-Mode. Doppler. -0.3077586 0.25928350 -0.37220851
#>       emb_004    emb_005     emb_006      emb_007     emb_008    emb_009    emb_010    emb_011     emb_012   emb_013
#> 1 -0.20641684 -0.1554238 -0.01624470  0.027011001  0.05331314 -0.1006668  0.3682853  0.0581439 -0.29079599 0.1611375
#> 2 -0.05496463  0.1488807 -0.19577999  0.052658666 -0.10433200 -0.0763495  0.1199215 -0.1860092  0.05465447 0.1267057
#> 3 -0.05496463  0.1488807 -0.19577999  0.052658666 -0.10433200 -0.0763495  0.1199215 -0.1860092  0.05465447 0.1267057
#> 4 -0.06021732  0.0386426 -0.07756314 -0.002676249  0.22511028  0.3279995 -0.2274373 -0.1656060 -0.30020200 0.5237787
#>      emb_014     emb_015     emb_016    emb_017    emb_018    emb_019      emb_020    emb_021    emb_022     emb_023
#> 1 -0.1118952 -0.03922822  0.06888010 -0.1862742 -0.1454458 0.04115367  0.049065500 0.39795328 0.05879098  0.05246135
#> 2 -0.2041533  0.01984984 -0.01107489  0.1080266  0.1128684 0.23062316 -0.005933613 0.06126638 0.05048515  0.12351524
#> 3 -0.2041533  0.01984984 -0.01107489  0.1080266  0.1128684 0.23062316 -0.005933613 0.06126638 0.05048515  0.12351524
#> 4 -0.1472114 -0.02312062 -0.11272645 -0.3415540 -0.2255931 0.02385290  0.074861225 0.12910485 0.02176433 -0.21616454
#>       emb_024     emb_025   emb_026     emb_027     emb_028     emb_029     emb_030     emb_031     emb_032     emb_033
#> 1 -0.19981400 -0.03346085 0.1395520  0.01792375 -0.06969561 -0.04942485  0.06613978  0.08035761 -0.12418544 -0.11839510
#> 2 -0.02489970 -0.26744565 0.3418240 -0.12783451  0.38420413 -0.20168215 -0.06550949  0.26997083 -0.07201438  0.13039007
#> 3 -0.02489970 -0.26744565 0.3418240 -0.12783451  0.38420413 -0.20168215 -0.06550949  0.26997083 -0.07201438  0.13039007
#> 4  0.08218845  0.33230226 0.2420833  0.08455360  0.22111987 -0.57962301  0.32054099 -0.26178523 -0.46501200  0.05091595
#>       emb_034     emb_035     emb_036     emb_037    emb_038    emb_039      emb_040     emb_041     emb_042      emb_043
#> 1  0.04266573 -0.04319873  0.06394462  0.02425202 -0.2158322 -0.1064802  0.005398401  0.01459978 -0.03936125 -0.216860471
#> 2 -0.13608095  0.10342984  0.03349850 -0.06359592 -0.2497478 -0.1312915 -0.068015995  0.12897950  0.20849532 -0.001854315
#> 3 -0.13608095  0.10342984  0.03349850 -0.06359592 -0.2497478 -0.1312915 -0.068015995  0.12897950  0.20849532 -0.001854315
#> 4 -0.22430425 -0.07319695 -0.19518739 -0.21279503 -0.1980325 -0.3900315  0.214830723 -0.03985715  0.32672650 -0.067201529
#>      emb_044     emb_045     emb_046     emb_047     emb_048     emb_049     emb_050   emb_051       emb_052     emb_053
#> 1 0.01146569 -0.01707370 -0.08789315 -0.48977432  0.11840488 -0.24063642 -0.23959090 0.1258371 -0.0001312072 -0.15632193
#> 2 0.02034700  0.04105476 -0.26218344  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.1197809521  0.04324770
#> 3 0.02034700  0.04105476 -0.26218344  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.1197809521  0.04324770
#> 4 0.43131340 -0.10445137 -0.36873272  0.39958726  0.03923560  0.06519943 -0.12042060 0.1947917  0.5587487221  0.02909975
#>      emb_054     emb_055      emb_056     emb_057      emb_058     emb_059    emb_060     emb_061     emb_062     emb_063
#> 1  0.2063196 -0.02019964 -0.002069766 -0.14390510 -0.112056380 -0.12671516 -0.3076788  0.01722672 -0.04037631  0.14633203
#> 2 -0.2046735 -0.21317951  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.18907296 -0.26335296  0.01884718
#> 3 -0.2046735 -0.21317951  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.18907296 -0.26335296  0.01884718
#> 4 -0.1112386 -0.29085600  0.051582206  0.03322158 -0.090760550 -0.01738100  0.4675597 -0.29520441  0.62886798 -0.14435785
#>        emb_064     emb_065    emb_066     emb_067     emb_068   emb_069     emb_070     emb_071     emb_072    emb_073
#> 1  0.072336150  0.04734538  0.2444712 0.005439494  0.07232769 0.1972760 0.007281476 -0.03698583 -0.07433472 -0.0170116
#> 2 -0.009265006 -0.16859459 -0.2767420 0.048937336 -0.35522249 0.1164578 0.345116988 -0.03482347 -0.09575927 -0.1530600
#> 3 -0.009265006 -0.16859459 -0.2767420 0.048937336 -0.35522249 0.1164578 0.345116988 -0.03482347 -0.09575927 -0.1530600
#> 4  0.002738898 -0.03027805 -0.4466182 0.080596073  0.29857932 0.2307856 0.032678135 -0.02464749 -0.05315572  0.2278580
#>       emb_074    emb_075    emb_076    emb_077     emb_078    emb_079    emb_080    emb_081     emb_082    emb_083     emb_084
#> 1  0.15559705 -0.0142159 0.03095377 0.14973202 -0.07275485 -0.1265165  0.0756736 -0.1064746 -0.04138183  0.1262948 -0.07008250
#> 2 -0.08885341  0.1138750 0.24408367 0.01405296 -0.00684475 -0.1356777 -0.1306460  0.2395754 -0.24276201  0.1975068 -0.03769429
#> 3 -0.08885341  0.1138750 0.24408367 0.01405296 -0.00684475 -0.1356777 -0.1306460  0.2395754 -0.24276201  0.1975068 -0.03769429
#> 4  0.05121428  0.3368990 0.12042545 0.05976460  0.20906300 -0.3898960 -0.2403080 -0.2094990 -0.43718034 -0.2580445 -0.36398449
#>      emb_085     emb_086    emb_087     emb_088     emb_089     emb_090    emb_091    emb_092     emb_093     emb_094
#> 1 -0.0581785 -0.08323197 -0.1252120  0.10060352 -0.01839051 -0.24945817  0.2108233  0.2314818 -0.07174893  0.03378552
#> 2 -0.2019527  0.09356334 -0.2311737  0.01929579 -0.18456985  0.16967812 -0.3636869 -0.1134262  0.07241845  0.29899751
#> 3 -0.2019527  0.09356334 -0.2311737  0.01929579 -0.18456985  0.16967812 -0.3636869 -0.1134262  0.07241845  0.29899751
#> 4 -0.1863167 -0.38763523  0.1124806 -0.25680842 -0.21670937 -0.02249805  0.2278338 -0.1409704  0.17529125 -0.05521812
#>        emb_095     emb_096    emb_097      emb_098     emb_099     emb_100     emb_101     emb_102    emb_103     emb_104
#> 1  0.002213914  0.22163883 0.30331765  0.009472401 -0.14205784  0.12607630 -0.19062089 -0.08417289 -0.0868922  0.08520973
#> 2  0.111884147 -0.04911397 0.05792167 -0.125230156 -0.27682150 -0.03230023  0.09556636 -0.01811487  0.2020687 -0.28405397
#> 3  0.111884147 -0.04911397 0.05792167 -0.125230156 -0.27682150 -0.03230023  0.09556636 -0.01811487  0.2020687 -0.28405397
#> 4 -0.186143875  0.54336450 0.13775243 -0.269951746  0.01101355  0.12618919  0.24217032  0.19674813  0.1094553 -0.02718710
#>         emb_105   emb_106     emb_107    emb_108     emb_109     emb_110     emb_111     emb_112    emb_113     emb_114
#> 1  0.1095840322 0.0911104 -0.11639215 -0.1988509 -0.02318672 -0.03355397  0.06281934  0.09064088 -0.1812218 -0.08294683
#> 2 -0.2379808277 0.0503400  0.07255385 -0.3391048  0.29906577 -0.28191616  0.04745353 -0.04532966 -0.1529041  0.04579017
#> 3 -0.2379808277 0.0503400  0.07255385 -0.3391048  0.29906577 -0.28191616  0.04745353 -0.04532966 -0.1529041  0.04579017
#> 4 -0.0006717525 0.1023474  0.30398776  0.0299391  0.38101604 -0.07525725 -0.19109026 -0.09757482 -0.3430861  0.07392349
#>       emb_115     emb_116     emb_117     emb_118     emb_119    emb_120    emb_121     emb_122    emb_123     emb_124
#> 1  0.09746995  0.16949679 0.001256246 -0.09206300 -0.27094193  0.1914412 0.10522338  0.01736773 -0.1658078 -0.24409867
#> 2  0.02364063 -0.31116034 0.160783665 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.20085029  0.3362202 -0.03874875
#> 3  0.02364063 -0.31116034 0.160783665 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.20085029  0.3362202 -0.03874875
#> 4 -0.34514988 -0.05409198 0.021575954  0.24660901 -0.25714830 -0.3096262 0.14711675 -0.09584628 -0.2465328  0.02228437
#>       emb_125     emb_126     emb_127    emb_128     emb_129    emb_130     emb_131     emb_132    emb_133     emb_134
#> 1 -0.20621473 -0.35578349  0.19991713 -0.1075110 0.050961102 0.08590268 -0.07344585 -0.11005830  0.2082962 -0.03440777
#> 2 -0.02545092  0.21585878 -0.04820869  0.1341518 0.084913827 0.21485816 -0.26201880 -0.04661880  0.1594945  0.24577541
#> 3 -0.02545092  0.21585878 -0.04820869  0.1341518 0.084913827 0.21485816 -0.26201880 -0.04661880  0.1594945  0.24577541
#> 4 -0.05287175  0.04758008  0.13082074 -0.4366458 0.002557264 0.30628723 -0.24981013 -0.01674807 -0.3169997  0.12056302
#>       emb_135     emb_136    emb_137     emb_138     emb_139      emb_140     emb_141     emb_142     emb_143     emb_144
#> 1 -0.15951183  0.04417117 -0.1002716 -0.07090355 -0.09013366  0.004567102 -0.04074124 -0.09970398 -0.07412403  0.08118367
#> 2 -0.04687785  0.02120483 -0.2707188 -0.05038439 -0.21531074 -0.214246295  0.12730155  0.04358483 -0.04084410  0.08556246
#> 3 -0.04687785  0.02120483 -0.2707188 -0.05038439 -0.21531074 -0.214246295  0.12730155  0.04358483 -0.04084410  0.08556246
#> 4 -0.09506032 -0.01222125 -0.4409042  0.23120450  0.01691840  0.127434801  0.19368662  0.02984041 -0.14155845 -0.15326020
#>      emb_145     emb_146     emb_147    emb_148    emb_149    emb_150     emb_151    emb_152     emb_153     emb_154
#> 1 0.04151318  0.01023637 -0.02712608  0.1120797 0.07420963  0.2022959 -0.02539130 -0.1542052  0.09878749  0.11210436
#> 2 0.37193301 -0.23297635  0.16786779 -0.1552295 0.13361997  0.4047717 -0.07385027  0.2168649  0.08279617  0.02853568
#> 3 0.37193301 -0.23297635  0.16786779 -0.1552295 0.13361997  0.4047717 -0.07385027  0.2168649  0.08279617  0.02853568
#> 4 0.02936405  0.05187999  0.06006772  0.0758267 0.04905358 -0.0133047  0.25728051  0.2761333 -0.10433040 -0.02122432
#>       emb_155    emb_156    emb_157     emb_158     emb_159    emb_160     emb_161     emb_162      emb_163    emb_164
#> 1 0.190853971 -0.2355878  0.1032905 -0.21532827  0.09456767 -0.1445503 -0.33522494  0.15268593 -0.001686232  0.2152747
#> 2 0.007983398 -0.2673024 -0.3518553  0.07097678  0.08358909 -0.1986835 -0.29901644 -0.01896982 -0.052200415  0.1262764
#> 3 0.007983398 -0.2673024 -0.3518553  0.07097678  0.08358909 -0.1986835 -0.29901644 -0.01896982 -0.052200415  0.1262764
#> 4 0.066375951 -0.3625118 -0.2547615  0.13501658 -0.28645951 -0.1917117 -0.01892012 -0.02507000 -0.031375002 -0.2519416
#>       emb_165   emb_166     emb_167    emb_168     emb_169    emb_170    emb_171     emb_172    emb_173     emb_174
#> 1 -0.10312133 0.1135696 -0.02624894  0.1098730  0.09047928 0.12684340 -0.0694985 -0.11949543  0.2164041 -0.29396720
#> 2  0.10607937 0.0321700 -0.25643115 -0.1073976  0.26462262 0.03679075 -0.2173935  0.07656907 -0.1012526 -0.02410151
#> 3  0.10607937 0.0321700 -0.25643115 -0.1073976  0.26462262 0.03679075 -0.2173935  0.07656907 -0.1012526 -0.02410151
#> 4  0.08888888 0.3796148 -0.25476800 -0.1437821 -0.15589955 0.23368900  0.1311810  0.52442150 -0.0487657  0.25153150
#>       emb_175    emb_176    emb_177     emb_178     emb_179     emb_180      emb_181    emb_182    emb_183     emb_184
#> 1 -0.16588253 -0.1348005 -0.1148055 -0.08968537  0.05097483  0.09355133  0.008875800  0.1106400 -0.1088511 -0.02326688
#> 2 -0.02048860 -0.1179298  0.2362113  0.30876314 -0.22625668  0.07487945  0.008851715 -0.1024263 -0.2249113 -0.06455390
#> 3 -0.02048860 -0.1179298  0.2362113  0.30876314 -0.22625668  0.07487945  0.008851715 -0.1024263 -0.2249113 -0.06455390
#> 4  0.02299049 -0.1953604 -0.1572996  0.29195935 -0.05653973 -0.12341889 -0.312314242 -0.1885454 -0.2873893 -0.02149600
#>       emb_185     emb_186    emb_187     emb_188      emb_189    emb_190     emb_191      emb_192     emb_193     emb_194
#> 1  0.17733055 -0.07351807  0.0222525 -0.12066887 -0.179350998 0.01909462  0.13228424  0.024832169  0.05002003 -0.20531311
#> 2  0.07631866  0.01623236 -0.1098196 -0.04689731 -0.033685058 0.16270872 -0.05825762  0.069446986 -0.05563271 -0.17479033
#> 3  0.07631866  0.01623236 -0.1098196 -0.04689731 -0.033685058 0.16270872 -0.05825762  0.069446986 -0.05563271 -0.17479033
#> 4 -0.16462975  0.14877875  0.2350687  0.36260483  0.004200405 0.20571376  0.09558415 -0.006550124 -0.30820300  0.01686265
#>       emb_195    emb_196     emb_197     emb_198     emb_199     emb_200
#> 1 -0.00853500  0.0639337  0.29886368  0.01618892 -0.08192083 -0.37027851
#> 2 -0.13635058  0.1291080 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 3 -0.13635058  0.1291080 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 4 -0.05414012 -0.1694009 -0.13313706 -0.15822850  0.14830773 -0.34555282
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
#>   |                                                                                                                             |                                                                                                                     |   0%  |                                                                                                                             |=====================================================================================================================| 100%
#>   clinspacy_id      cui      entity       lemma             semantic_type                      definition is_family
#> 1            1 C0030705     patient     patient Patient or Disabled Group                        Patients     FALSE
#> 2            1 C1578484     patient     patient           Idea or Concept Relationship modifier - Patient     FALSE
#> 3            1 C1578485     patient     patient      Intellectual Product Specimen Source Codes - Patient     FALSE
#> 4            1 C1578486     patient     patient      Intellectual Product  Disabled Person Code - Patient     FALSE
#> 5            1 C1705908     patient     patient                  Organism              Veterinary Patient     FALSE
#> 6            1 C0011847    diabetes    diabetes       Disease or Syndrome                        Diabetes     FALSE
#> 7            1 C0011849    diabetes    diabetes       Disease or Syndrome               Diabetes Mellitus     FALSE
#> 8            1 C2316787 CKD stage 3 ckd stage 3       Disease or Syndrome  Chronic kidney disease stage 3     FALSE
#> 9            1 C0020538         HTN         htn       Disease or Syndrome            Hypertensive disease     FALSE
#>   is_historical is_hypothetical is_negated is_uncertain section_title
#> 1         FALSE           FALSE      FALSE        FALSE          <NA>
#> 2         FALSE           FALSE      FALSE        FALSE          <NA>
#> 3         FALSE           FALSE      FALSE        FALSE          <NA>
#> 4         FALSE           FALSE      FALSE        FALSE          <NA>
#> 5         FALSE           FALSE      FALSE        FALSE          <NA>
#> 6         FALSE           FALSE      FALSE        FALSE          <NA>
#> 7         FALSE           FALSE      FALSE        FALSE          <NA>
#> 8         FALSE           FALSE      FALSE        FALSE          <NA>
#> 9         FALSE           FALSE       TRUE        FALSE          <NA>

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Pharmacologic Substance')
#>   |                                                                                                                             |                                                                                                                     |   0%  |                                                                                                                             |=====================================================================================================================| 100%
#>   clinspacy_id      cui     entity      lemma           semantic_type definition is_family is_historical is_hypothetical
#> 1            1 C0028978 omeprazole omeprazole Pharmacologic Substance Omeprazole     FALSE         FALSE           FALSE
#> 2            1 C0004057    aspirin    aspirin Pharmacologic Substance    Aspirin     FALSE         FALSE           FALSE
#> 3            1 C0065374 lisinopril lisinopril Pharmacologic Substance Lisinopril     FALSE         FALSE           FALSE
#> 4            1 C0001927  albuterol  albuterol Pharmacologic Substance  Albuterol     FALSE         FALSE           FALSE
#>   is_negated is_uncertain section_title
#> 1      FALSE        FALSE          <NA>
#> 2      FALSE        FALSE          <NA>
#> 3      FALSE        FALSE          <NA>
#> 4       TRUE        FALSE          <NA>

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Disease or Syndrome')
#>   |                                                                                                                             |                                                                                                                     |   0%  |                                                                                                                             |=====================================================================================================================| 100%
#>   clinspacy_id      cui   entity    lemma       semantic_type        definition is_family is_historical is_hypothetical
#> 1            1 C0011847 diabetes diabetes Disease or Syndrome          Diabetes     FALSE         FALSE           FALSE
#> 2            1 C0011849 diabetes diabetes Disease or Syndrome Diabetes Mellitus     FALSE         FALSE           FALSE
#> 3            1 C0004096   asthma   asthma Disease or Syndrome            Asthma     FALSE         FALSE           FALSE
#>   is_negated is_uncertain section_title
#> 1      FALSE        FALSE          <NA>
#> 2      FALSE        FALSE          <NA>
#> 3       TRUE        FALSE          <NA>
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

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   clinspacy_id note_id                                                      description C0009818 C0013516 C0020517 C0277786
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.        0        0        1        1
#> 2            2       2                         Consult for laparoscopic gastric bypass.        1        0        0        0
#> 3            3       3                         Consult for laparoscopic gastric bypass.        1        0        0        0
#> 4            4       4                                             2-D M-Mode. Doppler.        0        0        0        0
#> 5            5       5                                               2-D Echocardiogram        0        1        0        0
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
#>   clinspacy_id note_id                                                      description C0013516 C0554756
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.       NA       NA
#> 2            2       2                         Consult for laparoscopic gastric bypass.       NA       NA
#> 3            3       3                         Consult for laparoscopic gastric bypass.       NA       NA
#> 4            4       4                                             2-D M-Mode. Doppler.        0        1
#> 5            5       5                                               2-D Echocardiogram        1        0
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
#>   clinspacy_id note_id                                                      description    emb_001    emb_002    emb_003
#> 1            1       1 A 23-year-old white female presents with complaint of allergies. -0.3611527 0.30379833  0.1250187
#> 2            2       2                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144 -0.1351923
#> 3            3       3                         Consult for laparoscopic gastric bypass. -0.1115363 0.01725144 -0.1351923
#> 4            4       4                                             2-D M-Mode. Doppler. -0.4044230 0.21798199 -0.4359590
#>       emb_004    emb_005     emb_006     emb_007     emb_008    emb_009    emb_010    emb_011     emb_012   emb_013    emb_014
#> 1 -0.27718534 -0.3054457  0.04946094 -0.13725600  0.05227867 -0.2239260  0.5019193  0.1629576 -0.31555533 0.2533063 -0.3654707
#> 2 -0.05496463  0.1488807 -0.19577999  0.05265867 -0.10433200 -0.0763495  0.1199215 -0.1860092  0.05465447 0.1267057 -0.2041533
#> 3 -0.05496463  0.1488807 -0.19577999  0.05265867 -0.10433200 -0.0763495  0.1199215 -0.1860092  0.05465447 0.1267057 -0.2041533
#> 4 -0.05181420 -0.0757723 -0.03360050 -0.18084100  0.26080000  0.4181560 -0.2046540 -0.2572890 -0.42502299 0.7310580 -0.1249990
#>       emb_015     emb_016    emb_017    emb_018    emb_019      emb_020    emb_021     emb_022    emb_023    emb_024
#> 1 -0.12779960  0.17567993 -0.1446099 -0.1263563 -0.0373060 -0.115881334 0.57490400  0.12478290  0.0658141 -0.2563947
#> 2  0.01984984 -0.01107489  0.1080266  0.1128684  0.2306232 -0.005933613 0.06126638  0.05048515  0.1235152 -0.0248997
#> 3  0.01984984 -0.01107489  0.1080266  0.1128684  0.2306232 -0.005933613 0.06126638  0.05048515  0.1235152 -0.0248997
#> 4 -0.05637670 -0.29954299 -0.2941060 -0.2478460 -0.0287432  0.067911699 0.02872950 -0.02079800 -0.2892080  0.2813420
#>      emb_025   emb_026     emb_027    emb_028     emb_029     emb_030     emb_031     emb_032    emb_033      emb_034
#> 1 -0.1376491 0.2429187  0.05097854 -0.1929284 -0.09130429  0.17576200 -0.01365233 -0.09805207 -0.1376440  0.004004667
#> 2 -0.2674457 0.3418240 -0.12783451  0.3842041 -0.20168215 -0.06550949  0.26997083 -0.07201438  0.1303901 -0.136080950
#> 3 -0.2674457 0.3418240 -0.12783451  0.3842041 -0.20168215 -0.06550949  0.26997083 -0.07201438  0.1303901 -0.136080950
#> 4  0.6255990 0.4281110  0.20646299  0.2296980 -0.74650902  0.35579199 -0.41084301 -0.54899400  0.0451901 -0.219888002
#>     emb_035    emb_036     emb_037    emb_038     emb_039     emb_040    emb_041     emb_042      emb_043     emb_044
#> 1 0.0381910  0.1195871  0.01446407 -0.2498078  0.09343017  0.04716743  0.1713393 -0.03293247 -0.213242605 -0.03206829
#> 2 0.1034298  0.0334985 -0.06359592 -0.2497478 -0.13129150 -0.06801600  0.1289795  0.20849532 -0.001854315  0.02034700
#> 3 0.1034298  0.0334985 -0.06359592 -0.2497478 -0.13129150 -0.06801600  0.1289795  0.20849532 -0.001854315  0.02034700
#> 4 0.0889601 -0.3470430 -0.21991500 -0.1619850 -0.53598398  0.34043500 -0.0483518  0.36741400 -0.088588104  0.66488600
#>       emb_045    emb_046     emb_047     emb_048     emb_049     emb_050   emb_051     emb_052    emb_053    emb_054
#> 1 -0.04169884 -0.1699734 -0.74627431  0.13414333 -0.38696743 -0.17838313 0.1920727 -0.09024807 -0.1966087  0.2587477
#> 2  0.04105476 -0.2621834  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.11978095  0.0432477 -0.2046735
#> 3  0.04105476 -0.2621834  0.05762917 -0.08367021 -0.01368977  0.02369371 0.1266086 -0.11978095  0.0432477 -0.2046735
#> 4 -0.06560100 -0.5937040  0.62876701  0.06133320  0.02835000 -0.15147001 0.2244480  0.58674097  0.0381370 -0.1356160
#>       emb_055      emb_056     emb_057      emb_058     emb_059    emb_060    emb_061     emb_062     emb_063      emb_064
#> 1 -0.08574957  0.007523434 -0.30075601 -0.115144864 -0.16193766 -0.2485523  0.0884304  0.02391916  0.27797680  0.064277269
#> 2 -0.21317951  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.1890730 -0.26335296  0.01884718 -0.009265006
#> 3 -0.21317951  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.1890730 -0.26335296  0.01884718 -0.009265006
#> 4 -0.38449201 -0.047390901  0.03690350 -0.155994996 -0.24829200  0.5008110 -0.0982668  0.71681201 -0.03416720 -0.025456199
#>       emb_065    emb_066    emb_067      emb_068   emb_069    emb_070     emb_071     emb_072     emb_073     emb_074
#> 1 -0.03806543  0.3829273 0.09349866 -0.007119675 0.2117574 0.04720229 -0.02785233 -0.21897317  0.04923863  0.11586847
#> 2 -0.16859459 -0.2767420 0.04893734 -0.355222493 0.1164578 0.34511699 -0.03482347 -0.09575927 -0.15305997 -0.08885341
#> 3 -0.16859459 -0.2767420 0.04893734 -0.355222493 0.1164578 0.34511699 -0.03482347 -0.09575927 -0.15305997 -0.08885341
#> 4  0.01503300 -0.5353000 0.21822900  0.511924028 0.4966770 0.00565767 -0.34957999 -0.05733940  0.16006000  0.00709061
#>      emb_075   emb_076    emb_077     emb_078    emb_079     emb_080    emb_081     emb_082    emb_083     emb_084    emb_085
#> 1 0.01710307 0.0567466 0.21199200 -0.23542767 -0.1931737  0.08169073 -0.2768843  0.03886401  0.2959003 -0.19298467 -0.1155530
#> 2 0.11387503 0.2440837 0.01405296 -0.00684475 -0.1356777 -0.13064601  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527
#> 3 0.11387503 0.2440837 0.01405296 -0.00684475 -0.1356777 -0.13064601  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527
#> 4 0.29393500 0.1932350 0.09904870  0.10269100 -0.4426980 -0.30440599 -0.3246080 -0.62308598 -0.2460820 -0.24843900 -0.0256765
#>       emb_086    emb_087     emb_088    emb_089    emb_090    emb_091    emb_092     emb_093   emb_094     emb_095     emb_096
#> 1 -0.13447814 -0.1770210  0.13215400 -0.0339748 -0.2185643  0.2328593  0.3751490 -0.05381016 0.1146673 -0.01959847  0.28200266
#> 2  0.09356334 -0.2311737  0.01929579 -0.1845699  0.1696781 -0.3636869 -0.1134262  0.07241845 0.2989975  0.11188415 -0.04911397
#> 3  0.09356334 -0.2311737  0.01929579 -0.1845699  0.1696781 -0.3636869 -0.1134262  0.07241845 0.2989975  0.11188415 -0.04911397
#> 4 -0.51446497  0.2091200 -0.39628500 -0.3847940  0.0601322  0.1881050  0.0293956  0.15106900 0.1575840 -0.18849900  0.55679601
#>      emb_097     emb_098    emb_099     emb_100     emb_101     emb_102    emb_103     emb_104      emb_105   emb_106
#> 1 0.42902666  0.04848963 -0.1862663  0.12460214 -0.22326134 -0.08400663 0.02329567  0.05004047  0.104559732 0.0215449
#> 2 0.05792167 -0.12523016 -0.2768215 -0.03230023  0.09556636 -0.01811487 0.20206867 -0.28405397 -0.237980828 0.0503400
#> 3 0.05792167 -0.12523016 -0.2768215 -0.03230023  0.09556636 -0.01811487 0.20206867 -0.28405397 -0.237980828 0.0503400
#> 4 0.15977401 -0.21990800  0.0361496  0.09506090  0.31184199  0.47269401 0.18948001  0.01987330 -0.000530505 0.2547450
#>       emb_107    emb_108    emb_109    emb_110     emb_111     emb_112    emb_113     emb_114     emb_115    emb_116
#> 1 -0.15388466 -0.2977020 -0.1531017 -0.1190686  0.22010233  0.08900213 -0.3544760  0.09171167  0.23258676  0.1443347
#> 2  0.07255385 -0.3391048  0.2990658 -0.2819162  0.04745353 -0.04532966 -0.1529041  0.04579017  0.02364063 -0.3111603
#> 3  0.07255385 -0.3391048  0.2990658 -0.2819162  0.04745353 -0.04532966 -0.1529041  0.04579017  0.02364063 -0.3111603
#> 4  0.38338101  0.0516758  0.6453670  0.1093270 -0.20991200 -0.21882400 -0.5041480 -0.10509700 -0.50537401 -0.0655120
#>      emb_117     emb_118     emb_119    emb_120    emb_121    emb_122    emb_123     emb_124     emb_125      emb_126
#> 1 -0.1116737 -0.03960567 -0.40252632  0.2241620 0.05333853  0.1210103 -0.3505453 -0.37599967 -0.17959367 -0.372907996
#> 2  0.1607837 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.2008503  0.3362202 -0.03874875 -0.02545092  0.215858780
#> 3  0.1607837 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.2008503  0.3362202 -0.03874875 -0.02545092  0.215858780
#> 4  0.1273470  0.44890201 -0.50497001 -0.3773840 0.10423600 -0.2221160 -0.0152136 -0.13729800 -0.11480500 -0.000516588
#>       emb_127    emb_128    emb_129   emb_130     emb_131    emb_132    emb_133    emb_134     emb_135    emb_136    emb_137
#> 1  0.23109696 -0.1633047 0.08894860 0.1383011 -0.03854874 -0.1769396  0.4415511 0.06758907 -0.14083400 0.18984333 -0.1702950
#> 2 -0.04820869  0.1341518 0.08491383 0.2148582 -0.26201880 -0.0466188  0.1594945 0.24577541 -0.04687785 0.02120483 -0.2707188
#> 3 -0.04820869  0.1341518 0.08491383 0.2148582 -0.26201880 -0.0466188  0.1594945 0.24577541 -0.04687785 0.02120483 -0.2707188
#> 4  0.27843499 -0.5077260 0.00681453 0.3277110 -0.45759901  0.0445853 -0.2659470 0.16891700 -0.03073480 0.05147280 -0.5484980
#>       emb_138    emb_139     emb_140     emb_141     emb_142     emb_143     emb_144   emb_145     emb_146      emb_147
#> 1 -0.03138060 -0.1715784  0.02322287 -0.01208614 -0.15196758 -0.04809747  0.06830250 0.0689920 -0.01744726 -0.008307199
#> 2 -0.05038439 -0.2153107 -0.21424630  0.12730155  0.04358483 -0.04084410  0.08556246 0.3719330 -0.23297635  0.167867787
#> 3 -0.05038439 -0.2153107 -0.21424630  0.12730155  0.04358483 -0.04084410  0.08556246 0.3719330 -0.23297635  0.167867787
#> 4  0.29294801  0.0126988  0.23700000  0.24597199  0.00283213 -0.32100201 -0.10307100 0.0538421  0.14164799 -0.091728903
#>      emb_148   emb_149   emb_150     emb_151    emb_152     emb_153     emb_154     emb_155    emb_156    emb_157     emb_158
#> 1  0.1721520 0.0815931 0.3604187 -0.09423253 -0.2169230  0.12186506  0.05177177 0.248860496 -0.3412270  0.1060033 -0.17823740
#> 2 -0.1552295 0.1336200 0.4047717 -0.07385027  0.2168649  0.08279617  0.02853568 0.007983398 -0.2673024 -0.3518553  0.07097678
#> 3 -0.1552295 0.1336200 0.4047717 -0.07385027  0.2168649  0.08279617  0.02853568 0.007983398 -0.2673024 -0.3518553  0.07097678
#> 4  0.2749980 0.2364690 0.0516106  0.31944901  0.2596070 -0.20201600 -0.03634640 0.132135004 -0.4019700 -0.3961210  0.22471200
#>       emb_159    emb_160    emb_161     emb_162     emb_163    emb_164    emb_165   emb_166     emb_167    emb_168    emb_169
#> 1  0.14807933 -0.2403240 -0.4898007  0.28092899 -0.06756200  0.1374817 -0.2715797 0.0436814  0.08531557  0.0082764  0.1924960
#> 2  0.08358909 -0.1986835 -0.2990164 -0.01896982 -0.05220042  0.1262764  0.1060794 0.0321700 -0.25643115 -0.1073976  0.2646226
#> 3  0.08358909 -0.1986835 -0.2990164 -0.01896982 -0.05220042  0.1262764  0.1060794 0.0321700 -0.25643115 -0.1073976  0.2646226
#> 4 -0.28615400 -0.2248820  0.0843519  0.12150900  0.07793430 -0.3778230  0.1211260 0.3226820 -0.25913599 -0.0354177 -0.0709271
#>      emb_170      emb_171     emb_172    emb_173     emb_174     emb_175    emb_176    emb_177     emb_178    emb_179
#> 1 0.07621813  0.006314665 -0.30531877  0.2141445 -0.22668706 -0.22004866 -0.2229127 -0.2364223 -0.02967973  0.1305110
#> 2 0.03679075 -0.217393473  0.07656907 -0.1012526 -0.02410151 -0.02048860 -0.1179298  0.2362113  0.30876314 -0.2262567
#> 3 0.03679075 -0.217393473  0.07656907 -0.1012526 -0.02410151 -0.02048860 -0.1179298  0.2362113  0.30876314 -0.2262567
#> 4 0.28492600 -0.015468100  0.70878100  0.0050526  0.35008600 -0.00414608 -0.2252000 -0.0747713  0.47891200 -0.0237339
#>       emb_180      emb_181     emb_182    emb_183    emb_184     emb_185     emb_186     emb_187     emb_188     emb_189
#> 1 -0.04268587  0.005356933  0.14262900 -0.1319477  0.1089087  0.33032867 -0.02934333 -0.05704663 -0.05574000 -0.33545766
#> 2  0.07487945  0.008851715 -0.10242634 -0.2249113 -0.0645539  0.07631866  0.01623236 -0.10981955 -0.04689731 -0.03368506
#> 3  0.07487945  0.008851715 -0.10242634 -0.2249113 -0.0645539  0.07631866  0.01623236 -0.10981955 -0.04689731 -0.03368506
#> 4  0.00665774 -0.295183003  0.00914423 -0.4879910 -0.0119945 -0.19777000  0.25575000  0.21581100  0.49597701  0.05313870
#>     emb_190     emb_191     emb_192     emb_193    emb_194      emb_195    emb_196     emb_197     emb_198     emb_199
#> 1 0.0707290  0.23029859 -0.07569099  0.09401843 -0.3644300  0.001776733  0.1568153  0.39945501  0.10316629  0.03305000
#> 2 0.1627087 -0.05825762  0.06944699 -0.05563271 -0.1747903 -0.136350583  0.1291080 -0.09743453 -0.09941812 -0.05773153
#> 3 0.1627087 -0.05825762  0.06944699 -0.05563271 -0.1747903 -0.136350583  0.1291080 -0.09743453 -0.09941812 -0.05773153
#> 4 0.2184980  0.12104800  0.04292490 -0.46514499 -0.0659737 -0.164887995 -0.2337760 -0.20433401 -0.31397000  0.16799000
#>       emb_200
#> 1 -0.56594801
#> 2 -0.09702638
#> 3 -0.09702638
#> 4 -0.57338899
#>  [ reached 'max' / getOption("max.print") -- omitted 1 rows ]

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(
    mtsamples[1:5, 1:2],
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   clinspacy_id note_id                                                      description   emb_001  emb_002   emb_003
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.        NA       NA        NA
#> 2            2       2                         Consult for laparoscopic gastric bypass.        NA       NA        NA
#> 3            3       3                         Consult for laparoscopic gastric bypass.        NA       NA        NA
#> 4            4       4                                             2-D M-Mode. Doppler. -0.404423 0.217982 -0.435959
#>      emb_004    emb_005    emb_006   emb_007 emb_008  emb_009   emb_010   emb_011   emb_012  emb_013   emb_014    emb_015
#> 1         NA         NA         NA        NA      NA       NA        NA        NA        NA       NA        NA         NA
#> 2         NA         NA         NA        NA      NA       NA        NA        NA        NA       NA        NA         NA
#> 3         NA         NA         NA        NA      NA       NA        NA        NA        NA       NA        NA         NA
#> 4 -0.0518142 -0.0757723 -0.0336005 -0.180841  0.2608 0.418156 -0.204654 -0.257289 -0.425023 0.731058 -0.124999 -0.0563767
#>     emb_016   emb_017   emb_018    emb_019   emb_020   emb_021   emb_022   emb_023  emb_024  emb_025  emb_026  emb_027
#> 1        NA        NA        NA         NA        NA        NA        NA        NA       NA       NA       NA       NA
#> 2        NA        NA        NA         NA        NA        NA        NA        NA       NA       NA       NA       NA
#> 3        NA        NA        NA         NA        NA        NA        NA        NA       NA       NA       NA       NA
#> 4 -0.299543 -0.294106 -0.247846 -0.0287432 0.0679117 0.0287295 -0.020798 -0.289208 0.281342 0.625599 0.428111 0.206463
#>    emb_028   emb_029  emb_030   emb_031   emb_032   emb_033   emb_034   emb_035   emb_036   emb_037   emb_038   emb_039
#> 1       NA        NA       NA        NA        NA        NA        NA        NA        NA        NA        NA        NA
#> 2       NA        NA       NA        NA        NA        NA        NA        NA        NA        NA        NA        NA
#> 3       NA        NA       NA        NA        NA        NA        NA        NA        NA        NA        NA        NA
#> 4 0.229698 -0.746509 0.355792 -0.410843 -0.548994 0.0451901 -0.219888 0.0889601 -0.347043 -0.219915 -0.161985 -0.535984
#>    emb_040    emb_041  emb_042    emb_043  emb_044   emb_045   emb_046  emb_047   emb_048 emb_049  emb_050  emb_051  emb_052
#> 1       NA         NA       NA         NA       NA        NA        NA       NA        NA      NA       NA       NA       NA
#> 2       NA         NA       NA         NA       NA        NA        NA       NA        NA      NA       NA       NA       NA
#> 3       NA         NA       NA         NA       NA        NA        NA       NA        NA      NA       NA       NA       NA
#> 4 0.340435 -0.0483518 0.367414 -0.0885881 0.664886 -0.065601 -0.593704 0.628767 0.0613332 0.02835 -0.15147 0.224448 0.586741
#>    emb_053   emb_054   emb_055    emb_056   emb_057   emb_058   emb_059  emb_060    emb_061  emb_062    emb_063    emb_064
#> 1       NA        NA        NA         NA        NA        NA        NA       NA         NA       NA         NA         NA
#> 2       NA        NA        NA         NA        NA        NA        NA       NA         NA       NA         NA         NA
#> 3       NA        NA        NA         NA        NA        NA        NA       NA         NA       NA         NA         NA
#> 4 0.038137 -0.135616 -0.384492 -0.0473909 0.0369035 -0.155995 -0.248292 0.500811 -0.0982668 0.716812 -0.0341672 -0.0254562
#>    emb_065 emb_066  emb_067  emb_068  emb_069    emb_070  emb_071    emb_072 emb_073    emb_074  emb_075  emb_076   emb_077
#> 1       NA      NA       NA       NA       NA         NA       NA         NA      NA         NA       NA       NA        NA
#> 2       NA      NA       NA       NA       NA         NA       NA         NA      NA         NA       NA       NA        NA
#> 3       NA      NA       NA       NA       NA         NA       NA         NA      NA         NA       NA       NA        NA
#> 4 0.015033 -0.5353 0.218229 0.511924 0.496677 0.00565767 -0.34958 -0.0573394 0.16006 0.00709061 0.293935 0.193235 0.0990487
#>    emb_078   emb_079   emb_080   emb_081   emb_082   emb_083   emb_084    emb_085   emb_086 emb_087   emb_088   emb_089
#> 1       NA        NA        NA        NA        NA        NA        NA         NA        NA      NA        NA        NA
#> 2       NA        NA        NA        NA        NA        NA        NA         NA        NA      NA        NA        NA
#> 3       NA        NA        NA        NA        NA        NA        NA         NA        NA      NA        NA        NA
#> 4 0.102691 -0.442698 -0.304406 -0.324608 -0.623086 -0.246082 -0.248439 -0.0256765 -0.514465 0.20912 -0.396285 -0.384794
#>     emb_090  emb_091   emb_092  emb_093  emb_094   emb_095  emb_096  emb_097   emb_098   emb_099   emb_100  emb_101  emb_102
#> 1        NA       NA        NA       NA       NA        NA       NA       NA        NA        NA        NA       NA       NA
#> 2        NA       NA        NA       NA       NA        NA       NA       NA        NA        NA        NA       NA       NA
#> 3        NA       NA        NA       NA       NA        NA       NA       NA        NA        NA        NA       NA       NA
#> 4 0.0601322 0.188105 0.0293956 0.151069 0.157584 -0.188499 0.556796 0.159774 -0.219908 0.0361496 0.0950609 0.311842 0.472694
#>   emb_103   emb_104      emb_105  emb_106  emb_107   emb_108  emb_109  emb_110   emb_111   emb_112   emb_113   emb_114
#> 1      NA        NA           NA       NA       NA        NA       NA       NA        NA        NA        NA        NA
#> 2      NA        NA           NA       NA       NA        NA       NA       NA        NA        NA        NA        NA
#> 3      NA        NA           NA       NA       NA        NA       NA       NA        NA        NA        NA        NA
#> 4 0.18948 0.0198733 -0.000530505 0.254745 0.383381 0.0516758 0.645367 0.109327 -0.209912 -0.218824 -0.504148 -0.105097
#>     emb_115   emb_116  emb_117  emb_118  emb_119   emb_120  emb_121   emb_122    emb_123   emb_124   emb_125      emb_126
#> 1        NA        NA       NA       NA       NA        NA       NA        NA         NA        NA        NA           NA
#> 2        NA        NA       NA       NA       NA        NA       NA        NA         NA        NA        NA           NA
#> 3        NA        NA       NA       NA       NA        NA       NA        NA         NA        NA        NA           NA
#> 4 -0.505374 -0.065512 0.127347 0.448902 -0.50497 -0.377384 0.104236 -0.222116 -0.0152136 -0.137298 -0.114805 -0.000516588
#>    emb_127   emb_128    emb_129  emb_130   emb_131   emb_132   emb_133  emb_134    emb_135   emb_136   emb_137  emb_138
#> 1       NA        NA         NA       NA        NA        NA        NA       NA         NA        NA        NA       NA
#> 2       NA        NA         NA       NA        NA        NA        NA       NA         NA        NA        NA       NA
#> 3       NA        NA         NA       NA        NA        NA        NA       NA         NA        NA        NA       NA
#> 4 0.278435 -0.507726 0.00681453 0.327711 -0.457599 0.0445853 -0.265947 0.168917 -0.0307348 0.0514728 -0.548498 0.292948
#>     emb_139 emb_140  emb_141    emb_142   emb_143   emb_144   emb_145  emb_146    emb_147  emb_148  emb_149   emb_150  emb_151
#> 1        NA      NA       NA         NA        NA        NA        NA       NA         NA       NA       NA        NA       NA
#> 2        NA      NA       NA         NA        NA        NA        NA       NA         NA       NA       NA        NA       NA
#> 3        NA      NA       NA         NA        NA        NA        NA       NA         NA       NA       NA        NA       NA
#> 4 0.0126988   0.237 0.245972 0.00283213 -0.321002 -0.103071 0.0538421 0.141648 -0.0917289 0.274998 0.236469 0.0516106 0.319449
#>    emb_152   emb_153    emb_154  emb_155  emb_156   emb_157  emb_158   emb_159   emb_160   emb_161  emb_162   emb_163
#> 1       NA        NA         NA       NA       NA        NA       NA        NA        NA        NA       NA        NA
#> 2       NA        NA         NA       NA       NA        NA       NA        NA        NA        NA       NA        NA
#> 3       NA        NA         NA       NA       NA        NA       NA        NA        NA        NA       NA        NA
#> 4 0.259607 -0.202016 -0.0363464 0.132135 -0.40197 -0.396121 0.224712 -0.286154 -0.224882 0.0843519 0.121509 0.0779343
#>     emb_164  emb_165  emb_166   emb_167    emb_168    emb_169  emb_170    emb_171  emb_172   emb_173  emb_174     emb_175
#> 1        NA       NA       NA        NA         NA         NA       NA         NA       NA        NA       NA          NA
#> 2        NA       NA       NA        NA         NA         NA       NA         NA       NA        NA       NA          NA
#> 3        NA       NA       NA        NA         NA         NA       NA         NA       NA        NA       NA          NA
#> 4 -0.377823 0.121126 0.322682 -0.259136 -0.0354177 -0.0709271 0.284926 -0.0154681 0.708781 0.0050526 0.350086 -0.00414608
#>   emb_176    emb_177  emb_178    emb_179    emb_180   emb_181    emb_182   emb_183    emb_184  emb_185 emb_186  emb_187
#> 1      NA         NA       NA         NA         NA        NA         NA        NA         NA       NA      NA       NA
#> 2      NA         NA       NA         NA         NA        NA         NA        NA         NA       NA      NA       NA
#> 3      NA         NA       NA         NA         NA        NA         NA        NA         NA       NA      NA       NA
#> 4 -0.2252 -0.0747713 0.478912 -0.0237339 0.00665774 -0.295183 0.00914423 -0.487991 -0.0119945 -0.19777 0.25575 0.215811
#>    emb_188   emb_189  emb_190  emb_191   emb_192   emb_193    emb_194   emb_195   emb_196   emb_197  emb_198 emb_199   emb_200
#> 1       NA        NA       NA       NA        NA        NA         NA        NA        NA        NA       NA      NA        NA
#> 2       NA        NA       NA       NA        NA        NA         NA        NA        NA        NA       NA      NA        NA
#> 3       NA        NA       NA       NA        NA        NA         NA        NA        NA        NA       NA      NA        NA
#> 4 0.495977 0.0531387 0.218498 0.121048 0.0429249 -0.465145 -0.0659737 -0.164888 -0.233776 -0.204334 -0.31397 0.16799 -0.573389
#>  [ reached 'max' / getOption("max.print") -- omitted 1 rows ]
```

### Cui2vec embeddings (with the UMLS linker)

These are only available with the UMLS linker enabled.

``` r
clinspacy_output_file %>% 
  bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                            type = 'cui2vec')
#>   clinspacy_id note_id                                                      description     emb_001    emb_002       emb_003
#> 1            1       1 A 23-year-old white female presents with complaint of allergies. -0.03781852 0.01307321 -8.467619e-17
#>       emb_004    emb_005    emb_006    emb_007      emb_008    emb_009      emb_010     emb_011     emb_012     emb_013
#> 1 -0.03124591 0.01318394 0.03031191 0.02431865 0.0001103725 0.04350098 3.243933e-16 -0.07792482 -0.02392776 -0.07418388
#>       emb_014   emb_015   emb_016    emb_017      emb_018   emb_019    emb_020     emb_021     emb_022     emb_023     emb_024
#> 1 -0.01635606 0.5795962 0.2781278 -0.7857161 1.058181e-16 0.1514154 0.04846067 -0.06323447 -0.01420082 0.001504209 -0.06733951
#>       emb_025     emb_026    emb_027      emb_028     emb_029    emb_030      emb_031      emb_032     emb_033      emb_034
#> 1 0.004864776 -0.07110942 0.03399503 -0.006213914 -0.02295869 0.00935263 -0.005880135 0.0004999359 0.006844007 1.898872e-15
#>        emb_035       emb_036    emb_037     emb_038      emb_039     emb_040     emb_041     emb_042     emb_043     emb_044
#> 1 -0.006001428 -2.131541e-15 0.02288913 -0.01457824 -0.009136149 -0.01439758 0.007009739 -0.01903257 0.007831483 0.009378524
#>        emb_045     emb_046    emb_047     emb_048       emb_049    emb_050     emb_051    emb_052       emb_053     emb_054
#> 1 -0.003204715 -0.03820517 0.04289567 -0.02365533 -5.944681e-15 0.02874709 -0.01588802 -0.0211444 -2.811857e-14 -0.02247419
#>      emb_055    emb_056     emb_057      emb_058    emb_059      emb_060    emb_061    emb_062     emb_063     emb_064
#> 1 0.01404841 0.02320598 -0.05669309 4.630966e-16 0.06393656 -0.003755529 -0.0263556 0.06963348 -0.05871841 -0.08283147
#>      emb_065       emb_066     emb_067    emb_068    emb_069     emb_070    emb_071   emb_072     emb_073      emb_074
#> 1 0.03233505 -1.441555e-15 -0.03641877 0.01702242 0.06373662 -0.01303886 -0.3494035 0.1103518 -0.06503496 2.838008e-15
#>       emb_075    emb_076   emb_077      emb_078   emb_079     emb_080   emb_081     emb_082    emb_083    emb_084    emb_085
#> 1 -0.09284457 0.02124879 0.1085678 2.211339e-15 -0.251528 -0.09290887 0.1944582 -0.05660088 0.01629156 0.02405552 0.06484271
#>        emb_086     emb_087      emb_088    emb_089     emb_090     emb_091    emb_092     emb_093     emb_094      emb_095
#> 1 3.469447e-16 -0.02181927 9.089951e-16 0.02177562 -0.06472809 0.001181195 -0.0463867 -0.02218124 -0.03128873 2.745238e-14
#>      emb_096   emb_097      emb_098     emb_099     emb_100     emb_101     emb_102     emb_103       emb_104     emb_105
#> 1 0.02773409 0.1494745 4.288887e-15 0.007570393 -0.04882197 0.008137181 -0.04422842 -0.06598283 -7.952108e-15 0.005247747
#>      emb_106       emb_107    emb_108     emb_109       emb_110     emb_111    emb_112     emb_113    emb_114    emb_115
#> 1 0.01667812 -1.427352e-15 -0.0231042 -0.07101445 -3.275418e-14 -0.02052179 0.05204774 -0.03149831 0.01824475 0.03663663
#>      emb_116    emb_117  emb_118      emb_119     emb_120   emb_121   emb_122    emb_123       emb_124   emb_125     emb_126
#> 1 0.03726996 0.05580929 0.079616 -0.009899394 -0.04699317 0.2519331 0.2206324 0.06455009 -1.003538e-12 0.1807549 -0.06479312
#>      emb_127   emb_128      emb_129     emb_130    emb_131       emb_132    emb_133     emb_134     emb_135     emb_136
#> 1 -0.1548274 0.1010927 5.272085e-14 0.009017079 0.02185068 -4.631755e-14 0.07297088 -0.09302011 0.003222476 -0.02004648
#>       emb_137    emb_138       emb_139    emb_140   emb_141    emb_142     emb_143   emb_144     emb_145     emb_146
#> 1 0.007307386 -0.0250568 -2.253059e-14 0.02876285 0.1002285 0.02227501 -0.02635462 -0.063764 -0.07715663 -0.05728168
#>      emb_147       emb_148     emb_149    emb_150       emb_151    emb_152   emb_153    emb_154     emb_155     emb_156
#> 1 -0.1044355 -1.618621e-13 -0.06025092 0.07732774 -6.542347e-14 0.02152605 0.1060558 -0.1015316 5.69959e-13 -0.08239457
#>       emb_157     emb_158    emb_159    emb_160     emb_161     emb_162      emb_163     emb_164   emb_165    emb_166
#> 1 -0.04868086 -0.07823247 -0.0415651 0.03196455 -0.01268101 -0.02458498 3.823981e-16 -0.01244411 0.1629888 -0.1120408
#>         emb_167   emb_168   emb_169    emb_170     emb_171      emb_172  emb_173    emb_174     emb_175      emb_176
#> 1 -5.402618e-13 0.1378649 0.1073469 -0.1187398 -0.01592048 6.921547e-16 0.116662 0.06197424 -0.04106015 2.789401e-13
#>      emb_177    emb_178     emb_179  emb_180      emb_181     emb_182    emb_183       emb_184   emb_185     emb_186
#> 1 0.09776847 0.02808001 0.001654821 0.115253 -0.008950287 0.007458146 -0.0482787 -1.014295e-12 0.2108666 -0.03448274
#>      emb_187     emb_188       emb_189    emb_190   emb_191     emb_192     emb_193      emb_194      emb_195     emb_196
#> 1 -0.1019806 -0.08533795 -1.095591e-13 0.03257969 0.1005787 -0.03361096 -0.06593127 6.337812e-14 -0.004600378 -0.01190098
#>     emb_197     emb_198     emb_199      emb_200     emb_201   emb_202     emb_203     emb_204      emb_205    emb_206
#> 1 0.1450288 -0.02699752 -0.04894075 3.454355e-14 -0.01969393 0.0126802 -0.07223796 -0.02689012 -0.008998234 0.06339026
#>        emb_207    emb_208     emb_209   emb_210    emb_211   emb_212    emb_213       emb_214     emb_215       emb_216
#> 1 -2.72192e-13 0.01017948 0.006078192 0.1841305 0.04989772 -0.078352 0.07491462 -6.223667e-14 -0.01046129 -3.343012e-13
#>       emb_217    emb_218       emb_219   emb_220     emb_221   emb_222    emb_223   emb_224     emb_225       emb_226
#> 1 -0.06186115 -0.1014886 -7.100241e-13 0.1895484 -0.08542429 -0.105118 -0.1295739 0.1618792 -0.05942145 -2.654361e-13
#>       emb_227     emb_228    emb_229  emb_230       emb_231  emb_232    emb_233      emb_234    emb_235    emb_236   emb_237
#> 1 -0.02000706 -0.00404533 0.06079098 0.109732 -2.502842e-13 0.152951 0.02181502 5.757504e-14 0.01815343 -0.2105797 0.1222895
#>        emb_238   emb_239     emb_240      emb_241       emb_242    emb_243    emb_244    emb_245      emb_246    emb_247
#> 1 5.982216e-12 0.1630277 -0.01378361 6.042562e-14 -0.0003012956 -0.1153104 0.05677129 0.01891039 2.826472e-14 0.02471816
#>      emb_248     emb_249     emb_250     emb_251      emb_252     emb_253    emb_254      emb_255      emb_256     emb_257
#> 1 -0.0965776 -0.05466845 -0.06784251 0.006253995 7.272481e-14 -0.03053079 0.05388221 1.686689e-13 -0.008373781 -0.09103702
#>      emb_258       emb_259     emb_260    emb_261    emb_262   emb_263     emb_264    emb_265    emb_266      emb_267
#> 1 0.04108412 -1.478227e-13 0.007485319 0.04181334 0.01689354 0.0556558 -0.03840312 0.02186264 0.05101616 1.709674e-13
#>      emb_268      emb_269   emb_270   emb_271      emb_272    emb_273     emb_274     emb_275     emb_276    emb_277
#> 1 0.01420791 3.478641e-13 0.1578868 0.1157476 1.119498e-12 0.01239716 -0.06575584 -0.01166207 -0.05209524 0.03439466
#>      emb_278    emb_279   emb_280      emb_281    emb_282    emb_283     emb_284     emb_285     emb_286       emb_287
#> 1 -0.0828473 0.05798466 0.1157152 1.442535e-12 0.07220102 0.03024337 -0.04099056 -0.09026382 0.005694954 -7.309474e-13
#>      emb_288    emb_289     emb_290    emb_291      emb_292    emb_293    emb_294    emb_295     emb_296    emb_297
#> 1 0.01753257 0.08975417 0.006249599 0.04869372 5.186095e-13 0.01706837 0.03752635 0.02180578 -0.06536492 0.08750965
#>       emb_298     emb_299     emb_300     emb_301     emb_302   emb_303    emb_304       emb_305     emb_306       emb_307
#> 1 1.23007e-12 -0.03461091 -0.01252934 -0.02078484 -0.06089479 0.1251189 0.07787031 -6.861248e-13 -0.06359978 -2.450384e-13
#>       emb_308    emb_309      emb_310    emb_311    emb_312    emb_313     emb_314    emb_315     emb_316    emb_317
#> 1 -0.05108487 0.02028093 3.982231e-13 0.01712034 -0.1433469 -0.1420363 -0.07349513 0.02789938 -0.07610766 0.02289498
#>      emb_318    emb_319     emb_320      emb_321     emb_322     emb_323       emb_324    emb_325     emb_326      emb_327
#> 1 -0.1813304 0.06448579 -0.03121174 2.094725e-12 -0.06376456 -0.02779668 -2.147796e-13 0.02805153 -0.06059977 7.184431e-13
#>      emb_328    emb_329       emb_330    emb_331     emb_332     emb_333    emb_334       emb_335   emb_336     emb_337
#> 1 0.05250977 -0.1191304 -4.764114e-13 0.01789391 -0.04050895 -0.02071859 0.04258266 -7.929467e-14 0.0248878 -0.07067935
#>       emb_338     emb_339     emb_340    emb_341      emb_342     emb_343   emb_344    emb_345      emb_346   emb_347
#> 1 -0.03352817 -0.05853304 1.02483e-12 0.07822145 4.994512e-13 0.007989081 0.0972824 0.02649074 4.631122e-13 -0.106191
#>     emb_348       emb_349     emb_350     emb_351    emb_352    emb_353     emb_354   emb_355    emb_356      emb_357
#> 1 0.1188683 -1.239666e-12 -0.04890046 -0.01131075 0.03831049 -0.1975711 -0.09026127 -0.135166 0.03808265 5.980748e-13
#>      emb_358    emb_359       emb_360    emb_361      emb_362  emb_363   emb_364   emb_365      emb_366    emb_367    emb_368
#> 1 0.03793347 -0.0307508 -1.723374e-13 0.02532437 4.554078e-11 0.152117 0.1197015 -0.159713 1.642832e-12 0.05214736 -0.1029804
#>        emb_369     emb_370     emb_371     emb_372     emb_373   emb_374     emb_375    emb_376    emb_377      emb_378
#> 1 1.179057e-13 -0.04246897 -0.04615114 -0.02986085 4.11805e-13 0.0720955 -0.06018222 0.01853718 -0.1600198 -1.82437e-13
#>       emb_379     emb_380    emb_381    emb_382     emb_383    emb_384       emb_385   emb_386     emb_387   emb_388
#> 1 -0.02455534 -0.01357044 -0.1934758 0.03872473 -0.01408732 0.06700636 -2.205113e-12 0.1320191 -0.09288031 0.1269505
#>        emb_389    emb_390      emb_391     emb_392     emb_393     emb_394   emb_395      emb_396    emb_397    emb_398
#> 1 3.350228e-13 0.01268826 -2.24102e-13 -0.08240145 -0.05412759 -0.01469552 0.1422388 1.742402e-13 -0.1342045 0.04214676
#>       emb_399    emb_400    emb_401       emb_402     emb_403     emb_404       emb_405    emb_406     emb_407      emb_408
#> 1 -0.06020202 0.09372214 0.08420271 -4.783113e-13 0.001563145 -0.09189553 -2.980191e-12 -0.1191528 0.000946621 -4.46585e-14
#>       emb_409   emb_410   emb_411     emb_412   emb_413     emb_414      emb_415    emb_416      emb_417    emb_418
#> 1 -0.02036862 0.1231983 0.1170976 -0.01417901 0.1533088 -0.02945385 1.958712e-11 0.06601929 2.880125e-12 0.08959574
#>         emb_419    emb_420    emb_421       emb_422    emb_423    emb_424     emb_425     emb_426      emb_427   emb_428
#> 1 -1.612864e-11 0.08746608 0.05071407 -1.183341e-08 0.07989405 0.03126318 -0.05084686 -0.02092343 1.652089e-06 0.1404991
#>      emb_429      emb_430   emb_431   emb_432    emb_433    emb_434   emb_435    emb_436    emb_437   emb_438     emb_439
#> 1 0.05859478 4.018882e-06 0.1611122 0.1176786 0.02557395 0.08277447 0.0621556 0.06186424 0.04861409 0.1451271 -0.01634767
#>      emb_440    emb_441     emb_442     emb_443    emb_444     emb_445    emb_446    emb_447    emb_448     emb_449    emb_450
#> 1 -0.1823832 0.05367405 -0.01161441 0.005262139 -0.0116983 -0.03267676 0.02902867 0.05791496 0.04240405 0.001065599 0.04283678
#>       emb_451     emb_452    emb_453    emb_454     emb_455     emb_456     emb_457     emb_458     emb_459     emb_460
#> 1 -0.04969012 -0.04251662 0.01640115 0.09246403 -0.02880282 0.002619994 -0.06642604 -0.02627725 -0.05120852 -0.02214393
#>       emb_461     emb_462     emb_463     emb_464     emb_465    emb_466    emb_467    emb_468     emb_469    emb_470
#> 1 -0.04553535 0.006667155 0.009909439 -0.04677366 -0.07805975 0.04139923 0.02800893 -0.0146145 -0.01880968 0.08013333
#>         emb_471       emb_472     emb_473     emb_474      emb_475    emb_476      emb_477    emb_478   emb_479     emb_480
#> 1 -0.0008826349 -0.0006338334 -0.05826985 -0.01725681 -0.005946337 0.06276184 -0.005633696 0.03963313 0.1289018 -0.04810837
#>      emb_481     emb_482      emb_483      emb_484     emb_485     emb_486   emb_487     emb_488    emb_489     emb_490
#> 1 0.05533861 -0.02468046 7.029945e-05 -0.009101552 -0.02552084 -0.03073253 0.0436446 -0.03938914 0.06520238 -0.07481051
#>       emb_491      emb_492     emb_493   emb_494     emb_495     emb_496   emb_497    emb_498    emb_499    emb_500
#> 1 -0.03830966 -0.007437952 -0.08858182 0.0427307 -0.04997836 -0.01258949 0.0120235 -0.0134493 0.01217242 0.02225303
#>  [ reached 'max' / getOption("max.print") -- omitted 4 rows ]

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(
    mtsamples[1:5, 1:2],
    type = 'cui2vec',
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   clinspacy_id note_id                                                      description emb_001 emb_002 emb_003 emb_004
#> 1            1       1 A 23-year-old white female presents with complaint of allergies.      NA      NA      NA      NA
#>   emb_005 emb_006 emb_007 emb_008 emb_009 emb_010 emb_011 emb_012 emb_013 emb_014 emb_015 emb_016 emb_017 emb_018 emb_019
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_020 emb_021 emb_022 emb_023 emb_024 emb_025 emb_026 emb_027 emb_028 emb_029 emb_030 emb_031 emb_032 emb_033 emb_034
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_035 emb_036 emb_037 emb_038 emb_039 emb_040 emb_041 emb_042 emb_043 emb_044 emb_045 emb_046 emb_047 emb_048 emb_049
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_050 emb_051 emb_052 emb_053 emb_054 emb_055 emb_056 emb_057 emb_058 emb_059 emb_060 emb_061 emb_062 emb_063 emb_064
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_065 emb_066 emb_067 emb_068 emb_069 emb_070 emb_071 emb_072 emb_073 emb_074 emb_075 emb_076 emb_077 emb_078 emb_079
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_080 emb_081 emb_082 emb_083 emb_084 emb_085 emb_086 emb_087 emb_088 emb_089 emb_090 emb_091 emb_092 emb_093 emb_094
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_095 emb_096 emb_097 emb_098 emb_099 emb_100 emb_101 emb_102 emb_103 emb_104 emb_105 emb_106 emb_107 emb_108 emb_109
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_110 emb_111 emb_112 emb_113 emb_114 emb_115 emb_116 emb_117 emb_118 emb_119 emb_120 emb_121 emb_122 emb_123 emb_124
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_125 emb_126 emb_127 emb_128 emb_129 emb_130 emb_131 emb_132 emb_133 emb_134 emb_135 emb_136 emb_137 emb_138 emb_139
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_140 emb_141 emb_142 emb_143 emb_144 emb_145 emb_146 emb_147 emb_148 emb_149 emb_150 emb_151 emb_152 emb_153 emb_154
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_155 emb_156 emb_157 emb_158 emb_159 emb_160 emb_161 emb_162 emb_163 emb_164 emb_165 emb_166 emb_167 emb_168 emb_169
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_170 emb_171 emb_172 emb_173 emb_174 emb_175 emb_176 emb_177 emb_178 emb_179 emb_180 emb_181 emb_182 emb_183 emb_184
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_185 emb_186 emb_187 emb_188 emb_189 emb_190 emb_191 emb_192 emb_193 emb_194 emb_195 emb_196 emb_197 emb_198 emb_199
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_200 emb_201 emb_202 emb_203 emb_204 emb_205 emb_206 emb_207 emb_208 emb_209 emb_210 emb_211 emb_212 emb_213 emb_214
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_215 emb_216 emb_217 emb_218 emb_219 emb_220 emb_221 emb_222 emb_223 emb_224 emb_225 emb_226 emb_227 emb_228 emb_229
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_230 emb_231 emb_232 emb_233 emb_234 emb_235 emb_236 emb_237 emb_238 emb_239 emb_240 emb_241 emb_242 emb_243 emb_244
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_245 emb_246 emb_247 emb_248 emb_249 emb_250 emb_251 emb_252 emb_253 emb_254 emb_255 emb_256 emb_257 emb_258 emb_259
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_260 emb_261 emb_262 emb_263 emb_264 emb_265 emb_266 emb_267 emb_268 emb_269 emb_270 emb_271 emb_272 emb_273 emb_274
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_275 emb_276 emb_277 emb_278 emb_279 emb_280 emb_281 emb_282 emb_283 emb_284 emb_285 emb_286 emb_287 emb_288 emb_289
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_290 emb_291 emb_292 emb_293 emb_294 emb_295 emb_296 emb_297 emb_298 emb_299 emb_300 emb_301 emb_302 emb_303 emb_304
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_305 emb_306 emb_307 emb_308 emb_309 emb_310 emb_311 emb_312 emb_313 emb_314 emb_315 emb_316 emb_317 emb_318 emb_319
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_320 emb_321 emb_322 emb_323 emb_324 emb_325 emb_326 emb_327 emb_328 emb_329 emb_330 emb_331 emb_332 emb_333 emb_334
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_335 emb_336 emb_337 emb_338 emb_339 emb_340 emb_341 emb_342 emb_343 emb_344 emb_345 emb_346 emb_347 emb_348 emb_349
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_350 emb_351 emb_352 emb_353 emb_354 emb_355 emb_356 emb_357 emb_358 emb_359 emb_360 emb_361 emb_362 emb_363 emb_364
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_365 emb_366 emb_367 emb_368 emb_369 emb_370 emb_371 emb_372 emb_373 emb_374 emb_375 emb_376 emb_377 emb_378 emb_379
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_380 emb_381 emb_382 emb_383 emb_384 emb_385 emb_386 emb_387 emb_388 emb_389 emb_390 emb_391 emb_392 emb_393 emb_394
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_395 emb_396 emb_397 emb_398 emb_399 emb_400 emb_401 emb_402 emb_403 emb_404 emb_405 emb_406 emb_407 emb_408 emb_409
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_410 emb_411 emb_412 emb_413 emb_414 emb_415 emb_416 emb_417 emb_418 emb_419 emb_420 emb_421 emb_422 emb_423 emb_424
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_425 emb_426 emb_427 emb_428 emb_429 emb_430 emb_431 emb_432 emb_433 emb_434 emb_435 emb_436 emb_437 emb_438 emb_439
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_440 emb_441 emb_442 emb_443 emb_444 emb_445 emb_446 emb_447 emb_448 emb_449 emb_450 emb_451 emb_452 emb_453 emb_454
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_455 emb_456 emb_457 emb_458 emb_459 emb_460 emb_461 emb_462 emb_463 emb_464 emb_465 emb_466 emb_467 emb_468 emb_469
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_470 emb_471 emb_472 emb_473 emb_474 emb_475 emb_476 emb_477 emb_478 emb_479 emb_480 emb_481 emb_482 emb_483 emb_484
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_485 emb_486 emb_487 emb_488 emb_489 emb_490 emb_491 emb_492 emb_493 emb_494 emb_495 emb_496 emb_497 emb_498 emb_499
#> 1      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA      NA
#>   emb_500
#> 1      NA
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
