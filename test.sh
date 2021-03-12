#!/bin/bash

# *** USAGE *** 
# sbatch -a<min>-<max> -- jobsim_complete.sh <prefix> <nEvents> <simType> <pBeam> <opt> <mode>
# sbatch -a1-20 -- jobsim_complete.sh llbar 10 bkg 



# *** Account ***
#SBATCH -A aakram					         # Account Name (--account=g2020014)
#SBATCH -J llbar					         # Job Name (--job-name=HitPairs)
#SBATCH -t 2:00:00					         # Time (DD-HH:MM) (--time=0:59:00)
#SBATCH -p debug  			                 # Partition (debug/main/long/grid) (--partition=node)
#S-BATCH -N 2						         # No. of Nodes Requested (--nodes=2)

# *** I/O ***
#SBATCH --get-user-env

#SBATCH -D /lustre/panda/aakram/virgo/data   # Working Directory (--chdir=<directory>) on Lustre
#SBATCH -o %x-%j.out					     # Standard Output (--output=<file pattern>), %x-%j.out, %j_%N.out
#SBATCH -e %x-%j.err					     # Standard Error (--error=<file pattern>), %x-%j.err, %j_%N.err
#SBATCH --mail-type=END					     # Notification Type
#SBATCH --mail-user=adeel.chep@gmail.com     # Email for notification


#Path to Lustre Shared Storage
#LUSTRE_HOME=/lustre/$(id -g -n)/$USER
LUSTRE_HOME="/lustre/panda/"$USER



#PandaRoot Path
. "/lustre/panda/aakram/pandaroot/build-oct19/config.sh"


#Defaults
prefix=llbar
nevt=20          # number of events
simType="fwp"    # [fwp, bkg, dpm]
mom=1.642        # pbarp with 1.642 GeV/c
seed=42          # randomize with SLURM_ARRAY_TASK_ID


mode=0
opt=""

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

_target=$scripts"/data"

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
    echo "$_target exists."
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
    echo "$tmpdir exists."
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
echo "Macro Inputs   :"
echo "Events: $nevt, OutPrefix: $outprefix, DEC: $dec, pBeam: $mom, Seed: $seed"
echo ""



# Execute application code
hostname; uptime; sleep 30; uname -a
