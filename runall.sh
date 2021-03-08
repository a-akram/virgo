#!/bin/bash

if [ $# -lt 3 ]; then
  echo -e "\nJob script for submission of PandaRoot simulation jobs on KRONOS.\n"
  echo -e "USAGE: runall.sh <nevt> <prefix> <mode> <dec> <pbeam>\n"
  echo -e " <nevts>   : Number of events to be simulated"
  echo -e " <prefix>  : Prefix of output files"
  echo -e " <mode>    : Optional mode number for analysis (fwp, bkg, dpm)."
  echo -e " <dec>     : Name of EvtGen decay file 'xxx.dec'. Keyword 'DPM/FTF/BOX' runs other generator"
  echo -e " <pbeam>   : Momentum of pbar-beam."
  echo -e " [opt]     : Optional options: if contains 'savesim', sim output is copied as well.\n"
  echo -e "Example 1 : runall.sh 10000 llbar bkg llbar_bkg.DEC 1.642"
  echo -e "Example 2 : runall.sh 10000 llbar bkg"
  
  exit 1
fi


#Shared Storage on Cluster
#LUSTRE_HOME=/lustre/$(id -g -n)/$USER
LUSTRE_HOME="/lustre/panda/"$USER
WORKING_HOME=$LUSTRE_HOME"/virgo"
_target=$WORKING_HOME"/data/bkg/"

#PandaRoot Path
#. $LUSTRE_HOME"/pandaroot/build-oct19/config.sh"
. "/lustre/panda/aakram/pandaroot/build-oct19/config.sh"

#Default Parameters
nevt=10000
prefix=llbar
mode="fwp"                  # fwp, bkg, dpm
dec="llbar_fwp.DEC"
mom=1.642


#Macro Directory
nyx=$WORKING_HOME

# User Input
if test "$1" != ""; then
  nevt=$1
fi

if test "$2" != ""; then
  prefix=$2
fi

if test "$3" != ""; then
  mode=$3
  dec="llbar_"$mode".DEC"
fi

if test "$4" != ""; then
  dec=$4
fi

if test "$5" != ""; then
  mom=$5
fi

outprefix=$prefix"_"$mode

if [[ $mode == "fwp" ]]; then
    _target=$nyx"/1_"$mode
    dec="llbar_fwp.DEC"
fi

if [[ $mode == "bkg" ]]; then
    _target=$nyx"/2_"$mode
    dec="llbar_bkg.DEC"
fi 

if [[ $mode == "dpm" ]]; then
    _target=$nyx"/3_"$mode
    dec="dpm"
fi


# Dispaly Params
echo "Display Params:"
echo "(1) - Prefix: $outprefix"
echo "(2) - Option: $nevt, $outprefix, $mode, $dec, $mom"
echo "(3) - Target: $_target"
echo ""


# Set Flags
sim=""
ana=""

# run simulation
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



# run analysis
if [[ $ana == *"anaall"* ]]; then

    echo ""
    echo "Starting Analysis..."
    #root -b -q $nyx"/"prod_anaideal.C\($nevt,\"$outprefix\"\) > $outprefix"_ana.log" 2>&1
    root -b -q $nyx"/"ana_ntp.C\($nevt,\"$outprefix\"\) > $outprefix"_ana_ntp.log" 2>&1
    echo "Finishing Analysis..."
    echo ""
fi

