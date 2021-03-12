#!/bin/bash
#SBATCH -J pndana
#SBATCH --time=8:00:00
#SBATCH --get-user-env
#SBATCH -e data/llbar/slurmlog/slurm_%j_errout.log
#SBATCH -o data/llbar/slurmlog/slurm_%j_errout.log

#Set paths
. "/lustre/nyx/panda/walter/oct19/build/config.sh"

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
  echo -e "Example 1: sbatch jobana_kronos.sh d0sim 1 10 42\n"
  echo -e "Example 2 : sbatch -a1-20 jobana_kronos.sh ll"
  
  exit 1
fi

nyx="/lustre/nyx/panda/aakram/AdeelProdMarco"
_target=$nyx"/data/bkg/"

prefix=ll
from=1
to=20
mode=0
run=$SLURM_ARRAY_TASK_ID

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

outprefix=$_target$prefix"_"$run
pidfile=$outprefix"_pid.root"

root -l -q -b $nyx"/"prod_ana_fast.C\(\"$pidfile\",0,0,$mode,0\) &> $outprefix"_ana.log"



