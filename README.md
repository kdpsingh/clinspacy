
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clinspacy

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
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
#> Welcome to clinspacy.
#> By default, this package will install and use miniconda and create a "clinspacy" conda environment.
#> If you want to override this behavior, use clinspacy_init(miniconda = FALSE) and specify an alternative environment using reticulate::use_python() or reticulate::use_conda().
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
#>   |                                                                              |                                                                      |   0%  |                                                                              |======================================================================| 100%
#>   clinspacy_id      entity       lemma is_family is_historical is_hypothetical
#> 1            1     patient     patient     FALSE         FALSE           FALSE
#> 2            1    diabetes    diabetes     FALSE         FALSE           FALSE
#> 3            1 CKD stage 3 ckd stage 3     FALSE         FALSE           FALSE
#> 4            1         HTN         htn     FALSE         FALSE           FALSE
#>   is_negated is_uncertain section_title
#> 1      FALSE        FALSE          <NA>
#> 2      FALSE        FALSE          <NA>
#> 3      FALSE        FALSE          <NA>
#> 4       TRUE        FALSE          <NA>

clinspacy('HISTORY: He presents with chest pain. PMH: HTN. MEDICATIONS: This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved. ALLERGIES: penicillin.', verbose = FALSE)
#>    clinspacy_id     entity      lemma is_family is_historical is_hypothetical
#> 1             1 chest pain chest pain     FALSE          TRUE           FALSE
#> 2             1        PMH        PMH     FALSE         FALSE           FALSE
#> 3             1        HTN        htn     FALSE         FALSE           FALSE
#> 4             1    patient    patient     FALSE         FALSE           FALSE
#> 5             1   diabetes   diabetes     FALSE         FALSE           FALSE
#> 6             1 omeprazole omeprazole     FALSE         FALSE           FALSE
#> 7             1    aspirin    aspirin     FALSE         FALSE           FALSE
#> 8             1 lisinopril lisinopril     FALSE         FALSE           FALSE
#> 9             1  albuterol  albuterol     FALSE         FALSE           FALSE
#> 10            1     asthma     asthma     FALSE         FALSE           FALSE
#> 11            1 penicillin penicillin     FALSE         FALSE           FALSE
#>    is_negated is_uncertain        section_title
#> 1       FALSE        FALSE                 <NA>
#> 2       FALSE        FALSE past_medical_history
#> 3       FALSE        FALSE past_medical_history
#> 4       FALSE        FALSE          medications
#> 5       FALSE        FALSE          medications
#> 6       FALSE        FALSE          medications
#> 7       FALSE        FALSE          medications
#> 8       FALSE        FALSE          medications
#> 9        TRUE        FALSE          medications
#> 10       TRUE        FALSE          medications
#> 11      FALSE        FALSE            allergies
```

### A character vector as input

``` r
clinspacy(c('This pt has CKD and HTN', 'Pt only has CKD but no HTN'),
          verbose = FALSE)
#>   clinspacy_id entity lemma is_family is_historical is_hypothetical is_negated
#> 1            1    CKD   ckd     FALSE         FALSE           FALSE      FALSE
#> 2            1    HTN   htn     FALSE         FALSE           FALSE      FALSE
#> 3            2     Pt    pt     FALSE         FALSE           FALSE      FALSE
#> 4            2    CKD   ckd     FALSE         FALSE           FALSE      FALSE
#> 5            2    HTN   htn     FALSE         FALSE           FALSE       TRUE
#>   is_uncertain section_title
#> 1        FALSE          <NA>
#> 2        FALSE          <NA>
#> 3        FALSE          <NA>
#> 4        FALSE          <NA>
#> 5        FALSE          <NA>
```

### A data frame as input

``` r
data.frame(text = c('This pt has CKD and HTN', 'Diabetes is present'),
           stringsAsFactors = FALSE) %>%
  clinspacy(df_col = 'text', verbose = FALSE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.
#>   clinspacy_id   entity    lemma is_family is_historical is_hypothetical
#> 1            1      CKD      ckd     FALSE         FALSE           FALSE
#> 2            1      HTN      htn     FALSE         FALSE           FALSE
#> 3            2 Diabetes Diabetes     FALSE         FALSE           FALSE
#>   is_negated is_uncertain section_title
#> 1      FALSE        FALSE          <NA>
#> 2      FALSE        FALSE          <NA>
#> 3      FALSE        FALSE          <NA>
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
#>   note_id                                                      description
#> 1       1 A 23-year-old white female presents with complaint of allergies.
#> 2       2                         Consult for laparoscopic gastric bypass.
#> 3       3                         Consult for laparoscopic gastric bypass.
#> 4       4                                             2-D M-Mode. Doppler.
#> 5       5                                               2-D Echocardiogram
#>            medical_specialty                             sample_name
#> 1       Allergy / Immunology                       Allergic Rhinitis
#> 2                 Bariatrics Laparoscopic Gastric Bypass Consult - 2
#> 3                 Bariatrics Laparoscopic Gastric Bypass Consult - 1
#> 4 Cardiovascular / Pulmonary                  2-D Echocardiogram - 1
#> 5 Cardiovascular / Pulmonary                  2-D Echocardiogram - 2
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
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-d
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-d m-mode allergy complaint consult doppler echocardiogram
#> 1          0       1         1       0       0              0
#> 2          0       0         0       1       0              0
#> 3          0       0         0       1       0              0
#> 4          1       0         0       0       1              0
#> 5          0       0         0       0       0              1
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0
```

### We can also store the intermediate result so that bind\_clinspacy() does not need to re-process the text.

``` r
clinspacy_output_data = 
  mtsamples[1:5, 1:2] %>% 
  clinspacy(df_col = 'description', verbose = FALSE)
#> Since x is a data.frame and no id column was provided, the row number will be used as the id.

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-d
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-d m-mode allergy complaint consult doppler echocardiogram
#> 1          0       1         1       0       0              0
#> 2          0       0         0       1       0              0
#> 3          0       0         0       1       0              0
#> 4          1       0         0       0       1              0
#> 5          0       0         0       0       0              1
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 cs_col = 'entity')
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-D
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-D M-Mode Consult Doppler Echocardiogram allergies complaint
#> 1          0       0       0              0         1         1
#> 2          0       1       0              0         0         0
#> 3          0       1       0              0         0         0
#> 4          1       0       1              0         0         0
#> 5          0       0       0              1         0         0
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0

clinspacy_output_data %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 subset = 'is_uncertain == FALSE & is_negated == FALSE')
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-d
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-d m-mode allergy complaint consult doppler echocardiogram
#> 1          0       1         1       0       0              0
#> 2          0       0         0       1       0              0
#> 3          0       0         0       1       0              0
#> 4          1       0         0       0       1              0
#> 5          0       0         0       0       0              1
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0
```

### We can also re-use the output file we had created earlier and pipe this directly into bind\_clinspacy().

``` r
clinspacy_output_file
#> [1] "C:\\Users\\kdpsingh\\AppData\\Local\\clinspacy\\clinspacy/output.csv"

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2])
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-d
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-d m-mode allergy complaint consult doppler echocardiogram
#> 1          0       1         1       0       0              0
#> 2          0       0         0       1       0              0
#> 3          0       0         0       1       0              0
#> 4          1       0         0       0       1              0
#> 5          0       0         0       0       0              1
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 cs_col = 'entity')
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-D
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-D M-Mode Consult Doppler Echocardiogram allergies complaint
#> 1          0       0       0              0         1         1
#> 2          0       1       0              0         0         0
#> 3          0       1       0              0         0         0
#> 4          1       0       1              0         0         0
#> 5          0       0       0              1         0         0
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0

clinspacy_output_file %>% 
  bind_clinspacy(mtsamples[1:5, 1:2],
                 subset = 'is_uncertain == FALSE & is_negated == FALSE')
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description 2-d
#> 1 A 23-year-old white female presents with complaint of allergies.   0
#> 2                         Consult for laparoscopic gastric bypass.   0
#> 3                         Consult for laparoscopic gastric bypass.   0
#> 4                                             2-D M-Mode. Doppler.   0
#> 5                                               2-D Echocardiogram   1
#>   2-d m-mode allergy complaint consult doppler echocardiogram
#> 1          0       1         1       0       0              0
#> 2          0       0         0       1       0              0
#> 3          0       0         0       1       0              0
#> 4          1       0         0       0       1              0
#> 5          0       0         0       0       0              1
#>   laparoscopic gastric bypass white female
#> 1                           0            1
#> 2                           1            0
#> 3                           1            0
#> 4                           0            0
#> 5                           0            0
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
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description    emb_001
#> 1 A 23-year-old white female presents with complaint of allergies. -0.1959790
#> 2                         Consult for laparoscopic gastric bypass. -0.1115363
#> 3                         Consult for laparoscopic gastric bypass. -0.1115363
#> 4                                             2-D M-Mode. Doppler. -0.3077586
#> 5                                               2-D Echocardiogram  0.0248010
#>      emb_002     emb_003     emb_004    emb_005     emb_006      emb_007
#> 1 0.28813400  0.09685702 -0.20641684 -0.1554238 -0.01624470  0.027011001
#> 2 0.01725144 -0.13519235 -0.05496463  0.1488807 -0.19577999  0.052658666
#> 3 0.01725144 -0.13519235 -0.05496463  0.1488807 -0.19577999  0.052658666
#> 4 0.25928350 -0.37220851 -0.06021732  0.0386426 -0.07756314 -0.002676249
#> 5 0.32503700 -0.28739650  0.01444300  0.3118135 -0.10344578  0.034334995
#>       emb_008    emb_009    emb_010    emb_011     emb_012   emb_013    emb_014
#> 1  0.05331314 -0.1006668  0.3682853  0.0581439 -0.29079599 0.1611375 -0.1118952
#> 2 -0.10433200 -0.0763495  0.1199215 -0.1860092  0.05465447 0.1267057 -0.2041533
#> 3 -0.10433200 -0.0763495  0.1199215 -0.1860092  0.05465447 0.1267057 -0.2041533
#> 4  0.22511028  0.3279995 -0.2274373 -0.1656060 -0.30020200 0.5237787 -0.1472114
#> 5  0.06645205  0.1221710 -0.1668975  0.0184820 -0.06891620 0.4037399 -0.1430462
#>        emb_015     emb_016    emb_017      emb_018    emb_019      emb_020
#> 1 -0.039228218  0.06888010 -0.1862742 -0.145445829 0.04115367  0.049065500
#> 2  0.019849837 -0.01107489  0.1080266  0.112868395 0.23062316 -0.005933613
#> 3  0.019849837 -0.01107489  0.1080266  0.112868395 0.23062316 -0.005933613
#> 4 -0.023120617 -0.11272645 -0.3415540 -0.225593105 0.02385290  0.074861225
#> 5  0.007815915  0.15463200 -0.3087570 -0.009520501 0.16392200  0.267250001
#>      emb_021     emb_022     emb_023     emb_024     emb_025     emb_026
#> 1 0.39795328 0.058790984  0.05246135 -0.19981400 -0.03346085 0.139552017
#> 2 0.06126638 0.050485155  0.12351524 -0.02489970 -0.26744565 0.341824006
#> 3 0.06126638 0.050485155  0.12351524 -0.02489970 -0.26744565 0.341824006
#> 4 0.12910485 0.021764326 -0.21616454  0.08218845  0.33230226 0.242083345
#> 5 0.46028921 0.005547501 -0.14656110  0.02836150 -0.05752635 0.001926851
#>       emb_027     emb_028     emb_029     emb_030     emb_031     emb_032
#> 1  0.01792375 -0.06969561 -0.04942485  0.06613978  0.08035761 -0.12418544
#> 2 -0.12783451  0.38420413 -0.20168215 -0.06550949  0.26997083 -0.07201438
#> 3 -0.12783451  0.38420413 -0.20168215 -0.06550949  0.26997083 -0.07201438
#> 4  0.08455360  0.22111987 -0.57962301  0.32054099 -0.26178523 -0.46501200
#> 5  0.27219920  0.07002290 -0.23144800  0.13926494 -0.11301645 -0.24977000
#>       emb_033     emb_034     emb_035     emb_036     emb_037    emb_038
#> 1 -0.11839510  0.04266573 -0.04319873  0.06394462  0.02425202 -0.2158322
#> 2  0.13039007 -0.13608095  0.10342984  0.03349850 -0.06359592 -0.2497478
#> 3  0.13039007 -0.13608095  0.10342984  0.03349850 -0.06359592 -0.2497478
#> 4  0.05091595 -0.22430425 -0.07319695 -0.19518739 -0.21279503 -0.1980325
#> 5 -0.00930570 -0.35272649 -0.30005701 -0.10336256 -0.21567906 -0.1840260
#>      emb_039      emb_040     emb_041     emb_042      emb_043    emb_044
#> 1 -0.1064802  0.005398401  0.01459978 -0.03936125 -0.216860471 0.01146569
#> 2 -0.1312915 -0.068015995  0.12897950  0.20849532 -0.001854315 0.02034700
#> 3 -0.1312915 -0.068015995  0.12897950  0.20849532 -0.001854315 0.02034700
#> 4 -0.3900315  0.214830723 -0.03985715  0.32672650 -0.067201529 0.43131340
#> 5 -0.2846705  0.112792948 -0.08530600  0.09504810  0.176578552 0.40816229
#>       emb_045     emb_046     emb_047     emb_048     emb_049     emb_050
#> 1 -0.01707370 -0.08789315 -0.48977432  0.11840488 -0.24063642 -0.23959090
#> 2  0.04105476 -0.26218344  0.05762917 -0.08367021 -0.01368977  0.02369371
#> 3  0.04105476 -0.26218344  0.05762917 -0.08367021 -0.01368977  0.02369371
#> 4 -0.10445137 -0.36873272  0.39958726  0.03923560  0.06519943 -0.12042060
#> 5 -0.16311774 -0.13193195  0.21882000  0.01659951  0.06224230 -0.09493070
#>      emb_051       emb_052     emb_053     emb_054     emb_055      emb_056
#> 1 0.12583705 -0.0001312072 -0.15632193  0.20631963 -0.02019964 -0.002069766
#> 2 0.12660855 -0.1197809521  0.04324770 -0.20467351 -0.21317951  0.029707700
#> 3 0.12660855 -0.1197809521  0.04324770 -0.20467351 -0.21317951  0.029707700
#> 4 0.19479172  0.5587487221  0.02909975 -0.11123860 -0.29085600  0.051582206
#> 5 0.07704145  0.1767845079 -0.07080305 -0.08130625 -0.01666629 -0.006544501
#>       emb_057      emb_058      emb_059    emb_060     emb_061     emb_062
#> 1 -0.14390510 -0.112056380 -0.126715158 -0.3076788  0.01722672 -0.04037631
#> 2 -0.04107177 -0.003977332  0.033270188  0.1377243  0.18907296 -0.26335296
#> 3 -0.04107177 -0.003977332  0.033270188  0.1377243  0.18907296 -0.26335296
#> 4  0.03322158 -0.090760550 -0.017380998  0.4675597 -0.29520441  0.62886798
#> 5 -0.11609610 -0.047952104  0.008716501  0.3083473 -0.22871131  0.45885500
#>       emb_063      emb_064     emb_065    emb_066     emb_067     emb_068
#> 1  0.14633203  0.072336150  0.04734538  0.2444712 0.005439494  0.07232769
#> 2  0.01884718 -0.009265006 -0.16859459 -0.2767420 0.048937336 -0.35522249
#> 3  0.01884718 -0.009265006 -0.16859459 -0.2767420 0.048937336 -0.35522249
#> 4 -0.14435785  0.002738898 -0.03027805 -0.4466182 0.080596073  0.29857932
#> 5 -0.11078550  0.288143490 -0.07003010 -0.2528103 0.063950002 -0.04936190
#>       emb_069     emb_070     emb_071     emb_072    emb_073     emb_074
#> 1  0.19727601 0.007281476 -0.03698583 -0.07433472 -0.0170116  0.15559705
#> 2  0.11645776 0.345116988 -0.03482347 -0.09575927 -0.1530600 -0.08885341
#> 3  0.11645776 0.345116988 -0.03482347 -0.09575927 -0.1530600 -0.08885341
#> 4  0.23078560 0.032678135 -0.02464749 -0.05315572  0.2278580  0.05121428
#> 5 -0.06566995 0.169240553 -0.20291301  0.07451350  0.2253695 -0.12425205
#>      emb_075    emb_076     emb_077     emb_078    emb_079    emb_080
#> 1 -0.0142159 0.03095377  0.14973202 -0.07275485 -0.1265165  0.0756736
#> 2  0.1138750 0.24408367  0.01405296 -0.00684475 -0.1356777 -0.1306460
#> 3  0.1138750 0.24408367  0.01405296 -0.00684475 -0.1356777 -0.1306460
#> 4  0.3368990 0.12042545  0.05976460  0.20906300 -0.3898960 -0.2403080
#> 5  0.3129840 0.08488315 -0.03176650  0.21367506 -0.3424945 -0.2282295
#>      emb_081     emb_082    emb_083     emb_084    emb_085     emb_086
#> 1 -0.1064746 -0.04138183  0.1262948 -0.07008250 -0.0581785 -0.08323197
#> 2  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527  0.09356334
#> 3  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527  0.09356334
#> 4 -0.2094990 -0.43718034 -0.2580445 -0.36398449 -0.1863167 -0.38763523
#> 5 -0.1765565 -0.07380365 -0.0290005 -0.36411649 -0.2000140 -0.17566951
#>      emb_087     emb_088     emb_089     emb_090    emb_091    emb_092
#> 1 -0.1252120  0.10060352 -0.01839051 -0.24945817  0.2108233  0.2314818
#> 2 -0.2311737  0.01929579 -0.18456985  0.16967812 -0.3636869 -0.1134262
#> 3 -0.2311737  0.01929579 -0.18456985  0.16967812 -0.3636869 -0.1134262
#> 4  0.1124806 -0.25680842 -0.21670937 -0.02249805  0.2278338 -0.1409704
#> 5 -0.1593248 -0.09905184 -0.08182025 -0.08445005  0.2834230 -0.2843715
#>       emb_093     emb_094      emb_095     emb_096    emb_097      emb_098
#> 1 -0.07174893  0.03378552  0.002213914  0.22163883 0.30331765  0.009472401
#> 2  0.07241845  0.29899751  0.111884147 -0.04911397 0.05792167 -0.125230156
#> 3  0.07241845  0.29899751  0.111884147 -0.04911397 0.05792167 -0.125230156
#> 4  0.17529125 -0.05521812 -0.186143875  0.54336450 0.13775243 -0.269951746
#> 5  0.17449000 -0.29530999 -0.272728994  0.59950200 0.26153735 -0.204290494
#>       emb_099     emb_100     emb_101     emb_102    emb_103     emb_104
#> 1 -0.14205784  0.12607630 -0.19062089 -0.08417289 -0.0868922  0.08520973
#> 2 -0.27682150 -0.03230023  0.09556636 -0.01811487  0.2020687 -0.28405397
#> 3 -0.27682150 -0.03230023  0.09556636 -0.01811487  0.2020687 -0.28405397
#> 4  0.01101355  0.12618919  0.24217032  0.19674813  0.1094553 -0.02718710
#> 5 -0.06863150  0.03690425  0.07848000  0.10549650 -0.1505125 -0.23440950
#>         emb_105    emb_106     emb_107    emb_108     emb_109     emb_110
#> 1  0.1095840322  0.0911104 -0.11639215 -0.1988509 -0.02318672 -0.03355397
#> 2 -0.2379808277  0.0503400  0.07255385 -0.3391048  0.29906577 -0.28191616
#> 3 -0.2379808277  0.0503400  0.07255385 -0.3391048  0.29906577 -0.28191616
#> 4 -0.0006717525  0.1023474  0.30398776  0.0299391  0.38101604 -0.07525725
#> 5 -0.0879351497 -0.1177620  0.17887450  0.0354233  0.02180415 -0.06522250
#>       emb_111     emb_112     emb_113     emb_114     emb_115     emb_116
#> 1  0.06281934  0.09064088 -0.18122177 -0.08294683  0.09746995  0.16949679
#> 2  0.04745353 -0.04532966 -0.15290414  0.04579017  0.02364063 -0.31116034
#> 3  0.04745353 -0.04532966 -0.15290414  0.04579017  0.02364063 -0.31116034
#> 4 -0.19109026 -0.09757482 -0.34308612  0.07392349 -0.34514988 -0.05409198
#> 5 -0.13989535 -0.05977940 -0.03180425  0.23478350  0.19365625 -0.02712200
#>        emb_117     emb_118     emb_119    emb_120    emb_121     emb_122
#> 1  0.001256246 -0.09206300 -0.27094193  0.1914412 0.10522338  0.01736773
#> 2  0.160783665 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.20085029
#> 3  0.160783665 -0.07702465 -0.02175729 -0.1156647 0.01362599 -0.20085029
#> 4  0.021575954  0.24660901 -0.25714830 -0.3096262 0.14711675 -0.09584628
#> 5 -0.096087098  0.11767951 -0.06863010 -0.1213299 0.07506394 -0.09055045
#>      emb_123     emb_124      emb_125     emb_126     emb_127    emb_128
#> 1 -0.1658078 -0.24409867 -0.206214733 -0.35578349  0.19991713 -0.1075110
#> 2  0.3362202 -0.03874875 -0.025450919  0.21585878 -0.04820869  0.1341518
#> 3  0.3362202 -0.03874875 -0.025450919  0.21585878 -0.04820869  0.1341518
#> 4 -0.2465328  0.02228437 -0.052871749  0.04758008  0.13082074 -0.4366458
#> 5 -0.5109160  0.10823975  0.001296505  0.23576751  0.05705260 -0.1354439
#>       emb_129    emb_130     emb_131     emb_132    emb_133      emb_134
#> 1 0.050961102 0.08590268 -0.07344585 -0.11005830  0.2082962 -0.034407767
#> 2 0.084913827 0.21485816 -0.26201880 -0.04661880  0.1594945  0.245775409
#> 3 0.084913827 0.21485816 -0.26201880 -0.04661880  0.1594945  0.245775409
#> 4 0.002557264 0.30628723 -0.24981013 -0.01674807 -0.3169997  0.120563023
#> 5 0.218112495 0.30674499  0.11382775 -0.13082594 -0.0999395 -0.003668699
#>       emb_135     emb_136    emb_137     emb_138     emb_139      emb_140
#> 1 -0.15951183  0.04417117 -0.1002716 -0.07090355 -0.09013366  0.004567102
#> 2 -0.04687785  0.02120483 -0.2707188 -0.05038439 -0.21531074 -0.214246295
#> 3 -0.04687785  0.02120483 -0.2707188 -0.05038439 -0.21531074 -0.214246295
#> 4 -0.09506032 -0.01222125 -0.4409042  0.23120450  0.01691840  0.127434801
#> 5 -0.12727565 -0.15309890 -0.1739390  0.12822100 -0.05879501  0.018386799
#>       emb_141     emb_142     emb_143     emb_144    emb_145     emb_146
#> 1 -0.04074124 -0.09970398 -0.07412403  0.08118367 0.04151318  0.01023637
#> 2  0.12730155  0.04358483 -0.04084410  0.08556246 0.37193301 -0.23297635
#> 3  0.12730155  0.04358483 -0.04084410  0.08556246 0.37193301 -0.23297635
#> 4  0.19368662  0.02984041 -0.14155845 -0.15326020 0.02936405  0.05187999
#> 5  0.14392490  0.04070020 -0.19912900 -0.36284100 0.02668950 -0.15666850
#>       emb_147      emb_148     emb_149     emb_150      emb_151    emb_152
#> 1 -0.02712608  0.112079668  0.07420963  0.20229591 -0.025391301 -0.1542052
#> 2  0.16786779 -0.155229501  0.13361997  0.40477166 -0.073850274  0.2168649
#> 3  0.16786779 -0.155229501  0.13361997  0.40477166 -0.073850274  0.2168649
#> 4  0.06006772  0.075826705  0.04905358 -0.01330470  0.257280506  0.2761333
#> 5  0.34401850  0.004391499 -0.05388905  0.07474451  0.004865006  0.3119845
#>       emb_153     emb_154     emb_155    emb_156    emb_157      emb_158
#> 1  0.09878749  0.11210436 0.190853971 -0.2355878  0.1032905 -0.215328269
#> 2  0.08279617  0.02853568 0.007983398 -0.2673024 -0.3518553  0.070976785
#> 3  0.08279617  0.02853568 0.007983398 -0.2673024 -0.3518553  0.070976785
#> 4 -0.10433040 -0.02122432 0.066375951 -0.3625118 -0.2547615  0.135016575
#> 5 -0.10423495 -0.04607965 0.019390000 -0.2215498 -0.1231215  0.001952998
#>       emb_159    emb_160     emb_161     emb_162      emb_163     emb_164
#> 1  0.09456767 -0.1445503 -0.33522494  0.15268593 -0.001686232  0.21527467
#> 2  0.08358909 -0.1986835 -0.29901644 -0.01896982 -0.052200415  0.12627637
#> 3  0.08358909 -0.1986835 -0.29901644 -0.01896982 -0.052200415  0.12627637
#> 4 -0.28645951 -0.1917117 -0.01892012 -0.02507000 -0.031375002 -0.25194155
#> 5 -0.35480101 -0.2524989 -0.16960866 -0.09736640 -0.117169148  0.08709938
#>       emb_165   emb_166     emb_167    emb_168     emb_169    emb_170
#> 1 -0.10312133 0.1135696 -0.02624894  0.1098730  0.09047928 0.12684340
#> 2  0.10607937 0.0321700 -0.25643115 -0.1073976  0.26462262 0.03679075
#> 3  0.10607937 0.0321700 -0.25643115 -0.1073976  0.26462262 0.03679075
#> 4  0.08888888 0.3796148 -0.25476800 -0.1437821 -0.15589955 0.23368900
#> 5  0.01905625 0.4909470 -0.26902150 -0.2136845 -0.43323599 0.11910300
#>      emb_171     emb_172     emb_173     emb_174     emb_175    emb_176
#> 1 -0.0694985 -0.11949543  0.21640414 -0.29396720 -0.16588253 -0.1348005
#> 2 -0.2173935  0.07656907 -0.10125257 -0.02410151 -0.02048860 -0.1179298
#> 3 -0.2173935  0.07656907 -0.10125257 -0.02410151 -0.02048860 -0.1179298
#> 4  0.1311810  0.52442150 -0.04876570  0.25153150  0.02299049 -0.1953604
#> 5  0.3774175  0.23458600 -0.09184425  0.17077650 -0.21101214 -0.1608607
#>       emb_177     emb_178     emb_179     emb_180      emb_181    emb_182
#> 1 -0.11480546 -0.08968537  0.05097483  0.09355133  0.008875800  0.1106400
#> 2  0.23621126  0.30876314 -0.22625668  0.07487945  0.008851715 -0.1024263
#> 3  0.23621126  0.30876314 -0.22625668  0.07487945  0.008851715 -0.1024263
#> 4 -0.15729965  0.29195935 -0.05653973 -0.12341889 -0.312314242 -0.1885454
#> 5 -0.09569005 -0.04013630 -0.13597535 -0.24859951 -0.263478503 -0.3315965
#>       emb_183      emb_184     emb_185     emb_186    emb_187     emb_188
#> 1 -0.10885110 -0.023266877  0.17733055 -0.07351807  0.0222525 -0.12066887
#> 2 -0.22491133 -0.064553898  0.07631866  0.01623236 -0.1098196 -0.04689731
#> 3 -0.22491133 -0.064553898  0.07631866  0.01623236 -0.1098196 -0.04689731
#> 4 -0.28738926 -0.021496000 -0.16462975  0.14877875  0.2350687  0.36260483
#> 5  0.04214405  0.008745506  0.15740950  0.14536099  0.1339420  0.03969285
#>        emb_189    emb_190     emb_191      emb_192     emb_193     emb_194
#> 1 -0.179350998 0.01909462  0.13228424  0.024832169  0.05002003 -0.20531311
#> 2 -0.033685058 0.16270872 -0.05825762  0.069446986 -0.05563271 -0.17479033
#> 3 -0.033685058 0.16270872 -0.05825762  0.069446986 -0.05563271 -0.17479033
#> 4  0.004200405 0.20571376  0.09558415 -0.006550124 -0.30820300  0.01686265
#> 5 -0.084731993 0.04030700  0.05926515 -0.047493299 -0.00803750 -0.00575950
#>       emb_195     emb_196     emb_197     emb_198     emb_199     emb_200
#> 1 -0.00853500  0.06393370  0.29886368  0.01618892 -0.08192083 -0.37027851
#> 2 -0.13635058  0.12910799 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 3 -0.13635058  0.12910799 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 4 -0.05414012 -0.16940087 -0.13313706 -0.15822850  0.14830773 -0.34555282
#> 5  0.12281010 -0.07463215  0.08227439  0.01297700  0.10776870 -0.25013001
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
#>   |                                                                              |                                                                      |   0%  |                                                                              |======================================================================| 100%
#>   clinspacy_id      cui      entity       lemma             semantic_type
#> 1            1 C0030705     patient     patient Patient or Disabled Group
#> 2            1 C1550655     patient     patient            Body Substance
#> 3            1 C1578484     patient     patient           Idea or Concept
#> 4            1 C1578485     patient     patient      Intellectual Product
#> 5            1 C1705908     patient     patient                  Organism
#> 6            1 C0011847    diabetes    diabetes       Disease or Syndrome
#> 7            1 C0011849    diabetes    diabetes       Disease or Syndrome
#> 8            1 C2316787 CKD stage 3 ckd stage 3       Disease or Syndrome
#> 9            1 C0020538         HTN         htn       Disease or Syndrome
#>                        definition is_family is_historical is_hypothetical
#> 1                        Patients     FALSE         FALSE           FALSE
#> 2         Specimen Type - Patient     FALSE         FALSE           FALSE
#> 3 Relationship modifier - Patient     FALSE         FALSE           FALSE
#> 4 Specimen Source Codes - Patient     FALSE         FALSE           FALSE
#> 5              Veterinary Patient     FALSE         FALSE           FALSE
#> 6                        Diabetes     FALSE         FALSE           FALSE
#> 7               Diabetes Mellitus     FALSE         FALSE           FALSE
#> 8  Chronic kidney disease stage 3     FALSE         FALSE           FALSE
#> 9            Hypertensive disease     FALSE         FALSE           FALSE
#>   is_negated is_uncertain section_title
#> 1      FALSE        FALSE          <NA>
#> 2      FALSE        FALSE          <NA>
#> 3      FALSE        FALSE          <NA>
#> 4      FALSE        FALSE          <NA>
#> 5      FALSE        FALSE          <NA>
#> 6      FALSE        FALSE          <NA>
#> 7      FALSE        FALSE          <NA>
#> 8      FALSE        FALSE          <NA>
#> 9       TRUE        FALSE          <NA>

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Pharmacologic Substance')
#>   |                                                                              |                                                                      |   0%  |                                                                              |======================================================================| 100%
#>   clinspacy_id      cui     entity      lemma           semantic_type
#> 1            1 C0028978 omeprazole omeprazole Pharmacologic Substance
#> 2            1 C0004057    aspirin    aspirin Pharmacologic Substance
#> 3            1 C0065374 lisinopril lisinopril Pharmacologic Substance
#> 4            1 C0001927  albuterol  albuterol Pharmacologic Substance
#>   definition is_family is_historical is_hypothetical is_negated is_uncertain
#> 1 Omeprazole     FALSE         FALSE           FALSE      FALSE        FALSE
#> 2    Aspirin     FALSE         FALSE           FALSE      FALSE        FALSE
#> 3 Lisinopril     FALSE         FALSE           FALSE      FALSE        FALSE
#> 4  Albuterol     FALSE         FALSE           FALSE       TRUE        FALSE
#>   section_title
#> 1          <NA>
#> 2          <NA>
#> 3          <NA>
#> 4          <NA>

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Disease or Syndrome')
#>   |                                                                              |                                                                      |   0%  |                                                                              |======================================================================| 100%
#>   clinspacy_id      cui   entity    lemma       semantic_type        definition
#> 1            1 C0011847 diabetes diabetes Disease or Syndrome          Diabetes
#> 2            1 C0011849 diabetes diabetes Disease or Syndrome Diabetes Mellitus
#> 3            1 C0004096   asthma   asthma Disease or Syndrome            Asthma
#>   is_family is_historical is_hypothetical is_negated is_uncertain section_title
#> 1     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 2     FALSE         FALSE           FALSE      FALSE        FALSE          <NA>
#> 3     FALSE         FALSE           FALSE       TRUE        FALSE          <NA>
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
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description C0009818
#> 1 A 23-year-old white female presents with complaint of allergies.        0
#> 2                         Consult for laparoscopic gastric bypass.        1
#> 3                         Consult for laparoscopic gastric bypass.        1
#> 4                                             2-D M-Mode. Doppler.        0
#> 5                                               2-D Echocardiogram        0
#>   C0013516 C0020517 C0277786 C0554756 C1705052 C2243117 C3864418 C4039248
#> 1        0        1        1        0        0        0        1        0
#> 2        0        0        0        0        0        0        0        1
#> 3        0        0        0        0        0        0        0        1
#> 4        0        0        0        1        0        0        0        0
#> 5        1        0        0        0        1        1        0        0

clinspacy_output_file %>%  
  bind_clinspacy(
    mtsamples[1:5, 1:2],
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description C0013516
#> 1 A 23-year-old white female presents with complaint of allergies.       NA
#> 2                         Consult for laparoscopic gastric bypass.       NA
#> 3                         Consult for laparoscopic gastric bypass.       NA
#> 4                                             2-D M-Mode. Doppler.        0
#> 5                                               2-D Echocardiogram        1
#>   C0554756
#> 1       NA
#> 2       NA
#> 3       NA
#> 4        1
#> 5        0
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
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description    emb_001
#> 1 A 23-year-old white female presents with complaint of allergies. -0.3611527
#> 2                         Consult for laparoscopic gastric bypass. -0.1115363
#> 3                         Consult for laparoscopic gastric bypass. -0.1115363
#> 4                                             2-D M-Mode. Doppler. -0.4044230
#> 5                                               2-D Echocardiogram  0.0408278
#>      emb_002    emb_003     emb_004    emb_005     emb_006     emb_007
#> 1 0.30379833  0.1250187 -0.27718534 -0.3054457  0.04946094 -0.13725600
#> 2 0.01725144 -0.1351923 -0.05496463  0.1488807 -0.19577999  0.05265867
#> 3 0.01725144 -0.1351923 -0.05496463  0.1488807 -0.19577999  0.05265867
#> 4 0.21798199 -0.4359590 -0.05181420 -0.0757723 -0.03360050 -0.18084100
#> 5 0.34547000 -0.3142290  0.08719834  0.2681757 -0.13832818 -0.01684400
#>       emb_008     emb_009    emb_010     emb_011     emb_012   emb_013
#> 1  0.05227867 -0.22392599  0.5019193  0.16295764 -0.31555533 0.2533063
#> 2 -0.10433200 -0.07634950  0.1199215 -0.18600916  0.05465447 0.1267057
#> 3 -0.10433200 -0.07634950  0.1199215 -0.18600916  0.05465447 0.1267057
#> 4  0.26080000  0.41815600 -0.2046540 -0.25728899 -0.42502299 0.7310580
#> 5  0.09299837  0.06603294 -0.1864523  0.06326134 -0.04040294 0.5075143
#>      emb_014     emb_015     emb_016    emb_017     emb_018    emb_019
#> 1 -0.3654707 -0.12779960  0.17567993 -0.1446099 -0.12635626 -0.0373060
#> 2 -0.2041533  0.01984984 -0.01107489  0.1080266  0.11286839  0.2306232
#> 3 -0.2041533  0.01984984 -0.01107489  0.1080266  0.11286839  0.2306232
#> 4 -0.1249990 -0.05637670 -0.29954299 -0.2941060 -0.24784601 -0.0287432
#> 5 -0.1778468  0.01172654  0.16634334 -0.3013797  0.09262766  0.2369493
#>        emb_020    emb_021     emb_022    emb_023    emb_024    emb_025
#> 1 -0.115881334 0.57490400  0.12478290  0.0658141 -0.2563947 -0.1376491
#> 2 -0.005933613 0.06126638  0.05048515  0.1235152 -0.0248997 -0.2674457
#> 3 -0.005933613 0.06126638  0.05048515  0.1235152 -0.0248997 -0.2674457
#> 4  0.067911699 0.02872950 -0.02079800 -0.2892080  0.2813420  0.6255990
#> 5  0.297962000 0.58598981 -0.04294700 -0.1767534  0.1260417 -0.0280358
#>     emb_026     emb_027    emb_028     emb_029     emb_030     emb_031
#> 1 0.2429187  0.05097854 -0.1929284 -0.09130429  0.17576200 -0.01365233
#> 2 0.3418240 -0.12783451  0.3842041 -0.20168215 -0.06550949  0.26997083
#> 3 0.3418240 -0.12783451  0.3842041 -0.20168215 -0.06550949  0.26997083
#> 4 0.4281110  0.20646299  0.2296980 -0.74650902  0.35579199 -0.41084301
#> 5 0.0332130  0.34193847  0.0741707 -0.24375234  0.08454626 -0.16307730
#>       emb_032     emb_033      emb_034    emb_035    emb_036     emb_037
#> 1 -0.09805207 -0.13764400  0.004004667  0.0381910  0.1195871  0.01446407
#> 2 -0.07201438  0.13039007 -0.136080950  0.1034298  0.0334985 -0.06359592
#> 3 -0.07201438  0.13039007 -0.136080950  0.1034298  0.0334985 -0.06359592
#> 4 -0.54899400  0.04519010 -0.219888002  0.0889601 -0.3470430 -0.21991500
#> 5 -0.26218967 -0.02029267 -0.433704657 -0.2964910 -0.1361404 -0.27392204
#>      emb_038     emb_039     emb_040    emb_041     emb_042      emb_043
#> 1 -0.2498078  0.09343017  0.04716743  0.1713393 -0.03293247 -0.213242605
#> 2 -0.2497478 -0.13129150 -0.06801600  0.1289795  0.20849532 -0.001854315
#> 3 -0.2497478 -0.13129150 -0.06801600  0.1289795  0.20849532 -0.001854315
#> 4 -0.1619850 -0.53598398  0.34043500 -0.0483518  0.36741400 -0.088588104
#> 5 -0.1496720 -0.25656799  0.13342496 -0.1417563  0.04932813  0.206155370
#>       emb_044     emb_045    emb_046     emb_047     emb_048     emb_049
#> 1 -0.03206829 -0.04169884 -0.1699734 -0.74627431  0.13414333 -0.38696743
#> 2  0.02034700  0.04105476 -0.2621834  0.05762917 -0.08367021 -0.01368977
#> 3  0.02034700  0.04105476 -0.2621834  0.05762917 -0.08367021 -0.01368977
#> 4  0.66488600 -0.06560100 -0.5937040  0.62876701  0.06133320  0.02835000
#> 5  0.51246919 -0.13114166 -0.1510466  0.26385467  0.10011767  0.02377840
#>       emb_050   emb_051     emb_052    emb_053     emb_054      emb_055
#> 1 -0.17838313 0.1920727 -0.09024807 -0.1966087  0.25874766 -0.085749569
#> 2  0.02369371 0.1266086 -0.11978095  0.0432477 -0.20467351 -0.213179514
#> 3  0.02369371 0.1266086 -0.11978095  0.0432477 -0.20467351 -0.213179514
#> 4 -0.15147001 0.2244480  0.58674097  0.0381370 -0.13561600 -0.384492010
#> 5 -0.12043546 0.1156760  0.03966434 -0.1149410 -0.07681337 -0.008278387
#>        emb_056     emb_057      emb_058     emb_059    emb_060    emb_061
#> 1  0.007523434 -0.30075601 -0.115144864 -0.16193766 -0.2485523  0.0884304
#> 2  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.1890730
#> 3  0.029707700 -0.04107177 -0.003977332  0.03327019  0.1377243  0.1890730
#> 4 -0.047390901  0.03690350 -0.155994996 -0.24829200  0.5008110 -0.0982668
#> 5 -0.097004672 -0.18738506 -0.087724405 -0.07461200  0.2359717 -0.1328574
#>       emb_062     emb_063      emb_064     emb_065    emb_066    emb_067
#> 1  0.02391916  0.27797680  0.064277269 -0.03806543  0.3829273 0.09349866
#> 2 -0.26335296  0.01884718 -0.009265006 -0.16859459 -0.2767420 0.04893734
#> 3 -0.26335296  0.01884718 -0.009265006 -0.16859459 -0.2767420 0.04893734
#> 4  0.71681201 -0.03416720 -0.025456199  0.01503300 -0.5353000 0.21822900
#> 5  0.43036801 -0.03723133  0.410141987 -0.08564207 -0.3437732 0.13247234
#>        emb_068     emb_069    emb_070     emb_071     emb_072     emb_073
#> 1 -0.007119675  0.21175741 0.04720229 -0.02785233 -0.21897317  0.04923863
#> 2 -0.355222493  0.11645776 0.34511699 -0.03482347 -0.09575927 -0.15305997
#> 3 -0.355222493  0.11645776 0.34511699 -0.03482347 -0.09575927 -0.15305997
#> 4  0.511924028  0.49667701 0.00565767 -0.34957999 -0.05733940  0.16006000
#> 5 -0.075410267 -0.06451077 0.20232637 -0.34498568  0.14050734  0.19303000
#>       emb_074    emb_075    emb_076     emb_077     emb_078    emb_079
#> 1  0.11586847 0.01710307 0.05674660  0.21199200 -0.23542767 -0.1931737
#> 2 -0.08885341 0.11387503 0.24408367  0.01405296 -0.00684475 -0.1356777
#> 3 -0.08885341 0.11387503 0.24408367  0.01405296 -0.00684475 -0.1356777
#> 4  0.00709061 0.29393500 0.19323500  0.09904870  0.10269100 -0.4426980
#> 5 -0.17765903 0.25700567 0.08324507 -0.12633934  0.13572240 -0.3315180
#>       emb_080    emb_081     emb_082    emb_083     emb_084    emb_085
#> 1  0.08169073 -0.2768843  0.03886401  0.2959003 -0.19298467 -0.1155530
#> 2 -0.13064601  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527
#> 3 -0.13064601  0.2395754 -0.24276201  0.1975068 -0.03769429 -0.2019527
#> 4 -0.30440599 -0.3246080 -0.62308598 -0.2460820 -0.24843900 -0.0256765
#> 5 -0.25235700 -0.2111377 -0.07061774  0.0504900 -0.33650232 -0.1734907
#>       emb_086    emb_087     emb_088    emb_089     emb_090    emb_091
#> 1 -0.13447814 -0.1770210  0.13215400 -0.0339748 -0.21856434  0.2328593
#> 2  0.09356334 -0.2311737  0.01929579 -0.1845699  0.16967812 -0.3636869
#> 3  0.09356334 -0.2311737  0.01929579 -0.1845699  0.16967812 -0.3636869
#> 4 -0.51446497  0.2091200 -0.39628500 -0.3847940  0.06013220  0.1881050
#> 5 -0.16659834 -0.2067902 -0.06687712 -0.1402178 -0.04919873  0.3112270
#>      emb_092     emb_093    emb_094     emb_095     emb_096    emb_097
#> 1  0.3751490 -0.05381016  0.1146673 -0.01959847  0.28200266 0.42902666
#> 2 -0.1134262  0.07241845  0.2989975  0.11188415 -0.04911397 0.05792167
#> 3 -0.1134262  0.07241845  0.2989975  0.11188415 -0.04911397 0.05792167
#> 4  0.0293956  0.15106900  0.1575840 -0.18849900  0.55679601 0.15977401
#> 5 -0.2068463  0.17419133 -0.2231243 -0.27066033  0.65465200 0.33063823
#>       emb_098    emb_099      emb_100     emb_101     emb_102     emb_103
#> 1  0.04848963 -0.1862663  0.124602138 -0.22326134 -0.08400663  0.02329567
#> 2 -0.12523016 -0.2768215 -0.032300234  0.09556636 -0.01811487  0.20206867
#> 3 -0.12523016 -0.2768215 -0.032300234  0.09556636 -0.01811487  0.20206867
#> 4 -0.21990800  0.0361496  0.095060900  0.31184199  0.47269401  0.18948001
#> 5 -0.17092466 -0.1384083 -0.007094666  0.00840500  0.21127966 -0.13682433
#>       emb_104      emb_105    emb_106     emb_107     emb_108      emb_109
#> 1  0.05004047  0.104559732  0.0215449 -0.15388466 -0.29770200 -0.153101668
#> 2 -0.28405397 -0.237980828  0.0503400  0.07255385 -0.33910483  0.299065769
#> 3 -0.28405397 -0.237980828  0.0503400  0.07255385 -0.33910483  0.299065769
#> 4  0.01987330 -0.000530505  0.2547450  0.38338101  0.05167580  0.645367026
#> 5 -0.24095667 -0.098090433 -0.1384013  0.17705100  0.01229907  0.006831832
#>       emb_110     emb_111     emb_112     emb_113     emb_114     emb_115
#> 1 -0.11906860  0.22010233  0.08900213 -0.35447600  0.09171167  0.23258676
#> 2 -0.28191616  0.04745353 -0.04532966 -0.15290414  0.04579017  0.02364063
#> 3 -0.28191616  0.04745353 -0.04532966 -0.15290414  0.04579017  0.02364063
#> 4  0.10932700 -0.20991200 -0.21882400 -0.50414801 -0.10509700 -0.50537401
#> 5  0.01417566 -0.12123747 -0.06496130 -0.06273583  0.23477167  0.24153317
#>       emb_116    emb_117     emb_118     emb_119    emb_120    emb_121
#> 1  0.14433467 -0.1116737 -0.03960567 -0.40252632  0.2241620 0.05333853
#> 2 -0.31116034  0.1607837 -0.07702465 -0.02175729 -0.1156647 0.01362599
#> 3 -0.31116034  0.1607837 -0.07702465 -0.02175729 -0.1156647 0.01362599
#> 4 -0.06551200  0.1273470  0.44890201 -0.50497001 -0.3773840 0.10423600
#> 5  0.01856467 -0.1163874  0.23565034 -0.08695473 -0.1451062 0.05088425
#>      emb_122    emb_123     emb_124     emb_125      emb_126     emb_127
#> 1  0.1210103 -0.3505453 -0.37599967 -0.17959367 -0.372907996  0.23109696
#> 2 -0.2008503  0.3362202 -0.03874875 -0.02545092  0.215858780 -0.04820869
#> 3 -0.2008503  0.3362202 -0.03874875 -0.02545092  0.215858780 -0.04820869
#> 4 -0.2221160 -0.0152136 -0.13729800 -0.11480500 -0.000516588  0.27843499
#> 5 -0.1430313 -0.4773587  0.11286416 -0.06714533  0.272736674  0.10123973
#>      emb_128    emb_129   emb_130     emb_131    emb_132    emb_133     emb_134
#> 1 -0.1633047 0.08894860 0.1383011 -0.03854874 -0.1769396  0.4415511 0.067589067
#> 2  0.1341518 0.08491383 0.2148582 -0.26201880 -0.0466188  0.1594945 0.245775409
#> 3  0.1341518 0.08491383 0.2148582 -0.26201880 -0.0466188  0.1594945 0.245775409
#> 4 -0.5077260 0.00681453 0.3277110 -0.45759901  0.0445853 -0.2659470 0.168917000
#> 5 -0.0713318 0.25015599 0.3079040  0.12011950 -0.1746590 -0.0272890 0.001398367
#>       emb_135     emb_136    emb_137     emb_138    emb_139     emb_140
#> 1 -0.14083400  0.18984333 -0.1702950 -0.03138060 -0.1715784  0.02322287
#> 2 -0.04687785  0.02120483 -0.2707188 -0.05038439 -0.2153107 -0.21424630
#> 3 -0.04687785  0.02120483 -0.2707188 -0.05038439 -0.2153107 -0.21424630
#> 4 -0.03073480  0.05147280 -0.5484980  0.29294801  0.0126988  0.23700000
#> 5 -0.07868153 -0.12667487 -0.1493903  0.13558467 -0.1372783  0.03249137
#>       emb_141     emb_142     emb_143     emb_144    emb_145     emb_146
#> 1 -0.01208614 -0.15196758 -0.04809747  0.06830250 0.06899200 -0.01744726
#> 2  0.12730155  0.04358483 -0.04084410  0.08556246 0.37193301 -0.23297635
#> 3  0.12730155  0.04358483 -0.04084410  0.08556246 0.37193301 -0.23297635
#> 4  0.24597199  0.00283213 -0.32100201 -0.10307100 0.05384210  0.14164799
#> 5  0.08722320  0.01351893 -0.31425733 -0.36113399 0.07923834 -0.13842267
#>        emb_147     emb_148    emb_149   emb_150     emb_151    emb_152
#> 1 -0.008307199  0.17215200  0.0815931 0.3604187 -0.09423253 -0.2169230
#> 2  0.167867787 -0.15522950  0.1336200 0.4047717 -0.07385027  0.2168649
#> 3  0.167867787 -0.15522950  0.1336200 0.4047717 -0.07385027  0.2168649
#> 4 -0.091728903  0.27499801  0.2364690 0.0516106  0.31944901  0.2596070
#> 5  0.324531337  0.07220166 -0.0125724 0.1995310 -0.07353233  0.3384760
#>       emb_153     emb_154     emb_155    emb_156    emb_157     emb_158
#> 1  0.12186506  0.05177177 0.248860496 -0.3412270  0.1060033 -0.17823740
#> 2  0.08279617  0.02853568 0.007983398 -0.2673024 -0.3518553  0.07097678
#> 3  0.08279617  0.02853568 0.007983398 -0.2673024 -0.3518553  0.07097678
#> 4 -0.20201600 -0.03634640 0.132135004 -0.4019700 -0.3961210  0.22471200
#> 5 -0.14484830 -0.02586020 0.044083000 -0.1661427 -0.1285090 -0.03287167
#>       emb_159    emb_160    emb_161     emb_162     emb_163    emb_164
#> 1  0.14807933 -0.2403240 -0.4898007  0.28092899 -0.06756200  0.1374817
#> 2  0.08358909 -0.1986835 -0.2990164 -0.01896982 -0.05220042  0.1262764
#> 3  0.08358909 -0.1986835 -0.2990164 -0.01896982 -0.05220042  0.1262764
#> 4 -0.28615400 -0.2248820  0.0843519  0.12150900  0.07793430 -0.3778230
#> 5 -0.40400134 -0.3108976 -0.2173441 -0.06455853 -0.08542720  0.1152579
#>       emb_165   emb_166     emb_167    emb_168    emb_169    emb_170
#> 1 -0.27157966 0.0436814  0.08531557  0.0082764  0.1924960 0.07621813
#> 2  0.10607937 0.0321700 -0.25643115 -0.1073976  0.2646226 0.03679075
#> 3  0.10607937 0.0321700 -0.25643115 -0.1073976  0.2646226 0.03679075
#> 4  0.12112600 0.3226820 -0.25913599 -0.0354177 -0.0709271 0.28492600
#> 5  0.02523783 0.4710543 -0.25156167 -0.1987897 -0.4560020 0.12512134
#>        emb_171     emb_172     emb_173     emb_174     emb_175    emb_176
#> 1  0.006314665 -0.30531877  0.21414446 -0.22668706 -0.22004866 -0.2229127
#> 2 -0.217393473  0.07656907 -0.10125257 -0.02410151 -0.02048860 -0.1179298
#> 3 -0.217393473  0.07656907 -0.10125257 -0.02410151 -0.02048860 -0.1179298
#> 4 -0.015468100  0.70878100  0.00505260  0.35008600 -0.00414608 -0.2252000
#> 5  0.392213672  0.23281800 -0.07670033  0.19469800 -0.29500176 -0.1311099
#>      emb_177     emb_178    emb_179     emb_180      emb_181     emb_182
#> 1 -0.2364223 -0.02967973  0.1305110 -0.04268587  0.005356933  0.14262900
#> 2  0.2362113  0.30876314 -0.2262567  0.07487945  0.008851715 -0.10242634
#> 3  0.2362113  0.30876314 -0.2262567  0.07487945  0.008851715 -0.10242634
#> 4 -0.0747713  0.47891200 -0.0237339  0.00665774 -0.295183003  0.00914423
#> 5 -0.0423944 -0.06213820 -0.1487082 -0.21474134 -0.307412336 -0.31873799
#>      emb_183     emb_184     emb_185     emb_186     emb_187     emb_188
#> 1 -0.1319477  0.10890868  0.33032867 -0.02934333 -0.05704663 -0.05574000
#> 2 -0.2249113 -0.06455390  0.07631866  0.01623236 -0.10981955 -0.04689731
#> 3 -0.2249113 -0.06455390  0.07631866  0.01623236 -0.10981955 -0.04689731
#> 4 -0.4879910 -0.01199450 -0.19777000  0.25575000  0.21581100  0.49597701
#> 5  0.0226334  0.09429601  0.25106033  0.24275832  0.12570866  0.02213203
#>       emb_189    emb_190     emb_191     emb_192     emb_193     emb_194
#> 1 -0.33545766  0.0707290  0.23029859 -0.07569099  0.09401843 -0.36443001
#> 2 -0.03368506  0.1627087 -0.05825762  0.06944699 -0.05563271 -0.17479033
#> 3 -0.03368506  0.1627087 -0.05825762  0.06944699 -0.05563271 -0.17479033
#> 4  0.05313870  0.2184980  0.12104800  0.04292490 -0.46514499 -0.06597370
#> 5 -0.11212200 -0.0104400  0.04684850 -0.05184417  0.05493267 -0.05297033
#>        emb_195     emb_196     emb_197     emb_198     emb_199     emb_200
#> 1  0.001776733  0.15681533  0.39945501  0.10316629  0.03305000 -0.56594801
#> 2 -0.136350583  0.12910799 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 3 -0.136350583  0.12910799 -0.09743453 -0.09941812 -0.05773153 -0.09702638
#> 4 -0.164887995 -0.23377600 -0.20433401 -0.31397000  0.16799000 -0.57338899
#> 5  0.141286733 -0.03435453  0.11175992 -0.05605234  0.08956560 -0.28494201

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(
    mtsamples[1:5, 1:2],
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description    emb_001
#> 1 A 23-year-old white female presents with complaint of allergies.         NA
#> 2                         Consult for laparoscopic gastric bypass.         NA
#> 3                         Consult for laparoscopic gastric bypass.         NA
#> 4                                             2-D M-Mode. Doppler. -0.4044230
#> 5                                               2-D Echocardiogram  0.0728814
#>    emb_002   emb_003    emb_004    emb_005    emb_006   emb_007  emb_008
#> 1       NA        NA         NA         NA         NA        NA       NA
#> 2       NA        NA         NA         NA         NA        NA       NA
#> 3       NA        NA         NA         NA         NA        NA       NA
#> 4 0.217982 -0.435959 -0.0518142 -0.0757723 -0.0336005 -0.180841 0.260800
#> 5 0.386336 -0.367894  0.2327090  0.1809000 -0.2080930 -0.119202 0.146091
#>      emb_009   emb_010   emb_011    emb_012  emb_013   emb_014    emb_015
#> 1         NA        NA        NA         NA       NA        NA         NA
#> 2         NA        NA        NA         NA       NA        NA         NA
#> 3         NA        NA        NA         NA       NA        NA         NA
#> 4  0.4181560 -0.204654 -0.257289 -0.4250230 0.731058 -0.124999 -0.0563767
#> 5 -0.0462431 -0.225562  0.152820  0.0166236 0.715063 -0.247448  0.0195478
#>     emb_016   emb_017   emb_018    emb_019   emb_020   emb_021   emb_022
#> 1        NA        NA        NA         NA        NA        NA        NA
#> 2        NA        NA        NA         NA        NA        NA        NA
#> 3        NA        NA        NA         NA        NA        NA        NA
#> 4 -0.299543 -0.294106 -0.247846 -0.0287432 0.0679117 0.0287295 -0.020798
#> 5  0.189766 -0.286625  0.296924  0.3830040 0.3593860 0.8373910 -0.139936
#>     emb_023  emb_024   emb_025   emb_026  emb_027   emb_028   emb_029
#> 1        NA       NA        NA        NA       NA        NA        NA
#> 2        NA       NA        NA        NA       NA        NA        NA
#> 3        NA       NA        NA        NA       NA        NA        NA
#> 4 -0.289208 0.281342 0.6255990 0.4281110 0.206463 0.2296980 -0.746509
#> 5 -0.237138 0.321402 0.0309453 0.0957853 0.481417 0.0824663 -0.268361
#>      emb_030   emb_031   emb_032    emb_033   emb_034    emb_035   emb_036
#> 1         NA        NA        NA         NA        NA         NA        NA
#> 2         NA        NA        NA         NA        NA         NA        NA
#> 3         NA        NA        NA         NA        NA         NA        NA
#> 4  0.3557920 -0.410843 -0.548994  0.0451901 -0.219888  0.0889601 -0.347043
#> 5 -0.0248911 -0.263199 -0.287029 -0.0422666 -0.595661 -0.2893590 -0.201696
#>     emb_037   emb_038   emb_039  emb_040    emb_041    emb_042    emb_043
#> 1        NA        NA        NA       NA         NA         NA         NA
#> 2        NA        NA        NA       NA         NA         NA         NA
#> 3        NA        NA        NA       NA         NA         NA         NA
#> 4 -0.219915 -0.161985 -0.535984 0.340435 -0.0483518  0.3674140 -0.0885881
#> 5 -0.390408 -0.080964 -0.200363 0.174689 -0.2546570 -0.0421118  0.2653090
#>    emb_044    emb_045   emb_046  emb_047   emb_048    emb_049   emb_050
#> 1       NA         NA        NA       NA        NA         NA        NA
#> 2       NA         NA        NA       NA        NA         NA        NA
#> 3       NA         NA        NA       NA        NA         NA        NA
#> 4 0.664886 -0.0656010 -0.593704 0.628767 0.0613332  0.0283500 -0.151470
#> 5 0.721083 -0.0671895 -0.189276 0.353924 0.2671540 -0.0531494 -0.171445
#>    emb_051   emb_052   emb_053    emb_054     emb_055    emb_056    emb_057
#> 1       NA        NA        NA         NA          NA         NA         NA
#> 2       NA        NA        NA         NA          NA         NA         NA
#> 3       NA        NA        NA         NA          NA         NA         NA
#> 4 0.224448  0.586741  0.038137 -0.1356160 -0.38449201 -0.0473909  0.0369035
#> 5 0.192945 -0.234576 -0.203217 -0.0678276  0.00849742 -0.2779250 -0.3299630
#>     emb_058   emb_059   emb_060    emb_061  emb_062    emb_063    emb_064
#> 1        NA        NA        NA         NA       NA         NA         NA
#> 2        NA        NA        NA         NA       NA         NA         NA
#> 3        NA        NA        NA         NA       NA         NA         NA
#> 4 -0.155995 -0.248292 0.5008110 -0.0982668 0.716812 -0.0341672 -0.0254562
#> 5 -0.167269 -0.241269 0.0912205  0.0588504 0.373394  0.1098770  0.6541390
#>     emb_065   emb_066  emb_067   emb_068    emb_069    emb_070   emb_071
#> 1        NA        NA       NA        NA         NA         NA        NA
#> 2        NA        NA       NA        NA         NA         NA        NA
#> 3        NA        NA       NA        NA         NA         NA        NA
#> 4  0.015033 -0.535300 0.218229  0.511924  0.4966770 0.00565767 -0.349580
#> 5 -0.116866 -0.525699 0.269517 -0.127507 -0.0621924 0.26849800 -0.629131
#>      emb_072  emb_073     emb_074  emb_075   emb_076    emb_077    emb_078
#> 1         NA       NA          NA       NA        NA         NA         NA
#> 2         NA       NA          NA       NA        NA         NA         NA
#> 3         NA       NA          NA       NA        NA         NA         NA
#> 4 -0.0573394 0.160060  0.00709061 0.293935 0.1932350  0.0990487  0.1026910
#> 5  0.2724950 0.128351 -0.28447300 0.145049 0.0799689 -0.3154850 -0.0201829
#>     emb_079   emb_080   emb_081    emb_082   emb_083   emb_084    emb_085
#> 1        NA        NA        NA         NA        NA        NA         NA
#> 2        NA        NA        NA         NA        NA        NA         NA
#> 3        NA        NA        NA         NA        NA        NA         NA
#> 4 -0.442698 -0.304406 -0.324608 -0.6230860 -0.246082 -0.248439 -0.0256765
#> 5 -0.309565 -0.300612 -0.280300 -0.0642459  0.209471 -0.281274 -0.1204440
#>     emb_086   emb_087     emb_088   emb_089   emb_090  emb_091    emb_092
#> 1        NA        NA          NA        NA        NA       NA         NA
#> 2        NA        NA          NA        NA        NA       NA         NA
#> 3        NA        NA          NA        NA        NA       NA         NA
#> 4 -0.514465  0.209120 -0.39628500 -0.384794 0.0601322 0.188105  0.0293956
#> 5 -0.148456 -0.301721 -0.00252768 -0.257013 0.0213039 0.366835 -0.0517960
#>    emb_093   emb_094   emb_095  emb_096  emb_097   emb_098    emb_099
#> 1       NA        NA        NA       NA       NA        NA         NA
#> 2       NA        NA        NA       NA       NA        NA         NA
#> 3       NA        NA        NA       NA       NA        NA         NA
#> 4 0.151069  0.157584 -0.188499 0.556796 0.159774 -0.219908  0.0361496
#> 5 0.173594 -0.078753 -0.266523 0.764952 0.468840 -0.104193 -0.2779620
#>      emb_100   emb_101  emb_102   emb_103    emb_104      emb_105   emb_106
#> 1         NA        NA       NA        NA         NA           NA        NA
#> 2         NA        NA       NA        NA         NA           NA        NA
#> 3         NA        NA       NA        NA         NA           NA        NA
#> 4  0.0950609  0.311842 0.472694  0.189480  0.0198733 -0.000530505  0.254745
#> 5 -0.0950925 -0.131745 0.422846 -0.109448 -0.2540510 -0.118400998 -0.179680
#>    emb_107    emb_108    emb_109  emb_110    emb_111    emb_112   emb_113
#> 1       NA         NA         NA       NA         NA         NA        NA
#> 2       NA         NA         NA       NA         NA         NA        NA
#> 3       NA         NA         NA       NA         NA         NA        NA
#> 4 0.383381  0.0516758  0.6453670 0.109327 -0.2099120 -0.2188240 -0.504148
#> 5 0.173404 -0.0339494 -0.0231128 0.172972 -0.0839217 -0.0753251 -0.124599
#>     emb_114   emb_115   emb_116   emb_117  emb_118   emb_119   emb_120
#> 1        NA        NA        NA        NA       NA        NA        NA
#> 2        NA        NA        NA        NA       NA        NA        NA
#> 3        NA        NA        NA        NA       NA        NA        NA
#> 4 -0.105097 -0.505374 -0.065512  0.127347 0.448902 -0.504970 -0.377384
#> 5  0.234748  0.337287  0.109938 -0.156988 0.471592 -0.123604 -0.192659
#>      emb_121   emb_122    emb_123   emb_124   emb_125      emb_126  emb_127
#> 1         NA        NA         NA        NA        NA           NA       NA
#> 2         NA        NA         NA        NA        NA           NA       NA
#> 3         NA        NA         NA        NA        NA           NA       NA
#> 4 0.10423600 -0.222116 -0.0152136 -0.137298 -0.114805 -0.000516588 0.278435
#> 5 0.00252487 -0.247993 -0.4102440  0.122113 -0.204029  0.346675009 0.189614
#>      emb_128    emb_129  emb_130   emb_131    emb_132   emb_133   emb_134
#> 1         NA         NA       NA        NA         NA        NA        NA
#> 2         NA         NA       NA        NA         NA        NA        NA
#> 3         NA         NA       NA        NA         NA        NA        NA
#> 4 -0.5077260 0.00681453 0.327711 -0.457599  0.0445853 -0.265947 0.1689170
#> 5  0.0568923 0.31424299 0.310222  0.132703 -0.2623250  0.118012 0.0115325
#>      emb_135    emb_136   emb_137  emb_138    emb_139   emb_140    emb_141
#> 1         NA         NA        NA       NA         NA        NA         NA
#> 2         NA         NA        NA       NA         NA        NA         NA
#> 3         NA         NA        NA       NA         NA        NA         NA
#> 4 -0.0307348  0.0514728 -0.548498 0.292948  0.0126988 0.2370000  0.2459720
#> 5  0.0185067 -0.0738268 -0.100293 0.150312 -0.2942450 0.0607005 -0.0261802
#>       emb_142   emb_143   emb_144   emb_145   emb_146    emb_147  emb_148
#> 1          NA        NA        NA        NA        NA         NA       NA
#> 2          NA        NA        NA        NA        NA         NA       NA
#> 3          NA        NA        NA        NA        NA         NA       NA
#> 4  0.00283213 -0.321002 -0.103071 0.0538421  0.141648 -0.0917289 0.274998
#> 5 -0.04084360 -0.544514 -0.357720 0.1843360 -0.101931  0.2855570 0.207822
#>     emb_149   emb_150   emb_151  emb_152   emb_153    emb_154  emb_155
#> 1        NA        NA        NA       NA        NA         NA       NA
#> 2        NA        NA        NA       NA        NA         NA       NA
#> 3        NA        NA        NA       NA        NA         NA       NA
#> 4 0.2364690 0.0516106  0.319449 0.259607 -0.202016 -0.0363464 0.132135
#> 5 0.0700609 0.4491040 -0.230327 0.391459 -0.226075  0.0145787 0.093469
#>      emb_156   emb_157   emb_158   emb_159   emb_160    emb_161   emb_162
#> 1         NA        NA        NA        NA        NA         NA        NA
#> 2         NA        NA        NA        NA        NA         NA        NA
#> 3         NA        NA        NA        NA        NA         NA        NA
#> 4 -0.4019700 -0.396121  0.224712 -0.286154 -0.224882  0.0843519 0.1215090
#> 5 -0.0553286 -0.139284 -0.102521 -0.502402 -0.427695 -0.3128150 0.0010572
#>      emb_163   emb_164  emb_165  emb_166   emb_167    emb_168    emb_169
#> 1         NA        NA       NA       NA        NA         NA         NA
#> 2         NA        NA       NA       NA        NA         NA         NA
#> 3         NA        NA       NA       NA        NA         NA         NA
#> 4  0.0779343 -0.377823 0.121126 0.322682 -0.259136 -0.0354177 -0.0709271
#> 5 -0.0219433  0.171575 0.037601 0.431269 -0.216642 -0.1690000 -0.5015340
#>    emb_170    emb_171  emb_172    emb_173  emb_174     emb_175    emb_176
#> 1       NA         NA       NA         NA       NA          NA         NA
#> 2       NA         NA       NA         NA       NA          NA         NA
#> 3       NA         NA       NA         NA       NA          NA         NA
#> 4 0.284926 -0.0154681 0.708781  0.0050526 0.350086 -0.00414608 -0.2252000
#> 5 0.137158  0.4218060 0.229282 -0.0464125 0.242541 -0.46298099 -0.0716083
#>      emb_177   emb_178    emb_179     emb_180   emb_181     emb_182    emb_183
#> 1         NA        NA         NA          NA        NA          NA         NA
#> 2         NA        NA         NA          NA        NA          NA         NA
#> 3         NA        NA         NA          NA        NA          NA         NA
#> 4 -0.0747713  0.478912 -0.0237339  0.00665774 -0.295183  0.00914423 -0.4879910
#> 5  0.0641969 -0.106142 -0.1741740 -0.14702500 -0.395280 -0.29302099 -0.0163879
#>      emb_184   emb_185  emb_186  emb_187    emb_188    emb_189   emb_190
#> 1         NA        NA       NA       NA         NA         NA        NA
#> 2         NA        NA       NA       NA         NA         NA        NA
#> 3         NA        NA       NA       NA         NA         NA        NA
#> 4 -0.0119945 -0.197770 0.255750 0.215811  0.4959770  0.0531387  0.218498
#> 5  0.2653970  0.438362 0.437553 0.109242 -0.0129896 -0.1669020 -0.111934
#>     emb_191    emb_192   emb_193    emb_194   emb_195    emb_196   emb_197
#> 1        NA         NA        NA         NA        NA         NA        NA
#> 2        NA         NA        NA         NA        NA         NA        NA
#> 3        NA         NA        NA         NA        NA         NA        NA
#> 4 0.1210480  0.0429249 -0.465145 -0.0659737 -0.164888 -0.2337760 -0.204334
#> 5 0.0220152 -0.0605459  0.180873 -0.1473920  0.178240  0.0462007  0.170731
#>     emb_198   emb_199   emb_200
#> 1        NA        NA        NA
#> 2        NA        NA        NA
#> 3        NA        NA        NA
#> 4 -0.313970 0.1679900 -0.573389
#> 5 -0.194111 0.0531594 -0.354566
```

### Cui2vec embeddings (with the UMLS linker)

These are only available with the UMLS linker enabled.

``` r
clinspacy_output_file %>% 
  bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                            type = 'cui2vec')
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description     emb_001
#> 1 A 23-year-old white female presents with complaint of allergies. -0.03781852
#> 2                         Consult for laparoscopic gastric bypass. -0.06431815
#> 3                         Consult for laparoscopic gastric bypass. -0.06431815
#> 4                                             2-D M-Mode. Doppler. -0.06111055
#> 5                                               2-D Echocardiogram -0.08545282
#>      emb_002       emb_003      emb_004     emb_005     emb_006    emb_007
#> 1 0.01307321 -8.467619e-17 -0.031245908  0.01318394  0.03031191 0.02431865
#> 2 0.02979208 -1.353084e-16 -0.046832239  0.03387485  0.04323455 0.03737835
#> 3 0.02979208 -1.353084e-16 -0.046832239  0.03387485  0.04323455 0.03737835
#> 4 0.03059523 -1.340074e-16 -0.032813400 -0.02400309 -0.02559680 0.04846848
#> 5 0.03965676 -4.336809e-17 -0.008077436 -0.04463792 -0.05437294 0.06603530
#>         emb_008    emb_009      emb_010     emb_011     emb_012     emb_013
#> 1  0.0001103725 0.04350098 3.243933e-16 -0.07792482 -0.02392776 -0.07418388
#> 2 -0.0094831734 0.05477590 3.851086e-16 -0.10237675 -0.04983230 -0.10830155
#> 3 -0.0094831734 0.05477590 3.851086e-16 -0.10237675 -0.04983230 -0.10830155
#> 4 -0.0109314023 0.04029187 6.602249e-16 -0.08182351  0.02424283  0.01817957
#> 5 -0.0143850939 0.05986346 7.320533e-16 -0.08818264  0.08076658  0.06328653
#>         emb_014   emb_015   emb_016    emb_017       emb_018    emb_019
#> 1 -1.635606e-02 0.5795962 0.2781278 -0.7857161  1.058181e-16 0.15141543
#> 2 -1.407439e-05 0.5639421 0.2619365 -0.7316425  7.285839e-17 0.13524048
#> 3 -1.407439e-05 0.5639421 0.2619365 -0.7316425  7.285839e-17 0.13524048
#> 4  8.926259e-03 0.7286934 0.3618093 -1.0864111 -3.521489e-16 0.11064232
#> 5  4.729663e-02 0.7833567 0.3750314 -1.0443925 -7.381248e-16 0.07850813
#>      emb_020      emb_021      emb_022      emb_023     emb_024      emb_025
#> 1 0.04846067 -0.063234467 -0.014200820  0.001504209 -0.06733951  0.004864776
#> 2 0.02624005 -0.058723003 -0.009268231 -0.044739626 -0.07787475 -0.001147076
#> 3 0.02624005 -0.058723003 -0.009268231 -0.044739626 -0.07787475 -0.001147076
#> 4 0.07165768 -0.004772346 -0.027238981  0.034012415 -0.04099675 -0.105589370
#> 5 0.08235334  0.080923256  0.060323314  0.071848382  0.02404830 -0.073231346
#>       emb_026    emb_027      emb_028     emb_029     emb_030      emb_031
#> 1 -0.07110942 0.03399503 -0.006213914 -0.02295869  0.00935263 -0.005880135
#> 2 -0.06995130 0.04416575 -0.006971676 -0.01371582  0.01091472  0.001185995
#> 3 -0.06995130 0.04416575 -0.006971676 -0.01371582  0.01091472  0.001185995
#> 4 -0.17663323 0.04464371  0.005871212 -0.11535483 -0.03303530 -0.064727022
#> 5 -0.21618455 0.01648035  0.095369073 -0.13972570 -0.05403436 -0.087954255
#>         emb_032      emb_033       emb_034      emb_035       emb_036
#> 1  0.0004999359  0.006844007  1.898872e-15 -0.006001428 -2.131541e-15
#> 2 -0.0047622243  0.013324325  4.028028e-15  0.010080997 -3.435620e-15
#> 3 -0.0047622243  0.013324325  4.028028e-15  0.010080997 -3.435620e-15
#> 4  0.0108362558 -0.005695953 -4.412269e-15  0.133061966  3.086073e-15
#> 5  0.0622103816 -0.033214583 -1.147867e-14  0.209989795  5.528997e-15
#>       emb_037      emb_038      emb_039     emb_040     emb_041       emb_042
#> 1  0.02288913 -0.014578236 -0.009136149 -0.01439758 0.007009739 -0.0190325718
#> 2  0.03690702  0.003208619  0.010866416 -0.01969659 0.026163014  0.0003829418
#> 3  0.03690702  0.003208619  0.010866416 -0.01969659 0.026163014  0.0003829418
#> 4 -0.05242102  0.090870547  0.163841061  0.05942175 0.088712386  0.0668394674
#> 5 -0.08816897  0.082967948  0.183355322  0.07969723 0.094891974  0.1958307990
#>        emb_043      emb_044      emb_045     emb_046    emb_047      emb_048
#> 1  0.007831483  0.009378524 -0.003204715 -0.03820517 0.04289567 -0.023655332
#> 2  0.023817109  0.022357573  0.017419754 -0.12665759 0.02654248 -0.027084390
#> 3  0.023817109  0.022357573  0.017419754 -0.12665759 0.02654248 -0.027084390
#> 4 -0.031126773 -0.014388925  0.197237716 -0.82961240 0.35398491  0.005368506
#> 5  0.103868528 -0.075833177  0.267943042 -0.72747213 0.21737878  0.053046317
#>         emb_049     emb_050     emb_051     emb_052       emb_053     emb_054
#> 1 -5.944681e-15  0.02874709 -0.01588802 -0.02114440 -2.811857e-14 -0.02247419
#> 2 -7.030645e-15  0.06236709 -0.06521589 -0.01573079 -5.933882e-14 -0.04755129
#> 3 -7.030645e-15  0.06236709 -0.06521589 -0.01573079 -5.933882e-14 -0.04755129
#> 4 -4.128642e-16  0.06946373 -0.10157185  0.02818575  1.072675e-13  0.08571772
#> 5  1.321686e-14 -0.02125846 -0.07034135  0.03635827  1.692813e-13  0.13589856
#>       emb_055      emb_056     emb_057       emb_058     emb_059      emb_060
#> 1  0.01404841 0.0232059805 -0.05669309  4.630966e-16  0.06393656 -0.003755529
#> 2  0.02537560 0.0670367512 -0.11883459  4.948299e-16  0.08957024 -0.025650839
#> 3  0.02537560 0.0670367512 -0.11883459  4.948299e-16  0.08957024 -0.025650839
#> 4 -0.18812715 0.0003059182  0.12349607 -2.417337e-15 -0.14699747  0.014496338
#> 5 -0.28225729 0.0450989688  0.09481364 -3.910067e-15 -0.17294677  0.059322428
#>       emb_061     emb_062     emb_063     emb_064     emb_065       emb_066
#> 1 -0.02635560  0.06963348 -0.05871841 -0.08283147  0.03233505 -1.441555e-15
#> 2 -0.08122271  0.12413953 -0.02557740 -0.21614404  0.01861198 -7.620640e-15
#> 3 -0.08122271  0.12413953 -0.02557740 -0.21614404  0.01861198 -7.620640e-15
#> 4  0.20977940 -0.15799739  0.19973795  0.02314434 -0.23523706 -4.510281e-16
#> 5  0.16946882 -0.08216626  0.18937106 -0.14545062 -0.30105507  5.898060e-16
#>       emb_067     emb_068     emb_069     emb_070     emb_071     emb_072
#> 1 -0.03641877  0.01702242  0.06373662 -0.01303886 -0.34940346  0.11035179
#> 2 -0.10491625 -0.21607946  0.11233728 -0.34401693 -1.11975599  0.31387242
#> 3 -0.10491625 -0.21607946  0.11233728 -0.34401693 -1.11975599  0.31387242
#> 4  0.07770390 -0.35410180 -0.14586650 -0.71942375  0.34022655 -0.07945074
#> 5  0.15280180 -0.54948412 -0.06534203 -1.02372652 -0.06825129 -0.02395073
#>       emb_073       emb_074     emb_075     emb_076    emb_077       emb_078
#> 1 -0.06503496  2.838008e-15 -0.09284457  0.02124879  0.1085678  2.211339e-15
#> 2  0.12252998 -2.560799e-14 -0.19160113 -0.04867764  0.5523220  5.398459e-15
#> 3  0.12252998 -2.560799e-14 -0.19160113 -0.04867764  0.5523220  5.398459e-15
#> 4  0.72334832 -7.658457e-14  0.25905869 -0.35165164 -0.1670191 -1.570272e-14
#> 5  0.67068700 -7.306655e-14  0.15812147 -0.59691628 -0.3880477 -2.409878e-14
#>      emb_079     emb_080    emb_081     emb_082    emb_083     emb_084
#> 1 -0.2515280 -0.09290887  0.1944582 -0.05660088 0.01629156  0.02405552
#> 2 -0.8451104 -0.23552498  0.9745863 -0.33928142 0.07840940  0.01195948
#> 3 -0.8451104 -0.23552498  0.9745863 -0.33928142 0.07840940  0.01195948
#> 4  0.4723263  0.29268296 -0.4390311  0.13544565 0.02052987 -0.04702967
#> 5  0.3388141  0.39420910 -0.5539414  0.11042804 0.05884497 -0.15852562
#>       emb_085       emb_086     emb_087       emb_088     emb_089     emb_090
#> 1  0.06484271  3.469447e-16 -0.02181927  9.089951e-16  0.02177562 -0.06472809
#> 2  0.42441549  5.551115e-17 -0.23277894  6.050715e-15 -0.02551769 -0.23846076
#> 3  0.42441549  5.551115e-17 -0.23277894  6.050715e-15 -0.02551769 -0.23846076
#> 4 -0.08651022 -4.884981e-15 -0.07435743 -5.634382e-15 -0.23977559  0.05733172
#> 5 -0.16558745 -9.658940e-15 -0.17738093 -8.340550e-15 -0.28447641 -0.17663589
#>       emb_091     emb_092     emb_093     emb_094       emb_095     emb_096
#> 1 0.001181195 -0.04638670 -0.02218124 -0.03128873  2.745238e-14  0.02773409
#> 2 0.138114628  0.08764413  0.80378838 -0.46015315 -3.019286e-14 -0.03355261
#> 3 0.138114628  0.08764413  0.80378838 -0.46015315 -3.019286e-14 -0.03355261
#> 4 0.014850146  0.26515747  0.42364347 -0.02683883 -1.508776e-13 -0.15995590
#> 5 0.003708819  0.24130178  0.44406986 -0.02370578 -2.187573e-13 -0.23251378
#>       emb_097       emb_098      emb_099     emb_100     emb_101     emb_102
#> 1  0.14947455  4.288887e-15  0.007570393 -0.04882197 0.008137181 -0.04422842
#> 2 -0.08767266 -5.091413e-15 -0.166197295  0.10732502 0.055149845 -0.06242211
#> 3 -0.08767266 -5.091413e-15 -0.166197295  0.10732502 0.055149845 -0.06242211
#> 4 -0.44881396 -1.758316e-14 -0.085092413  0.19375553 0.104342648  0.05008170
#> 5 -0.47233423 -2.239181e-14 -0.095497018  0.20884384 0.212106760  0.03865176
#>       emb_103       emb_104      emb_105     emb_106       emb_107     emb_108
#> 1 -0.06598283 -7.952108e-15  0.005247747 0.016678123 -1.427352e-15 -0.02310420
#> 2 -0.09599754  1.334176e-14  0.144182208 0.036139203 -6.897261e-15 -0.10232649
#> 3 -0.09599754  1.334176e-14  0.144182208 0.036139203 -6.897261e-15 -0.10232649
#> 4  0.16742771  5.061489e-15 -0.123311701 0.004329035  1.835164e-14  0.01208217
#> 5  0.26550386  6.421946e-15 -0.235197986 0.078403812  5.946112e-14  0.12235013
#>       emb_109       emb_110      emb_111     emb_112     emb_113     emb_114
#> 1 -0.07101445 -3.275418e-14 -0.020521786  0.05204774 -0.03149831  0.01824475
#> 2 -0.01593159  1.865869e-14  0.006780394  0.15184022 -0.07247200 -0.28684400
#> 3 -0.01593159  1.865869e-14  0.006780394  0.15184022 -0.07247200 -0.28684400
#> 4  0.06013918  5.255778e-14  0.064285345 -0.39346255  0.22814502  0.21557504
#> 5  0.08616510  9.392053e-14  0.103747328 -0.70788670  0.31461195  0.40257955
#>       emb_115     emb_116     emb_117     emb_118      emb_119     emb_120
#> 1  0.03663663  0.03726996  0.05580929  0.07961600 -0.009899394 -0.04699317
#> 2 -0.21497745  0.14715543 -0.01739415  0.02241806 -0.184658018  0.16215069
#> 3 -0.21497745  0.14715543 -0.01739415  0.02241806 -0.184658018  0.16215069
#> 4 -0.13034265 -0.18484702  0.01702929 -0.21871035  0.167345957  0.24920657
#> 5  0.02442212 -0.30551484  0.02886832 -0.28471657  0.278661711  0.38014528
#>      emb_121    emb_122     emb_123       emb_124     emb_125     emb_126
#> 1  0.2519331  0.2206324  0.06455009 -1.003538e-12  0.18075492 -0.06479312
#> 2  0.2636777  0.2608694  0.26691904  2.445819e-13 -0.04708107  0.11500474
#> 3  0.2636777  0.2608694  0.26691904  2.445819e-13 -0.04708107  0.11500474
#> 4 -1.1131071 -0.5648160 -0.38256051  3.438994e-12 -0.59772217  0.19531082
#> 5 -1.3533353 -0.6622776 -0.72869530  3.063832e-12 -0.50992830  0.09782189
#>      emb_127    emb_128       emb_129      emb_130     emb_131       emb_132
#> 1 -0.1548274  0.1010927  5.272085e-14  0.009017079  0.02185068 -4.631755e-14
#> 2 -0.1135360  0.1718157  4.223011e-14 -0.144642005 -0.03329647 -2.228426e-14
#> 3 -0.1135360  0.1718157  4.223011e-14 -0.144642005 -0.03329647 -2.228426e-14
#> 4  0.5088026 -0.4964799 -1.798041e-13  0.109656368 -0.48087387  6.550663e-14
#> 5  0.6542731 -0.5160938 -1.680669e-13  0.211973016 -0.58530437  4.063763e-14
#>       emb_133     emb_134      emb_135     emb_136      emb_137     emb_138
#> 1  0.07297088 -0.09302011  0.003222476 -0.02004648  0.007307386 -0.02505680
#> 2  0.05258090  0.06319484 -0.029659151 -0.01547830  0.116481430  0.02657212
#> 3  0.05258090  0.06319484 -0.029659151 -0.01547830  0.116481430  0.02657212
#> 4 -0.30904490  0.69464423 -0.039638203  0.18345654 -0.081877613  0.29432672
#> 5 -0.28935675  0.67681910 -0.166787705  0.15089200 -0.098513422  0.42405252
#>         emb_139     emb_140    emb_141     emb_142     emb_143     emb_144
#> 1 -2.253059e-14  0.02876285 0.10022845  0.02227501 -0.02635462 -0.06376400
#> 2  7.391310e-14  0.03950770 0.01946894 -0.04451527  0.04041157 -0.02481254
#> 3  7.391310e-14  0.03950770 0.01946894 -0.04451527  0.04041157 -0.02481254
#> 4 -5.811671e-14 -0.10208119 0.03675050 -0.03258399  0.13460180 -0.05587448
#> 5 -1.283609e-13 -0.06222996 0.14881324 -0.20332200  0.11942885 -0.05558873
#>       emb_145     emb_146    emb_147       emb_148     emb_149      emb_150
#> 1 -0.07715663 -0.05728168 -0.1044355 -1.618621e-13 -0.06025092  0.077327739
#> 2  0.08950269  0.01175055 -0.0662768 -2.075735e-13  0.02206553 -0.008658736
#> 3  0.08950269  0.01175055 -0.0662768 -2.075735e-13  0.02206553 -0.008658736
#> 4  0.10025069  0.13251755  0.1651028  2.125175e-13 -0.02277593 -0.034907791
#> 5  0.02174056  0.14338486  0.3250313  5.608951e-13 -0.16384927 -0.088665453
#>         emb_151     emb_152     emb_153     emb_154       emb_155     emb_156
#> 1 -6.542347e-14  0.02152605  0.10605584 -0.10153155  5.699590e-13 -0.08239457
#> 2 -2.652392e-15 -0.06361843  0.02033925 -0.01044769 -2.183895e-13  0.03480149
#> 3 -2.652392e-15 -0.06361843  0.02033925 -0.01044769 -2.183895e-13  0.03480149
#> 4  7.952319e-14 -0.50684792 -0.10650996  0.11477080  5.121190e-13 -0.08457432
#> 5  9.641290e-14 -0.87854237 -0.04230861 -0.05589497  1.221761e-12 -0.17876150
#>         emb_157       emb_158     emb_159     emb_160     emb_161     emb_162
#> 1 -0.0486808645 -0.0782324706 -0.04156510  0.03196455 -0.01268101 -0.02458498
#> 2  0.0038722078  0.1312810905  0.05609832 -0.14129266 -0.07418614 -0.05302076
#> 3  0.0038722078  0.1312810905  0.05609832 -0.14129266 -0.07418614 -0.05302076
#> 4  0.0179079851  0.1088385902  0.28243251 -0.14059878 -0.11989107 -0.16073072
#> 5 -0.0007130762 -0.0004208772  0.46249983  0.07650607 -0.32936041 -0.20787514
#>        emb_163     emb_164      emb_165     emb_166       emb_167     emb_168
#> 1 3.823981e-16 -0.01244411  0.162988803 -0.11204079 -5.402618e-13  0.13786489
#> 2 1.890857e-13 -0.13439796 -0.297818003  0.02870743  6.995221e-13 -0.18868838
#> 3 1.890857e-13 -0.13439796 -0.297818003  0.02870743  6.995221e-13 -0.18868838
#> 4 1.484524e-13 -0.15457128 -0.171804822  0.03053137  2.444815e-13 -0.02664467
#> 5 3.454429e-13 -0.37478028  0.002465816 -0.18412485 -3.199038e-13  0.08781372
#>       emb_169     emb_170     emb_171      emb_172    emb_173     emb_174
#> 1  0.10734690 -0.11873981 -0.01592048 6.921547e-16 0.11666197  0.06197424
#> 2 -0.19137518  0.07350984  0.17477225 8.503810e-14 0.01203242 -0.24135828
#> 3 -0.19137518  0.07350984  0.17477225 8.503810e-14 0.01203242 -0.24135828
#> 4 -0.10924014  0.20515071 -0.02773444 2.283668e-13 0.15508508 -0.08313571
#> 5  0.01867714  0.06961732  0.13705351 2.518038e-13 0.21216136 -0.14021672
#>       emb_175       emb_176     emb_177     emb_178     emb_179    emb_180
#> 1 -0.04106015  2.789401e-13  0.09776847  0.02808001 0.001654821  0.1152530
#> 2  0.36612951 -1.781389e-12 -0.43295767 -0.16220656 0.081211252 -0.4522241
#> 3  0.36612951 -1.781389e-12 -0.43295767 -0.16220656 0.081211252 -0.4522241
#> 4  0.10200997 -2.563952e-13  0.10427605  0.10297132 0.091447575 -0.1477150
#> 5  0.47762415 -1.806196e-12 -0.25855755  0.08122381 0.200775071 -0.1253954
#>        emb_181     emb_182    emb_183       emb_184    emb_185     emb_186
#> 1 -0.008950287 0.007458146 -0.0482787 -1.014295e-12  0.2108666 -0.03448274
#> 2 -0.044385411 0.090658199  0.2255538 -4.625640e-14 -0.1161811 -0.08492217
#> 3 -0.044385411 0.090658199  0.2255538 -4.625640e-14 -0.1161811 -0.08492217
#> 4  0.137593440 0.170677913  0.1646901 -1.437587e-12  0.1580584 -0.24940895
#> 5  0.203510017 0.077205828  0.2429455 -1.979646e-12  0.1658734 -0.43649029
#>      emb_187     emb_188       emb_189    emb_190     emb_191     emb_192
#> 1 -0.1019806 -0.08533795 -1.095591e-13 0.03257969  0.10057873 -0.03361096
#> 2 -0.1399807  0.23276806  5.244321e-13 0.23982175 -0.01018941 -0.20431635
#> 3 -0.1399807  0.23276806  5.244321e-13 0.23982175 -0.01018941 -0.20431635
#> 4 -0.2133598 -0.03684678  1.727160e-13 0.14437881  0.33774852 -0.06218973
#> 5 -0.3303334  0.26474861  8.581222e-13 0.15881768  0.54887102 -0.40832544
#>       emb_193       emb_194      emb_195     emb_196    emb_197     emb_198
#> 1 -0.06593127  6.337812e-14 -0.004600378 -0.01190098 0.14502876 -0.02699752
#> 2 -0.21981727 -9.255478e-13  0.063048615 -0.01716309 0.03809741  0.18312652
#> 3 -0.21981727 -9.255478e-13  0.063048615 -0.01716309 0.03809741  0.18312652
#> 4 -0.35141086  5.410497e-12 -0.292362335  0.40076410 0.03703129 -0.19063927
#> 5 -0.58976646  1.194013e-11 -0.675315249  0.61303345 0.21432033 -0.55726102
#>       emb_199       emb_200     emb_201      emb_202     emb_203     emb_204
#> 1 -0.04894075  3.454355e-14 -0.01969393  0.012680201 -0.07223796 -0.02689012
#> 2 -0.02288177 -1.565725e-13 -0.05573739 -0.003061037 -0.01878783 -0.07355733
#> 3 -0.02288177 -1.565725e-13 -0.05573739 -0.003061037 -0.01878783 -0.07355733
#> 4 -0.03360996  4.150066e-13 -0.11253081  0.200606780 -0.15354758  0.15039220
#> 5 -0.06757736  9.420117e-13 -0.08300392  0.462727978 -0.30683723  0.25539420
#>        emb_205     emb_206       emb_207     emb_208      emb_209     emb_210
#> 1 -0.008998234  0.06339026 -2.721920e-13  0.01017948  0.006078192  0.18413046
#> 2  0.105143808 -0.07655918  2.888193e-13  0.01714326 -0.112990989 -0.13611984
#> 3  0.105143808 -0.07655918  2.888193e-13  0.01714326 -0.112990989 -0.13611984
#> 4  0.170571111  0.26667400 -4.352768e-13 -0.12690335  0.172870508  0.08764913
#> 5 -0.007316906  0.63219393 -1.421054e-12 -0.24711309  0.298172444  0.10947941
#>       emb_211     emb_212     emb_213       emb_214     emb_215       emb_216
#> 1  0.04989772 -0.07835200  0.07491462 -6.223667e-14 -0.01046129 -3.343012e-13
#> 2 -0.02852789 -0.01476567  0.05864686  1.693038e-13 -0.11455488  4.520722e-14
#> 3 -0.02852789 -0.01476567  0.05864686  1.693038e-13 -0.11455488  4.520722e-14
#> 4  0.29832320  0.03660953 -0.09505927  3.004960e-13 -0.13819224  6.906309e-13
#> 5  0.29751983  0.25747832  0.06725040  7.156038e-13 -0.34935054  4.203879e-13
#>       emb_217      emb_218       emb_219     emb_220      emb_221     emb_222
#> 1 -0.06186115 -0.101488624 -7.100241e-13  0.18954843 -0.085424290 -0.10511798
#> 2  0.01801138 -0.102428210  2.519721e-13 -0.04396181  0.086189032  0.03509181
#> 3  0.01801138 -0.102428210  2.519721e-13 -0.04396181  0.086189032  0.03509181
#> 4  0.12985165  0.001393696  2.132422e-13 -0.08854380 -0.002717749  0.01317363
#> 5  0.12827808  0.153216867 -7.914298e-13  0.07924780  0.150907585  0.24783030
#>       emb_223     emb_224     emb_225       emb_226     emb_227      emb_228
#> 1 -0.12957392  0.16187920 -0.05942145 -2.654361e-13 -0.02000706 -0.004045330
#> 2 -0.03199517 -0.02290138 -0.06060765 -3.396982e-13  0.01915374 -0.009686212
#> 3 -0.03199517 -0.02290138 -0.06060765 -3.396982e-13  0.01915374 -0.009686212
#> 4  0.27963672 -0.06427652  0.39456485  1.677393e-12 -0.13699759 -0.257851349
#> 5  0.29241438 -0.04715676  0.34991085  1.895064e-12 -0.03218816  0.112355261
#>       emb_229     emb_230       emb_231     emb_232     emb_233       emb_234
#> 1  0.06079098  0.10973196 -2.502842e-13  0.15295100  0.02181502  5.757504e-14
#> 2  0.05007254  0.01447912  2.040729e-14 -0.05082994  0.02059045  5.164714e-13
#> 3  0.05007254  0.01447912  2.040729e-14 -0.05082994  0.02059045  5.164714e-13
#> 4 -0.44931526 -0.11125827  2.757275e-13 -0.11162070 -0.47856221 -4.560696e-12
#> 5 -0.29382055 -0.01778665 -2.770887e-13  0.08691990  0.03126804 -3.107323e-13
#>       emb_235     emb_236     emb_237       emb_238    emb_239      emb_240
#> 1  0.01815343 -0.21057966  0.12228953  5.982216e-12  0.1630277 -0.013783608
#> 2  0.09597327  0.00572994 -0.02157019 -1.047816e-12  0.0412974  0.029324745
#> 3  0.09597327  0.00572994 -0.02157019 -1.047816e-12  0.0412974  0.029324745
#> 4  0.08970520 -0.10439184  0.31800839  1.411288e-11 -0.1958148 -0.000121747
#> 5 -0.25294150  0.04092276  0.39150335  1.760406e-11 -0.1266960 -0.126755687
#>         emb_241       emb_242     emb_243     emb_244     emb_245       emb_246
#> 1  6.042562e-14 -0.0003012956 -0.11531038  0.05677129  0.01891039  2.826472e-14
#> 2  3.094053e-14  0.0030695966 -0.03629561 -0.09241034 -0.12802759 -2.588442e-13
#> 3  3.094053e-14  0.0030695966 -0.03629561 -0.09241034 -0.12802759 -2.588442e-13
#> 4 -3.157977e-13 -0.0744337977  0.05070939  0.14551198 -0.23311058 -4.619933e-13
#> 5 -3.486066e-13 -0.0497269541  0.10603192 -0.01639295  0.08365563  1.102113e-13
#>         emb_247       emb_248     emb_249     emb_250      emb_251
#> 1  0.0247181626 -0.0965775950 -0.05466845 -0.06784251  0.006253995
#> 2 -0.0005041777 -0.0500139181 -0.01903609  0.04816566 -0.043125211
#> 3 -0.0005041777 -0.0500139181 -0.01903609  0.04816566 -0.043125211
#> 4  0.0670538400 -0.1461326399  0.19504723 -0.01643798 -0.164846414
#> 5  0.1964018013  0.0005008687  0.06326827  0.25687935 -0.008511848
#>         emb_252      emb_253     emb_254       emb_255      emb_256     emb_257
#> 1  7.272481e-14 -0.030530793  0.05388221  1.686689e-13 -0.008373781 -0.09103702
#> 2 -2.002842e-13 -0.007831904 -0.02320273 -2.330809e-13 -0.017388570 -0.04813275
#> 3 -2.002842e-13 -0.007831904 -0.02320273 -2.330809e-13 -0.017388570 -0.04813275
#> 4 -3.759449e-13  0.013600230  0.06831679  2.862719e-13 -0.165312799  0.14528997
#> 5 -6.933495e-14 -0.159340629  0.05615992 -8.575779e-14  0.131156187  0.22280074
#>      emb_258       emb_259      emb_260     emb_261     emb_262     emb_263
#> 1 0.04108412 -1.478227e-13  0.007485319  0.04181334  0.01689354  0.05565580
#> 2 0.08554805 -1.054712e-15 -0.009718817 -0.01703099 -0.07279915 -0.01131729
#> 3 0.08554805 -1.054712e-15 -0.009718817 -0.01703099 -0.07279915 -0.01131729
#> 4 0.31707855 -2.029347e-12  0.128771975 -0.00782843 -0.12547147  0.05922798
#> 5 0.08163872  2.016330e-13 -0.028787447  0.18087594 -0.09434174 -0.11026357
#>        emb_264     emb_265     emb_266       emb_267       emb_268
#> 1 -0.038403117  0.02186264  0.05101616  1.709674e-13  0.0142079110
#> 2  0.076101527  0.01123601  0.04916268  2.233942e-13  0.0642664908
#> 3  0.076101527  0.01123601  0.04916268  2.233942e-13  0.0642664908
#> 4  0.004037597 -0.03425739  0.15758658  2.951263e-13  0.0003474812
#> 5 -0.350492114 -0.19420902 -0.10208481 -8.671865e-13 -0.3391703721
#>         emb_269      emb_270    emb_271      emb_272     emb_273     emb_274
#> 1  3.478641e-13  0.157886776 0.11574756 1.119498e-12  0.01239716 -0.06575584
#> 2  1.476120e-13  0.009307396 0.05313810 3.275952e-13  0.02365128 -0.10773760
#> 3  1.476120e-13  0.009307396 0.05313810 3.275952e-13  0.02365128 -0.10773760
#> 4  1.130016e-13  0.121610502 0.13233015 1.460317e-12 -0.24250010 -0.10936652
#> 5 -7.817549e-13 -0.326984988 0.06815635 1.255796e-12 -0.06105348  0.09134861
#>       emb_275     emb_276     emb_277    emb_278     emb_279     emb_280
#> 1 -0.01166207 -0.05209524  0.03439466 -0.0828473  0.05798466  0.11571524
#> 2  0.01593246 -0.06108688 -0.04333693 -0.1265331  0.07789986 -0.03701199
#> 3  0.01593246 -0.06108688 -0.04333693 -0.1265331  0.07789986 -0.03701199
#> 4 -0.03169095 -0.01765951  0.25185831  0.2070342 -0.06212051  0.47360480
#> 5  0.09950271  0.08906861  0.24431136  0.4495954 -0.07580445  0.20429099
#>         emb_281     emb_282     emb_283     emb_284     emb_285      emb_286
#> 1  1.442535e-12  0.07220102  0.03024337 -0.04099056 -0.09026382  0.005694954
#> 2  1.115542e-12  0.09482270  0.09852857 -0.05157709 -0.17211486  0.116482957
#> 3  1.115542e-12  0.09482270  0.09852857 -0.05157709 -0.17211486  0.116482957
#> 4  1.242141e-12  0.12043678 -0.19796958 -0.17087139 -0.12880664 -0.183017453
#> 5 -1.651109e-12 -0.16902575 -0.26720995  0.02635919 -0.03811699 -0.066607423
#>         emb_287     emb_288     emb_289      emb_290     emb_291       emb_292
#> 1 -7.309474e-13  0.01753257  0.08975417  0.006249599  0.04869372  5.186095e-13
#> 2 -1.508366e-12  0.04676678  0.10130410 -0.016495787 -0.13798458 -1.233768e-12
#> 3 -1.508366e-12  0.04676678  0.10130410 -0.016495787 -0.13798458 -1.233768e-12
#> 4 -2.401274e-13 -0.01811341  0.04193978  0.084405645 -0.02067056 -7.591102e-13
#> 5  1.298879e-12 -0.03057237 -0.26440527 -0.049738248 -0.02460703 -1.116056e-12
#>       emb_293     emb_294     emb_295     emb_296     emb_297       emb_298
#> 1  0.01706837  0.03752635  0.02180578 -0.06536492  0.08750965  1.230070e-12
#> 2 -0.04586478 -0.12182872  0.07919412  0.08335672  0.02901141 -1.216449e-13
#> 3 -0.04586478 -0.12182872  0.07919412  0.08335672  0.02901141 -1.216449e-13
#> 4 -0.03368913  0.16947167 -0.04524931 -0.41035361  0.05982436  2.674666e-13
#> 5 -0.05999318  0.12506594 -0.10158316 -0.08531947 -0.04289863 -1.935049e-13
#>       emb_299     emb_300     emb_301     emb_302     emb_303     emb_304
#> 1 -0.03461091 -0.01252934 -0.02078484 -0.06089479  0.12511890  0.07787031
#> 2  0.05629688  0.04866406 -0.04369103 -0.06262994 -0.04730099  0.19845011
#> 3  0.05629688  0.04866406 -0.04369103 -0.06262994 -0.04730099  0.19845011
#> 4  0.02630741  0.06472109 -0.09441109  0.21867327  0.01358494 -0.10007471
#> 5 -0.04376559 -0.01093457  0.11396241  0.16948913  0.12095387 -0.30624157
#>         emb_305     emb_306       emb_307     emb_308     emb_309       emb_310
#> 1 -6.861248e-13 -0.06359978 -2.450384e-13 -0.05108487  0.02028093  3.982231e-13
#> 2 -6.782313e-13  0.11998240  3.771853e-14 -0.03801370 -0.15864210 -8.550920e-13
#> 3 -6.782313e-13  0.11998240  3.771853e-14 -0.03801370 -0.15864210 -8.550920e-13
#> 4  1.115249e-13 -0.12750826 -8.859406e-14 -0.07870845  0.01705794 -7.734820e-13
#> 5  1.287156e-12 -0.10517396 -3.234565e-14 -0.01996947 -0.07463995  6.152084e-13
#>       emb_311     emb_312    emb_313     emb_314       emb_315     emb_316
#> 1  0.01712034 -0.14334693 -0.1420363 -0.07349513  0.0278993828 -0.07610766
#> 2 -0.03034751 -0.06410232 -0.3124439 -0.35120147 -0.2182381555  0.14639480
#> 3 -0.03034751 -0.06410232 -0.3124439 -0.35120147 -0.2182381555  0.14639480
#> 4 -0.07534298  0.04631573 -0.0676209 -0.04182119  0.0003058283 -0.14509994
#> 5  0.06919403 -0.12915033  0.1414813  0.27145877  0.1689929675 -0.14226697
#>       emb_317    emb_318     emb_319      emb_320       emb_321     emb_322
#> 1  0.02289498 -0.1813304  0.06448579 -0.031211737  2.094725e-12 -0.06376456
#> 2  0.21401412 -0.1970658  0.15105251 -0.147871005  8.241926e-12  0.09349213
#> 3  0.21401412 -0.1970658  0.15105251 -0.147871005  8.241926e-12  0.09349213
#> 4  0.06308354 -0.1663199 -0.02330706 -0.078981174  3.587138e-12 -0.03226527
#> 5 -0.20023340 -0.1510720 -0.07023443 -0.003108304 -3.083688e-13 -0.22737777
#>        emb_323       emb_324      emb_325     emb_326       emb_327     emb_328
#> 1 -0.027796676 -2.147796e-13  0.028051531 -0.06059977  7.184431e-13  0.05250977
#> 2  0.156452366  1.124798e-12 -0.003673887  0.26563607 -1.823554e-13  0.24850549
#> 3  0.156452366  1.124798e-12 -0.003673887  0.26563607 -1.823554e-13  0.24850549
#> 4 -0.122380465 -8.803803e-13  0.005277217 -0.11790651  9.366310e-13  0.04362533
#> 5 -0.006149756 -2.853013e-14  0.035586546 -0.16138238  5.296701e-13 -0.10252037
#>       emb_329       emb_330     emb_331     emb_332     emb_333     emb_334
#> 1 -0.11913040 -4.764114e-13  0.01789391 -0.04050895 -0.02071859  0.04258266
#> 2 -0.37618564 -8.257093e-13  0.05502652 -0.01163906 -0.08979251 -0.08609076
#> 3 -0.37618564 -8.257093e-13  0.05502652 -0.01163906 -0.08979251 -0.08609076
#> 4 -0.12273796 -2.352328e-13 -0.04637697 -0.02388273  0.08050075 -0.09666872
#> 5  0.02297047 -2.591746e-13  0.05319282 -0.13494522 -0.02954834  0.21110836
#>         emb_335     emb_336     emb_337     emb_338      emb_339      emb_340
#> 1 -7.929467e-14  0.02488780 -0.07067935 -0.03352817 -0.058533038 1.024830e-12
#> 2 -1.800163e-12  0.15856278 -0.20496441 -0.07934619  0.004629124 2.425509e-12
#> 3 -1.800163e-12  0.15856278 -0.20496441 -0.07934619  0.004629124 2.425509e-12
#> 4 -2.970523e-13 -0.12620312 -0.09348152  0.04527044 -0.134521556 3.329975e-13
#> 5  1.107510e-12 -0.01949145 -0.13105778 -0.04808341 -0.010259565 1.679841e-13
#>      emb_341       emb_342      emb_343      emb_344     emb_345       emb_346
#> 1 0.07822145  4.994512e-13  0.007989081 0.0972823957  0.02649074  4.631122e-13
#> 2 0.03132349 -1.140437e-12 -0.150181057 0.0006789592 -0.19253009 -2.044698e-12
#> 3 0.03132349 -1.140437e-12 -0.150181057 0.0006789592 -0.19253009 -2.044698e-12
#> 4 0.08802666  4.656510e-13 -0.011751462 0.1246532251 -0.03616979 -4.862950e-14
#> 5 0.04861647  3.257353e-12  0.323622824 0.0412825494  0.11943696  1.416861e-12
#>        emb_347     emb_348       emb_349     emb_350     emb_351     emb_352
#> 1 -0.106191031  0.11886833 -1.239666e-12 -0.04890046 -0.01131075  0.03831049
#> 2 -0.196604800 -0.04223692 -4.345526e-12 -0.23944660 -0.15070741 -0.02622578
#> 3 -0.196604800 -0.04223692 -4.345526e-12 -0.23944660 -0.15070741 -0.02622578
#> 4 -0.006850071  0.10564758 -3.291038e-12 -0.11098326  0.16544917 -0.03799365
#> 5 -0.164655875  0.14601587 -2.050414e-12 -0.07440715 -0.04344833  0.37000507
#>      emb_353      emb_354     emb_355     emb_356       emb_357     emb_358
#> 1 -0.1975711 -0.090261272 -0.13516600  0.03808265  5.980748e-13  0.03793347
#> 2 -0.1056438 -0.004863485  0.01601255  0.24135053  2.058490e-12  0.11864898
#> 3 -0.1056438 -0.004863485  0.01601255  0.24135053  2.058490e-12  0.11864898
#> 4 -0.2316792 -0.091774230  0.05363560 -0.07851889 -5.452722e-13 -0.05503336
#> 5 -0.1338210 -0.197038701 -0.02966876 -0.15024788 -1.390663e-12 -0.01188317
#>       emb_359       emb_360     emb_361       emb_362      emb_363    emb_364
#> 1 -0.03075080 -1.723374e-13 0.025324372  4.554078e-11  0.152117004 0.11970152
#> 2  0.29760882  1.256226e-12 0.008602285  1.615175e-12  0.005957204 0.05584681
#> 3  0.29760882  1.256226e-12 0.008602285  1.615175e-12  0.005957204 0.05584681
#> 4 -0.05052853 -7.042960e-13 0.074002605 -2.028035e-12 -0.005941921 0.03385700
#> 5 -0.50552845 -1.740094e-12 0.077782354  7.723751e-12  0.025833331 0.01697262
#>       emb_365       emb_366     emb_367     emb_368       emb_369     emb_370
#> 1 -0.15971297  1.642832e-12  0.05214736 -0.10298040  1.179057e-13 -0.04246897
#> 2  0.08315891 -2.869085e-13 -0.02541207  0.02195315 -2.067348e-13  0.07078014
#> 3  0.08315891 -2.869085e-13 -0.02541207  0.02195315 -2.067348e-13  0.07078014
#> 4 -0.21226688  1.512563e-12  0.06703108 -0.14246239  2.529344e-13 -0.21551165
#> 5 -0.31059048  2.213498e-12  0.15569839 -0.13507675  3.186982e-13 -0.09288684
#>       emb_371     emb_372       emb_373     emb_374     emb_375     emb_376
#> 1 -0.04615114 -0.02986085  4.118050e-13  0.07209550 -0.06018222  0.01853718
#> 2  0.00255738 -0.02201666 -7.871308e-14 -0.05384964  0.04824348 -0.13211490
#> 3  0.00255738 -0.02201666 -7.871308e-14 -0.05384964  0.04824348 -0.13211490
#> 4 -0.15091257 -0.05008386  1.049490e-13  0.04738739  0.04214961  0.07021530
#> 5  0.08519399 -0.14532378  1.739563e-12  0.21414058  0.02775971 -0.20849830
#>       emb_377       emb_378      emb_379     emb_380    emb_381     emb_382
#> 1 -0.16001977 -1.824370e-13 -0.024555338 -0.01357044 -0.1934758  0.03872473
#> 2 -0.05827139 -4.348832e-13 -0.001874426 -0.08071778 -0.1544008  0.03156871
#> 3 -0.05827139 -4.348832e-13 -0.001874426 -0.08071778 -0.1544008  0.03156871
#> 4  0.01808400 -6.198236e-13 -0.017438225 -0.09442351 -0.1357185  0.06190860
#> 5 -0.35670357 -1.807599e-12 -0.149928802 -0.18404385 -0.2312257 -0.13281195
#>       emb_383    emb_384       emb_385    emb_386     emb_387    emb_388
#> 1 -0.01408732 0.06700636 -2.205113e-12  0.1320191 -0.09288031 0.12695050
#> 2 -0.12228787 0.07466151 -2.537344e-12  0.2175604 -0.22754751 0.01770064
#> 3 -0.12228787 0.07466151 -2.537344e-12  0.2175604 -0.22754751 0.01770064
#> 4  0.13024242 0.04883224 -9.351755e-13 -0.1148738  0.11555804 0.01071683
#> 5 -0.13178830 0.09619369 -3.430232e-12  0.2588573 -0.10535239 0.18611954
#>         emb_389    emb_390       emb_391      emb_392     emb_393      emb_394
#> 1  3.350228e-13 0.01268826 -2.241020e-13 -0.082401451 -0.05412759 -0.014695518
#> 2 -3.745819e-13 0.20539603  2.722527e-13 -0.249588808 -0.24457242 -0.004368427
#> 3 -3.745819e-13 0.20539603  2.722527e-13 -0.249588808 -0.24457242 -0.004368427
#> 4 -2.008740e-13 0.02511839 -5.589278e-14 -0.009700783  0.20109573  0.001698337
#> 5  1.489399e-13 0.08461017 -3.527135e-13 -0.309405550 -0.23486981  0.123035370
#>      emb_395       emb_396     emb_397      emb_398      emb_399      emb_400
#> 1 0.14223882  1.742402e-13 -0.13420452  0.042146758 -0.060202025  0.093722143
#> 2 0.09277689  1.093443e-12  0.14372287 -0.009778225  0.229413898  0.055869440
#> 3 0.09277689  1.093443e-12  0.14372287 -0.009778225  0.229413898  0.055869440
#> 4 0.11697203 -4.420856e-14 -0.10885254  0.043288606 -0.004378112 -0.002262005
#> 5 0.40916898  1.454045e-12 -0.08358448  0.096061421 -0.084939111  0.006325625
#>       emb_401       emb_402      emb_403     emb_404       emb_405     emb_406
#> 1  0.08420271 -4.783113e-13  0.001563145 -0.09189553 -2.980191e-12 -0.11915284
#> 2  0.03215189 -3.025861e-13 -0.027000945 -0.09261547 -5.958636e-13 -0.02370640
#> 3  0.03215189 -3.025861e-13 -0.027000945 -0.09261547 -5.958636e-13 -0.02370640
#> 4  0.10714157 -3.165333e-13  0.099221758  0.17432810 -9.410183e-13 -0.08587056
#> 5 -0.03199672 -3.369440e-13 -0.063546814 -0.03486700 -2.884884e-12 -0.11595804
#>        emb_407       emb_408     emb_409   emb_410   emb_411      emb_412
#> 1  0.000946621 -4.465850e-14 -0.02036862 0.1231983 0.1170976 -0.014179007
#> 2 -0.021404031  1.846537e-12  0.14594995 0.3217929 0.3389194 -0.005197826
#> 3 -0.021404031  1.846537e-12  0.14594995 0.3217929 0.3389194 -0.005197826
#> 4 -0.174587571  8.910140e-12 -0.06782946 0.2898116 0.2675731  0.279287162
#> 5 -0.033170566  2.088097e-12  0.02438279 0.1356713 0.3744071 -0.155906661
#>     emb_413     emb_414       emb_415    emb_416       emb_417       emb_418
#> 1 0.1533088 -0.02945385  1.958712e-11 0.06601929  2.880125e-12  8.959574e-02
#> 2 0.3798634 -0.06696444  1.130481e-10 0.16948883 -1.321527e-11  3.958436e-05
#> 3 0.3798634 -0.06696444  1.130481e-10 0.16948883 -1.321527e-11  3.958436e-05
#> 4 0.2793248  0.11027247 -4.480029e-11 0.08309108 -8.795664e-12  3.209912e-02
#> 5 0.1944962 -0.13360431  2.571364e-10 0.25248042 -2.077639e-11 -3.605870e-01
#>         emb_419      emb_420      emb_421       emb_422     emb_423     emb_424
#> 1 -1.612864e-11 0.0874660772  0.050714075 -1.183341e-08  0.07989405  0.03126318
#> 2 -8.295571e-11 0.3228441558 -0.140776595  6.440711e-08  0.10095751  0.06072162
#> 3 -8.295571e-11 0.3228441558 -0.140776595  6.440711e-08  0.10095751  0.06072162
#> 4  3.674122e-11 0.2908293867  0.107630889  5.478808e-08 -0.28911062 -0.08852960
#> 5 -1.871559e-10 0.0008882202  0.008671267  6.589931e-08  0.45263004  0.11132275
#>       emb_425     emb_426       emb_427   emb_428     emb_429       emb_430
#> 1 -0.05084686 -0.02092343  1.652089e-06 0.1404991  0.05859478  4.018882e-06
#> 2 -0.07006938 -0.15288901  6.192345e-06 0.5075582 -0.02251685  1.473271e-05
#> 3 -0.07006938 -0.15288901  6.192345e-06 0.5075582 -0.02251685  1.473271e-05
#> 4 -0.09214874 -0.01274021 -3.650862e-06 0.1863044  0.01924708 -7.929370e-06
#> 5 -0.07229512 -0.20847473  1.394678e-05 0.4183998  0.08513676  3.111471e-05
#>     emb_431    emb_432     emb_433    emb_434    emb_435     emb_436
#> 1 0.1611122 0.11767865  0.02557395 0.08277447  0.0621556  0.06186424
#> 2 0.3608305 0.35032992  0.26385347 0.01776173  0.1058981  0.08670475
#> 3 0.3608305 0.35032992  0.26385347 0.01776173  0.1058981  0.08670475
#> 4 0.2260583 0.09126615 -0.03182264 0.17801368 -0.1218137 -0.04843736
#> 5 0.3137080 0.07173353  0.07079803 0.11259804  0.2922276 -0.11904000
#>       emb_437    emb_438     emb_439    emb_440    emb_441     emb_442
#> 1  0.04861409  0.1451271 -0.01634767 -0.1823832 0.05367405 -0.01161441
#> 2  0.06410791  0.3396561  0.03792711 -0.3369770 0.07700815  0.07857426
#> 3  0.06410791  0.3396561  0.03792711 -0.3369770 0.07700815  0.07857426
#> 4 -0.07555228 -0.1534222 -0.10582987 -0.2571021 0.08209140  0.03703506
#> 5 -0.06283969  0.3818492  0.18364647 -0.3303589 0.04387851  0.08021988
#>        emb_443     emb_444     emb_445     emb_446     emb_447    emb_448
#> 1  0.005262139 -0.01169830 -0.03267676  0.02902867  0.05791496 0.04240405
#> 2 -0.009301149 -0.01120432  0.03560695  0.06689872 -0.05740614 0.13088067
#> 3 -0.009301149 -0.01120432  0.03560695  0.06689872 -0.05740614 0.13088067
#> 4 -0.024758366  0.06041580  0.11452404 -0.10771542  0.07286484 0.05413467
#> 5  0.013463796 -0.08198665  0.03270869  0.22174185  0.11836165 0.19237499
#>        emb_449     emb_450     emb_451     emb_452     emb_453    emb_454
#> 1  0.001065599  0.04283678 -0.04969012 -0.04251662  0.01640115 0.09246403
#> 2  0.001987939  0.18764991 -0.05066409 -0.06953020  0.01082361 0.14669386
#> 3  0.001987939  0.18764991 -0.05066409 -0.06953020  0.01082361 0.14669386
#> 4 -0.001981237 -0.03192318 -0.07612470  0.04913110  0.07688414 0.05316707
#> 5  0.004757918  0.25713310 -0.01111090 -0.14199019 -0.07895569 0.05250290
#>       emb_455      emb_456     emb_457     emb_458     emb_459     emb_460
#> 1 -0.02880282  0.002619994 -0.06642604 -0.02627725 -0.05120852 -0.02214393
#> 2  0.04212574 -0.024928811 -0.17770790 -0.08892779 -0.15865525  0.09226504
#> 3  0.04212574 -0.024928811 -0.17770790 -0.08892779 -0.15865525  0.09226504
#> 4  0.03142852  0.072493205 -0.08570266  0.21773380  0.07903480 -0.11239800
#> 5 -0.04411270 -0.018900933 -0.22273719 -0.22932084 -0.19358206  0.04157965
#>       emb_461      emb_462      emb_463     emb_464     emb_465     emb_466
#> 1 -0.04553535  0.006667155  0.009909439 -0.04677366 -0.07805975  0.04139923
#> 2  0.05226520 -0.053018434  0.131324524 -0.15536638  0.02678915  0.19579825
#> 3  0.05226520 -0.053018434  0.131324524 -0.15536638  0.02678915  0.19579825
#> 4  0.18351539  0.005527198  0.126489544 -0.02387597 -0.20877735 -0.05675264
#> 5 -0.13282190 -0.006547928 -0.036462357 -0.12745622  0.01917186  0.23133308
#>      emb_467     emb_468     emb_469     emb_470       emb_471       emb_472
#> 1 0.02800893 -0.01461450 -0.01880968  0.08013333 -0.0008826349 -0.0006338334
#> 2 0.03757365 -0.04813412  0.14853193  0.10093114 -0.0205958041 -0.0332143727
#> 3 0.03757365 -0.04813412  0.14853193  0.10093114 -0.0205958041 -0.0332143727
#> 4 0.13044012  0.01777485 -0.01369878  0.02841593  0.0339889727  0.0582500238
#> 5 0.04953598 -0.25336550  0.12226047 -0.03564174 -0.0853662333 -0.0719515328
#>       emb_473     emb_474      emb_475     emb_476      emb_477     emb_478
#> 1 -0.05826985 -0.01725681 -0.005946337  0.06276184 -0.005633696  0.03963313
#> 2 -0.02415477  0.05257704  0.113426129 -0.11054000  0.062784899  0.07966384
#> 3 -0.02415477  0.05257704  0.113426129 -0.11054000  0.062784899  0.07966384
#> 4 -0.03862636  0.03509980  0.038272962 -0.03880686  0.041835140 -0.13625199
#> 5 -0.06260727 -0.06190320  0.349291049 -0.18305449  0.009962709  0.10127730
#>       emb_479     emb_480     emb_481     emb_482       emb_483      emb_484
#> 1  0.12890184 -0.04810837  0.05533861 -0.02468046  7.029945e-05 -0.009101552
#> 2  0.03405358  0.01247095 -0.01220794 -0.01133157 -3.042379e-02  0.020719248
#> 3  0.03405358  0.01247095 -0.01220794 -0.01133157 -3.042379e-02  0.020719248
#> 4  0.10998141  0.14622776 -0.02779268  0.07200135  3.007148e-02  0.066179003
#> 5 -0.29675271  0.02889118 -0.16619766 -0.25785689 -1.532018e-01 -0.015949763
#>       emb_485     emb_486     emb_487       emb_488      emb_489      emb_490
#> 1 -0.02552084 -0.03073253  0.04364460 -3.938914e-02  0.065202384 -0.074810509
#> 2  0.05802977 -0.10438158  0.03358698  5.321755e-05  0.001408298 -0.043021184
#> 3  0.05802977 -0.10438158  0.03358698  5.321755e-05  0.001408298 -0.043021184
#> 4  0.04643974 -0.12082286  0.02359699 -1.086398e-01  0.136323605 -0.005603803
#> 5  0.01883938 -0.08732674 -0.05901341  7.553885e-02 -0.145588243  0.014216448
#>       emb_491      emb_492      emb_493     emb_494     emb_495      emb_496
#> 1 -0.03830966 -0.007437952 -0.088581816  0.04273070 -0.04997836 -0.012589490
#> 2  0.14576074  0.104519917 -0.009854297  0.02670965 -0.13166993 -0.018952248
#> 3  0.14576074  0.104519917 -0.009854297  0.02670965 -0.13166993 -0.018952248
#> 4 -0.14128112 -0.148972736 -0.052560064  0.02581775 -0.01723987 -0.051494177
#> 5  0.17936958  0.120923802  0.073238902 -0.01638885 -0.18283217 -0.008869669
#>        emb_497     emb_498     emb_499     emb_500
#> 1  0.012023504 -0.01344930  0.01217242  0.02225303
#> 2 -0.008256469  0.05708323 -0.04817061  0.10674458
#> 3 -0.008256469  0.05708323 -0.04817061  0.10674458
#> 4 -0.027346263  0.03189524 -0.04115119 -0.19835515
#> 5 -0.012252740  0.02882364 -0.07064556  0.06026562

clinspacy_output_file %>% 
  bind_clinspacy_embeddings(
    mtsamples[1:5, 1:2],
    type = 'cui2vec',
    subset = 'is_negated == FALSE & semantic_type == "Diagnostic Procedure"'
    )
#>   clinspacy_id note_id
#> 1            1       1
#> 2            2       2
#> 3            3       3
#> 4            4       4
#> 5            5       5
#>                                                        description     emb_001
#> 1 A 23-year-old white female presents with complaint of allergies.          NA
#> 2                         Consult for laparoscopic gastric bypass.          NA
#> 3                         Consult for laparoscopic gastric bypass.          NA
#> 4                                             2-D M-Mode. Doppler. -0.06111055
#> 5                                               2-D Echocardiogram -0.08545282
#>      emb_002       emb_003      emb_004     emb_005     emb_006    emb_007
#> 1         NA            NA           NA          NA          NA         NA
#> 2         NA            NA           NA          NA          NA         NA
#> 3         NA            NA           NA          NA          NA         NA
#> 4 0.03059523 -1.340074e-16 -0.032813400 -0.02400309 -0.02559680 0.04846848
#> 5 0.03965676 -4.336809e-17 -0.008077436 -0.04463792 -0.05437294 0.06603530
#>       emb_008    emb_009      emb_010     emb_011    emb_012    emb_013
#> 1          NA         NA           NA          NA         NA         NA
#> 2          NA         NA           NA          NA         NA         NA
#> 3          NA         NA           NA          NA         NA         NA
#> 4 -0.01093140 0.04029187 6.602249e-16 -0.08182351 0.02424283 0.01817957
#> 5 -0.01438509 0.05986346 7.320533e-16 -0.08818264 0.08076658 0.06328653
#>       emb_014   emb_015   emb_016   emb_017       emb_018    emb_019    emb_020
#> 1          NA        NA        NA        NA            NA         NA         NA
#> 2          NA        NA        NA        NA            NA         NA         NA
#> 3          NA        NA        NA        NA            NA         NA         NA
#> 4 0.008926259 0.7286934 0.3618093 -1.086411 -3.521489e-16 0.11064232 0.07165768
#> 5 0.047296627 0.7833567 0.3750314 -1.044393 -7.381248e-16 0.07850813 0.08235334
#>        emb_021     emb_022    emb_023     emb_024     emb_025    emb_026
#> 1           NA          NA         NA          NA          NA         NA
#> 2           NA          NA         NA          NA          NA         NA
#> 3           NA          NA         NA          NA          NA         NA
#> 4 -0.004772346 -0.02723898 0.03401242 -0.04099675 -0.10558937 -0.1766332
#> 5  0.080923256  0.06032331 0.07184838  0.02404830 -0.07323135 -0.2161846
#>      emb_027     emb_028    emb_029     emb_030     emb_031    emb_032
#> 1         NA          NA         NA          NA          NA         NA
#> 2         NA          NA         NA          NA          NA         NA
#> 3         NA          NA         NA          NA          NA         NA
#> 4 0.04464371 0.005871212 -0.1153548 -0.03303530 -0.06472702 0.01083626
#> 5 0.01648035 0.095369073 -0.1397257 -0.05403436 -0.08795426 0.06221038
#>        emb_033       emb_034   emb_035      emb_036     emb_037    emb_038
#> 1           NA            NA        NA           NA          NA         NA
#> 2           NA            NA        NA           NA          NA         NA
#> 3           NA            NA        NA           NA          NA         NA
#> 4 -0.005695953 -4.412269e-15 0.1330620 3.086073e-15 -0.05242102 0.09087055
#> 5 -0.033214583 -1.147867e-14 0.2099898 5.528997e-15 -0.08816897 0.08296795
#>     emb_039    emb_040    emb_041    emb_042     emb_043     emb_044   emb_045
#> 1        NA         NA         NA         NA          NA          NA        NA
#> 2        NA         NA         NA         NA          NA          NA        NA
#> 3        NA         NA         NA         NA          NA          NA        NA
#> 4 0.1638411 0.05942175 0.08871239 0.06683947 -0.03112677 -0.01438893 0.1972377
#> 5 0.1833553 0.07969723 0.09489197 0.19583080  0.10386853 -0.07583318 0.2679430
#>      emb_046   emb_047     emb_048       emb_049     emb_050     emb_051
#> 1         NA        NA          NA            NA          NA          NA
#> 2         NA        NA          NA            NA          NA          NA
#> 3         NA        NA          NA            NA          NA          NA
#> 4 -0.8296124 0.3539849 0.005368506 -4.128642e-16  0.06946373 -0.10157185
#> 5 -0.7274721 0.2173788 0.053046317  1.321686e-14 -0.02125846 -0.07034135
#>      emb_052      emb_053    emb_054    emb_055      emb_056    emb_057
#> 1         NA           NA         NA         NA           NA         NA
#> 2         NA           NA         NA         NA           NA         NA
#> 3         NA           NA         NA         NA           NA         NA
#> 4 0.02818575 1.072675e-13 0.08571772 -0.1881272 0.0003059182 0.12349607
#> 5 0.03635827 1.692813e-13 0.13589856 -0.2822573 0.0450989688 0.09481364
#>         emb_058    emb_059    emb_060   emb_061     emb_062   emb_063
#> 1            NA         NA         NA        NA          NA        NA
#> 2            NA         NA         NA        NA          NA        NA
#> 3            NA         NA         NA        NA          NA        NA
#> 4 -2.417337e-15 -0.1469975 0.01449634 0.2097794 -0.15799739 0.1997379
#> 5 -3.910067e-15 -0.1729468 0.05932243 0.1694688 -0.08216626 0.1893711
#>       emb_064    emb_065       emb_066   emb_067    emb_068     emb_069
#> 1          NA         NA            NA        NA         NA          NA
#> 2          NA         NA            NA        NA         NA          NA
#> 3          NA         NA            NA        NA         NA          NA
#> 4  0.02314434 -0.2352371 -4.510281e-16 0.0777039 -0.3541018 -0.14586650
#> 5 -0.14545062 -0.3010551  5.898060e-16 0.1528018 -0.5494841 -0.06534203
#>      emb_070     emb_071     emb_072   emb_073       emb_074   emb_075
#> 1         NA          NA          NA        NA            NA        NA
#> 2         NA          NA          NA        NA            NA        NA
#> 3         NA          NA          NA        NA            NA        NA
#> 4 -0.7194238  0.34022655 -0.07945074 0.7233483 -7.658457e-14 0.2590587
#> 5 -1.0237265 -0.06825129 -0.02395073 0.6706870 -7.306655e-14 0.1581215
#>      emb_076    emb_077       emb_078   emb_079   emb_080    emb_081   emb_082
#> 1         NA         NA            NA        NA        NA         NA        NA
#> 2         NA         NA            NA        NA        NA         NA        NA
#> 3         NA         NA            NA        NA        NA         NA        NA
#> 4 -0.3516516 -0.1670191 -1.570272e-14 0.4723263 0.2926830 -0.4390311 0.1354457
#> 5 -0.5969163 -0.3880477 -2.409878e-14 0.3388141 0.3942091 -0.5539414 0.1104280
#>      emb_083     emb_084     emb_085       emb_086     emb_087       emb_088
#> 1         NA          NA          NA            NA          NA            NA
#> 2         NA          NA          NA            NA          NA            NA
#> 3         NA          NA          NA            NA          NA            NA
#> 4 0.02052987 -0.04702967 -0.08651022 -4.884981e-15 -0.07435743 -5.634382e-15
#> 5 0.05884497 -0.15852562 -0.16558745 -9.658940e-15 -0.17738093 -8.340550e-15
#>      emb_089     emb_090     emb_091   emb_092   emb_093     emb_094
#> 1         NA          NA          NA        NA        NA          NA
#> 2         NA          NA          NA        NA        NA          NA
#> 3         NA          NA          NA        NA        NA          NA
#> 4 -0.2397756  0.05733172 0.014850146 0.2651575 0.4236435 -0.02683883
#> 5 -0.2844764 -0.17663589 0.003708819 0.2413018 0.4440699 -0.02370578
#>         emb_095    emb_096    emb_097       emb_098     emb_099   emb_100
#> 1            NA         NA         NA            NA          NA        NA
#> 2            NA         NA         NA            NA          NA        NA
#> 3            NA         NA         NA            NA          NA        NA
#> 4 -1.508776e-13 -0.1599559 -0.4488140 -1.758316e-14 -0.08509241 0.1937555
#> 5 -2.187573e-13 -0.2325138 -0.4723342 -2.239181e-14 -0.09549702 0.2088438
#>     emb_101    emb_102   emb_103      emb_104    emb_105     emb_106
#> 1        NA         NA        NA           NA         NA          NA
#> 2        NA         NA        NA           NA         NA          NA
#> 3        NA         NA        NA           NA         NA          NA
#> 4 0.1043426 0.05008170 0.1674277 5.061489e-15 -0.1233117 0.004329035
#> 5 0.2121068 0.03865176 0.2655039 6.421946e-15 -0.2351980 0.078403812
#>        emb_107    emb_108    emb_109      emb_110    emb_111    emb_112
#> 1           NA         NA         NA           NA         NA         NA
#> 2           NA         NA         NA           NA         NA         NA
#> 3           NA         NA         NA           NA         NA         NA
#> 4 1.835164e-14 0.01208217 0.06013918 5.255778e-14 0.06428535 -0.3934626
#> 5 5.946112e-14 0.12235013 0.08616510 9.392053e-14 0.10374733 -0.7078867
#>     emb_113   emb_114     emb_115    emb_116    emb_117    emb_118   emb_119
#> 1        NA        NA          NA         NA         NA         NA        NA
#> 2        NA        NA          NA         NA         NA         NA        NA
#> 3        NA        NA          NA         NA         NA         NA        NA
#> 4 0.2281450 0.2155750 -0.13034265 -0.1848470 0.01702929 -0.2187104 0.1673460
#> 5 0.3146119 0.4025795  0.02442212 -0.3055148 0.02886832 -0.2847166 0.2786617
#>     emb_120   emb_121    emb_122    emb_123      emb_124    emb_125    emb_126
#> 1        NA        NA         NA         NA           NA         NA         NA
#> 2        NA        NA         NA         NA           NA         NA         NA
#> 3        NA        NA         NA         NA           NA         NA         NA
#> 4 0.2492066 -1.113107 -0.5648160 -0.3825605 3.438994e-12 -0.5977222 0.19531082
#> 5 0.3801453 -1.353335 -0.6622776 -0.7286953 3.063832e-12 -0.5099283 0.09782189
#>     emb_127    emb_128       emb_129   emb_130    emb_131      emb_132
#> 1        NA         NA            NA        NA         NA           NA
#> 2        NA         NA            NA        NA         NA           NA
#> 3        NA         NA            NA        NA         NA           NA
#> 4 0.5088026 -0.4964799 -1.798041e-13 0.1096564 -0.4808739 6.550663e-14
#> 5 0.6542731 -0.5160938 -1.680669e-13 0.2119730 -0.5853044 4.063763e-14
#>      emb_133   emb_134    emb_135   emb_136     emb_137   emb_138       emb_139
#> 1         NA        NA         NA        NA          NA        NA            NA
#> 2         NA        NA         NA        NA          NA        NA            NA
#> 3         NA        NA         NA        NA          NA        NA            NA
#> 4 -0.3090449 0.6946442 -0.0396382 0.1834565 -0.08187761 0.2943267 -5.811671e-14
#> 5 -0.2893567 0.6768191 -0.1667877 0.1508920 -0.09851342 0.4240525 -1.283609e-13
#>       emb_140   emb_141     emb_142   emb_143     emb_144    emb_145   emb_146
#> 1          NA        NA          NA        NA          NA         NA        NA
#> 2          NA        NA          NA        NA          NA         NA        NA
#> 3          NA        NA          NA        NA          NA         NA        NA
#> 4 -0.10208119 0.0367505 -0.03258399 0.1346018 -0.05587448 0.10025069 0.1325176
#> 5 -0.06222996 0.1488132 -0.20332200 0.1194288 -0.05558873 0.02174056 0.1433849
#>     emb_147      emb_148     emb_149     emb_150      emb_151    emb_152
#> 1        NA           NA          NA          NA           NA         NA
#> 2        NA           NA          NA          NA           NA         NA
#> 3        NA           NA          NA          NA           NA         NA
#> 4 0.1651028 2.125175e-13 -0.02277593 -0.03490779 7.952319e-14 -0.5068479
#> 5 0.3250313 5.608951e-13 -0.16384927 -0.08866545 9.641290e-14 -0.8785424
#>       emb_153     emb_154      emb_155     emb_156       emb_157       emb_158
#> 1          NA          NA           NA          NA            NA            NA
#> 2          NA          NA           NA          NA            NA            NA
#> 3          NA          NA           NA          NA            NA            NA
#> 4 -0.10650996  0.11477080 5.121190e-13 -0.08457432  0.0179079851  0.1088385902
#> 5 -0.04230861 -0.05589497 1.221761e-12 -0.17876150 -0.0007130762 -0.0004208772
#>     emb_159     emb_160    emb_161    emb_162      emb_163    emb_164
#> 1        NA          NA         NA         NA           NA         NA
#> 2        NA          NA         NA         NA           NA         NA
#> 3        NA          NA         NA         NA           NA         NA
#> 4 0.2824325 -0.14059878 -0.1198911 -0.1607307 1.484524e-13 -0.1545713
#> 5 0.4624998  0.07650607 -0.3293604 -0.2078751 3.454429e-13 -0.3747803
#>        emb_165     emb_166       emb_167     emb_168     emb_169    emb_170
#> 1           NA          NA            NA          NA          NA         NA
#> 2           NA          NA            NA          NA          NA         NA
#> 3           NA          NA            NA          NA          NA         NA
#> 4 -0.171804822  0.03053137  2.444815e-13 -0.02664467 -0.10924014 0.20515071
#> 5  0.002465816 -0.18412485 -3.199038e-13  0.08781372  0.01867714 0.06961732
#>       emb_171      emb_172   emb_173     emb_174   emb_175       emb_176
#> 1          NA           NA        NA          NA        NA            NA
#> 2          NA           NA        NA          NA        NA            NA
#> 3          NA           NA        NA          NA        NA            NA
#> 4 -0.02773444 2.283668e-13 0.1550851 -0.08313571 0.1020100 -2.563952e-13
#> 5  0.13705351 2.518038e-13 0.2121614 -0.14021672 0.4776242 -1.806196e-12
#>      emb_177    emb_178    emb_179    emb_180   emb_181    emb_182   emb_183
#> 1         NA         NA         NA         NA        NA         NA        NA
#> 2         NA         NA         NA         NA        NA         NA        NA
#> 3         NA         NA         NA         NA        NA         NA        NA
#> 4  0.1042761 0.10297132 0.09144758 -0.1477150 0.1375934 0.17067791 0.1646901
#> 5 -0.2585575 0.08122381 0.20077507 -0.1253954 0.2035100 0.07720583 0.2429455
#>         emb_184   emb_185    emb_186    emb_187     emb_188      emb_189
#> 1            NA        NA         NA         NA          NA           NA
#> 2            NA        NA         NA         NA          NA           NA
#> 3            NA        NA         NA         NA          NA           NA
#> 4 -1.437587e-12 0.1580584 -0.2494089 -0.2133598 -0.03684678 1.727160e-13
#> 5 -1.979646e-12 0.1658734 -0.4364903 -0.3303334  0.26474861 8.581222e-13
#>     emb_190   emb_191     emb_192    emb_193      emb_194    emb_195   emb_196
#> 1        NA        NA          NA         NA           NA         NA        NA
#> 2        NA        NA          NA         NA           NA         NA        NA
#> 3        NA        NA          NA         NA           NA         NA        NA
#> 4 0.1443788 0.3377485 -0.06218973 -0.3514109 5.410497e-12 -0.2923623 0.4007641
#> 5 0.1588177 0.5488710 -0.40832544 -0.5897665 1.194013e-11 -0.6753152 0.6130335
#>      emb_197    emb_198     emb_199      emb_200     emb_201   emb_202
#> 1         NA         NA          NA           NA          NA        NA
#> 2         NA         NA          NA           NA          NA        NA
#> 3         NA         NA          NA           NA          NA        NA
#> 4 0.03703129 -0.1906393 -0.03360996 4.150066e-13 -0.11253081 0.2006068
#> 5 0.21432033 -0.5572610 -0.06757736 9.420117e-13 -0.08300392 0.4627280
#>      emb_203   emb_204      emb_205   emb_206       emb_207    emb_208
#> 1         NA        NA           NA        NA            NA         NA
#> 2         NA        NA           NA        NA            NA         NA
#> 3         NA        NA           NA        NA            NA         NA
#> 4 -0.1535476 0.1503922  0.170571111 0.2666740 -4.352768e-13 -0.1269034
#> 5 -0.3068372 0.2553942 -0.007316906 0.6321939 -1.421054e-12 -0.2471131
#>     emb_209    emb_210   emb_211    emb_212     emb_213      emb_214    emb_215
#> 1        NA         NA        NA         NA          NA           NA         NA
#> 2        NA         NA        NA         NA          NA           NA         NA
#> 3        NA         NA        NA         NA          NA           NA         NA
#> 4 0.1728705 0.08764913 0.2983232 0.03660953 -0.09505927 3.004960e-13 -0.1381922
#> 5 0.2981724 0.10947941 0.2975198 0.25747832  0.06725040 7.156038e-13 -0.3493505
#>        emb_216   emb_217     emb_218       emb_219    emb_220      emb_221
#> 1           NA        NA          NA            NA         NA           NA
#> 2           NA        NA          NA            NA         NA           NA
#> 3           NA        NA          NA            NA         NA           NA
#> 4 6.906309e-13 0.1298516 0.001393696  2.132422e-13 -0.0885438 -0.002717749
#> 5 4.203879e-13 0.1282781 0.153216867 -7.914298e-13  0.0792478  0.150907585
#>      emb_222   emb_223     emb_224   emb_225      emb_226     emb_227
#> 1         NA        NA          NA        NA           NA          NA
#> 2         NA        NA          NA        NA           NA          NA
#> 3         NA        NA          NA        NA           NA          NA
#> 4 0.01317363 0.2796367 -0.06427652 0.3945648 1.677393e-12 -0.13699759
#> 5 0.24783030 0.2924144 -0.04715676 0.3499108 1.895064e-12 -0.03218816
#>      emb_228    emb_229     emb_230       emb_231    emb_232     emb_233
#> 1         NA         NA          NA            NA         NA          NA
#> 2         NA         NA          NA            NA         NA          NA
#> 3         NA         NA          NA            NA         NA          NA
#> 4 -0.2578513 -0.4493153 -0.11125827  2.757275e-13 -0.1116207 -0.47856221
#> 5  0.1123553 -0.2938206 -0.01778665 -2.770887e-13  0.0869199  0.03126804
#>         emb_234    emb_235     emb_236   emb_237      emb_238    emb_239
#> 1            NA         NA          NA        NA           NA         NA
#> 2            NA         NA          NA        NA           NA         NA
#> 3            NA         NA          NA        NA           NA         NA
#> 4 -4.560696e-12  0.0897052 -0.10439184 0.3180084 1.411288e-11 -0.1958148
#> 5 -3.107323e-13 -0.2529415  0.04092276 0.3915034 1.760406e-11 -0.1266960
#>        emb_240       emb_241     emb_242    emb_243     emb_244     emb_245
#> 1           NA            NA          NA         NA          NA          NA
#> 2           NA            NA          NA         NA          NA          NA
#> 3           NA            NA          NA         NA          NA          NA
#> 4 -0.000121747 -3.157977e-13 -0.07443380 0.05070939  0.14551198 -0.23311058
#> 5 -0.126755687 -3.486066e-13 -0.04972695 0.10603192 -0.01639295  0.08365563
#>         emb_246    emb_247       emb_248    emb_249     emb_250      emb_251
#> 1            NA         NA            NA         NA          NA           NA
#> 2            NA         NA            NA         NA          NA           NA
#> 3            NA         NA            NA         NA          NA           NA
#> 4 -4.619933e-13 0.06705384 -0.1461326399 0.19504723 -0.01643798 -0.164846414
#> 5  1.102113e-13 0.19640180  0.0005008687 0.06326827  0.25687935 -0.008511848
#>         emb_252     emb_253    emb_254       emb_255    emb_256   emb_257
#> 1            NA          NA         NA            NA         NA        NA
#> 2            NA          NA         NA            NA         NA        NA
#> 3            NA          NA         NA            NA         NA        NA
#> 4 -3.759449e-13  0.01360023 0.06831679  2.862719e-13 -0.1653128 0.1452900
#> 5 -6.933495e-14 -0.15934063 0.05615992 -8.575779e-14  0.1311562 0.2228007
#>      emb_258       emb_259     emb_260     emb_261     emb_262     emb_263
#> 1         NA            NA          NA          NA          NA          NA
#> 2         NA            NA          NA          NA          NA          NA
#> 3         NA            NA          NA          NA          NA          NA
#> 4 0.31707855 -2.029347e-12  0.12877197 -0.00782843 -0.12547147  0.05922798
#> 5 0.08163872  2.016330e-13 -0.02878745  0.18087594 -0.09434174 -0.11026357
#>        emb_264     emb_265    emb_266       emb_267       emb_268       emb_269
#> 1           NA          NA         NA            NA            NA            NA
#> 2           NA          NA         NA            NA            NA            NA
#> 3           NA          NA         NA            NA            NA            NA
#> 4  0.004037597 -0.03425739  0.1575866  2.951263e-13  0.0003474812  1.130016e-13
#> 5 -0.350492114 -0.19420902 -0.1020848 -8.671865e-13 -0.3391703721 -7.817549e-13
#>      emb_270    emb_271      emb_272     emb_273     emb_274     emb_275
#> 1         NA         NA           NA          NA          NA          NA
#> 2         NA         NA           NA          NA          NA          NA
#> 3         NA         NA           NA          NA          NA          NA
#> 4  0.1216105 0.13233015 1.460317e-12 -0.24250010 -0.10936652 -0.03169095
#> 5 -0.3269850 0.06815635 1.255796e-12 -0.06105348  0.09134861  0.09950271
#>       emb_276   emb_277   emb_278     emb_279   emb_280       emb_281
#> 1          NA        NA        NA          NA        NA            NA
#> 2          NA        NA        NA          NA        NA            NA
#> 3          NA        NA        NA          NA        NA            NA
#> 4 -0.01765951 0.2518583 0.2070342 -0.06212051 0.4736048  1.242141e-12
#> 5  0.08906861 0.2443114 0.4495954 -0.07580445 0.2042910 -1.651109e-12
#>      emb_282    emb_283     emb_284     emb_285     emb_286       emb_287
#> 1         NA         NA          NA          NA          NA            NA
#> 2         NA         NA          NA          NA          NA            NA
#> 3         NA         NA          NA          NA          NA            NA
#> 4  0.1204368 -0.1979696 -0.17087139 -0.12880664 -0.18301745 -2.401274e-13
#> 5 -0.1690257 -0.2672100  0.02635919 -0.03811699 -0.06660742  1.298879e-12
#>       emb_288     emb_289     emb_290     emb_291       emb_292     emb_293
#> 1          NA          NA          NA          NA            NA          NA
#> 2          NA          NA          NA          NA            NA          NA
#> 3          NA          NA          NA          NA            NA          NA
#> 4 -0.01811341  0.04193978  0.08440564 -0.02067056 -7.591102e-13 -0.03368913
#> 5 -0.03057237 -0.26440527 -0.04973825 -0.02460703 -1.116056e-12 -0.05999318
#>     emb_294     emb_295     emb_296     emb_297       emb_298     emb_299
#> 1        NA          NA          NA          NA            NA          NA
#> 2        NA          NA          NA          NA            NA          NA
#> 3        NA          NA          NA          NA            NA          NA
#> 4 0.1694717 -0.04524931 -0.41035361  0.05982436  2.674666e-13  0.02630741
#> 5 0.1250659 -0.10158316 -0.08531947 -0.04289863 -1.935049e-13 -0.04376559
#>       emb_300     emb_301   emb_302    emb_303    emb_304      emb_305
#> 1          NA          NA        NA         NA         NA           NA
#> 2          NA          NA        NA         NA         NA           NA
#> 3          NA          NA        NA         NA         NA           NA
#> 4  0.06472109 -0.09441109 0.2186733 0.01358494 -0.1000747 1.115249e-13
#> 5 -0.01093457  0.11396241 0.1694891 0.12095387 -0.3062416 1.287156e-12
#>      emb_306       emb_307     emb_308     emb_309       emb_310     emb_311
#> 1         NA            NA          NA          NA            NA          NA
#> 2         NA            NA          NA          NA            NA          NA
#> 3         NA            NA          NA          NA            NA          NA
#> 4 -0.1275083 -8.859406e-14 -0.07870845  0.01705794 -7.734820e-13 -0.07534298
#> 5 -0.1051740 -3.234565e-14 -0.01996947 -0.07463995  6.152084e-13  0.06919403
#>       emb_312    emb_313     emb_314      emb_315    emb_316     emb_317
#> 1          NA         NA          NA           NA         NA          NA
#> 2          NA         NA          NA           NA         NA          NA
#> 3          NA         NA          NA           NA         NA          NA
#> 4  0.04631573 -0.0676209 -0.04182119 0.0003058283 -0.1450999  0.06308354
#> 5 -0.12915033  0.1414813  0.27145877 0.1689929675 -0.1422670 -0.20023340
#>      emb_318     emb_319      emb_320       emb_321     emb_322      emb_323
#> 1         NA          NA           NA            NA          NA           NA
#> 2         NA          NA           NA            NA          NA           NA
#> 3         NA          NA           NA            NA          NA           NA
#> 4 -0.1663199 -0.02330706 -0.078981174  3.587138e-12 -0.03226527 -0.122380465
#> 5 -0.1510720 -0.07023443 -0.003108304 -3.083688e-13 -0.22737777 -0.006149756
#>         emb_324     emb_325    emb_326      emb_327     emb_328     emb_329
#> 1            NA          NA         NA           NA          NA          NA
#> 2            NA          NA         NA           NA          NA          NA
#> 3            NA          NA         NA           NA          NA          NA
#> 4 -8.803803e-13 0.005277217 -0.1179065 9.366310e-13  0.04362533 -0.12273796
#> 5 -2.853013e-14 0.035586546 -0.1613824 5.296701e-13 -0.10252037  0.02297047
#>         emb_330     emb_331     emb_332     emb_333     emb_334       emb_335
#> 1            NA          NA          NA          NA          NA            NA
#> 2            NA          NA          NA          NA          NA            NA
#> 3            NA          NA          NA          NA          NA            NA
#> 4 -2.352328e-13 -0.04637697 -0.02388273  0.08050075 -0.09666872 -2.970523e-13
#> 5 -2.591746e-13  0.05319282 -0.13494522 -0.02954834  0.21110836  1.107510e-12
#>       emb_336     emb_337     emb_338     emb_339      emb_340    emb_341
#> 1          NA          NA          NA          NA           NA         NA
#> 2          NA          NA          NA          NA           NA         NA
#> 3          NA          NA          NA          NA           NA         NA
#> 4 -0.12620312 -0.09348152  0.04527044 -0.13452156 3.329975e-13 0.08802666
#> 5 -0.01949145 -0.13105778 -0.04808341 -0.01025957 1.679841e-13 0.04861647
#>        emb_342     emb_343    emb_344     emb_345       emb_346      emb_347
#> 1           NA          NA         NA          NA            NA           NA
#> 2           NA          NA         NA          NA            NA           NA
#> 3           NA          NA         NA          NA            NA           NA
#> 4 4.656510e-13 -0.01175146 0.12465323 -0.03616979 -4.862950e-14 -0.006850071
#> 5 3.257353e-12  0.32362282 0.04128255  0.11943696  1.416861e-12 -0.164655875
#>     emb_348       emb_349     emb_350     emb_351     emb_352    emb_353
#> 1        NA            NA          NA          NA          NA         NA
#> 2        NA            NA          NA          NA          NA         NA
#> 3        NA            NA          NA          NA          NA         NA
#> 4 0.1056476 -3.291038e-12 -0.11098326  0.16544917 -0.03799365 -0.2316792
#> 5 0.1460159 -2.050414e-12 -0.07440715 -0.04344833  0.37000507 -0.1338210
#>       emb_354     emb_355     emb_356       emb_357     emb_358     emb_359
#> 1          NA          NA          NA            NA          NA          NA
#> 2          NA          NA          NA            NA          NA          NA
#> 3          NA          NA          NA            NA          NA          NA
#> 4 -0.09177423  0.05363560 -0.07851889 -5.452722e-13 -0.05503336 -0.05052853
#> 5 -0.19703870 -0.02966876 -0.15024788 -1.390663e-12 -0.01188317 -0.50552845
#>         emb_360    emb_361       emb_362      emb_363    emb_364    emb_365
#> 1            NA         NA            NA           NA         NA         NA
#> 2            NA         NA            NA           NA         NA         NA
#> 3            NA         NA            NA           NA         NA         NA
#> 4 -7.042960e-13 0.07400260 -2.028035e-12 -0.005941921 0.03385700 -0.2122669
#> 5 -1.740094e-12 0.07778235  7.723751e-12  0.025833331 0.01697262 -0.3105905
#>        emb_366    emb_367    emb_368      emb_369     emb_370     emb_371
#> 1           NA         NA         NA           NA          NA          NA
#> 2           NA         NA         NA           NA          NA          NA
#> 3           NA         NA         NA           NA          NA          NA
#> 4 1.512563e-12 0.06703108 -0.1424624 2.529344e-13 -0.21551165 -0.15091257
#> 5 2.213498e-12 0.15569839 -0.1350767 3.186982e-13 -0.09288684  0.08519399
#>       emb_372      emb_373    emb_374    emb_375    emb_376    emb_377
#> 1          NA           NA         NA         NA         NA         NA
#> 2          NA           NA         NA         NA         NA         NA
#> 3          NA           NA         NA         NA         NA         NA
#> 4 -0.05008386 1.049490e-13 0.04738739 0.04214961  0.0702153  0.0180840
#> 5 -0.14532378 1.739563e-12 0.21414058 0.02775971 -0.2084983 -0.3567036
#>         emb_378     emb_379     emb_380    emb_381    emb_382    emb_383
#> 1            NA          NA          NA         NA         NA         NA
#> 2            NA          NA          NA         NA         NA         NA
#> 3            NA          NA          NA         NA         NA         NA
#> 4 -6.198236e-13 -0.01743822 -0.09442351 -0.1357185  0.0619086  0.1302424
#> 5 -1.807599e-12 -0.14992880 -0.18404385 -0.2312257 -0.1328120 -0.1317883
#>      emb_384       emb_385    emb_386    emb_387    emb_388       emb_389
#> 1         NA            NA         NA         NA         NA            NA
#> 2         NA            NA         NA         NA         NA            NA
#> 3         NA            NA         NA         NA         NA            NA
#> 4 0.04883224 -9.351755e-13 -0.1148738  0.1155580 0.01071683 -2.008740e-13
#> 5 0.09619369 -3.430232e-12  0.2588573 -0.1053524 0.18611954  1.489399e-13
#>      emb_390       emb_391      emb_392    emb_393     emb_394  emb_395
#> 1         NA            NA           NA         NA          NA       NA
#> 2         NA            NA           NA         NA          NA       NA
#> 3         NA            NA           NA         NA          NA       NA
#> 4 0.02511839 -5.589278e-14 -0.009700783  0.2010957 0.001698337 0.116972
#> 5 0.08461017 -3.527135e-13 -0.309405550 -0.2348698 0.123035370 0.409169
#>         emb_396     emb_397    emb_398      emb_399      emb_400     emb_401
#> 1            NA          NA         NA           NA           NA          NA
#> 2            NA          NA         NA           NA           NA          NA
#> 3            NA          NA         NA           NA           NA          NA
#> 4 -4.420856e-14 -0.10885254 0.04328861 -0.004378112 -0.002262005  0.10714157
#> 5  1.454045e-12 -0.08358448 0.09606142 -0.084939111  0.006325625 -0.03199672
#>         emb_402     emb_403    emb_404       emb_405     emb_406     emb_407
#> 1            NA          NA         NA            NA          NA          NA
#> 2            NA          NA         NA            NA          NA          NA
#> 3            NA          NA         NA            NA          NA          NA
#> 4 -3.165333e-13  0.09922176  0.1743281 -9.410183e-13 -0.08587056 -0.17458757
#> 5 -3.369440e-13 -0.06354681 -0.0348670 -2.884884e-12 -0.11595804 -0.03317057
#>        emb_408     emb_409   emb_410   emb_411    emb_412   emb_413    emb_414
#> 1           NA          NA        NA        NA         NA        NA         NA
#> 2           NA          NA        NA        NA         NA        NA         NA
#> 3           NA          NA        NA        NA         NA        NA         NA
#> 4 8.910140e-12 -0.06782946 0.2898116 0.2675731  0.2792872 0.2793248  0.1102725
#> 5 2.088097e-12  0.02438279 0.1356713 0.3744071 -0.1559067 0.1944962 -0.1336043
#>         emb_415    emb_416       emb_417     emb_418       emb_419      emb_420
#> 1            NA         NA            NA          NA            NA           NA
#> 2            NA         NA            NA          NA            NA           NA
#> 3            NA         NA            NA          NA            NA           NA
#> 4 -4.480029e-11 0.08309108 -8.795664e-12  0.03209912  3.674122e-11 0.2908293867
#> 5  2.571364e-10 0.25248042 -2.077639e-11 -0.36058699 -1.871559e-10 0.0008882202
#>       emb_421      emb_422    emb_423    emb_424     emb_425     emb_426
#> 1          NA           NA         NA         NA          NA          NA
#> 2          NA           NA         NA         NA          NA          NA
#> 3          NA           NA         NA         NA          NA          NA
#> 4 0.107630889 5.478808e-08 -0.2891106 -0.0885296 -0.09214874 -0.01274021
#> 5 0.008671267 6.589931e-08  0.4526300  0.1113228 -0.07229512 -0.20847473
#>         emb_427   emb_428    emb_429       emb_430   emb_431    emb_432
#> 1            NA        NA         NA            NA        NA         NA
#> 2            NA        NA         NA            NA        NA         NA
#> 3            NA        NA         NA            NA        NA         NA
#> 4 -3.650862e-06 0.1863044 0.01924708 -7.929370e-06 0.2260583 0.09126615
#> 5  1.394678e-05 0.4183998 0.08513676  3.111471e-05 0.3137080 0.07173353
#>       emb_433   emb_434    emb_435     emb_436     emb_437    emb_438
#> 1          NA        NA         NA          NA          NA         NA
#> 2          NA        NA         NA          NA          NA         NA
#> 3          NA        NA         NA          NA          NA         NA
#> 4 -0.03182264 0.1780137 -0.1218137 -0.04843736 -0.07555228 -0.1534222
#> 5  0.07079803 0.1125980  0.2922276 -0.11904000 -0.06283969  0.3818492
#>      emb_439    emb_440    emb_441    emb_442     emb_443     emb_444
#> 1         NA         NA         NA         NA          NA          NA
#> 2         NA         NA         NA         NA          NA          NA
#> 3         NA         NA         NA         NA          NA          NA
#> 4 -0.1058299 -0.2571021 0.08209140 0.03703506 -0.02475837  0.06041580
#> 5  0.1836465 -0.3303589 0.04387851 0.08021988  0.01346380 -0.08198665
#>      emb_445    emb_446    emb_447    emb_448      emb_449     emb_450
#> 1         NA         NA         NA         NA           NA          NA
#> 2         NA         NA         NA         NA           NA          NA
#> 3         NA         NA         NA         NA           NA          NA
#> 4 0.11452404 -0.1077154 0.07286484 0.05413467 -0.001981237 -0.03192318
#> 5 0.03270869  0.2217418 0.11836165 0.19237499  0.004757918  0.25713310
#>      emb_451    emb_452     emb_453    emb_454     emb_455     emb_456
#> 1         NA         NA          NA         NA          NA          NA
#> 2         NA         NA          NA         NA          NA          NA
#> 3         NA         NA          NA         NA          NA          NA
#> 4 -0.0761247  0.0491311  0.07688414 0.05316707  0.03142852  0.07249320
#> 5 -0.0111109 -0.1419902 -0.07895569 0.05250290 -0.04411270 -0.01890093
#>       emb_457    emb_458    emb_459     emb_460    emb_461      emb_462
#> 1          NA         NA         NA          NA         NA           NA
#> 2          NA         NA         NA          NA         NA           NA
#> 3          NA         NA         NA          NA         NA           NA
#> 4 -0.08570266  0.2177338  0.0790348 -0.11239800  0.1835154  0.005527198
#> 5 -0.22273719 -0.2293208 -0.1935821  0.04157965 -0.1328219 -0.006547928
#>       emb_463     emb_464     emb_465     emb_466    emb_467     emb_468
#> 1          NA          NA          NA          NA         NA          NA
#> 2          NA          NA          NA          NA         NA          NA
#> 3          NA          NA          NA          NA         NA          NA
#> 4  0.12648954 -0.02387597 -0.20877735 -0.05675264 0.13044012  0.01777485
#> 5 -0.03646236 -0.12745622  0.01917186  0.23133308 0.04953598 -0.25336550
#>       emb_469     emb_470     emb_471     emb_472     emb_473    emb_474
#> 1          NA          NA          NA          NA          NA         NA
#> 2          NA          NA          NA          NA          NA         NA
#> 3          NA          NA          NA          NA          NA         NA
#> 4 -0.01369878  0.02841593  0.03398897  0.05825002 -0.03862636  0.0350998
#> 5  0.12226047 -0.03564174 -0.08536623 -0.07195153 -0.06260727 -0.0619032
#>      emb_475     emb_476     emb_477    emb_478    emb_479    emb_480
#> 1         NA          NA          NA         NA         NA         NA
#> 2         NA          NA          NA         NA         NA         NA
#> 3         NA          NA          NA         NA         NA         NA
#> 4 0.03827296 -0.03880686 0.041835140 -0.1362520  0.1099814 0.14622776
#> 5 0.34929105 -0.18305449 0.009962709  0.1012773 -0.2967527 0.02889118
#>       emb_481     emb_482     emb_483     emb_484    emb_485     emb_486
#> 1          NA          NA          NA          NA         NA          NA
#> 2          NA          NA          NA          NA         NA          NA
#> 3          NA          NA          NA          NA         NA          NA
#> 4 -0.02779268  0.07200135  0.03007148  0.06617900 0.04643974 -0.12082286
#> 5 -0.16619766 -0.25785689 -0.15320179 -0.01594976 0.01883938 -0.08732674
#>       emb_487     emb_488    emb_489      emb_490    emb_491    emb_492
#> 1          NA          NA         NA           NA         NA         NA
#> 2          NA          NA         NA           NA         NA         NA
#> 3          NA          NA         NA           NA         NA         NA
#> 4  0.02359699 -0.10863979  0.1363236 -0.005603803 -0.1412811 -0.1489727
#> 5 -0.05901341  0.07553885 -0.1455882  0.014216448  0.1793696  0.1209238
#>       emb_493     emb_494     emb_495      emb_496     emb_497    emb_498
#> 1          NA          NA          NA           NA          NA         NA
#> 2          NA          NA          NA           NA          NA         NA
#> 3          NA          NA          NA           NA          NA         NA
#> 4 -0.05256006  0.02581775 -0.01723987 -0.051494177 -0.02734626 0.03189524
#> 5  0.07323890 -0.01638885 -0.18283217 -0.008869669 -0.01225274 0.02882364
#>       emb_499     emb_500
#> 1          NA          NA
#> 2          NA          NA
#> 3          NA          NA
#> 4 -0.04115119 -0.19835515
#> 5 -0.07064556  0.06026562
```

# UMLS CUI definitions

``` r
cui2vec_definitions = dataset_cui2vec_definitions()
head(cui2vec_definitions)
#>        cui                         semantic_type
#> 1 C0000005       Amino Acid, Peptide, or Protein
#> 2 C0000005               Pharmacologic Substance
#> 3 C0000005 Indicator, Reagent, or Diagnostic Aid
#> 4 C0000039                      Organic Chemical
#> 5 C0000039               Pharmacologic Substance
#> 6 C0000052       Amino Acid, Peptide, or Protein
#>                           definition
#> 1     (131)I-Macroaggregated Albumin
#> 2     (131)I-Macroaggregated Albumin
#> 3     (131)I-Macroaggregated Albumin
#> 4 1,2-Dipalmitoylphosphatidylcholine
#> 5 1,2-Dipalmitoylphosphatidylcholine
#> 6  1,4-alpha-Glucan Branching Enzyme
```
