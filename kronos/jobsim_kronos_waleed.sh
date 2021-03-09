#!/bin/bash
#
# USAGE:
# sbatch -a<min>-<max> jobsim_kronos.sh <pref> <nevt> <dec> <mom> <saveall>
#
#SBATCH -J pndsim
#SBATCH --time=8:00:00
#SBATCH --get-user-env
#SBATCH -e data/slurmlog/slurm_%j_errout.log
#SBATCH -o data/slurmlog/slurm_%j_errout.log


if [ $# -lt 1 ]; then
  echo -e "\nJob script for submission of PandaRoot simulation jobs on KRONOS.\n"
  echo -e "USAGE: sbatch -a<min>-<max> jobsim_kronos.sh <prefix> <nevts> <gen> <pbeam> [opt] [mode]\n"
  echo -e " <min>     : Minimum job number"
  echo -e " <max>     : Maximum job number"
  echo -e " <prefix>  : Prefix of output files"
  echo -e " <nevts>   : Number of events to be simulated"
  echo -e " <gen>     : Name of EvtGen decay file 'xxx.dec:iniRes'. Keyword 'DPM/FTF/BOX' instead runs other generator"
  echo -e " <pbeam>   : Momentum of pbar-beam."
  echo -e " [opt]     : Optional options: if contains 'savesim', sim output is copied as well, 'ana' runs prod_ana.C in addition.";
  echo -e " [mode]    : Optional mode number for analysis.\n";
  echo -e "Example 1 : sbatch -a1-20 jobsim_kronos.sh d0sim 1000 D0toKpi.dec 12. ana 10"
  echo -e "Example 2 : sbatch -a1-20 jobsim_kronos.sh dpmbkg 1000 dpm 12."
  echo -e "Example 3 : sbatch -a1-20 jobsim_kronos.sh singleK 1000 box:type[321,1]:p[0.05,8]:tht[0,180]:phi[0,360] 12.\n"

  exit 1
fi

# the working directory
nyx=$VMCWORKDIR"/macro/run"

# the data store
_target=$nyx"/data/"

# default parameter settings
prefix=evtcomplete
nevt=10
dec="p_jpsi2pi_jpsi_mumu.dec"
mom=15.0
opt=""
mode=0
run=$SLURM_ARRAY_TASK_ID

#create and change to a temporary directory to run root
tmpdir="/tmp/"$USER"_"$SLURM_JOB_ID"_"$run"/"
mkdir $tmpdir
cd $tmpdir
echo "tmpdir is "$tmpdir
echo "SIMPATH is "$SIMPATH
echo "FAIRROOTPATH is "$FAIRROOTPATH


# check which parameters are set
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

# if local dec-file given, prepend the absolute path to it
if [[ $dec == *".dec"* ]]; then
  if [[ $dec != \/* ]] ; then
	dec=$nyx"/"$dec
  fi
fi

if [[ $dec == *".DEC"* ]]; then
  if [[ $dec != \/* ]] ; then
	dec=$nyx"/"$dec
  fi
fi

echo "Using decay file "$dec

# the prefix with appendend run number ($SLURM_ARRAY_TASK_ID)
outprefix=$prefix"_"$run
simfile=$outprefix"_sim.root"
digiprefix=$prefix"_digi"
#
# run the simulation
#
#root -l -q -b $nyx"/"sim_complete_vis.C\(\"$outprefix\",$nevt,$mom\) &> $outprefix"_sim.log"
root -l -q -b $nyx"/"evtgen_complete.C\(\"$outprefix\",$nevt\) &> $outprefix"_sim.log"

root -l -q -b $nyx"/"digi_complete.C\(\"$outprefix\",0\) &> $outprefix"_digi.log"

cp $outprefix"_digi.log" $_target
cp $outprefix"_digi.root" $_target

# ls in tmpdir to appear in slurmlog
ls -ltrh $tmpdir

# move outputs to target dir
mv  $outprefix"_par.root" $_target
mv  $outprefix"_sim.log" $_target
mv  $outprefix"_sim.root" $_target

# tidy up
rm -rf $tmpdir
