#!/bin/bash

#SBATCH -J pndana
#SBATCH --time=8:00:00
#SBATCH --get-user-env
#SBATCH -e data/llbar/slurmlog/slurm_%j_errout.log
#SBATCH -o data/llbar/slurmlog/slurm_%j_errout.log

if [ $# -lt 1 ]; then
  echo -e "\nJob script for submission of PandaRoot analysis jobs based on macro 'prod_ana_fast.C' on KRONOS. *The macro needs to configured beforehand!*\n"
  echo -e "   ********************************************************"
  echo -e "   *** RECOMMENDED: Use anasub.pl for easier submission ***"
  echo -e "   *********************************************************\n"
  echo -e "USAGE: sbatch jobana_kronos.sh <prefix> <min> <max> <mode>\n"
  echo -e " <prefix>  : Prefix of input files"
  echo -e " <min>     : Minimum job number of files data/<prefix>_<min>_pid.root"
  echo -e " <max>     : Maximum job number of files data/<prefix>_<max>_pid.root"
  echo -e " <mode>    : Arbitrary mode number to be stored in n-tuples.\n"
  echo -e "Example 1  : sbatch jobana_kronos.sh d0sim 1 10 42\n"
  echo -e "Example 2  : sbatch -a1-20 jobana_kronos.sh ll"
  
  exit 1
fi

# Lustre Storage
LUSTRE_HOME="/lustre/panda/"$USER

# Working Directory
nyx=$LUSTRE_HOME"/hpc"

# Data Storage
_target=$nyx"/data"

# Init PandaRoot
#. $LUSTRE_HOME"/pandaroot/build-dev/config.sh"
. $LUSTRE_HOME"/pandaroot/install-dev/bin/config.sh" -p


echo -e "\n";

# Defaults
prefix=llbar                # output file naming
nevt=2000                   # number of events
from=1                      # Start value
to=20                       # End value
mode=0                      # Mode ???
IsSignal=true               # Signal or Background
run=$SLURM_ARRAY_TASK_ID    # Slurm Array ID

if test "$1" != ""; then
  prefix=$1
fi

if test "$2" != ""; then
  from=$2
fi

if test "$3" != ""; then
  to=$3
fi

if test "$4" != ""; then
  mode=$4
fi

# IF ARRAY_TASK Used
if test "$run" == ""; then
    outprefix=$_target"/"$prefix
    pidfile=$outprefix"_pid.root"
else
    outprefix=$_target"/"$prefix"_"$run
    pidfile=$outprefix"_pid.root"
fi


# ---------------------------------------------------------------
#                              Print Flags
# ---------------------------------------------------------------

echo ""
echo "Lustre Home  : $LUSTRE_HOME"
echo "Working Dir. : $nyx"
echo "Target Dir.  : $_target"
echo ""
echo -e "--Macro--"
echo -e "Events    : $nevt"
echo -e "Prefix    : $outprefix"
echo -e "IsSignal  : $IsSignal"
echo -e "PID File  : $pidfile"


# Terminate Script for Testing.
# exit 0;


# ---------------------------------------------------------------
#                            Initiate Analysis
# ---------------------------------------------------------------

echo "Starting Analysis..."
root -l -q -b $nyx"/"prod_ana_multi.C\(0,\"$pidfile\",$IsSignal,0,0,$mode\) > $outprefix"_ana.log" 2>&1
echo "Finishing Analysis..."

# ---------------------------------------------------------------
#                            Storing Files
# ---------------------------------------------------------------

mv $outprefix"_ana.root" $_target
mv $outprefix"_pid_ana.root" $_target
mv $outprefix"_ana.log" $_target


#*** Tidy Up ***
#rm -rf $tmpdir

echo "The Script has Finished wit SLURM_JOB_ID: $SLURM_JOB_ID."
