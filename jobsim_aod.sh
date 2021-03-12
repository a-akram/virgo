#!/bin/bash

# *** USAGE *** 
# sbatch -a<min>-<max> -- jobsim_complete.sh <prefix> <nEvents> <simType> <pBeam> <opt> <mode>
# sbatch -a1-20 -- jobsim_complete.sh llbar 1000 bkg 


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



# ---------------------------------------------------------------
#                            Initiate Simulaton
# ---------------------------------------------------------------

echo ""
echo "Started Simulating..."
root -b -q $scripts"/"prod_sim.C\($nevt,\"$outprefix\",\"$dec\",$mom,$seed\) > $outprefix"_sim.log" 2>&1

echo "Started AOD (Digi, Reco, Pid)..."
#root -b -q $scripts"/"prod_aod.C\($nevt,\"$outprefix\"\) > $outprefix"_pid.log" 2>&1 

echo "Finished Simulating..."
echo ""

# ---------------------------------------------------------------
#                            Initiate Analysis
# ---------------------------------------------------------------

echo "Starting Analysis..."
#root -b -q $scripts"/"prod_ana.C\($nevt,\"$outprefix\"\) > $outprefix"_ana.log" 2>&1
#root -b -q $scripts"/"ana_ntp.C\($nevt,\"$outprefix\"\) > $outprefix"_ana_ntp.log" 2>&1
echo "Finishing Analysis..."
echo ""

# ---------------------------------------------------------------
#                            Storing Files
# ---------------------------------------------------------------

NUMEV=`grep 'Generated Events' $outprefix"_sim.log"`
echo $NUMEV >> $outprefix"_pid.log"

# ls in tmpdir to appear in slurmlog
ls -ltrh $tmpdir

echo "Moving Files from '$tmpdir' to '$_target'"

# move outputs to target dir
mv $outprefix"_par.root" $_target
mv $outprefix"_sim.log" $_target
mv $outprefix"_sim.root" $_target
mv $outprefix"_pid.log" $_target

#*** Tidy Up ***
#rm -rf $tmpdir

