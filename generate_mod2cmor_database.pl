#!/usr/bin/perl
use strict;
use warnings;

# Read AEROCOM 2D table
open INPUT, "<Aerocom_table_2D-M.txt";
my @lines2D = <INPUT>;
close INPUT;
do shift(@lines2D) until ($lines2D[0] =~ m/AEROCOM-ACC Table/);

# Read AEROCOM 3D table
open INPUT, "<Aerocom_table_3D-M.txt";
my @lines3D = <INPUT>;
close INPUT;
do shift(@lines3D) until ($lines3D[0] =~ m/AEROCOM-ACC Table/);

# Combine results from 2D nd 3D
my @lines = (@lines2D, @lines3D);

# Define header for databse file
my @newlines = (
"# This database contains important information used in CMORizing ECHAM-HAM data\n",
"# It links variables to streams and possible modifications, like\n",
"# 1) a linear transformation: factor*variable+offset\n",
"# 2) a renaming of variable units\n",
"#\n",
"# General record structure is\n",
"#  { 'modvar'    => <STRING>,    this is a variable as appearing in an echam-ham output stream\n",
"#    'stream'    => <STRING>,    this is the name of an echam-ham output stream\n",
"#    'factor'    => <REAL>,      this is a real number, used to scale the variable\n",
"#    'offset'    => <REAL>,      this is a real number, used to offset the variable\n",
"#    'cmorvar'   => <STRING>,    this is the CMOR variable name\n",
"#    'std_name'  => <STRING>,    this is the CMOR standard name\n",
"#    'long_name' => <STRING>,    this is the CMOR long name\n",
"#    'units'     => <STRING>,    this is the CMOR unit type of the variable\n",
"#    'valid_min' => <REAL>,      this is the CMOR minimum value (not used)\n",
"#    'valid_max' => <REAL>,      this is the CMOR maximum value (not used)\n",
"#    'vertcoord' => <STRING>,    this is the CMOR vertical cooordinate type\n",
"#   }\n",
"#\n",
"# In the above record, 'modvar' and 'stream' are obligatory.\n",
"# 'factor', 'offset' and 'units' are optional. Default behaviour is:\n",
"# no scaling (factor=1), no offset (offset=0) and no changes in unit name.\n",
"\n",
"\n",
'@mod2cmor = ('."\n"
);

# Loop over contents of AEROCOM table and define output for database
  my $std_name;
  my $units;
  my $long_name;
  my $valid_min;
  my $valid_max;
  my $vertcoord;
for (my $iline=2;$iline<=$#lines-1;$iline++) {
  if ($lines[$iline] =~ m/variable_entry: (.*)/) {
    my $cmorvar = $1;
    $iline++; # Pass by the "!====" line

    do {
      $iline++;
      $std_name  = $1 if ($lines[$iline] =~ m/^standard_name: (.*)/);
      $units     = $1 if ($lines[$iline] =~ m/^units:(.*)/);  
      $long_name = $1 if ($lines[$iline] =~ m/^long_name: (.*)/);
      $valid_min = $1 if ($lines[$iline] =~ m/^valid_min: (.*)/);
      $valid_max = $1 if ($lines[$iline] =~ m/^valid_max: (.*)/);
    } until (($lines[$iline] =~ m/!====/) or ($iline == $#lines-1));

#------------------------------------------------------------------------------
    # The following logic may need tuning from the user. From the data we have
    # read in sofar, the type of vertical coordinate has to be estimated.
    if ($iline <= $#lines2D) {
      $vertcoord = 'Column';
      $vertcoord = 'TOA'     if ($long_name =~ m/(TOA|flux)/); 
      $vertcoord = 'Surface' if ($long_name =~ m/(surface|emission|deposition|precipitation)/i); 
    } else {
      $vertcoord = 'ModelLevel';
    } # conditional
#------------------------------------------------------------------------------

    push(@newlines,"  { 'modvar'    => '',\n"); 
    push(@newlines,"    'stream'    => '',\n");
    push(@newlines,"    'cmorvar'   => '${cmorvar}',\n");
    push(@newlines,"    'std_name'  => '${std_name}',\n");
    push(@newlines,"    'long_name' => '${long_name}',\n");
    push(@newlines,"    'units'     => '${units}',\n");
    push(@newlines,"    'valid_min' => ${valid_min},\n");
    push(@newlines,"    'valid_max' => ${valid_max},\n");
    push(@newlines,"    'vertcoord' => '${vertcoord}'\n");
    push(@newlines,"  },\n");

  } # conditional
} # loop: $line
push(@newlines,');');

# Write to database file
open OUTPUT,">database.pl";
print OUTPUT @newlines;
close OUTPUT;
