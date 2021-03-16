## _Slurm User Guide (UPPMAX)_
## Slurm Commands

```bash
interactive 		# Start an interactive session
sbatch 				# Submit a batch script to Slurm.
srun				# Typically used inside batch job scripts for running parallel jobs
squeue				# View information about jobs located in the Slurm scheduling queue
scancel				# Cancel one or more of your jobs.
scontrol			# Administrative tasks.
sinfo				# View information about Slurm nodes and partitions.
```

## Submitting Jobs 

```bash
# interactive
$ interactive -n 1 -t 2:00:00 -A p2010999					# Interactive job on one core
$ interactive -n 80 -t 15:00 -A p2010999 --qos=short    	# Interactive job on four nodes

# sbatch
$ sbatch job_script_file.sh						    	    # sbatch job

# srun
$ srun -A g2020014 -t 0:59:00 -p core -n 4 -M snowy \
--gres=gpu:t4:1 singularity run --nv container.sif
```

## Cancelling Jobs

```bash
$ scancel 4456      						    # Cancel a job with job ID '4456'
$ scancel –u aakram								# Cancel all my jobs
$ scancel –n hitpairs							# Cancel a job named 'hitpairs'
$ scancel –j <jobid>							# Cancel a job with <jobid>
$ scancel -i -u aakram				 			# kills all your jobs, but confirm first.
$ scancel -u aakram --state=pending 			# terminates all your pending jobs
$ scancel -u aakram -n <firsttest> -t running 	# kills all your running jobs that are named 'firsttest'
```	

## Monitoring Jobs
```bash
$ jobinfo | less								# how many jobs are running? Type **q** to quit.
$ jobinfo –u aakram								# Find job ids with username **aakram**

$ squeue 										# view information about jobs in queue
$ squeue -u username 							# view jobs from username=aakram
$ squeue -j jobid								# view job with a jobid
$ squeue -p partition							# 
$ squeue -q qos									#
$ squeue -M snowy							    # use `-M snowy` to request info on cluster snowy
$ squeue -M snowy -u aakram 					# list all jobs on cluster=snowy from user aakram
$ scontrol show job -M snowy 3019023			# sbatch enques our job. Use scontrol to see its stats
$ cat slurm-3019023.out						    # OR use the `slurm-jobid.out` file
```

## Important Commands
You will probably have good use of the following commands:

```bash
$ uquota 										# telling you about your file system usage.
$ projinfo  									# telling you about the CPU hour usage of your projects.
$ jobinfo  										# telling you about running and waiting jobs on Snowy.
$ finishedjobinfo  								# telling you about finished jobs on Snowy.
$ projmembers  									# telling you about project memberships.
$ projsummary [project id]  					# summarizes some useful information about projects
$ uppmax_jobstats								# UPPMAX Job Statistics
$ scontrol show job <job id>					# 
$ finishedjobinfo –s today						# 
```

## Testing in devel partition

- `-p devcore –n 4 –t 60`
	- Normal sbatch job: sbatch flags jobscript input
	- Run on four cores for 60 minutes
	- Note: Max one job submitted
	- Job starts quickly!
		- **Example:** Before submitting the real job, I want to make sure the script and submit works as intended. 


## SNOWY Cluster from RACKHAM
For SLURM commands and for commands like `projinfo`, `jobinfo` and `finishedjobinfo`, you may use the `-M` flag to ask for the answer to be given for a system that you are not logged in to, e.g., when logged into **Rackham**, you may ask about information about current core hour usage on **Snowy**, with the command `projinfo -M Snowy`.

**Note:** When acessing snowy from Rackhams login nodes you must always use the flag -M for all SLURM commands. For examples:

```bash
$ squeue -M snowy
$ jobinfo -M snowy
$ sbatch -M snowy slurm_script_file
$ scancel -u username -M snowy
$ interactive -A projectname -M snowy -p node -n 32 -t 01:00:00
```

**Note:** We always recommend loading all your modules in your job script file, This is even more important when running on Snowy since the module environment is not the same on the Rackham login nodes as on Snowy compute nodes.

```bash
$ sinfo -p [core/devcore/node/devel]
$ sinfo -M snowy -p node                    # for Snowy cluster from Rackham
$ jobinfo -M snowy -p node
$ jobinfo -M snowy -u aakram
```
	
	
## Difference between devel partition and devcore partition
Sometimes it is too expensive to pay for a full node, if you only need one core or a few. So, we have now configured a new partition, named "devcore". It covers the same physical nodes as the "devel" partition, but you can ask for single cores or multiple cores, like in the "core" partition. Some examples:

- `-p devcore -n 8` asks for eight cores and the proportional amount of RAM
- `-p devcore -n 1` on Rackham gives you one core and 6.4 GB of RAM
- `-p devcore -n 10` on Rackham gives you ten cores and 64 GB of RAM
- `-p devel -n 20` on Rackham gives you all cores and 128 GB of RAM
- `-p devcore -n 1` on Snowy gives you one core and 8 GB of RAM
- `-p devcore -n 8` on Snowy gives you eight cores and 64 GB of RAM
- `-p devel -n 16` on Snowy gives you all cores and 128 GB of RAM

So, what is the difference on Snowy between -p devcore -n 16 and -p devel -n 16?
None at all! In both cases, you ask for all cores on the node and all RAM on the node.


## Sbatch Flags

```bash
# sbatch flags
-A, --account=<account>                # e.g. --account=g2020014
-J, --job-name=<jobname>               # e.g. --job-name=HitPairs
-M, --clusters=<string>                # e.g. --clusters=snowy
-N, --nodes=<minnodes[-maxnodes]>      # e.g. --nodes=2
-p, --partition=<partition_names>      # e.g. --partition=node
-t, --time=<time>                      # e.g. --time=0:59:00 
-q, --qos=<qos>                        # e.g. --qos=15
-c, --cpus-per-task=<ncpus>            # e.g. --cpus-per-task=8
-n, --ntasks=<number>                  # e.g. --ntasks=2
-G, --gpus=[<type>:]<number>           # e.g. --gpus=t4:1 OR --gpus=volta:3,kepler:1 (comma separated list)

--gres=name[[:type]:count]             # e.g. --gres=gpu:t4:1

--cpus-per-gpu=<ncpus>                 # not compatible with --cpus-per-task
--ntasks-per-node=<ntasks>             # e.g. 
--ntasks-per-core=<ntasks>             # e.g.	
--gpus-per-node=[<type>:]<number>      # e.g.
--gpus-per-task=[<type>:]<number>      # e.g.
```

## Example Scripts

```bash	
# Example sbatch Script (1)		

#!/bin/sh
#SBATCH -A g2020014 -J hitpairs -M snowy -c16 -N2 --gres=gpu:t4:1 -t 0:59:00 --parsable
	
CENV=${5-tf-gpu}
CONTAINER=${6-container.sif}
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$1" && exit
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$2" && exit
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$3" && exit
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$4" && exit
```

```bash
# Example sbatch Script (2)

#!/bin/sh
#SBATCH -A g2020014						    # Account Name
#SBATCH -J hitpairs						    # Some Job Name
#SBATCH -M snowy						    # Cluster Name
#SBATCH -t 0:59:00						    # Time (DD-HH:MM)
#SBATCH -p node							    # Partition (node, core or devcore)
#SBATCH -N 2							    # Number of Nodes Requested
#SBATCH -c 16							    # Number of CPUs or Cores per Task
#SBATCH --gres=gpu:t4:1                     # Number of GPUs per Node
#SBATCH --gpus-per-node=t4:1			    # Number of GPUs per Node
#SBATCH --mail-type=END
#SBATCH --mail-user=adeel.chep@gmail.com
#SBATCH --parsable						    # Parseable
	
CENV=${5-tf-gpu}
CONTAINER=${6-container.sif}
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$1" && exit
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$2" && exit
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$3" && exit
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && jupyter lab --ip=127.0.0.1 --port=$4" && exit
```

```bash
# Example sbatch Script (3)

#!/bin/bash -l
#SBATCH -A g2020014						# Account Name
#SBATCH -J hitpairs						# Some Job Name
#SBATCH -M snowy						# Cluster Name
#SBATCH -t 0:59:00						# Time (DD-HH:MM)
#SBATCH -p node							# Partition (node, core or devcore)
#SBATCH -N 2							# Number of Nodes Requested
#SBATCH -c 16							# Number of CPUs or Cores per Task
#SBATCH --gres=gpu:t4:1                 # Number of GPUs per Node
#SBATCH --gpus-per-node=t4:1			# Number of GPUs per Node
#SBATCH --mail-type=END
#SBATCH --mail-user=adeel.chep@gmail.com
#SBATCH --parsable						# Parseable
	
CENV=${tf-gpu}
CONTAINER=${container.sif}
singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && python main.py"
```


```bash	
# Run sbatch Script
$ sbatch job_script_file.sh
```
