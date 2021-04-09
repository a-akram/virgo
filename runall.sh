#!/bin/bash

# *** Local USAGE ***
# ./runall.sh fwp 100 llbar_fwp.DEC
# ./runall.sh bkg 100 llbar_bkg.DEC


# Lustre Storage
LUSTRE_HOME=$HOME"/current/2_deepana/hpc"

# Working Directory
nyx=$HOME"/current/2_deepana/hpc"

# Data Storage
_target=$nyx"/data"


# Init PandaRoot
. "/home/adeel/fair/pandaroot_dev/build-April2021/config.sh"


# Defaults
prefix=llbar                # output file naming
nevt=1000                   # number of events
dec="llbar_fwp.DEC"         # decay file OR keywords [fwp, bkg, dpm]
mom=1.642                   # pbarp with 1.642 GeV/c
mode=0                      # mode for analysis
opt="ana:sim"               # use opt to do specific tasks e.g. ana for analysis etc.
#seed=$RANDOM               # random seed for simulation
seed=42                     # fixed seed for reproducing results.
run=1                       # Slurm Array ID
IsExtendedTarget=true       # Ask for point-like or extended target during simulation.

# User Input
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
    #_target=$nyx"/data/fwp"
fi

if [[ $dec == *"bkg"* ]]; then
    IsSignal=false
    #_target=$nyx"/data/bkg"
fi

if [[ $dec == *"dpm"* ]]; then
    IsSignal=false
    #_target=$nyx"/data/dpm"
fi


# Make sure `$_target` Exists
if [ ! -d $_target ]; then
    mkdir -p $_target;
    echo -e "\nThe data dir. at '$_target' created."
else
    echo -e "\nThe data dir. at '$_target' exists."
fi

# Set Output Prefix

outprefix=$_target"/"$prefix

# ---------------------------------------------------------------
#                              Print Flags
# ---------------------------------------------------------------

echo ""
echo -e "Directories :-"
echo -e "Lustre Home : $LUSTRE_HOME"
echo -e "Working Dir.: $nyx"
#echo -e "Temp Dir.  : $tmpdir"
echo -e "Target Dir. : $_target"
echo ""
echo -e "Macro Params:-"
echo -e "Events      : $nevt"
echo -e "Prefix      : $outprefix"
echo -e "Decay       : $dec"
echo -e "pBeam       : $mom"
echo -e "Seed        : $seed"
echo -e "Is Signal   : $IsSignal"
echo -e "Is Extended : $IsExtendedTarget"


# Terminate Script for Testing.
exit 0;


# ---------------------------------------------------------------
#                            Initiate Simulaton
# ---------------------------------------------------------------
if [[ $opt == *"sim"* ]]; then
    echo ""
    echo "Started Simulating..."
    root -l -b -q $nyx"/"prod_sim.C\($nevt,\"$outprefix\",\"$dec\",$mom,$seed,$IsExtendedTarget\) > $outprefix"_sim.log" 2>&1

    echo "Started Digitization..."
    root -l -b -q $nyx"/"prod_digi.C\($nevt,\"$outprefix\"\) > $outprefix"_digi.log" 2>&1 

    echo "Started Ideal Reconstruction..."
    root -l -b -q $nyx"/"prod_reco.C\($nevt,\"$outprefix\"\) > $outprefix"_reco.log" 2>&1

    echo "Started Ideal PID..."
    root -l -b -q $nyx"/"prod_pid.C\($nevt,\"$outprefix\"\) > $outprefix"_pid.log" 2>&1 

    echo "Finished Simulating..."
    echo ""

fi

# ---------------------------------------------------------------
#                            Initiate Analysis
# ---------------------------------------------------------------
if [[ $opt == *"ana"* ]]; then
    
    echo "Starting Analysis..."
    #root -l -b -q $nyx"/"ana_ntp.C\($nevt,\"$outprefix\"\) > $outprefix"_ana_ntp.log" 2>&1
    root -l -b -q $nyx"/"prod_ana.C\($nevt,\"$outprefix\",$IsSignal\) > $outprefix"_ana.log" 2>&1
    echo "Finishing Analysis..."
    echo ""
    
fi

