#!/bin/bash

# Export Variables
export LUSTRE_HOME="/lustre/panda/"$USER
export SLURM_SUBMIT_DIR=$LUSTRE_HOME"/virgo"
export SLURM_WORKING_DIR=$LUSTRE_HOME"/virgo/logs"
export SLURM_JOB_NAME="stdbkg"

# Submit Jobs

# sbatch --get-user-env -t 8:00:00 -a1-10 --output='%x-%j.out' --error='%x-%j.err' \ 
#        --job-name=$SLURM_JOB_NAME --comment '1m-fwp' --mail-type=END \
#        --mail-user=a.akram@gsi.de --chdir=$SLURM_WORKING_DIR \
#        -- $LUSTRE_HOME/jobsim_aod.sh llbar 100 fwp

# Quick Test
# sbatch --get-user-env -t 8:00:00 -a1-5 -o '%x-%j.out' -e '%x-%j.err' -J $SLURM_JOB_NAME --comment 'test' --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_complete.sh llbar 10 fwp

# Example 1:
# sbatch --get-user-env -t 8:00:00 -a1-100 -o '%x-%j.out' -e '%x-%j.err' -J $SLURM_JOB_NAME --comment '1m-fwp' --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_aod.sh llbar 1000 fwp

# Example 2:
sbatch --get-user-env -t 8:00:00 -a1-100 -o '%x-%j.out' -e '%x-%j.err' -J $SLURM_JOB_NAME --comment '1million' --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_complete.sh llbar 10000 bkg


# Monitor Jobs 
# squeue -n $SLURM_JOB_NAME
# scontrol show job $(squeue -ho %A -n $SLURM_JOB_NAME) | grep StdOut
squeue -u $USER
