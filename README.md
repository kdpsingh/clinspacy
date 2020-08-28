
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clinspacy

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

The goal of clinspacy is to perform biomedical named entity recognition,
Unified Medical Language System (UMLS) concept mapping, and negation
detection using the Python spaCy, scispacy, and negspacy packages.

## Installation

You can install the GitHub version of clinspacy
with:

``` r
remotes::install_github('ML4LHS/clinspacy', INSTALL_opts = '--no-multiarch')
```

## How to load clinspacy

``` r
library(clinspacy)
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
#> Checking if the cui2vec_embeddings.rda dataset has been downloaded...
#> Checking if miniconda is installed...
#> Importing spacy...
#> Importing scispacy...
#> Importing negspacy...
#> Loading the en_core_sci_lg language model...
#> Loading NegEx...
#> Adding NegEx to the spacy pipeline...
```

## Named entity recognition (without the UMLS linker)

``` r
clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#> Processing... This patient has diabetes and CKD stage 3 but no HTN.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================                                                                |  25%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |================================================================                      |  75%  |                                                                                              |======================================================================================| 100%
#>        entity       lemma negated
#> 1     patient     patient   FALSE
#> 2    diabetes    diabetes   FALSE
#> 3 CKD stage 3 ckd stage 3   FALSE
#> 4         HTN         htn    TRUE

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.')
#> Processing... This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |============                                                                          |  14%  |                                                                                              |=========================                                                             |  29%  |                                                                                              |=====================================                                                 |  43%  |                                                                                              |=================================================                                     |  57%  |                                                                                              |=============================================================                         |  71%  |                                                                                              |==========================================================================            |  86%  |                                                                                              |======================================================================================| 100%
#>       entity      lemma negated
#> 1    patient    patient   FALSE
#> 2   diabetes   diabetes   FALSE
#> 3 omeprazole omeprazole   FALSE
#> 4    aspirin    aspirin   FALSE
#> 5 lisinopril lisinopril   FALSE
#> 6  albuterol  albuterol    TRUE
#> 7     asthma     asthma    TRUE

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.')
#> Processing... This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |============                                                                          |  14%  |                                                                                              |=========================                                                             |  29%  |                                                                                              |=====================================                                                 |  43%  |                                                                                              |=================================================                                     |  57%  |                                                                                              |=============================================================                         |  71%  |                                                                                              |==========================================================================            |  86%  |                                                                                              |======================================================================================| 100%
#>       entity      lemma negated
#> 1    patient    patient   FALSE
#> 2   diabetes   diabetes   FALSE
#> 3 omeprazole omeprazole   FALSE
#> 4    aspirin    aspirin   FALSE
#> 5 lisinopril lisinopril   FALSE
#> 6  albuterol  albuterol    TRUE
#> 7     asthma     asthma    TRUE
```

## Using the mtsamples dataset

``` r
data(mtsamples)

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
```

## Binding named entities to a data frame (without the UMLS linker)

Negated concepts, as identified by negspacy’s NegEx implementation, are
ignored and do not count towards the frequencies.

``` r
bind_clinspacy(mtsamples[1:5, 1:2],
               text = 'description')
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=============================                                                         |  33%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description 2-D 2-D M-Mode
#> 1       1 A 23-year-old white female presents with complaint of allergies.   0          0
#> 2       2                         Consult for laparoscopic gastric bypass.   0          0
#> 3       3                         Consult for laparoscopic gastric bypass.   0          0
#> 4       4                                             2-D M-Mode. Doppler.   0          1
#> 5       5                                               2-D Echocardiogram   1          0
#>   Consult Doppler Echocardiogram allergies complaint laparoscopic gastric bypass white female
#> 1       0       0              0         1         1                           0            1
#> 2       1       0              0         0         0                           1            0
#> 3       1       0              0         0         0                           1            0
#> 4       0       1              0         0         0                           0            0
#> 5       0       0              1         0         0                           0            0
```

## Binding entity embeddings to a data frame (without the UMLS linker)

With the UMLS linker disabled, entity embeddings can be extracted from
the scispacy Python package. Up to 200-dimensional embeddings can be
returned.

``` r
bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                          text = 'description',
                          num_embeddings = 5)
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=============================                                                         |  33%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description    emb_001
#> 1       1 A 23-year-old white female presents with complaint of allergies. -0.1959790
#> 2       2                         Consult for laparoscopic gastric bypass. -0.1115363
#> 3       3                         Consult for laparoscopic gastric bypass. -0.1115363
#> 4       4                                             2-D M-Mode. Doppler. -0.3077586
#> 5       5                                               2-D Echocardiogram  0.0248010
#>      emb_002     emb_003     emb_004    emb_005
#> 1 0.28813400  0.09685702 -0.20641684 -0.1554238
#> 2 0.01725144 -0.13519235 -0.05496463  0.1488807
#> 3 0.01725144 -0.13519235 -0.05496463  0.1488807
#> 4 0.25928350 -0.37220851 -0.06021732  0.0386426
#> 5 0.32503700 -0.28739650  0.01444300  0.3118135
```

## Adding the UMLS linker

If you would like the UMLS linker to be enabled by default, then there
is no need for

``` r
clinspacy_init(use_linker = TRUE)
#> Loading the UMLS entity linker... (this may take a while)
#> Adding the UMLS entity linker to the spacy pipeline...
#> NULL
```

## Named entity recognition (with the UMLS linker)

By turning on the UMLS linker, you can restrict the results by semantic
type.

``` r
clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#> Processing... This patient has diabetes and CKD stage 3 but no HTN.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================                                                                |  25%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |================================================================                      |  75%  |                                                                                              |======================================================================================| 100%
#>        cui      entity       lemma             semantic_type                      definition
#> 1 C0030705     patient     patient Patient or Disabled Group                        Patients
#> 2 C1550655     patient     patient            Body Substance         Specimen Type - Patient
#> 3 C1578485     patient     patient      Intellectual Product Specimen Source Codes - Patient
#> 4 C1578486     patient     patient      Intellectual Product  Disabled Person Code - Patient
#> 5 C1705908     patient     patient                  Organism              Veterinary Patient
#> 6 C0011847    diabetes    diabetes       Disease or Syndrome                        Diabetes
#> 7 C0011849    diabetes    diabetes       Disease or Syndrome               Diabetes Mellitus
#> 8 C2316787 CKD stage 3 ckd stage 3       Disease or Syndrome  Chronic kidney disease stage 3
#> 9 C0020538         HTN         htn       Disease or Syndrome            Hypertensive disease
#>   negated
#> 1   FALSE
#> 2   FALSE
#> 3   FALSE
#> 4   FALSE
#> 5   FALSE
#> 6   FALSE
#> 7   FALSE
#> 8   FALSE
#> 9    TRUE

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Pharmacologic Substance')
#> Processing... This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |============                                                                          |  14%  |                                                                                              |=========================                                                             |  29%  |                                                                                              |=====================================                                                 |  43%  |                                                                                              |=================================================                                     |  57%  |                                                                                              |=============================================================                         |  71%  |                                                                                              |==========================================================================            |  86%  |                                                                                              |======================================================================================| 100%
#>        cui     entity      lemma           semantic_type definition negated
#> 1 C0028978 omeprazole omeprazole Pharmacologic Substance Omeprazole   FALSE
#> 2 C0004057    aspirin    aspirin Pharmacologic Substance    Aspirin   FALSE
#> 3 C0065374 lisinopril lisinopril Pharmacologic Substance Lisinopril   FALSE
#> 4 C0001927  albuterol  albuterol Pharmacologic Substance  Albuterol    TRUE

clinspacy('This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.',
          semantic_types = 'Disease or Syndrome')
#> Processing... This patient with diabetes is taking omeprazole, aspirin, and lisinopril 10 mg but is not taking albuterol anymore as his asthma has resolved.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |============                                                                          |  14%  |                                                                                              |=========================                                                             |  29%  |                                                                                              |=====================================                                                 |  43%  |                                                                                              |=================================================                                     |  57%  |                                                                                              |=============================================================                         |  71%  |                                                                                              |==========================================================================            |  86%  |                                                                                              |======================================================================================| 100%
#>        cui   entity    lemma       semantic_type        definition negated
#> 1 C0011847 diabetes diabetes Disease or Syndrome          Diabetes   FALSE
#> 2 C0011849 diabetes diabetes Disease or Syndrome Diabetes Mellitus   FALSE
#> 3 C0004096   asthma   asthma Disease or Syndrome            Asthma    TRUE
```

## Binding UMLS concept unique identifiers to a data frame (with the UMLS linker)

This function binds columns containing concept unique identifiers with
which scispacy has 99% confidence of being present with values
containing frequencies. Negated concepts, as identified by negspacy’s
NegEx implementation, are ignored and do not count towards the
frequencies.

Note that by turning on the UMLS linker, you can restrict the results by
semantic type.

``` r
bind_clinspacy(mtsamples[1:5, 1:2],
               text = 'description')
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description C0009818 C0013516
#> 1       1 A 23-year-old white female presents with complaint of allergies.        0        0
#> 2       2                         Consult for laparoscopic gastric bypass.        1        0
#> 3       3                         Consult for laparoscopic gastric bypass.        1        0
#> 4       4                                             2-D M-Mode. Doppler.        0        0
#> 5       5                                               2-D Echocardiogram        0        1
#>   C0020517 C0554756 C1705052 C2243117 C3864418 C4039248
#> 1        1        0        0        0        1        0
#> 2        0        0        0        0        0        1
#> 3        0        0        0        0        0        1
#> 4        0        1        0        0        0        0
#> 5        0        0        1        1        0        0

bind_clinspacy(mtsamples[1:5, 1:2],
               text = 'description',
               semantic_types = 'Diagnostic Procedure')
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description C0013516 C0554756
#> 1       1 A 23-year-old white female presents with complaint of allergies.        0        0
#> 2       2                         Consult for laparoscopic gastric bypass.        0        0
#> 3       3                         Consult for laparoscopic gastric bypass.        0        0
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
to multiple concepts).

``` r
bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                          text = 'description',
                          num_embeddings = 5)
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description    emb_001
#> 1       1 A 23-year-old white female presents with complaint of allergies. -0.3446915
#> 2       2                         Consult for laparoscopic gastric bypass. -0.1115363
#> 3       3                         Consult for laparoscopic gastric bypass. -0.1115363
#> 4       4                                             2-D M-Mode. Doppler. -0.4044230
#> 5       5                                               2-D Echocardiogram  0.0408278
#>      emb_002    emb_003     emb_004    emb_005
#> 1 0.31240000  0.1075445 -0.33388351 -0.2601905
#> 2 0.01725144 -0.1351923 -0.05496463  0.1488807
#> 3 0.01725144 -0.1351923 -0.05496463  0.1488807
#> 4 0.21798199 -0.4359590 -0.05181420 -0.0757723
#> 5 0.34547000 -0.3142290  0.08719834  0.2681757

bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                          text = 'description',
                          num_embeddings = 5,
                          semantic_types = 'Diagnostic Procedure')
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description    emb_001  emb_002
#> 1       1 A 23-year-old white female presents with complaint of allergies.         NA       NA
#> 2       2                         Consult for laparoscopic gastric bypass.         NA       NA
#> 3       3                         Consult for laparoscopic gastric bypass.         NA       NA
#> 4       4                                             2-D M-Mode. Doppler. -0.4044230 0.217982
#> 5       5                                               2-D Echocardiogram  0.0728814 0.386336
#>     emb_003    emb_004    emb_005
#> 1        NA         NA         NA
#> 2        NA         NA         NA
#> 3        NA         NA         NA
#> 4 -0.435959 -0.0518142 -0.0757723
#> 5 -0.367894  0.2327090  0.1809000
```

### Cui2vec embeddings (with the UMLS linker)

These are only available with the UMLS linker enabled.

``` r
bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                          text = 'description',
                          type = 'cui2vec',
                          num_embeddings = 5)
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description     emb_001
#> 1       1 A 23-year-old white female presents with complaint of allergies. -0.02252676
#> 2       2                         Consult for laparoscopic gastric bypass. -0.06431815
#> 3       3                         Consult for laparoscopic gastric bypass. -0.06431815
#> 4       4                                             2-D M-Mode. Doppler. -0.06111055
#> 5       5                                               2-D Echocardiogram -0.08545282
#>      emb_002       emb_003      emb_004     emb_005
#> 1 0.00981737 -7.112366e-17 -0.015715369  0.00204883
#> 2 0.02979208 -1.353084e-16 -0.046832239  0.03387485
#> 3 0.02979208 -1.353084e-16 -0.046832239  0.03387485
#> 4 0.03059523 -1.340074e-16 -0.032813400 -0.02400309
#> 5 0.03965676 -4.336809e-17 -0.008077436 -0.04463792

bind_clinspacy_embeddings(mtsamples[1:5, 1:2],
                          text = 'description',
                          type = 'cui2vec',
                          num_embeddings = 5,
                          semantic_types = 'Diagnostic Procedure')
#> Processing... A 23-year-old white female presents with complaint of allergies.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |=========================================================                             |  67%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... Consult for laparoscopic gastric bypass.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D M-Mode. Doppler.
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |======================================================================================| 100%
#> Processing... 2-D Echocardiogram
#>   |                                                                                              |                                                                                      |   0%  |                                                                                              |===========================================                                           |  50%  |                                                                                              |======================================================================================| 100%
#>   note_id                                                      description     emb_001
#> 1       1 A 23-year-old white female presents with complaint of allergies.          NA
#> 2       2                         Consult for laparoscopic gastric bypass.          NA
#> 3       3                         Consult for laparoscopic gastric bypass.          NA
#> 4       4                                             2-D M-Mode. Doppler. -0.06111055
#> 5       5                                               2-D Echocardiogram -0.08545282
#>      emb_002       emb_003      emb_004     emb_005
#> 1         NA            NA           NA          NA
#> 2         NA            NA           NA          NA
#> 3         NA            NA           NA          NA
#> 4 0.03059523 -1.340074e-16 -0.032813400 -0.02400309
#> 5 0.03965676 -4.336809e-17 -0.008077436 -0.04463792
```

# UMLS CUI definitions

``` r
data(cui2vec_definitions)
head(cui2vec_definitions)
#>        cui                         semantic_type                         definition
#> 1 C0000005       Amino Acid, Peptide, or Protein     (131)I-Macroaggregated Albumin
#> 2 C0000005               Pharmacologic Substance     (131)I-Macroaggregated Albumin
#> 3 C0000005 Indicator, Reagent, or Diagnostic Aid     (131)I-Macroaggregated Albumin
#> 4 C0000039                      Organic Chemical 1,2-Dipalmitoylphosphatidylcholine
#> 5 C0000039               Pharmacologic Substance 1,2-Dipalmitoylphosphatidylcholine
#> 6 C0000052       Amino Acid, Peptide, or Protein  1,4-alpha-Glucan Branching Enzyme
```
