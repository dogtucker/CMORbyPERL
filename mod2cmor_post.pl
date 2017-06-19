#!/usr/bin/perl
use strict;
use warnings;

# This code renames files prepared by mod2cmor_main.pl according to AEROCOM convention
# Author: NAJ Schutgens
# Affil : University of Oxford
# Date  : March 2014

# Execute the code as follows: ./cmor2mod_post.pl
# Below the user can define a directory where the output from mod2cmor_mian.pl can be found 
# and a directory where results can be written. 
#
# This code uses filename templates to find appropriate files. Currently acceptable names are:
# - {experiment name}_{year}{month}.01_{stream}_{variable name}.nc
# - {experiment name}_{year}_{stream}{period}_{variable name}.nc
#
# Currently, the code does the following:
# - Loops over all files and selects only NetCDF files
# - Parses filename and renames file
#
# Common AEROCOM file naming convention is:
# aerocom_<ModelName>_<ExperimentName>_<VariableName>_<VerticalCoordinateType>_<Period>_<Frequency>.nc 
# where
#   <VerticalCoordinateType> => "Surface", "TOA", "Column", "ModelLevel" 
#   <Period> => "2008", "2010", ...  
#   <Frequency> => "timeinvariant","hourly", ,"3hourly", "daily", "monthly" 
#
# Todo


### START: user defined constants ##############################################
# model name
my $modelname   = "ECHAM5.5HAM2.0";

# Extra info added to global attributes
my $info_exp     = "hindcast experiment (1980-2008); ACCMIP-MACCity emissions; nudged to ERAIA.";
my $info_contact = "Nick Schutgens (schutgens\@physics.ox.ac.uk)";

# output frequency of the {EXP}_{YEAR}{MONTH}.01 files
my $frequency01 = "monthly";

# directories
my $in  = "tmp"; # Location for output of mod2cmor_main.pl
my $out = "out"; # Final results: CMORized data!!
### END: user defined constants ################################################



### Main code ### [DO NOT CHANGE] ##############################################

# Read all files present in $in
opendir(DIR,$in) or die;
my @files = readdir(DIR);
closedir(DIR);

# Loop over files and rename based on regex
foreach my $file (@files) {
  next if !($file =~ m/\.nc$/); # skip if file is not netcdf
  print "Renaming ${file}\n";

# Add new global attributes
  `ncatted -hO -a info_exp,global,c,c,"${info_exp}" ${in}/${file}`;
  `ncatted -hO -a info_contact,global,c,c,"${info_contact}" ${in}/${file}`;

# Attempt to parse filenames
  my $expname   = undef;
  my $period    = undef;
  my $frequency = undef;
  my $vertcoord = undef;
  my $varname   = undef;
  if ($file =~ m/(.+)\_(\d{4})\_\w+\_(\w+)\_(.+)\_(.+)\.nc/) {
    $expname   = $1;
    $period    = $2;
    $frequency = $3;
    $vertcoord = $4;
    $varname   = $5;
  } # conditional
  if ( ($file =~ m/(.+)\_(\d{6})\.01\_.+\_(.+)\_(.+)\.nc/) or
       ($file =~ m/(.+)\_(\d{6})\_aux\_.+\_(.+)\_(.+)\.nc/) ) {
    $expname   = $1;
    $period    = $2;
    $frequency = $frequency01;
    $vertcoord = $3;
    $varname   = $4;
  } # conditional

# Check if we have all information and rename file, else print a warning
  if (defined($expname) and defined ($period) and defined($frequency) and defined($varname) and defined($vertcoord)) {
    `cdo -s copy ${in}/${file} ${out}/${modelname}_${expname}_${varname}_${vertcoord}_${period}_${frequency}.nc`;
#    `rm ${in}/${file}`;
  } else {
    print "  cannot parse filename:\n";
    print "    unknown experiment name\n" if (undef($expname));
    print "    unknown period\n"          if (undef($period));
    print "    unknown frequency\n"       if (undef($frequency));
    print "    unknown variable name\n"   if (undef($varname));
  } # conditional

} # loop: $file



