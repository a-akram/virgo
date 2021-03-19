#!/bin/bash

# *** Cluster USAGE ***
# sbatch [options] -- jobsim_complete.sh <prefix> <events> <dec> <pbeam> [opt] [mode]

# *** Local USAGE ***
# ./jobsim_complete.sh <prefix> <events> <dec>
# ./jobsim_complete.sh llbar 100 llbar_fwp.DEC

if [ $# -lt 3 ]; then
  echo -e "\nMinimum Three Arguments Are Required\n"
  echo -e "USAGE: sbatch -a<min>-<max> -- jobsim_complete.sh <prefix> <nEvents> <dec>\n"
  echo -e " <min>     : Minimum job number"
  echo -e " <max>     : Maximum job number"
  echo -e " <prefix>  : Prefix of output files"
  echo -e " <nevts>   : Number of events to be simulated"
  echo -e " <dec>     : Decay File or Keywords: fwp (signal), bkg (non-resonant bkg), dpm (generic bkg)"
  echo -e " <pbeam>   : Momentum of pbar-beam (GeV/c)."
  echo -e " [opt]     : Optional options: if contains 'savesim', 'saveall' or 'ana'\n";
  echo -e "Example 1 : sbatch -a1-20 [options] jobsim_complete.sh sig 1000 fwp"
  echo -e "Example 2 : sbatch -a1-20 [options] jobsim_complete.sh bkg 1000 dpm"
  echo -e "Example 3 : ./jobsim_complete.sh llbar 100 fwp\n"
  exit 1
fi


# Lustre Storage
# LUSTRE_HOME=/lustre/$(id -g -n)/$USER
LUSTRE_HOME="/lustre/panda/"$USER

# Working Directory
nyx=$LUSTRE_HOME"/virgo"

# Data Storage
#_target=$nyx"/data"


# Init PandaRoot
#. $LUSTRE_HOME"/fair/oct19/build/config.sh"
. $LUSTRE_HOME"/fair/dev/build/config.sh"


echo -e "\n";

#Defaults
prefix=llbar                # output file naming
nevt=1000                   # number of events
dec="llbar_fwp.DEC"         # decay file OR keywords [fwp, bkg, dpm]
mom=1.642                   # pbarp with 1.642 GeV/c
mode=0                      # mode for analysis
opt="ana"                   # use opt to do specific tasks e.g. ana for analysis etc.
seed=$RANDOM                # random seed for simulation
run=$SLURM_ARRAY_TASK_ID    # Slurm Array ID


#User Input
if test "$1" != ""; then
  prefix=$1
fi

if test "$2" != ""; then
  nevt=$2
fi

if test "$3" != ""; then
  dec=$3
fi

if test "$4" != ""; then
  mom=$4
fi

if test "$5" != ""; then
  opt=$5
fi

if test "$6" != ""; then
  mode=$6
fi


# Get .DEC if Only Keywords [fwp,bkg,dpm] Are Given.
# e.g. ./jobsim_complete.sh llbar 100 fwp 1.642

if [[ $dec == "fwp" ]]; then
    _target=$nyx"/data/"$dec
    dec="llbar_fwp.DEC"
fi

if [[ $dec == "bkg" ]]; then
    _target=$nyx"/data/"$dec
    dec="llbar_bkg.DEC"
fi 

if [[ $dec == "dpm" ]]; then
    _target=$nyx"/data/"$dec
    dec="dpm"
fi


# Deduce Signal/Bkg from .DEC & Create Storage Accordingly.
# e.g. ./jobsim_complete.sh llbar 100 llbar_fwp.DEC 1.642

if [[ $dec == *"fwp"* ]]; then
    IsSignal=true
    _target=$nyx"/data/fwp"
fi

if [[ $dec == *"bkg"* ]]; then
    IsSignal=false
    _target=$nyx"/data/bkg"
fi

if [[ $dec == *"dpm"* ]]; then
    IsSignal=false
    _target=$nyx"/data/dpm"
fi

# Prepend Absolute Path to .DEC File
if [[ $dec == *".dec"* ]]; then
  if [[ $dec != \/* ]] ; then
	dec=$nyx"/"$dec
  fi
fi

if [[ $dec == *".DEC"* ]]; then
  if [[ $dec != \/* ]] ; then
	dec=$nyx"/"$dec
  fi
fi


# Make sure `$_target` Exists
if [ ! -d $_target ]; then
    mkdir $_target;
    echo -e "\nThe data dir. at '$_target' created."
else
    echo -e "\nThe data dir. at '$_target' exists."
fi


# IF ARRAY_TASK Used
if test "$run" == ""; then
    tmpdir="/tmp/"$USER
	outprefix=$tmpdir"/"$prefix
	pidfile=$outprefix"_pid.root"
else
    tmpdir="/tmp/"$USER"_"$SLURM_JOB_ID
	outprefix=$tmpdir"/"$prefix"_"$run
	pidfile=$outprefix"_pid.root"
	seed=$seed$run
fi


# Make sure $tempdir exists
if [ ! -d $tmpdir ]; then
    mkdir $tmpdir;
    echo -e "The temporary dir. at '$tmpdir' created."
else
    echo -e "The temporary dir. at '$tmpdir' exists."
fi


# ---------------------------------------------------------------
#                              Print Flags
# ---------------------------------------------------------------

echo ""
echo "Lustre Home  : $LUSTRE_HOME"
echo "Working Dir. : $nyx"
echo "Temp Dir.    : $tmpdir"
echo "Target Dir.  : $_target"
echo ""
echo -e "--Macro--"
echo -e "Events    : $nevt"
echo -e "Prefix    : $outprefix"
echo -e "Decay     : $dec"
echo -e "pBeam     : $mom"
echo -e "Seed      : $seed"
echo -e "Is Signal : $IsSignal"
echo -e "PID File  : $pidfile"

# Terminate Script for Testing.
exit 0;

# Execute application code
hostname; sleep 200;
