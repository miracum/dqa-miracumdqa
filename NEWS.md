# miRacumDQA NEWS

## Unreleased (2022-08-30)

#### CI

-   added deps for devtools
    ([dfda09d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/dfda09d0def1408c0d82ca2d40296333ec5814d4))

#### Other changes

-   updated dev-tag
    ([95f2b4d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/95f2b4d535bfde4d951c6db21fb7238f2774d8d6))

Full set of changes:
[`v3.1.0...dfda09d`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v3.1.0...dfda09d)

## v3.1.0 (2022-07-04)

#### New features

-   updated i2b2 sqls; closes \#33
    ([1de1b42](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/1de1b42f39cf017ebe050088f8f762e9ab13153b))
-   remove schema from sql statements
    ([489cc68](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/489cc689800b79cae9a6938bf9c1b954374b4e46))
-   more atemporal plausibilities
    ([0a87632](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/0a87632af960bcb619d33465cd5e5343e1f14344))

#### Bug fixes

-   update mdr i2b2 start date
    ([1ff737c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/1ff737cc402b3976e7a39b6987d811c116810091))
-   moving i2b2 to sql-modify; addresses \#33
    ([b336261](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/b336261b93a35358a32f0c8e2bab31f76825b382))
-   fixed issue with i2b2 plausi regex
    ([63d8f75](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/63d8f7510a2ed4f106c5e1636a5418275c07f8aa))

#### Refactorings

-   updated sqls of i2b2 to exclude null values and to be conform with
    fhir
    ([aae3f69](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/aae3f69d028d61b4852fe700a92fa6f22e9d6c71))

#### CI

-   updated gha
    ([0ab2376](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/0ab2376d0b158827b00f385d97bf0f820a1a1903))

#### Other changes

-   preparing release v3.1.0
    ([b922b59](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/b922b590ade09a42b5bcb79bc7db1f4b0fa98254))
-   updated news.md
    ([461c6d8](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/461c6d8bb952d3b1686583c9f3ed3ba595ef70da))
-   updated news.md
    ([b370a03](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/b370a0380cf179f235d1efc437996a86748435a6))
-   updated news.md
    ([a0ddbf6](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a0ddbf6c806fb9a0c46d0053355419b3cb9f4231))
-   replaced “data system” with “database”
    ([9e4f31d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/9e4f31d256818b3cd38cc73b7aa740a25d52d32c))
-   changed “Completeness” to “Completeness Checks” in the GUI
    ([12208e1](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/12208e17e4567b5e05837b3e364860fde8eb0cc9))
-   updated description
    ([1b9f024](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/1b9f024a50a17928e8ca3d4f87289898a0d83840))
-   updated news.md
    ([d349765](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/d349765243e0ac414bfe6054be503f4f7ef53d39))
-   updated dev version
    ([7253284](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/7253284faf0218c5e2535a3c0294e8edcfdc362c))

Full set of changes:
[`v3.0.0...v3.1.0`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v3.0.0...v3.1.0)

## v3.0.0 (2022-05-20)

#### New features

-   added preparation for logo
    ([d9697f2](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/d9697f2d41b8e120f7274ed905970c63a9fa2ce9))
-   added laboratory values; enhanced sqls for i2b2 and fhir
    ([2212c92](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/2212c9269fcebfc23d9afb8e3b3496261195b67e))
-   working on fhir sqls
    ([90d2073](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/90d207343a9b36fff4bcca9340ce1a4a4f337710))
-   adding more dataelements (wip)
    ([6a0f179](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/6a0f1791325a8d24f67ac5ef16a8f19e03ba2f0c))
-   added cache of 1 day for mdr
    ([b53cd7f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/b53cd7f0b72cff468e0090f48f4c316b8b10c6e7))
-   added more data elements
    ([f99399b](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/f99399b8994e70b3d895f785e65772eb1cb586a1))
-   added further dataelements
    ([e98743f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/e98743f3d3bd0b0974417d56b22fdd4ba33a9467))
-   working on re-adding omop; added to mdr
    ([e6e738a](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/e6e738a586efea99861128699612f7c9d5c71104))
-   working on adaption of dehub mdr
    ([a5d2550](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a5d2550ff86220d897ab953e1ae4304003327dd7))
-   working on mdr downloading
    ([9246d51](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/9246d51b3c62abf5ed823accb0260ded213dda78))
-   connecting dehub mdr via reticulate with r
    ([13844a2](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/13844a2027eddbeedf08b065d0ea2183ead76b53))
-   working on dehup adaption
    ([4b5ce04](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/4b5ce0400a8248fcecdc66077e1898e05b239ed7))
-   working on mdr upload
    ([8734d4f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/8734d4f0acae062ca9f59a80c3f60328f15a35c5))
-   working on dehub adaptions; wip
    ([5fe6885](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/5fe68855ece4de994a6941353fa223d912a9322d))

#### Bug fixes

-   updated constraints for kontaktklasse
    ([1451fd0](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/1451fd066625943f9479aab6dd6bd48c874ff488))
-   added data elements to be tested to dqamdr\_config.py
    ([066f783](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/066f7830d7c86cfb1025cb0b91ce92629bf2f1c2))
-   fixed error in fachabteilung-fhir sql
    ([26b6c87](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/26b6c8765225fffa8c72be8c3c980010ae2de6dc))
-   fixed utf8 typo
    ([b301c25](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/b301c25a57f6d64c2a0cf1d23323f33420c2ab85))
-   fallback to local mdr file if api does not return sufficient rows
    ([98a632a](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/98a632a78572a39533d8e6082e75f5dad3aa11a5))
-   fixed datatype of fachabteilung
    ([eb0dd6e](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/eb0dd6e671448aaa4e6f0397ac4d8303722a8899))
-   re-added data.table import for datamap sending
    ([feae6a3](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/feae6a349ee2571a6d7a3f40152b827e0ad907dd))
-   fixed loading mdr from new dehub-dev
    ([83daf16](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/83daf16e8d5319c0cf82ef92736dedbc5b8e9da9))
-   working on issue with escaped slashes (wip)
    ([96830b8](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/96830b8aaf60388d58f1d09b9ea97acea24b55c5))
-   updated logic to append old slots when updating; furthermore now
    only consider wanted datalements
    ([261ee6e](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/261ee6e8cd2cbbcc06d3a8ab9c317b015324f6f6))
-   updated sql statements to new fhir paths
    ([1e06191](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/1e061918a74e6cea2cf1c041b8dd66cca3492cf0))
-   fixed downloading of clean mdr and preparation with dqa specific
    information
    ([2b06105](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/2b0610585262b668337ea2fd94b5aaf1de38ddc8))
-   corrected reference to `DQAgui`
    ([0652bdd](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/0652bdd57447df788af909dacc689104eae8d479))
-   typo in dependency `DQAgui`
    ([614940a](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/614940a4bdd4d8657abc142b3da58d911b58d3a1))
-   removed custom reset due to shiny errors
    ([6f64bd4](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/6f64bd4de0ebc18c9d81e32c6257d2042cce81fe))
-   updated omop sqls
    ([1a781f7](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/1a781f7fefe4580594492337cd1719f910f243a0))
-   distinct gender with patid
    ([367a2aa](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/367a2aa6a1c6c6921fd17b84afb458f4df3c2714))
-   updated dt.hospitalization
    ([3c18ce6](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/3c18ce6e6e41e4a33f50a89686628df899530331))
-   updated dt.hospitalization sql in fhir-gw
    ([71fa4d9](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/71fa4d97f931b0895089bd0fc5c7d400d69d2582))
-   sending data to datamap in headless mode caused crashes
    ([df1d537](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/df1d537c5ed49da3eba5e00d9d28b636fe2a739a))
-   don’t display a gui warning if headles==true
    ([40ff47c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/40ff47c74d96033e3a5f78ca1e129f8165497715))

#### Refactorings

-   revised sql statements for fhir and i2b2
    ([62fc60b](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/62fc60b93d3ff31f67b110283f8adbcee695c251))
-   enhanced labor-statement
    ([3b20460](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/3b204600747f371db02a2f164e04571ed1531048))
-   reworked fhir sqls
    ([60166c5](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/60166c5b47b12ce08ac4078fc339788794233e42))
-   switching from dizutils to diztools
    ([88cefad](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/88cefada657bb74fa2bd0d4efa81054a6d941de4))

#### Tests

-   added tic.R
    ([ebb9f9b](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/ebb9f9bfdd29b8fd1df3659144b9679b3e7d13af))
-   now really really added gha
    ([a38d04f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a38d04f5f98f29ded3a414cedd696e3544fc9c4a))
-   now really added gha
    ([3ffc27f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/3ffc27f943787f840422a89b1b77ff1f4e776d33))
-   added gha
    ([59884e5](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/59884e5192768ff36e407f249261d1ec96551419))

#### Docs

-   updated readme
    ([3c38d1c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/3c38d1ca86d376558047884dcb78d6c2a9694563))

#### Other changes

-   updated version to 3.0.0
    ([6522aa0](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/6522aa0adc1427463df41368fd81b4a81bb73003))
-   updated news.md
    ([d422726](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/d422726c014ab0453036af296bc37684ad84f146))
-   updated news.md
    ([e9981e3](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/e9981e30c2ecc745b9fc76d337ce953ca1b5b4bd))
-   added tic.R to rbuildignore
    ([5058928](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/5058928b8ff0ce9b38fedc01a5f9de202c8f2b7b))
-   always applying dqastats::read\_mdr on imported mdr to apply all
    implemented rules
    ([24dd4e1](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/24dd4e17dcbc92e070ab1b1b8cfd6759afbd4b35))
-   added logo to app title
    ([8aa8c13](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/8aa8c134bfbce2b350a6a20dbc00aa20d67422a6))
-   removed badges from readme
    ([ba46f7d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/ba46f7d89d1d64da7ffdc7948758dc4a955e805a))
-   updated news.md and rbuildignore
    ([24fd55f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/24fd55f92783ffe9ed2f34988cb7d6e32ec53364))
-   updated news.md
    ([68346a0](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/68346a05ac10a6173e5e45e6cde44aea359008a6))
-   updated devstuffs to get auto-changelog working again
    ([015637d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/015637d1c357306fc037c1054a1f96307eb1c718))
-   updated news.md
    ([6f98857](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/6f9885725a4c081587c9fe04824039be3c948211))
-   updated misspelled urls from readme and description
    ([5610204](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/5610204056d21560330bb833a2f52ef0d0e34325))
-   removed unneeded dependencies; fixed subtitle in markdown
    ([965957c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/965957c2f3389a6871e06b92a457ecc9ab3750c2))
-   updated news.md
    ([c151626](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/c151626d3bbfc9023839d8da0664feae66f22b20))
-   added error messages and feedback details
    ([3973ae7](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/3973ae7e52ce69b1cf85083d6d15ee8c99cab11d))
-   removed mdr\_legacy.csv
    ([7ff3883](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/7ff388392764f30d8c71ea9bf4d00045b870f60a))
-   updated news.md
    ([f8390e4](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/f8390e4194c56aba80e8b62195eea04ae824e6fa))
-   added diztools version
    ([29ba00b](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/29ba00bf72d5c7d023154fb7e0ef0c4e797d9b0f))
-   updated news.md
    ([5cbd294](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/5cbd294ff8968ff345dce6f8f91c80c150733bd4))
-   updated formatting of i2b2 sql
    ([10be45a](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/10be45abc4196d009b9712c7feb095c7394f118e))
-   merged feat\_new\_coreds\_python into development
    ([4392d38](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/4392d3859af4472ea6d6738357a9af47dff671fc))
-   updated debugging-script
    ([cdec8e0](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/cdec8e0da5fe9297f32d5d9a7d8577f0a600a5cc))
-   comments to upload script
    ([9217f25](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/9217f257d40820a533b71711fa4717ab3a4f6022))
-   updated news.md
    ([7864a4f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/7864a4f7c3b857c79e5ae6d565f379512df8ac6c))
-   updated data range in license statement
    ([cda9d94](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/cda9d94655cf137ecc383add8d50c713c5fb6e9a))
-   revised adding of remotes in devstuffs
    ([d4fdab4](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/d4fdab4132f021784432adda34959e00b0de5158))
-   updated news.md
    ([a5828c1](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a5828c187ab54b1ef325a882eae3804af48b13f1))
-   updated news.md
    ([a78768c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a78768c286f20af58b21d63cef8d89c2f5e6175c))
-   implementing new value\_set (downstream to dqagui/dqastats)
    ([f5070b5](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/f5070b531d4bd033796452e5263cddcf0eed6204))
-   creating news.md; allow in gitignore; addctoryed to rbuildignore
    ([bbba955](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/bbba955ccc102cb2556c14b77fc71bc3abffc84c))

Full set of changes:
[`v2.1.2...v3.0.0`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.1.2...v3.0.0)

## v2.1.2 (2021-07-02)

#### New features

-   added date format to fhirgw in the mdr
    ([a3e4737](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a3e47370bf5a9740675cfd0cd9a724037eac5319))
-   added db\_scheme to mdr-column for table\_name
    ([6c37cd6](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/6c37cd62e165048ff64b41d41854f6741b874757))
-   modified mdr to `restricting_date_var`
    ([20e7baf](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/20e7baf6d59f8fa493f264268e8a4ad1df156641))

#### Bug fixes

-   updated fhir sqls
    ([049384d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/049384d6a5ee65a731704f98bd8bcac154e146ad))
-   romveing empty rows from influx export
    ([22b75d8](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/22b75d89fd0f0550017cf2f8828e1191f7a1b8f3))
-   made influxdb export work agaon
    ([b78219f](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/b78219f03ceb558d8476de170b0bc8c74f5263b3))
-   changed default date format from plain to json
    ([70ec411](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/70ec4111b8761964b0dddb9b9e35e5ecc9c528de))
-   changed dqagui dep to dev
    ([672eba2](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/672eba20c6b285c8fc4556e18048cb3e30d48582))
-   changed date format for i2b2 date-cols
    ([24a82b3](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/24a82b3e0f9286a90a6b854471fc3f4b63347643))

#### Refactorings

-   speed improvements in sql
    ([2525bf9](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/2525bf9eeb4cc50de8cf83427ddb78218564dd83))
-   added markdown to suggests due to error in knitr
    ([e77b233](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/e77b2330eec2fbf30cc7489ab76be58b94065d2b))

#### CI

-   updated ci token name
    ([aa12f2a](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/aa12f2a8eeb17df62b055c7acd3d4607ab633aa0))
-   moved to central ci-config
    ([9bbf4de](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/9bbf4de6dcd323f8a0f6990313c41d8bc85a37cb))

#### Style

-   added newpages before new sections
    ([642b25c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/642b25c5eaa3a5ae4fb798ebb0f01b97319d934e))
-   added R version to gui
    ([9a00427](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/9a004272bb4a5a45d2d288b699e82417e2ba478c))

#### Other changes

-   first commit after release
    ([eebbbed](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/eebbbeda5eac606b54105660f6f2011f2eb9dc85))
-   linting stuff
    ([243f9c8](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/243f9c894a31302095e4610d90e5a180ff145a87))
-   excluded ci folder from r build
    ([4379e1d](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/4379e1d727a443f5d1087582de13a758ce49ee53))
-   preparation for new release
    ([a46e3a3](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/a46e3a36131a3a46bb8150aab6ac2ffd14643135))
-   switched back to slower sql due to jdbc version incompatibility
    ([2be3955](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/2be39554df5d0a2371352041164bfec2067a8b7c))
-   updated mdr import for samply
    ([cd2f364](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/cd2f364452accccc63e7773165d0154f07db5230))
-   updated mdr
    ([6a9e32a](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/6a9e32ad475e9b9b22233ed4f9295bda1b45de1a))
-   removed p21csv and restricting data for p21staging
    ([cb16f56](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/cb16f5612f5df089458be7d0716014d56b0e32c6))
-   moving towards date-restriction
    ([7121ea2](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/7121ea2c1a6bb2c0602e2e9c82a189a465c617f7))
-   added analysis period to output markdown
    ([4ccf9e7](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/4ccf9e7a3a02440188c8323d263e8bb1387e8c1c))
-   updated license date
    ([092c21c](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/092c21c5eb47ed7c38408ef69fd2aad585b3cc0d))

Full set of changes:
[`v2.1.1...v2.1.2`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.1.1...v2.1.2)

## v2.1.1 (2021-02-19)

#### Refactorings

-   preparation for new release
    ([9a8a656](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/9a8a656f6a646f378304a985c5ab2b58a5de28c9))

#### CI

-   added `docker:git` as image for release-build
    ([06249d6](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/06249d6745a3ed7449f82797cab26030cdaeecdf))
-   updated ci to also run for new tags
    ([ae7cb93](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/ae7cb93eab41f9b2b08b46973769a746067b487e))
-   updated ci
    ([dd737ed](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/dd737ed3384e7f3dc35fac49a61be3cf9dbe7c96))
-   updated ci for new harbor and base\_image
    ([2813fa8](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/2813fa84898cf6a129dabc03b3615f57ade5c596))
-   siwtched to dqa\_base\_image
    ([c0b4794](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/c0b479481c79c7e14349cd39bddd51fa93bfb9bd))
-   simplified ci, removed dqastats-tag, dqagui-tag, dizutils-tag
    ([424adc9](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/tree/424adc923f1436c0e071863dd6eb0015fe1ea5c2))

Full set of changes:
[`v2.1.0...v2.1.1`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.1.0...v2.1.1)

## v2.1.0 (2020-05-07)

Full set of changes:
[`v2.0.8...v2.1.0`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.8...v2.1.0)

## v2.0.8 (2020-04-28)

Full set of changes:
[`v2.0.7...v2.0.8`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.7...v2.0.8)

## v2.0.7 (2020-04-21)

Full set of changes:
[`v2.0.6...v2.0.7`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.6...v2.0.7)

## v2.0.6 (2020-03-20)

Full set of changes:
[`v2.0.5...v2.0.6`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.5...v2.0.6)

## v2.0.5 (2020-03-16)

Full set of changes:
[`v2.0.4...v2.0.5`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.4...v2.0.5)

## v2.0.4 (2020-02-25)

Full set of changes:
[`v2.0.3...v2.0.4`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.3...v2.0.4)

## v2.0.3 (2020-01-30)

Full set of changes:
[`v2.0.2...v2.0.3`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.2...v2.0.3)

## v2.0.2 (2019-11-15)

Full set of changes:
[`v2.0.1...v2.0.2`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.1...v2.0.2)

## v2.0.1 (2019-11-12)

Full set of changes:
[`v2.0.0...v2.0.1`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v2.0.0...v2.0.1)

## v2.0.0 (2019-09-27)

Full set of changes:
[`v1.3.2.9010...v2.0.0`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.2.9010...v2.0.0)

## v1.3.2.9010 (2019-08-30)

Full set of changes:
[`v1.3.2.9000...v1.3.2.9010`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.2.9000...v1.3.2.9010)

## v1.3.2.9000 (2019-08-20)

Full set of changes:
[`v1.3.1.9006...v1.3.2.9000`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.1.9006...v1.3.2.9000)

## v1.3.1.9006 (2019-08-14)

Full set of changes:
[`v1.3.1.9005...v1.3.1.9006`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.1.9005...v1.3.1.9006)

## v1.3.1.9005 (2019-08-08)

Full set of changes:
[`v1.3.1.9003...v1.3.1.9005`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.1.9003...v1.3.1.9005)

## v1.3.1.9003 (2019-07-19)

Full set of changes:
[`v1.3.1.9001...v1.3.1.9003`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.1.9001...v1.3.1.9003)

## v1.3.1.9001 (2019-07-19)

Full set of changes:
[`v1.3.1.9000...v1.3.1.9001`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/v1.3.1.9000...v1.3.1.9001)

## v1.3.1.9000 (2019-07-19)

Full set of changes:
[`371821e...v1.3.1.9000`](https://gitlab.miracum.org/miracum/dqa/miracumdqa.git/compare/371821e...v1.3.1.9000)
