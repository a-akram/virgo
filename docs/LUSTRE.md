
## Mounting Remote Storage

- using `sshfs`


### (+) -  Mount GSI user Home Directory from the Login Nodes:


```bash
# mount gsi linux $HOME to $mnt
adeel@phy-akre:~$ mnt=/tmp/u/$USER          
adeel@phy-akre:~$ mkdir -p $mnt
adeel@phy-akre:~$ sshfs $USER@lxpool: $mnt
adeel@phy-akre:~$ ls $mnt
```


### (+) -  Mount Lustre Shared Storage from the lustre.hpc.gsi.de nodes using a Proxy Jump over a Login Nodes:

```bash
# mount lustre $HOME to $mnt
adeel@phy-akre:~$ mnt=/tmp/lustre
adeel@phy-akre:~$ mkdir $mnt
adeel@phy-akre:~$ sshfs -o ProxyJump=lxpool lustre.hpc.gsi.de:/lustre $mnt 

# However, above command gives error.
```

Work around is to use `~/.ssh/config` for proxy jump to lustre storage. First add following config settings.

```bash
# proxy jump using ~/.ssh/config

Host lxpool
  User aakram
  Hostname lxpool.gsi.de
  CheckHostIP no
  ForwardX11 yes

host lxpool-lustre
  ProxyJump lxpool
  User aakram
  Hostname lustre.hpc.gsi.de
  CheckHostIP no
```
___

```bash
# now use sshfs
sshfs lxpool-lustre:/lustre/panda/aakram /tmp/lustre/
```

____
Now to unmount the storage use

```bash
# unmount remote storage
fusermount -u /tmp/lustre
```