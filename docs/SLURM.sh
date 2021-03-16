#!/bin/sh
#S-BATCH -A g2020014 -J HitPairs -M snowy -p node -n 2 -c16 -N2 --gres=gpu:t4:1 -t 0:59:00

# OR
#SBATCH -A g2020014											# Account Name (--account=g2020014)
#SBATCH -J HitPairs											# Job Name (--job-name=HitPairs)
#SBATCH -M snowy											# Cluster Name (--clusters=snowy)
#SBATCH -t 0:59:00											# Time (DD-HH:MM) (--time=0:59:00)
#SBATCH -p node												# Partition (node/core/devcore) (--partition=node)
#SBATCH -N 2												# No. of Nodes Requested (--nodes=2)

#SBATCH --ntasks-per-node 8
#SBATCH --gpus-per-task 1
#SBATCH --cpus-per-task=16									# No. of CPUs/Task (-c)
#SBATCH --cpus-per-gpu=8									# No. of CPUs/GPU (not compatible with -c flag)
#SBATCH --gres=gpu:t4:1                 					# No. of GPUs/Node
#SBATCH --gpus-per-node=t4:1								# No. of GPUs/Node

#SBATCH --parsable											# Parseable

##SBATCH -o backup/%a-%.out									# Output (--output=<filename pattern>), keep default
#SBATCH --mail-type=END										# Notification Type
#SBATCH --mail-user=adeel.chep@gmail.com					# Email for notification
	
echo "== --------------------------------------------"
echo "== Starting Run at $(date)"
echo "== SLURM Cluster: ${SLURM_CLUSTER_NAME}"				# 
echo "== --------------------------------------------"
echo "== SLURM CPUS on GPU: ${SLURM_CPUS_PER_GPU}"    		# Only set if the --cpus-per-gpu is specified.
echo "== SLURM CPUS on NODE: ${SLURM_CPUS_ON_NODE}"			#
echo "== SLURM CPUS per TASK: ${SLURM_CPUS_PER_TASK}" 		# Only set if the --cpus-per-task is specified.
echo "== --------------------------------------------"
echo "== SLURM No. of GPUS: ${SLURM_GPUS}"					# Only set if the -G, --gpus option is specified.
echo "== SLURM GPUS per NODE: ${SLURM_GPUS_PER_NODE}"		# 
echo "== SLURM GPUS per TASK: ${SLURM_GPUS_PER_TASK}"		#
echo "== --------------------------------------------"
echo "== SLURM Job ID: ${SLURM_JOB_ID}"				 		# OR SLURM_JOBID. The ID of the job allocation.
echo "== SLURM Job ACC: ${SLURM_JOB_ACCOUNT}"				# Account name associated of the job allocation. 	
echo "== SLURM Job NAME: ${SLURM_JOB_NAME}"					# Name of the job.
echo "== SLURM Node LIST: ${SLURM_JOB_NODELIST}"	 		# OR SLURM_NODELIST. List of nodes allocated to job.
echo "== SLURM No. of NODES: ${SLURM_JOB_NUM_NODES}" 		# OR SLURM_NNODES. Total #nodes in job's resources.
echo "== SLURM No. of CPUs/NODE: ${SLURM_JOB_CPUS_PER_NODE}" #  
echo "== --------------------------------------------"
echo "== SLURM Node ID: ${SLURM_NODEID}"		 			# ID of the nodes allocated.
echo "== SLURM Node Name: ${SLURMD_NODENAME}"		 		# Name of the node running the job script
echo "== SLURM No. of Tasks: ${SLURM_NTASKS}"		 		# OR SLURM_NPROCS. Similar as -n, --ntasks
echo "== SLURM No. of Tasks/Core: ${SLURM_NTASKS_PER_CORE}" # Only set if the --ntasks-per-core is specified.
echo "== SLURM No. of Tasks/Node: ${SLURM_NTASKS_PER_NODE}" # Only set if the --ntasks-per-node is specified.
echo "== SLURM Submit Dir. : ${SLURM_SUBMIT_DIR}"			# Dir. where sbatch was invoked. Flag: -D, --chdir.
echo "== --------------------------------------------"

# CENV=${5-tf-gpu}
# CONTAINER=${6-container.sif}
# singularity run --nv /proj/g2020014/nobackup/private/$CONTAINER -c "conda activate $CENV && python main.py"
singularity run --nv /proj/g2020014/nobackup/private/container.sif -c "conda activate tf-gpu && python main.py"
