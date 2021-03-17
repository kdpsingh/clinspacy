## Test environments
* local R installation, R 3.6.0
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Resubmission

* I corrected all references to software and APIs in the DESCRIPTION to have single quotes, including converting spaCy to 'spaCy', scispaCy to 'scispaCy', and medspaCy to 'medspaCy'. I made this change to both the title and description sections.

* I added references to the DESCRIPTION file (in the description section) to relevant methods papers related to the underlying 'scispaCy' and 'medspaCy' packages used by this package, as well references to the 'cui2vec' study.

* I added all missing \value and \argument tags to clinspacy_init.Rd, dataset_cui2vec_definitions.Rd, dataset_cui2vec_embeddings.Rd, dataset_mtsamples.Rd, and pipe.Rd

* I am confirming that none of the functions write to the user's home directory, the working directory, or the package directory. Any files that are written by functions are written to the appropriate OS-specific app directory folder, which is identified using the rappdirs package.

* Due to the inclusion of cui2vec data in this package (which is also licensed through an MIT license), I have added Benjamin Kompa, Andrew Beam, and Allen Schmaltz as authors on this package (with their permission) and listed them as copyright holders in the LICENSE file.
