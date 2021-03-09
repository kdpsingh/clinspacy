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
