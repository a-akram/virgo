#!/bin/bash

# USAGE: $ ./runext.sh 10000 llbar bkg llbar_bkg.DEC 1.642

#Set paths
. "/home/adeel/fair/pandaroot_dev/trackml-20-01-21/config.sh"

# Defaults
nevt=10000
prefix=llbar
mode="fwp"         # fwp, bkg, dpm
mom=1.642

# Flags
sim="simall"
ana="anaall"
opt=""

# Set Path (Fix Accordingly for GSI)
nyx="/lustre/nyx/panda/aakram/virgo"

# From User
if test "$1" != ""; then
  nevt=$1
fi

if test "$2" != ""; then
  prefix=$2
fi

if test "$3" != ""; then
  mode=$3
fi

dec=$prefix"_"$mode".DEC"
outprefix=$prefix"_"$mode

if [[ $mode == "fwp" ]]; then
    _target=$nyx"/1_"$mode
fi

if [[ $mode == "bkg" ]]; then
    _target=$nyx"/2_"$mode
fi 

if [[ $mode == "dpm" ]]; then
    _target=$nyx"/3_"$mode
    dec="dpm"
fi 

# Test Flags
echo ""
echo "Prefix: $outprefix"
echo "Option: $nevt, $outprefix, $mode, $dec, $mom"
echo "Target: $_target"
echo ""


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

    echo "Starting Analysis..."
    #root -b -q prod_anaideal.C\($nevt,\"$outprefix\"\) > $outprefix"_ana.log" 2>&1
    #root -b -q ana_ntp.C\($nevt,\"$outprefix\"\) > $outprefix"_anantp.log" 2>&1
    echo "Finishing Simulation..."
    echo ""
fi



# run analysis
if [[ $ana == *"anaall"* ]]; then

    echo ""
    echo "Starting Analysis..."
    root -b -q prod_anaideal.C\($nevt,\"$outprefix\"\) > $outprefix"_ana.log" 2>&1
    root -b -q ana_ntp.C\($nevt,\"$outprefix\"\) > $outprefix"_ana_ntp.log" 2>&1
    echo "Finishing Analysis..."
    echo ""
fi

# copy all output to storage element
if [[ $opt == *"saveall"* ]]; then
   cp  $outprefix"_par.root" $_target
   cp  $outprefix"_sim.log" $_target
   cp  $outprefix"_sim.root" $_target
   cp  $outprefix"_digi.log" $_target
   cp  $outprefix"_digi.root" $_target
   cp  $outprefix"_reco.log" $_target
   cp  $outprefix"_reco.root" $_target
   cp  $outprefix"_pid.log" $_target
   cp  $outprefix"_pid.root" $_target
   cp  $outprefix"_ana.root" $_target
fi


# move all output to storage element
if [[ $opt == *"moveall"* ]]; then
   mv  $outprefix"_par.root" $_target
   mv  $outprefix"_sim.log" $_target
   mv  $outprefix"_sim.root" $_target
   mv  $outprefix"_digi.log" $_target
   mv  $outprefix"_digi.root" $_target
   mv  $outprefix"_reco.log" $_target
   mv  $outprefix"_reco.root" $_target
   mv  $outprefix"_pid.log" $_target
   mv  $outprefix"_pid.root" $_target
   mv  $outprefix"_ana.root" $_target
fi

