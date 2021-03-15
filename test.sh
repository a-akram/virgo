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
#S-BATCH --get-user-env                      # Get user login info specified in `--uid` option.
#SBATCH -A panda					         # Account Name (--account=g2020014)
#SBATCH -J llbar					         # Job Name (--job-name=HitPairs)
#SBATCH -t 8:00:00					         # Time (DD-HH:MM) (--time=0:59:00)
#SBATCH -p main  			                 # Partition (debug/main/long/grid) (--partition=node)
#S-BATCH -N 2						         # No. of Nodes Requested (--nodes=2)
#SBATCH -a 1-5                               # Submit a Job Array (--array=<indexes>)


# *** I/O ***
#SBATCH -D /lustre/panda/aakram/virgo        # Set Working Directory (--chdir=<directory>), on Lustre (Abs Path)
#SBATCH -o logs/%x-%j.out				     # Std Output (--output=<file pattern>), on Lustre (Abs/Rel Path)
#SBATCH -e logs/%x-%j.err					 # Std Error (--error=<file pattern>), on Lustre (Abs/Rel Path)
#SBATCH --mail-type=END					     # Notification Type
#SBATCH --mail-user=adeel.chep@gmail.com     # Email for notification


echo ""
echo "== --------------------------------------------"
echo "== Starting Run at $(date)"
echo "== SLURM Cluster: ${SLURM_CLUSTER_NAME}"
echo "== SLURM Job ID: ${SLURM_JOB_ID}"
echo "== SLURM Job ACC: ${SLURM_JOB_ACCOUNT}"
echo "== SLURM Job NAME: ${SLURM_JOB_NAME}"
echo "== SLURM Submit Dir. : ${SLURM_SUBMIT_DIR}"
echo "== SLURM Work Dir. : ${SLURM_WORKING_DIR}"
echo "== --------------------------------------------"
echo "== SLURM CPUS on GPU: ${SLURM_CPUS_PER_GPU}"
echo "== SLURM CPUS on NODE: ${SLURM_CPUS_ON_NODE}"
echo "== SLURM CPUS per TASK: ${SLURM_CPUS_PER_TASK}"
echo "== --------------------------------------------"
echo "== SLURM No. of GPUS: ${SLURM_GPUS}"
echo "== SLURM GPUS per NODE: ${SLURM_GPUS_PER_NODE}"
echo "== SLURM GPUS per TASK: ${SLURM_GPUS_PER_TASK}"
echo "== --------------------------------------------"
echo ""


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

_target=$scripts"/data"

#Make sure `$_target` Exists
if [ ! -d $_target ]; then
    mkdir $_target;
else
    echo "Target directory at '$_target' exists."
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
    echo "Temp directory at '$tmpdir' exists."
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
hostname; sleep 200;
