
## LOGIN to Virgo

```bash
# proxy jump to Virgo Submit Node
ssh -J aakram@lxpool.gsi.de aakram@virgo-debian8.hpc.gsi.de
ssh -J lxpool aakram@virgo-debian8.hpc.gsi.de
ssh lxpool-virgo-debian8
```

## Tools on Virgo

### (+) - Terminal Multiplexer (tmux)

See tmux guide in Dropbox for details. 

```bash
# start tmux
tmux
# at some point use `C-b d` to detach
# close your SSH session, and eventully login again later
# list all sessions managed by the server
tmux list-sessions
# attach to most recently used session
tmux attach-session
```

### (+) - Git Protocol Proxy

Git uses several protocols for client-server communication:

| Protocol    | Example Connection Address            | Virgo |
| ----------- | -----------                           |------ |
| https       | https://example.com/repository.git    | Yes   |
| ssh         | git@example.com/repository.git        | No    |
| git         | git://example.com/repository.git      | Yes, but set Git Proxy|

```bash
# create a helper script with the proxy command
cat > gitproxy <<'EOF'
#! /bin/bash
exec ssh lx-pool.gsi.de nc "$@"
EOF
# make sure that is is executable
chmod +x gitproxy
# set an environment variable to use a proxy command
export GIT_PROXY_COMMAND=$PWD/gitproxy
```

### (+) - Singularity Containers

- See official guide or SeSEGPU repo for building **Singularity Containers** for HPCs.



----




## SLURM Guide

```bash
sinfo       # Information on cluster partitions and nodes
squeue      # Overview of jobs and their states
scontrol    # View configuration, states, (un-)suspending jobs
srun        # Run executable as job (blocks until the job is scheduled)
salloc      # Submit an interactive job. (blocks until prompt appears)
sbatch      # Submit a job script for batch scheduling
scancel     # Cancels a running or pending job
```

### (a) - Arguments & Options
```
                   ┌─── SLURM resource allocation with options
                   │
┌──────────────────┤
sbatch -p debug -N 1 -- root.exe -b /path/to/macro.C
                        ├──────────────────────────┘
                        │
                        └─── User application with options
```


### Partitions

```bash
# inspect the partition configuration, access control, limits
scontrol show partition $name

# partition state summary with no node state details
sinfo -s       # NODES(A/I/O/T) available/idle/other/total

# show default runtime and runtime limits
sinfo -o "%9P  %6g %11L %10l %5D %20C"

# show CPUs and memory per node
sinfo -o "%9P %6g %4c %6z %6m %5D %20C"

# show hardware resources on idle nodes
sinfo -Nel -t idle
```

Note that the suffix `*` identifies the default partition.

Option                                          | Description
------------------------------------------------|-------------------
`-p <partition>`,<br/> `--partition=<partition` | Request a specific partition for the resource allocation.

`salloc`, `srun`, and `sbatch` support the command option above to **select a
partition**.

```bash

# using a partition, for example
sbatch --partition=debug ...
```

### (b) - Submitting Jobs

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


```bash
# submitt job
$ sbatch test.sh

Submitted batch job 3235548 on cluster snowy

# dry-run job
$ sbatch --test-only test.sh

sbatch: Job 3235632 to start at 2020-12-03T13:05:41 using 32 processors on nodes s[152,162] in partition node
```


### (c) - Information on Jobs

- `squeue`
- `scontrol`

---
```bash
# squeue
squeue -u $USER                   # List all jobs for <username> on Snowy cluster
squeue -u $USER -t RUNNING        # List all RUNNING jobs for a user, add -M snowy if needed
squeue -u $USER -t PENDING        # List all PENDING jobs for a user, add -M snowy if needed
squeue -u $USER -p shared         # List all current jobs in the shared partition for a user:

squeue -n <jobname>               # List a job with <jobname> on Snowy cluster
squeue -j <jobid>                 # Detail of <jobid>
squeue -j <job_list>              # Details of <job-list>=345,346,348 (comma separated list)
```
----
```bash
# scontrol
scontrol show job <jobid>         # Detail of <jobid>
scontrol show jobid -dd <jobid>   # List detailed information for a job 
```

The examples are given below:

```bash
# Examples
$ scontrol show job 3235548
... 

$ cat slurm-3235548.out
```

### (d) - Controlling Jobs

- `scancel`
- `scontrol`

---
```bash
# scancel
scancel -u $USER			              # To cancel all the jobs for a user
scancel -u $USER -t RUNNING               # To cancel all the Running jobs for a user
scancel -u $USER -t PENDING               # To cancel all the Pending jobs for a user
scancel -u $USER -n <jobname> -t running  # kills all your running jobs that are named 'firsttest'

scancel <jobid>					          # To cancel a job with <jobid>
scancel -n <jobname>                      # To cancel a job with <jobname> (-n, --name)
scancel -j <job_list>                     # Cancel jobs from a list
scancel -i -u <username>                  # '-i', ask for confirmation
```
___
```bash
# scontrol
scontrol hold <jobid>                     # To hold a particular job from being scheduled:
scontrol release <jobid>                  # To release a particular job to be scheduled:
scontrol requeue <jobid>                  # To requeue (cancel and rerun) a particular job:
```

### (e) - Advance Commands

```bash
# print job ID, name, and comment
squeue -o '%25A %10j %10k' -n pndsim

# inspect the partition configuration, access control, limits
scontrol show partition $name

# partition state summary with no node state details
sinfo -s       # NODES(A/I/O/T) available/idle/other/total

# show default runtime and runtime limits
sinfo -o "%9P  %6g %11L %10l %5D %20C"

# show CPUs and memory per node
sinfo -o "%9P %6g %4c %6z %6m %5D %20C"

# show hardware resources on idle nodes
sinfo -Nel -t idle

# investigate the job configuration
scontrol show job $SLURM_JOB_ID | grep Time

# Check if the state of the job using the squeue command:
squeue --format='%6A %8T %8N %9L %o' --name=sleep

# Use the sinfo command to overview resource limits for nodes in their corresponding Partitions:
sinfo -o "%9P  %6g %11L %10l %10m %5D %7X %5Y %7Z"

# Use the sinfo command to list runtime limits:
sinfo -o "%9P %6g %11L %10l %5D %20C"

# Print the number of sockets, cores and threads with sinfo:
# The -e, --exact option list all available node configurations explicilty.

sinfo -e -o '%9P %4c %8z %8X %8Y %8Z %5D %N'

```

**NOTE:** Everything is good to go.