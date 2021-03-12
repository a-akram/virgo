#!/bin/bash

# *** USAGE *** 
# sbatch -a<min>-<max> -- jobsim_complete.sh <prefix> <nEvents> <simType> <pBeam> <opt> <mode>
# sbatch -a1-20 -- jobsim_complete.sh llbar 10 bkg 


# *** Account ***
#SBATCH -A panda					         # Account Name (--account=g2020014)
#SBATCH -J llbar					         # Job Name (--job-name=HitPairs)
#SBATCH -t 2:00:00					         # Time (DD-HH:MM) (--time=0:59:00)
#SBATCH -p debug  			                 # Partition (debug/main/long/grid) (--partition=node)
#S-BATCH -N 2						         # No. of Nodes Requested (--nodes=2)


# *** I/O ***
#SBATCH --get-user-env
#S-BATCH -D /lustre/panda/aakram/virgo/data  # Working Directory (--chdir=<directory>) on Lustre
#SBATCH -o %x-%j.out					     # Standard Output (--output=<file pattern>), %x-%j.out, %j_%N.out
#SBATCH -e %x-%j.err					     # Standard Error (--error=<file pattern>), %x-%j.err, %j_%N.err
#SBATCH --mail-type=END					     # Notification Type
#SBATCH --mail-user=adeel.chep@gmail.com     # Email for notification

echo "== --------------------------------------------"
echo "== Starting Run at $(date)"			           # 	 
echo "== SLURM Cluster: ${SLURM_CLUSTER_NAME}"		   # 
echo "== --------------------------------------------"
echo "== SLURM CPUS on GPU: ${SLURM_CPUS_PER_GPU}"     # Only set if the --cpus-per-gpu is specified.
echo "== SLURM CPUS on NODE: ${SLURM_CPUS_ON_NODE}"	   #
echo "== SLURM CPUS per TASK: ${SLURM_CPUS_PER_TASK}"  # Only set if the --cpus-per-task is specified.
echo "== --------------------------------------------"
echo "== SLURM No. of GPUS: ${SLURM_GPUS}"		       # Only set if the -G, --gpus option is specified.
echo "== SLURM GPUS per NODE: ${SLURM_GPUS_PER_NODE}"  # 
echo "== SLURM GPUS per TASK: ${SLURM_GPUS_PER_TASK}"  #
echo "== --------------------------------------------"
echo "== SLURM Job ID: ${SLURM_JOB_ID}"                # OR SLURM_JOBID. The ID of the job allocation.
echo "== SLURM Job ACC: ${SLURM_JOB_ACCOUNT}"          # Account name associated of the job allocation. 	
echo "== SLURM Job NAME: ${SLURM_JOB_NAME}"            # Name of the job.
echo "== SLURM Node LIST: ${SLURM_JOB_NODELIST}"       # OR SLURM_NODELIST. List of nodes allocated to job.
echo "== SLURM No. of NODES: ${SLURM_JOB_NUM_NODES}"   # OR SLURM_NNODES. Total #nodes in job's resources.
echo "== SLURM No. of CPUs/NODE: ${SLURM_JOB_CPUS_PER_NODE}" #  
echo "== --------------------------------------------"
echo "== SLURM Node ID: ${SLURM_NODEID}"                     # ID of the nodes allocated.
echo "== SLURM Node Name: ${SLURMD_NODENAME}"                # Name of the node running the job script
echo "== SLURM No. of Tasks: ${SLURM_NTASKS}"		         # OR SLURM_NPROCS. Similar as -n, --ntasks
echo "== SLURM No. of Tasks/Core: ${SLURM_NTASKS_PER_CORE}"  # Only set if the --ntasks-per-core is specified.
echo "== SLURM No. of Tasks/Node: ${SLURM_NTASKS_PER_NODE}"  # Only set if the --ntasks-per-node is specified.
echo "== SLURM Submit Dir. : ${SLURM_SUBMIT_DIR}"	         # Dir. where sbatch was invoked. Flag: -D, --chdir.
echo "== --------------------------------------------"

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
hostname; uptime; sleep 30; uname -a
