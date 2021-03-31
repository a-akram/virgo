#!/bin/bash

# *** USAGE ***
# ./runall_prod.sh <prefix> <nevts> <gen> <pbeam>
# ./runall_prod.sh llbar 100 llbar_fwp.DEC 1.642

if [ $# -lt 3 ]; then
  echo -e "\nPerforms Simulation of EvtGen/DPM/FTF/BOX Events.\n"
  echo -e "USAGE: ./runall_prod.sh <prefix> <nevts> <gen> <pbeam>"
  echo -e "USAGE: ./runall_prod.sh llbar 100 llbar_fwp.DEC 1.642\n"
  echo -e " <prefix> : Prefix of output files"
  echo -e " <nevts>  : Number of events to be simulated"
  echo -e " <gen>    : Name of EvtGen decay file ('xxx.dec') Or keywords 'DPM/FTF/BOX' for others gens."
  echo -e " <pbeam>  : Momentum of pbar-beam.\n"
  echo -e "Creates output files: <prefix>_sim.root, <prefix>_par.root, <prefix>_pid.root and log files.\n"
  exit 1
fi

# Lustre Storage
LUSTRE_HOME=$HOME"/current/2_deepana"

# Working Directory
nyx=$LUSTRE_HOME"/hpc"

# Data Storage
_target=$nyx"/data"


# Init PandaRoot
#. $HOME"/fair/pandaroot/build-oct19/config.sh"
. $HOME"/fair/pandaroot_dev/build-April2021/config.sh"


echo -e "\n";

# Defaults
prefix=llbar
nevt=10
dec="llbar_fwp.DEC"
pbeam=1.642
seed=$RANDOM


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


# Make sure `$_target` Exists
if [ ! -d $_target ]; then
    mkdir $_target;
    echo -e "\nThe data dir. at '$_target' created."
else
    echo -e "\nThe data dir. at '$_target' exists."
fi

tmpdir="/tmp/"$USER

# Make sure $tempdir exists
if [ ! -d $tmpdir ]; then
    mkdir $tmpdir;
    echo -e "The temporary dir. at '$tmpdir' created."
else
    echo -e "The temporary dir. at '$tmpdir' exists."
fi

#outprefix=$tmpdir"/"$prefix
outprefix=$_target"/"$prefix

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


# ---------------------------------------------------------------
#                     Initiate Simulaton & Analysis
# ---------------------------------------------------------------
echo ""
echo "Started Simulating..."
root -l -b -q $nyx"/"prod_sim.C\($nevt,\"$outprefix\",\"$dec\",$mom,$seed\) > $outprefix"_sim.log" 2>&1
NUMEV=`grep 'Generated Events' $outprefix"_sim.log"`

echo "Started AOD (Digi, Reco, Pid)..."
root -l -b -q $nyx"/"prod_aod.C\($nevt,\"$outprefix\"\) > $outprefix"_pid.log" 2>&1
echo $NUMEV >> $outprefix"_pid.log"
echo "Finished Simulating..."
echo ""

echo "Starting Analysis..."
#root -l -b -q $nyx"/"ana_ntp.C\($nevt,\"$outprefix\"\) > $outprefix"_ana_ntp.log" 2>&1
root -l -b -q $nyx"/"prod_ana.C\($nevt,\"$outprefix\",$IsSignal\) > $outprefix"_ana.log" 2>&1
echo "Finishing Analysis..."

#*** Tidy Up ***
rm -rf $tmpdir

