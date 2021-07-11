
## Building Singularity Container for PandaRoot


### (i) - Interactive Method

Using on terminal for testing.

```bash
# fetch & build 'pandaroot' container from docker with fakeroot (-f) and sandbox (-s)
# for base OS ubuntu 18.04
adeel@phy-akre:~$ singularity build -f -s pandaroot docker://ubuntu:18.04
adeel@phy-akre:~$ singularity exec --no-home -f -w pandaroot/ bash -l

# Now we will have Singularity Prompt, first run PWD
Singularity> pwd
/root

# Now update, upgrade and install
Singularity> apt update && apt upgrade -y && apt install git

# Install FairSoft
Singularity> git clone -b apr21_patches https://github.com/FairRootGroup/FairSoft
Singularity> FairSoft/legacy/setup-ubuntu.sh  # install dependencies
Singularity> FairSoft/bootstrap-cmake.sh FairSoft/install  # install cmake to FairSoft/install folder
Singularity> export PATH=/root/FairSoft/install/bin:$PATH  # export path to use cmake, one can install sys wide.
Singularity> cmake -S FairSoft -B /tmp/fairsoft -C FairSoft/FairSoftConfig.cmake  # config for build
Singularity> cmake --build /tmp/fairsoft --target geant4-configure -j8  # start build process
```

### (ii) - Definition Method
Use a definition file to automate whole process. Good for production level usage.

See `pandaroot.def` for details.