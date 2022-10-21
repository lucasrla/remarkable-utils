
# reMarkable command-line utils

- [reMarkable command-line utils](#remarkable-command-line-utils)
  - [Clone this repo](#clone-this-repo)
  - [SSH setup](#ssh-setup)
    - [Tweak: auto sleep off](#tweak-auto-sleep-off)
  - [Install remarkable_entware](#install-remarkable_entware)
  - [Install rsync via opkg](#install-rsync-via-opkg)
  - [Use rsync and crontab to run backups automatically](#use-rsync-and-crontab-to-run-backups-automatically)
  - [Re-enable remarkable_entware after a reMarkable software update](#re-enable-remarkable_entware-after-a-remarkable-software-update)
- [Credits and Acknowledgements](#credits-and-acknowledgements)
- [Disclaimers](#disclaimers)

## Clone this repo

```sh
git clone --recursive https://github.com/lucasrla/remarkable-utils.git
# --recursive in order to include the remarkable_entware submodule

# if you need a refresher, see: https://www.vogella.com/tutorials/GitSubmodules/article.html
```

## SSH setup

1. On your reMarkable tablet, go to `Menu > Settings > Help`, then under `About` tap on `Copyrights and licenses`. In `General information`, right after the section titled "GPLv3 Compliance", there will be the username (`root`), password and IP addresses needed for `SSH`.

2. Add the following lines to your `~/.ssh/config`

```conf
Host remarkable
  Hostname IP_ADDRESS_YOU_HAVE_JUST_FOUND
  User root
  ForwardX11 no
  ForwardAgent no
  # reMarkable's SSH is an old version of Dropbear (v2019.78), which seems to use an algorithm considered weak nowadays (Oct 2022)
  # https://matt.ucc.asn.au/dropbear/dropbear.html
  PubkeyAcceptedAlgorithms +ssh-rsa
  HostkeyAlgorithms +ssh-rsa  
  # h/t: https://stackoverflow.com/questions/69875520/unable-to-negotiate-with-40-74-28-9-port-22-no-matching-host-key-type-found-th
```

3. Have a public key ready at `~/.ssh/`

4. Run `ssh-copy-id remarkable`

5. Type your device password. You should see an output similar to:

```sh
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/Users/$USER/.ssh/id_rsa.pub"
...
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? y
Please type 'yes', 'no' or the fingerprint: yes
...
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@192.168.XXX.XXX\'s password:

Number of key(s) added:        1.

Now try logging into the machine, with:   "ssh 'remarkable'"
and check to make sure that only the key(s) you wanted were added.
```

Note: For some reason, `ssh-copy-id` is not working with my reMarkable 2 (`2.15.0.1067`). I had to add my public key to `/home/root/.ssh/authorized_keys` manually.

6. Let's test it out. Type `ssh remarkable`:

```sh
ssh remarkable
  ｒｅＭａｒｋａｂｌｅ
  ╺━┓┏━╸┏━┓┏━┓   ┏━╸┏━┓┏━┓╻ ╻╻╺┳╸┏━┓┏━┓
  ┏━┛┣╸ ┣┳┛┃ ┃   ┃╺┓┣┳┛┣━┫┃┏┛┃ ┃ ┣━┫┗━┓
  ┗━╸┗━╸╹┗╸┗━┛   ┗━┛╹┗╸╹ ╹┗┛ ╹ ╹ ╹ ╹┗━┛
  reMarkable: ~/
```

Voilà! We're in. 

(Type `exit` to get out.)

### Tweak: auto sleep off

On your device, navigate to `Menu > Settings > Battery` and then turn `Auto sleep` off to prevent the device from sleeping unintentedly while we're SSH'ing into it.

## Install remarkable_entware

Use the awesome [reMarkable Entware](https://github.com/Evidlo/remarkable_entware) scripts to install `rsync` and other utilities to your reMarkable device:

```sh
# On your computer's shell
scp remarkable_entware/install.sh remarkable:

ssh remarkable

./install.sh
  ...
  Configuring entware-upgrade.
  Upgrade operations are not required.
  Configuring opkg.
  Configuring zoneinfo-europe.
  Configuring zoneinfo-asia.
  Configuring libstdcpp.
  Configuring entware-release.
  Configuring findutils.
  Configuring entware-opt.

  Info: Congratulations! Entware has been installed.
  ...

# Add /opt/bin & /opt/sbin to PATH
echo PATH=$PATH:/opt/bin:/opt/sbin >> ~/.bashrc

# Check
cat ~/.bashrc
  ...
  PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/bin:/opt/sbin

# Double check
source ~/.bashrc
echo $PATH
  /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/bin:/opt/sbin

# Feel free to exit now
exit
```

## Install rsync via opkg

```sh
# On your computer
ssh remarkable

# Inside your reMarkable
opkg install rsync
  ...

rsync --version
  rsync  version 3.1.3  protocol version 31
  Copyright (C) 1996-2018 by Andrew Tridgell, Wayne Davison, and others.
  Web site: http://rsync.samba.org/
  Capabilities:
      64-bit files, 64-bit inums, 32-bit timestamps, 64-bit long ints,
      no socketpairs, hardlinks, symlinks, IPv6, batchfiles, inplace,
      append, ACLs, xattrs, iconv, symtimes, prealloc

  rsync comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
  are welcome to redistribute it under certain conditions.  See the GNU
  General Public Licence for details.
```

Here are the packages that are available via `opkg`: [http://bin.entware.net/armv7sf-k3.2/Packages.html](http://bin.entware.net/armv7sf-k3.2/Packages.html).

For a collection of community-maintained, reMarkable-specific `opkg` packages, check out [toltec-dev.org/stable](https://toltec-dev.org/stable/) and [github.com/toltec-dev/toltec](https://github.com/toltec-dev/toltec).

## Use rsync and crontab to run backups automatically (from reMarkable device to computer)

First, make sure you have `rsync` installed on your computer and that its protocol version is compatible with the one you have just installed in your reMarkable.

```sh
# On your computer

# Edit rsync-remarkable.TEMPLATE.sh according to your needs

# Save it as rsync-remarkable.sh

# Test it out
# You might need to `mkdir` and `touch` some dirs and files
source rsync-remarkable.sh
```

Then, add it to your `crontab`:

```conf
# On your computer
crontab -e

# Add a new line, like
0 9 * * * source /PATH/TO/rsync-remarkable.sh >> /PATH/TO/rsync-remarkable.log 2>&1

# If you need a refresher: https://crontab.guru
```

## Re-enable remarkable_entware after a reMarkable software update

```sh
# On your computer
scp remarkable_entware/reenable.sh remarkable:

ssh remarkable

./reenable.sh
  Created symlink /etc/systemd/system/local-fs.target.wants/opt.mount → /etc/systemd/system/opt.mount.

  Info: Entware has been re-enabled.

# Double check if rsync is still there
rsync --version
  rsync  version 3.1.3  protocol version 31
  Copyright (C) 1996-2018 by Andrew Tridgell, Wayne Davison, and others.
  Web site: http://rsync.samba.org/
  Capabilities:
      64-bit files, 64-bit inums, 32-bit timestamps, 64-bit long ints,
      no socketpairs, hardlinks, symlinks, IPv6, batchfiles, inplace,
      append, ACLs, xattrs, iconv, symtimes, prealloc

  rsync comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
  are welcome to redistribute it under certain conditions.  See the GNU
  General Public Licence for details.
```

# Credits and Acknowledgements

- The team who wrote and maintains [Entware](https://github.com/Entware/Entware)

- [Evan Widloski](http://evan.widloski.com) who wrote [reMarkable Entware](https://github.com/Evidlo/remarkable_entware)

- [JBB](https://jbbgameich.github.io) who put together [rsync-static](https://github.com/JBBgameich/rsync-static) and started the [reddit thread about rsync](https://www.reddit.com/r/RemarkableTablet/comments/atkrs7/rsync_on_remarkable/) that got me going

For more reMarkable resources, check out the great [awesome-reMarkable](https://github.com/reHackable/awesome-reMarkable) and [remarkablewiki.com](https://remarkablewiki.com/).

# Disclaimers

This is free open source software from hobby project of an enthusiastic reMarkable user.

There is no warranty whatsoever. Use it at your own risk.

> The author(s) and contributor(s) are not associated with reMarkable AS, Norway. reMarkable is a registered trademark of reMarkable AS in some countries. Please see https://remarkable.com for their products.
