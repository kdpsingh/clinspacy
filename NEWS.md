# clinspacy 0.1.0.9002
* Added a `NEWS.md` file to track changes to the package.
* bind_* functions no longer run clinspacy_init() -- this should speed up load times

# clinspacy 0.2.0.9000
* Added `NA` to `semantic_types` argument for both `clinspacy()` and `clinspacy_single()` to prevent tokens from being discarded if they do not match a listed semantic type.
* Moved `clinspacy_single()` logic into `lapply()` instead of gradually building a list using a `for` loop for boost in speed
* Moved progress bar to `clinspacy()` so that it iterates over documents rather than tokens

# clinspacy 0.2.0 (2021-02-22)
* Changed lifecycle badge to stable

# clinspacy 1.0.0 (2021-02-23)
* Bumped version number to 1.0.0 since it's ready for CRAN submission

# clinspacy 1.0.1 (2021-03-08)
* Bug fix: removed unnecessary arguments and some clean up in prep for CRAN submission

# clinspacy 1.0.2 (2021-03-18)
* Fixed documentation prior to CRAN submission based on feedback
* Bug fix: Specified version numbers for spaCy (2.3.0), scispaCy (0.2.5), and medspaCy (0.1.0.2) to ensure that the versions are compatible with one another
* Bug fix: spaCy 2.3.0 must be installed from conda-forge (`pip` set to `FALSE`) because the source fails to build properly on Windows even with Visual C++ build tools installed
* Update: Switched to using medspaCy instead of its individual components because medspaCy 0.1.0.2 is compatible with spaCy 2.3.0 (an older version was not).
* Bug fix: changed `section_title` to `section_category` due to updates in medspaCy sectionizer API
* Known issue: After first running `clinspacy_init()` on Windows, sometimes it cannot find `numpy`. This is a known issue with `reticulate` [https://github.com/rstudio/reticulate/issues/367](https://github.com/rstudio/reticulate/issues/367). Restarting the R session and re-running `clinspacy_init()` appears to fix the issue
