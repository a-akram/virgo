#!/bin/bash

# Export Variables
export LUSTRE_HOME="/lustre/panda/"$USER
export SLURM_SUBMIT_DIR=$LUSTRE_HOME"/virgo"
export SLURM_WORKING_DIR=$LUSTRE_HOME"/virgo"
export SLURM_JOB_NAME="stdsig"

# *** Submit Jobs ***

# Example 1:
# sbatch --get-user-env -t 4:00:00 -a1-10 --output='%x-%j.out' --error='%x-%j.err' --job-name=run1 --chdir=$SLURM_WORKING_DIR -- $LUSTRE_HOME/jobsim_aod.sh llbar 1000 fwp

# Example 2:
# sbatch --get-user-env -t 4:00:00 -a1-10 -o '%x-%j.out' -e '%x-%j.err' -J run1 -D $SLURM_WORKING_DIR -- $LUSTRE_HOME/virgo/jobsim_aod.sh llbar 1000 fwp

# Example 3:
# sbatch --get-user-env -t 4:00:00 -a1-10 -o '%x-%j.out' -e '%x-%j.err' -J run1 -D $SLURM_WORKING_DIR -- $SLURM_WORKING_DIR/jobsim_aod.sh llbar 1000 fwp

# Example 4: (USING)
sbatch --get-user-env -t 4:00:00 -a1-10 -o '%x-%j.out' -e '%x-%j.err' -J $SLURM_JOB_NAME --comment '1m-fwp' --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_aod.sh llbar 10 fwp


# *** Monitor Jobs ***
#squeue -n sleep
#scontrol show job $(squeue -ho %A -n run1) | grep StdOut
