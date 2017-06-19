#!/usr/bin/perl
use strict;
use warnings;

# This code separates individual variables from their files for further processing (CMORizing)
# Author: NAJ Schutgens
# Affil : University of Oxford
# Date  : February 2014

# Execute the code as follows: ./mod2cmor_main.pl
# Below the user can define a directory where ECHAM-HAM files can be found and a directory
# where results can be written. The user may wish to modify/expand on the database, please 
# see relevant comments in mod2cmor.database
#
# This script depends on cdo (Climate Data Operators) and nco (NetCDF Operators) software.
#
# This code use filename templates to find appropriate files. Currently acceptable names are:
# - *{stream}.nc
# - *{stream}m.nc
# - *{stream}_avg.nc
# - *{stream}_monthly.nc
# - *{stream}_annual.nc
#
# The user can change these templates in the appropriate line in this file (search for 'template')
#
# Currently, the code does the following:
# - Loops over all model variables defined in mod2cmor.database
# - Loops over all relevant files that contain this variable
# - Separates the variable from the file and modifies various attributes
#   1. Separate variable from file
#   2. Rescale variable if necessary           (as defined in mod2cmor.database)
#   3. Add offset to variable if necessary     (as defined in mod2cmor.database)
#   4. Rename units if necessary               (as defined in mod2cmor.database)
#   5. Add comments if required                (as defined in mod2cmor.database)
#   6. Add minimum and maximum values          (as defined in mod2cmor.database)
#   7. 
#   8. Modify new file according to CMOR rules (as defined in mod2cmor.database)
#


### START: user defined constants ##############################################
# Filename templates, there will be prepended with the stream name
my @templates = ( ".nc", "m.nc", "_monthly.nc", "_annual.nc","_avg.nc");

# directories
my $in  = "in";    # ECHAM-HAM output files
my $out = "tmp";   # Results from mod2cmor_main.pl
### START: user defined constants ##############################################



### Main code ### [DO NOT CHANGE] ##############################################

# Database
our @mod2cmor;
do "mod2cmor.database";

# Read all files present in $in
opendir(DIR,$in) or die;
my @files = readdir(DIR);
closedir(DIR);

# Loop over database
foreach my $record (@mod2cmor) {

# Read and check record entries
  my $modvar    = $$record{"modvar"}; # Note: %{$record}->{} is deprecated, %{$record}{} does not work
  if (!defined($modvar))    {die "---\nDatabase record (modvar) not defined"};
  my $stream    = $$record{"stream"};
  if (!defined($stream))    {die "---\nDatabase record (stream) not defined"};
  my $factor    = $$record{"factor"};
  my $offset    = $$record{"offset"};
  my $cmorvar   = $$record{"cmorvar"};
  if (!defined($cmorvar))   {die "---\nDatabase record (cmorvar) not defined"};
  my $std_name  = $$record{"std_name"};
  if (!defined($std_name))  {die "---\nDatabase record (std_name) not defined"};
  my $long_name = $$record{"long_name"};
  if (!defined($long_name)) {die "---\nDatabase record (long_name) not defined"};
  my $units     = $$record{"units"};
  if (!defined($units))     {die "---\nDatabase record (units) not defined"};
  my $valid_min = $$record{"valid_min"};
  if (!defined($valid_min)) {die "---\nDatabase record (valid_min) not defined"};
  my $valid_max = $$record{"valid_max"};
  if (!defined($valid_max)) {die "---\nDatabase record (valid_max) not defined"};
  my $vertcoord = $$record{"vertcoord"};
  if (!defined($vertcoord)) {die "---\nDatabase record (vertcoord) not defined"};
  my $comments  = $$record{"comments"};

# Check if model entries make passable sense
  next if ($modvar eq "" or $stream eq ""); # Nothing to do here, moving on
  print "Separating $modvar from stream $stream\n";

# template for files that contain relevant stream are constructed here
  my @templates4stream = @templates;
  foreach my $template4stream (@templates4stream) {
    $template4stream = "${stream}".$template4stream;
  }

# Loop over all files to find relevant files
  my @files4stream = ();
  foreach my $file (@files) {
    foreach my $template4stream (@templates4stream) {
      if ($file =~ m/_$template4stream/) {
        push (@files4stream,$file); 
      } # conditional
    } # loop: $template4stream
  } # loop: $file

# Loop over relevant files  
  foreach my $file4stream (@files4stream) {
    print "  in file $file4stream\n";
   
    # Test if variable is present in file
    chomp(my @names = `cdo -s showname ${in}/${file4stream}`);
    if (!grep {/$modvar/} @names) {
      print "    ${modvar} NOT PRESENT in this file\n";
      next; # go to next file
    } # conditional

    # Create new filename
    my $newfile4modvar = $file4stream;
    $newfile4modvar =~ s/\.nc/_${vertcoord}_${cmorvar}.nc/;

    # 1. separate variable from file
    `cdo -s selname,${modvar} ${in}/${file4stream} ${out}/tmp_out`;

    # 2. rescale variable as necessary
    if (defined($factor)) {
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `cdo -s mulc,${factor} ${out}/tmp_in ${out}/tmp_out`;
    } # conditional

    # 3. offset variable as necessary
    if (defined($offset)) {
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `cdo -s addc,${offset} ${out}/tmp_in ${out}/tmp_out`;
    } # conditional

    # 4. rename units as necessary
    if (defined($units)) {
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `ncatted -h -a units,"${modvar}",m,c,"${units}" ${out}/tmp_in ${out}/tmp_out`;
    } # conditional

    # 5. Add comment if required
    if (defined($comments)) {
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `ncatted -h -a comments,"${modvar}",o,c,"${comments}" ${out}/tmp_in ${out}/tmp_out`;
    } # conditional

    # 6. Add minimum and maximum values
    if (defined($valid_min)) {
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `ncatted -h -a valid_min,"${modvar}",o,f,"${valid_min}" ${out}/tmp_in ${out}/tmp_out`;
    } # conditional
    if (defined($valid_max)) {
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `ncatted -h -a valid_max,"${modvar}",o,f,"${valid_max}" ${out}/tmp_in ${out}/tmp_out`;
    } # conditional

    # 7. Shift reference time to 1850:01:01T00:00:00
    `mv ${out}/tmp_out ${out}/tmp_in`;
    `cdo -s setreftime,1850-01-01,00:00:00 ${out}/tmp_in ${out}/tmp_out`;

    # 8. conversion according to cmor tables
    # 8a. standard names
    `mv ${out}/tmp_out ${out}/tmp_in`;
    `ncatted -h -a standard_name,"${modvar}",o,c,"${std_name}" ${out}/tmp_in ${out}/tmp_out`;
    # 8b. long names
    `mv ${out}/tmp_out ${out}/tmp_in`;
    `ncatted -h -a long_name,"${modvar}",o,c,"${long_name}" ${out}/tmp_in ${out}/tmp_out`;
    # 8c. units
    `mv ${out}/tmp_out ${out}/tmp_in`;
    `ncatted -h -a units,"${modvar}",o,c,"${units}" ${out}/tmp_in ${out}/tmp_out`;
    # 8d. variable names
    if (${modvar} ne ${cmorvar}) { # rename throws error when modvar=cmorvar
      `mv ${out}/tmp_out ${out}/tmp_in`;
      `ncrename -v "${modvar}","${cmorvar}" ${out}/tmp_in ${out}/tmp_out`;
    }
    # 8e. axes definitions
    # For 2D ECHAM-HAM longitude/latitude fields nothing needs to change

    # 9. Clean up
    `rm -f ${out}/tmp_in`;
    `mv ${out}/tmp_out ${out}/${newfile4modvar}`;

  } # loop: $file4stream
} # loop: $record
