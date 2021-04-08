## USAGE:

```bash
resub.pl "<cmd>" [check]
```
## Examples:
```bash
./resub.pl "sbatch -a1-20 jobsim_kronos.sh d0sim 1000 D0toKpi.dec 12." check    # prints out the failed job numbers and the submission commands
./resub.pl "sbatch -a1-20 jobsim_kronos.sh d0sim 1000 D0toKpi.dec 12."          # actual re-submission of the jobs
```

## Commands:
```
./resub.pl "sbatch -a1-50 --get-user-env -t 8:00:00 -o '%x-%j.out' -e '%x-%j.err' -J test --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_complete.sh test 2000 llbar_fwp.DEC 1.642" check

./resub.pl "sbatch -a1-500 --get-user-env -t 8:00:00 -o '%x-%j.out' -e '%x-%j.err' -J efwp1 --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_complete.sh efwp1 2000 llbar_fwp.DEC 1.642" check

./resub.pl "sbatch -a1-500 --get-user-env -t 8:00:00 -o '%x-%j.out' -e '%x-%j.err' -J ebkg1 --mail-type=END --mail-user=a.akram@gsi.de -D $SLURM_WORKING_DIR -- $SLURM_SUBMIT_DIR/jobsim_complete.sh ebkg1 2000 llbar_bkg.DEC 1.642" check
```

## Monitor Jobs: 

```bash
squeue -n $SLURM_JOB_NAME
scontrol show job $(squeue -ho %A -n $SLURM_JOB_NAME) | grep StdOut
squeue -u $USER
```