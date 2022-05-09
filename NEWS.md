# miRacumDQA NEWS

## Unreleased (2022-05-09)

#### New Features

* added laboratory values; enhanced sqls for i2b2 and fhir
* working on fhir sqls
* adding more dataelements (wip)
* added cache of 1 day for mdr
* added more data elements
* added further dataelements
* working on re-adding omop; added to mdr
* working on adaption of dehub mdr
* working on mdr downloading
* connecting dehub mdr via reticulate with r
* working on dehup adaption
* working on mdr upload
* working on dehub adaptions; wip
#### Fixes

* added data elements to be tested to dqamdr_config.py
* fixed error in fachabteilung-fhir sql
* fixed utf8 typo
* fallback to local mdr file if api does not return sufficient rows
* fixed datatype of fachabteilung
* re-added data.table import for datamap sending
* fixed loading mdr from new dehub-dev
* working on issue with escaped slashes (wip)
* updated logic to append old slots when updating; furthermore now only consider wanted datalements
* updated sql statements to new fhir paths
* fixed downloading of clean mdr and preparation with dqa specific information
* corrected reference to `DQAgui`
* typo in dependency `DQAgui`
* removed custom reset due to shiny errors
* updated omop sqls
* distinct gender with patid
* updated dt.hospitalization
* updated dt.hospitalization sql in fhir-gw
* sending data to datamap in headless mode caused crashes
* don't display a gui warning if headles==true
#### Refactorings

* revised sql statements for fhir and i2b2
* enhanced labor-statement
* reworked fhir sqls
* switching from dizutils to diztools
#### Docs

* updated readme
#### Others

* updated news.md and rbuildignore
* updated news.md
* updated devstuffs to get auto-changelog working again
* updated news.md
* updated misspelled urls from readme and description
* removed unneeded dependencies; fixed subtitle in markdown
* updated news.md
* added error messages and feedback details
* removed mdr_legacy.csv
* updated news.md
* added diztools version
* updated news.md
* updated formatting of i2b2 sql
* merged feat_new_coreds_python into development
* updated debugging-script
* comments to upload script
* updated news.md
* updated data range in license statement
* revised adding of remotes in devstuffs
* updated news.md
* updated news.md
* implementing new value_set (downstream to dqagui/dqastats)
* creating news.md; allow in gitignore; addctoryed to rbuildignore
* added tic.R
* now really really added gha
* now really added gha
* added gha

Full set of changes: [`v2.1.2...ebb9f9b`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.1.2...ebb9f9b)

## v2.1.2 (2021-07-02)

#### New Features

* added date format to fhirgw in the mdr
* added db_scheme to mdr-column for table_name
* modified mdr to `restricting_date_var`
#### Fixes

* updated fhir sqls
* romveing empty rows from influx export
* made influxdb export work agaon
* changed default date format from plain to json
* changed dqagui dep to dev
* changed date format for i2b2 date-cols
#### Refactorings

* speed improvements in sql
* added markdown to suggests due to error in knitr
#### Others

* updated ci token name
* moved to central ci-config
* first commit after release
* linting stuff
* excluded ci folder from r build
* preparation for new release
* switched back to slower sql due to jdbc version incompatibility
* updated mdr import for samply
* updated mdr
* removed p21csv and restricting data for p21staging
* moving towards date-restriction
* added analysis period to output markdown
* updated license date
* added newpages before new sections
* added R version to gui

Full set of changes: [`v2.1.1...v2.1.2`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.1.1...v2.1.2)

## v2.1.1 (2021-02-19)

#### Refactorings

* preparation for new release
#### Others

* added `docker:git` as image for release-build
* updated ci to also run for new tags
* updated ci
* updated ci for new harbor and base_image
* siwtched to dqa_base_image
* simplified ci, removed dqastats-tag, dqagui-tag, dizutils-tag

Full set of changes: [`v2.1.0...v2.1.1`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.1.0...v2.1.1)

## v2.1.0 (2020-05-07)


Full set of changes: [`v2.0.8...v2.1.0`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.8...v2.1.0)

## v2.0.8 (2020-04-28)


Full set of changes: [`v2.0.7...v2.0.8`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.7...v2.0.8)

## v2.0.7 (2020-04-21)


Full set of changes: [`v2.0.6...v2.0.7`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.6...v2.0.7)

## v2.0.6 (2020-03-20)


Full set of changes: [`v2.0.5...v2.0.6`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.5...v2.0.6)

## v2.0.5 (2020-03-16)


Full set of changes: [`v2.0.4...v2.0.5`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.4...v2.0.5)

## v2.0.4 (2020-02-25)


Full set of changes: [`v2.0.3...v2.0.4`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.3...v2.0.4)

## v2.0.3 (2020-01-30)


Full set of changes: [`v2.0.2...v2.0.3`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.2...v2.0.3)

## v2.0.2 (2019-11-15)


Full set of changes: [`v2.0.1...v2.0.2`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.1...v2.0.2)

## v2.0.1 (2019-11-12)


Full set of changes: [`v2.0.0...v2.0.1`](https://gitlab.miracum.org/miracum/dqa/miracumdqa/compare/v2.0.0...v2.0.1)

## v2.0.0 (2019-09-27)

