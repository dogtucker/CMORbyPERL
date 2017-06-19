#!/usr/bin/perl
use strict;
use warnings;

# 2017/06/19: Adapted for ECHAM6-HAM2 variable names

### START: user defined constants ##############################################
# Filename templates, these will be prepended with the stream name
my @templates = ( ".nc", "m.nc", "_monthly.nc", "_annual.nc","_avg.nc");

# directories
my $in  = "in";    # ECHAM-HAM output files
my $out = "in";   # Results from mod2cmor_pre.pl
my $tmp = "tmp";
### START: user defined constants ##############################################


### Main code ### [DO NOT CHANGE] ##############################################

# Erase file in $tmp
`rm -f ${tmp}/*`;

# Initialize
my $stream;
my $expr;

# Read all files present in $in
opendir(DIR,$in) or die;
my @files = readdir(DIR);
closedir(DIR);

# AOT at 440nm
  $stream = "rad";
  $expr   = "od440aer=TAU_2D_550nm*(1.25)^ANG_550nm_865nm"; # 550/440=1.25
  &constructvar($stream,$expr);

# AOT at 870nm
  $stream = "rad";
  $expr   = "od870aer=TAU_2D_865nm*(0.9942529)^ANG_550nm_865nm"; # 865/870=0.9942529
  &constructvar($stream,$expr);

# Fine mode AOT at 550nm
  $stream = "rad";
  $expr   = "od550lt1aer=TAU_MODE_KS_550nm+TAU_MODE_KI_550nm+TAU_MODE_AS_550nm+TAU_MODE_AI_550nm";
  &constructvar($stream,$expr);

# POM wet deposition
  $stream = "wetdep";
  $expr   = "wetoa=wdep_OC_KS+wdep_OC_AS+wdep_OC_CS+wdep_OC_KI";
  &constructvar($stream,$expr);

# BC wet deposition
  $stream = "wetdep";
  $expr   = "wetbc=wdep_BC_KS+wdep_BC_AS+wdep_BC_CS+wdep_BC_KI";
  &constructvar($stream,$expr);

# SO2 emissions
  $stream = "emi";
  $expr   = "emiso2=emi_SO2";
  &constructvar($stream,$expr);

# SO4 emissions
  $stream = "emi";
  $expr   = "emiso4=emi_SO4";
  &constructvar($stream,$expr);

# DMS emissions
  $stream = "emi";
  $expr   = "emidms=emi_DMS";
  &constructvar($stream,$expr);

# OC emissions due to biomass burning
  $stream = "emi";
  $expr   = "emibb=emi_OC_ffire+emi_OC_gfire";
  &constructvar($stream,$expr);

# SO4 wet deposition
  $stream = "wetdep";
  $expr   = "wetso4=wdep_SO4_NS+wdep_SO4_KS+wdep_SO4_AS+wdep_SO4_CS";
  &constructvar($stream,$expr);

# SS emissions
  $stream = "emi";
  $expr   = "emiss=emi_SS";
  &constructvar($stream,$expr);

# SS wet deposition
  $stream = "wetdep";
  $expr   = "wetss=wdep_SS_AS+wdep_SS_CS";
  &constructvar($stream,$expr);

# DU wet deposition
  $stream = "wetdep";
  $expr   = "wetdust=wdep_DU_AI+wdep_DU_AS+wdep_DU_CI+wdep_DU_CS";
  &constructvar($stream,$expr);

# POM burden
  $stream = "burden";
  $expr   ="loadoa=burden_OC";
  &constructvar($stream,$expr);

# BC burden
  $stream = "burden";
  $expr   ="loadbc=burden_BC";
  &constructvar($stream,$expr);

# SO4 burden
  $stream = "burden";
  $expr   ="loadso4=burden_SO4";
  &constructvar($stream,$expr);

# DU burden
  $stream = "burden";
  $expr   ="loaddust=burden_DU";
  &constructvar($stream,$expr);

# SS burden
  $stream = "burden";
  $expr   ="loadss=burden_SS";
  &constructvar($stream,$expr);

# SO4 dry deposition
  $stream = "drydep";
  $expr   = "dryso4=ddep_SO4_NS+ddep_SO4_KS+ddep_SO4_AS+ddep_SO4_CS";
  &constructvar($stream,$expr);

# SS dry deposition
  $stream = "drydep";
  $expr   = "dryss=ddep_SS_AS+ddep_SS_CS";
  &constructvar($stream,$expr);

# DU dry deposition
  $stream = "drydep";
  $expr   = "drydust=ddep_DU_AI+ddep_DU_AS+ddep_DU_CI+ddep_DU_CS";
  &constructvar($stream,$expr);

# POM dry deposition
  $stream = "drydep";
  $expr   = "dryoa=ddep_OC_KS+ddep_OC_AS+ddep_OC_CS+ddep_OC_KI";
  &constructvar($stream,$expr);

# BC dry deposition
  $stream = "drydep";
  $expr   = "drybc=ddep_BC_KS+ddep_BC_AS+ddep_BC_CS+ddep_BC_KI";
  &constructvar($stream,$expr);

# SW TOA upwelling solar flux in clear sky regions
  $stream = "echam";
  $expr   = "rsutcs=sraf0-srad0d";
  &constructvar($stream,$expr);

# SW surface downwelling solar flux
  $stream = "echam";
  $expr   = "rsds=srads-sradsu";
  &constructvar($stream,$expr);

# LW surface downwelling solar flux
  $stream = "echam";
  $expr   = "rlds=trads-tradsu";
  &constructvar($stream,$expr);

# Mixing ratio of water in ambient aerosol 
  $stream = "tracer";
  $expr   = "mmraerh2o=WAT_NS+WAT_KS+WAT_AS+WAT_CS";
  &constructvar($stream,$expr);

# POM mixing ratio
  $stream = "tracer";
  $expr   = "mmroa=OC_KS+OC_AS+OC_CS+OC_KI";
  &constructvar($stream,$expr);

# BC mixing ratio
  $stream = "tracer";
  $expr   = "mmrbc=BC_KS+BC_AS+BC_CS+BC_KI";
  &constructvar($stream,$expr);

# SO4 mixing ratio
  $stream = "tracer";
  $expr   = "mmrso4=SO4_NS+SO4_KS+SO4_AS+SO4_CS";
  &constructvar($stream,$expr);

# SS mixing ratio
  $stream = "tracer";
  $expr   = "mmrss=SS_AS+SS_CS";
  &constructvar($stream,$expr);

# DU mixing ratio
  $stream = "tracer";
  $expr   = "mmrdu=DU_AS+DU_CS+DU_AI+DU_CI";
  &constructvar($stream,$expr);

# SO2 mass mixing ratio converted to volume mixing ratio
  $stream = "tracer";
  $expr   = "vmrso2=0.45219*SO2"; # 28.97/64.066=0.45219
  &constructvar($stream,$expr);

# SO4 (gas) mass mixing ratio converted to volume mixing ratio
  $stream = "tracer";
  $expr   = "vmrso4=0.301573*H2SO4"; # 28.97/96.063=0.301573
  &constructvar($stream,$expr);

# DMS mass mixing ratio converted to volume mixing ratio
  $stream = "tracer";
  $expr   = "vmrdms=0.466250*DMS"; # 28.97/62.134=0.466250
  &constructvar($stream,$expr);

# Total precipitation
  $stream = "echam";
  $expr   = "precip=aprl+aprc";
  &constructvar($stream,$expr);

# Move all aux-files in tmp to out
`mv $tmp/*aux*.nc $out`;

### SUBROUTINES ###############################################################
  # should ignore tmp* files
  # 2015/11/5: Should gnerate error messages when files not found
sub constructvar{ 
  my $stream = $_[0];
  my $expr   = $_[1];
  my @files4stream = ();
  my @prepend      = ();
  foreach my $file (@files) {
    foreach my $template (@templates) {
      if ($file =~ m/(.*)${stream}${template}/) {
        push (@files4stream,$file); 
        push (@prepend,$1);
      } # conditional
    } # loop: $template
  } # loop: $file

  $expr =~ m/(.*)\s*=/; # find name of new variable
  print "Constructing $1 from stream \'${stream}\'.\n";

  my $auxfile;
  for (my $ifile=0;$ifile<=$#files4stream;$ifile++) {
    $auxfile = $files4stream[$ifile];
    $auxfile =~ s/${stream}/aux/;
    `cdo -s expr,"${expr}" $in/$files4stream[$ifile] $tmp/tmp1.nc`;
    if (-e "$tmp/$auxfile") {
      `cdo -s --no_history merge $tmp/tmp1.nc $tmp/$auxfile $tmp/tmp2.nc`;
      `mv $tmp/tmp2.nc $tmp/$auxfile`;
      `rm -f $tmp/tmp1.nc`;
    } else {
      `mv $tmp/tmp1.nc $tmp/$auxfile`;
    }
  }
}

