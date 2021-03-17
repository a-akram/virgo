#!/bin/bash

# *** USAGE ***
# export LUSTRE_WORK="/lustre/panda/"$USER"/virgo"

# sbatch --get-user-env [options] -- $LUSTRE_WORK/jobsim_aod.sh [arguments]
# sbatch --get-user-env -a1-10 -J pndsim -D $LUSTRE_WORK/logs -- $LUSTRE_WORK/jobsim_aod.sh llbar 1000 fwp

# Examples:

# (1)- Containerized: Give SBATCH Flags on CLI before '--' separator.
# sbatch --get-user-env -a1-10 -J pndsim -D $LUSTRE_WORK/logs -- $LUSTRE_WORK/jobsim_aod.sh llbar 1000 fwp

# (2)- Conventional: Give SBATCH Flags inside script (mind the warning)
# sbatch $LUSTRE_WORK/jobsim_aod.sh llbar 1000 fwp


# *** Account ***
#SBATCH -A panda					         # Account Name (--account=g2020014)
#SBATCH -J llbar					         # Job Name (--job-name=HitPairs)
#SBATCH -t 8:00:00					         # Time (DD-HH:MM) (--time=0:59:00)
#SBATCH -p main  			                 # Partition (debug/main/long/grid) (--partition=node)
#SBATCH --array=1-5                          # Submit a Job Array (--array=<indexes>)


# *** I/O ***
#SBATCH -D /lustre/panda/aakram/virgo        # Set Working Directory (--chdir=<directory>), on Lustre (Abs Path)
#SBATCH -o %x-%j.out				         # Std Output (--output=<file pattern>), on Lustre (Abs/Rel Path)
#SBATCH -e %x-%j.err					     # Std Error (--error=<file pattern>), on Lustre (Abs/Rel Path)
#SBATCH --mail-type=END					     # Notification Type
#SBATCH --mail-user=adeel.chep@gmail.com     # Email for notification


if [ $# -lt 3 ]; then
  echo -e "\nMinimum Three Arguments Are Required\n"
  echo -e "USAGE: sbatch -a<min>-<max> -- jobsim_complete.sh <prefix> <nEvents> <simType>\n"
  echo -e " <min>     : Minimum job number"
  echo -e " <max>     : Maximum job number"
  echo -e " <prefix>  : Prefix of output files"
  echo -e " <nevts>   : Number of events to be simulated"
  echo -e " <simType> : Simulation type e.g. fwp (signal), bkg (non-resonant bkg), dpm (generic bkg)"
  echo -e " <pbeam>   : Momentum of pbar-beam (GeV/c)."
  echo -e " [opt]     : Optional options: if contains 'savesim', 'saveall' or 'ana'\n";
  echo -e "Example 1 : sbatch -a1-20 jobsim_complete.sh sig 1000 fwp"
  echo -e "Example 2 : sbatch -a1-20 jobsim_complete.sh bkg 1000 dpm\n"
  exit 1
fi


#Path to Lustre Shared Storage
#LUSTRE_HOME=/lustre/$(id -g -n)/$USER
LUSTRE_HOME="/lustre/panda/"$USER
#LUSTRE_HOME="/home/adeel/current/2_deepana"


#PandaRoot Path
. "/lustre/panda/aakram/fair/oct19/build/config.sh"

echo "";

#Defaults
prefix=llbar     # output file naming
nevt=1000        # number of events
simType="fwp"    # [fwp, bkg, dpm]
mom=1.642        # pbarp with 1.642 GeV/c
seed=$RANDOM     # random seed for simulation
mode=0           # mode for analysis
opt="ana"        # use opt to do specific tasks e.g. ana for analysis etc.

run=$SLURM_ARRAY_TASK_ID

#User Input
if test "$1" != ""; then
  prefix=$1
fi

if test "$2" != ""; then
  nevt=$2
fi

if test "$3" != ""; then
  simType=$3
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

#Macro Folder
scripts=$LUSTRE_HOME"/virgo"

#Get Proper Generator
if [[ $simType == "fwp" ]]; then
    _target=$scripts"/1_"$simType
    dec="llbar_fwp.DEC"
fi

if [[ $simType == "bkg" ]]; then
    _target=$scripts"/2_"$simType
    dec="llbar_bkg.DEC"
fi 

if [[ $simType == "dpm" ]]; then
    _target=$scripts"/3_"$simType
    dec="dpm"
fi


#Prepend Absolute Path to DEC File
if [[ $dec == *".dec"* ]]; then
  if [[ $dec != \/* ]] ; then
	dec=$scripts"/"$dec
  fi
fi

if [[ $dec == *".DEC"* ]]; then
  if [[ $dec != \/* ]] ; then
	dec=$scripts"/"$dec
  fi
fi

#Make sure `$_target` Exists
if [ ! -d $_target ]; then
    mkdir $_target;
else
    echo "The target dire. at '$_target' exists."
fi


#IF ARRAY_TASK Used
if test "$run" == ""; then
    tmpdir="/tmp/"$USER"/"
	outprefix=$tmpdir$prefix
	pidfile=$outprefix"_pid.root"
else
    tmpdir="/tmp/"$USER"_"$SLURM_JOB_ID"/"
	outprefix=$tmpdir$prefix"_"$run
	pidfile=$outprefix"_pid.root"
	seed=$seed$run
fi

#Make sure $tempdir exists
if [ ! -d $tmpdir ]; then
    mkdir $tmpdir;
else
    echo "The temporary dir. at '$tmpdir' exists."
fi


# ---------------------------------------------------------------
#                              Print Flags
# ---------------------------------------------------------------

echo ""
echo "Lustre Home    : $LUSTRE_HOME"
echo "Macro Directory: $scripts"
echo "Data Directory : $_target"
echo "Temp Directory : $tmpdir"
echo "Generator File : $dec"
echo "PID File       : $pidfile"
echo ""
echo "Macro Inputs:"
echo "Events: '$nevt', OutPrefix: '$outprefix', DEC: '$dec', pBeam: '$mom', Seed: '$seed'"
echo ""


# Execute application code
hostname; sleep 200;

