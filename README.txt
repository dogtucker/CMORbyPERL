Software package to convert ECHAM-HAM output into CMOR-conform AEROCOM format
What this code DOES NOT DO: 1) it does not average output over longer periods; 2) it does not merge output over different periods into a single file.

Use of this package requires installs of nco and cdo

Package consists of 4 files (3 scripts and one database):
  mod2cmor_pre.pl
  mod2cmor_main.pl + mod2cmor.database
  mod2cmor_post.pl

Package install:
  1) Copy these files to a new directory
  2) Create sub-directores "in", "tmp" and "out"
  3) make changes to mod2cmor_pre.pl and mod2cmor.database, if required
  4) Copy (or link) ECHAM-HAM data to "in"

Execution (in sequence):
  1) ./mod2cmor_pre.pl
  2) ./mod2cmor_main.pl
  3) ./mod2cmor_post.pl
  We suggest to redirect standard & error output to a file ('>&') to keep a log  

Explanation:

mod2cmor_pre.pl (reads and writes to "in", uses "tmp" but cleans up "tmp" afterwards):
Some required variables do not exists as standard output and have to be constructed from ECHAM-HAM output. E.g. wet deposition of DU aerosol (wdep_DU) is the sum of wdep_DU_AI+wdep_DU_AS+wdep_DU_CI+wdep_DU_CS. mod2cmor_pre.pl creates a new stream (called aux, in "in" directory) that contains these constructed variables. Adding or changing constructed variables is easy, see mod2cmor_pre.pl

mod2cmor_main.pl (read from "in", writes to "tmp"):
ECHAM-HAM variables will need to be split off from their stream, renamed, and rescaled. In addition, long & short names as well min/max values need to be defined. All this is done by mod2cmor_main.pl, which creates a single file per variable in the "tmp" directory. Information on which variables to use and how to rename etc them is contained in mod2cmor.database. This database is based on Aerocom_table_2D-M.txt and Aerocom_table_3D-M.txt files

mod2cmor_post.pl (reads from "tmp", writes to "out"):
AEROCOM specifies a particular format for filenames. mod2cmor_post.pl renames the output from mod2cmor_main.pl according to that format. In addition, users can specify some extra information by modyfing the code, in particular by modifying the following: "modelname", "info_exp", "info_contact", "frequency01".

mod2cmor.database:
This file contains information on which ECHAM-HAM variables correspond to which CMOR variables. It also defines short and long-names as well as potential multiplication factors and offsets (the latter two are ignored if not present). If 'modvar' and 'stream' are empty then no action is taken for that particualr entry. The information in mod2cmor.database is used by mod2cmor_main.pl.

