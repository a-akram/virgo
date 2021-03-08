#!/bin/bash

# *** USAGE *** 
# sbatch -a<min>-<max> -- jobsim_complete.sh <pref> <nevt> <dec> <mom> <saveall>
# sbatch -a1-20 -- jobsim_complete.sh bkg 1000 llbar_bkg.dec 1.642 

# *** Account ***
#SBATCH -A aakram					               # Account Name (--account=g2020014)
#SBATCH -J pndsim					               # Job Name (--job-name=HitPairs)
#SBATCH -t 2:00:00					               # Time (DD-HH:MM) (--time=0:59:00)
#SBATCH -p main					                   # Partition (debug/main/long/grid) (--partition=node)
#s-BATCH -N 2						               # No. of Nodes Requested (--nodes=2)

# *** I/O ***	     
#SBATCH --get-user-env                             # Working Directory (-D, --chdir=<directory>). Default=PWD
#SBATCH -o data/llbar/slurmlog/slurm_%j_errout.log # Standard Output (--output=<filename pattern>)
#SBATCH -e data/llbar/slurmlog/slurm_%j_errout.log # standard Error (--error=<filename pattern>)
#SBATCH --mail-type=END					           # Notification Type
#SBATCH --mail-user=adeel.chep@gmail.com		   # Email for notification


if [ $# -lt 1 ]; then
  echo -e "\nJob script for submission of PandaRoot simulation jobs on KRONOS.\n"
  echo -e "USAGE: sbatch -a<min>-<max> jobsim_complete.sh <prefix> <nevts> <gen> <pbeam> [opt] [mode]\n"
  echo -e " <min>     : Minimum job number"
  echo -e " <max>     : Maximum job number"
  echo -e " <prefix>  : Prefix of output files"
  echo -e " <nevts>   : Number of events to be simulated"
  echo -e " <gen>     : Name of EvtGen decay file 'xxx.dec:iniRes'. Keyword 'DPM/FTF/BOX' instead runs other generator"
  echo -e " <pbeam>   : Momentum of pbar-beam."
  echo -e " [opt]     : Optional options: if contains 'savesim', sim output is copied as well.";
  echo -e " [opt]     : Optional options: if contains 'saveall', all output (sim, digi, reco, pid) is copied as well.";
  echo -e " [opt]     : Optional options: if contains 'ana', runs prod_ana.C in addition.";
  echo -e " [mode]    : Optional mode number for analysis.\n";
  echo -e "Example 1 : sbatch -a1-20 jobsim_complete.sh d0sim 1000 D0toKpi.dec 12. ana 10"
  echo -e "Example 2 : sbatch -a1-20 jobsim_complete.sh dpmbkg 1000 dpm 12."
  echo -e "Example 3 : sbatch -a1-20 jobsim_complete.sh singleK 1000 box:type[321,1]:p[0.05,8]:tht[0,180]:phi[0,360] 12.\n"
  echo -e "Example 4 : sbatch -a1-20 jobsim_complete.sh bkg 1000 llbar_bkg.dec 1.642 none 10"
  
  exit 1
fi


#Shared Storage on Cluster
#LUSTRE_HOME=/lustre/$(id -g -n)/$USER
LUSTRE_HOME="/lustre/panda/"$USER
WORKING_HOME=$LUSTRE_HOME"/llbar"
_target=$WORKING_HOME"/data/bkg/"

#PandaRoot Path
. "/lustre/panda/aakram/pandaroot/build-oct19/config.sh"

#Macro DIR
nyx="/u/aakram/virgo"




#Macro Parameters
prefix=ll
nevt=20
dec="llbar_bkg.DEC"
mom=1.642
opt=""
mode=0
run=$SLURM_ARRAY_TASK_ID

tmpdir="/tmp/"$USER"_"$SLURM_JOB_ID"/"
mkdir $tmpdir

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


outprefix=$tmpdir$prefix"_"$run
pidfile=$outprefix"_pid.root"


# Test Flags
echo "Setting Up..."
echo "LUSTER_HOME: $LUSTRE_HOME"
echo "Working_HOME: $nyx"
echo ""
echo "Script Inputs: $prefix, $nevt, $mode, $dec, $mom, $opt, $mode"
echo "Out Prefix: $outprefix"
echo "Data Dir. : $_target"
echo ""



sim="simall"

if [[ $sim == *"simall"* ]]; then
    
    echo ""
    echo "Started Simulating..."
    root -b -q $nyx"/"prod_sim.C\($nevt,\"$outprefix\",\"$dec\",$mom\) > $outprefix"_sim.log" 2>&1

    echo "Started Digitization..."
    root -b -q $nyx"/"prod_digi.C\($nevt,\"$outprefix\"\) > $outprefix"_digi.log" 2>&1 

    echo "Started Ideal Reconstruction..."
    root -b -q $nyx"/"prod_reco.C\($nevt,\"$outprefix\"\) > $outprefix"_reco.log" 2>&1

    echo "Started Ideal PID..."
    root -b -q $nyx"/"prod_pid.C\($nevt,\"$outprefix\"\) > $outprefix"_pid.log" 2>&1 
    echo ""

fi

# copy sim output to storage element
if [[ $opt == *"savesim"* ]]; then
   cp  $outprefix"_sim.log" $_target
   cp  $outprefix"_sim.root" $_target
fi

# copy all output to storage element
if [[ $opt == *"saveall"* ]]; then
   cp  $outprefix"_sim.log" $_target
   cp  $outprefix"_sim.root" $_target
   cp  $outprefix"_digi.log" $_target
   cp  $outprefix"_digi.root" $_target
   cp  $outprefix"_reco.log" $_target
   cp  $outprefix"_reco.root" $_target
fi

# if opt contains 'ana', also run analysis
if [[ $opt == *"ana"* ]]; then
   root -l -q -b $nyx"/"prod_ana_fast.C\(\"$pidfile\",0,0,$mode,0\) &> $outprefix"_ana.log"
   cp $outprefix"_ana.log" $_target
   cp $outprefix"_pid_ana.root" $_target
fi
   
# copy number of generated events from FairFilteredPrimaryGenerator in ...sim.log to ...pid.log
NUMEV=`grep 'Generated Events' $outprefix"_sim.log"`
echo $NUMEV >> $outprefix"_pid.log"
   
cp  $outprefix"_par.root" $_target
cp  $outprefix"_pid.log" $_target
cp  $outprefix"_pid.root" $_target

#*** Tidy Up ***
if [[ $opt == *"removeall"* ]]; then
    rm  $outprefix"_par.root"
    rm  $outprefix"_sim.log"
    rm  $outprefix"_digi.log"
    rm  $outprefix"_reco.log"
    rm  $outprefix"_pid.log"
    rm  $outprefix"_sim.root"
    rm  $outprefix"_digi.root"
    rm  $outprefix"_reco.root"
    rm  $outprefix"_pid.root"
if

if [[ $opt == *"ana"* ]]; then
    rm  $outprefix"_pid_ana.root"
    rm  $outprefix"_ana.log"
fi

