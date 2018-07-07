[![Build Status](https://travis-ci.org/sdkks/DockerizedUbuntuWS.svg?branch=master)](https://travis-ci.org/sdkks/DockerizedUbuntuWS)

# Dockerized Terminal/Workstation
## What is this project about?
Windows On Linux, a.k.a. Windows Linux Subsystem (WSL) is cool, but did you ever want to have an environment that you can tear down and bring up easily and still expect to find it will be operational just as you left it?

This mini project leverages `docker` on Windows to spawn a working environment for you. All you need to do is SSH to this dockerized box, better yet make a terminal emulator like `cmder` to auto start-up every tab with SSH connection to this box.

With minor modification you could use it on Linux or OSX hosts, too, in case you need a temporary environment on a loaner machine.

Note: Won't be focusing on X11 (Graphical) interface for now. It should be possible if you were to install XMing on your Windows and use X11 forwarding in your SSH connection.

## Getting started
This would take to 30 to 90 minutes, depending on your familiarity with the tools used here.
### Prerequisites
1. Docker for Windows. Get it [here](https://docs.docker.com/docker-for-windows/)
2. SSH Client (non-GUI) to connect to container. [This](https://fossbytes.com/enable-built-windows-10-openssh-client/) could be one of possible clients. You should also create an `ssh` public-private key pair if you don't have one. [This]([https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) is one of the ways of doing it.
3. Basic working knowledge of `YAML`, `Docker`, terminal editors (`nano`/`vim`)

### Steps
#### 1. Prepare Docker Compose File
Start by copying sample `docker-compose.example.yml` to `docker-compose.yml`
`cp -iv docker-compose.example.yml docker-compose.yml`
`git` won't track it because `docker-compose.yml` is in `.gitignore`

Modify fields accordingly, you will have something like this:
```yml
version: '3.6'
services:
  bionic:
    build: .
    privileged: true
    container_name: ws
    hostname: galileo
    ports:
     - "2222:22"
    volumes:
      - "home:/home"
      - d:\\:/mnt/d
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always
volumes:
  home:
```

Above example does the following:
1. Create a service named `bionic` and create a container named `ws` within.
2. Docker should forward port `2222` of host to `22` of container `ws`
3. It should mount 3 volumes. A `docker` managed `volume`, my local disk `d:\` and `UDS socket` of `docker daemon` so I can build containers, run web servers, etc. within this container.
4. If this container dies, always restart it. (I think it will survive across reboots but I haven't verified its reliability.)

#### 2. Prepare docker managed volume
If you didn't mount a `docker` managed `volume`, you can skip this step.

I did so for `/home`, so `POSIX` attributes of the files won't be lost. In my setup I have `linuxbrew` under `/home/linuxbrew/.linuxbrew` and my own user `$HOME` of course.

You can do so by simply running a single command in your `cmd` or `powershell`  
`docker volume create home`

For passwordless `ssh` login into your container, you should mount your new volume in a dummy container and paste your `ssh` public-key, usually it's `id_rsa.pub` into your `~/.ssh/authorized_keys`

You could do so using a temporary container and a terminal text editor.
In `cmd` or `powershell`, run this:
`docker run --rm -ti -v home:/home ubuntu:bionic bash`

It will start an interactive session with your terminal. Then enter below commands:
```bash
apt update
apt install nano -y
mkdir -p /home/<yourUserName, i.e. ubuntu>/.ssh/
touch /home/<username above>/.ssh/authorized_keys
chown 1000 /home/<username above>/.ssh/authorized_keys
```

Now you need to paste contents of your `id_rsa.pub` key into `authorized_keys`.

Open it with `nano /home/username/.ssh/authorized_keys` and paste it, use `CTRL+X` to save and exit.

If you prefer `vim`, install `vim` in above steps.

Your private key `id_rsa` should be copied to `c:\Users\yourWindowsUsername\.ssh\id_rsa`

If you already have something like `git-bash`, `msysgit`, `cygwin` or `WSL`, you can generate a pair easily with:  
`ssh-keygen -t rsa -b 2048`

Don't enter passphrase, just press enter since this will be passwordless login.

#### 3. Allow Docker For Windows to mount your local disk
Skip this if you are not mounting your local disk, i.e. Windows disk `C:` or `D:`

I'm mounting `D:` drive, that's where my Dropbox is as well.

Enable shared drive you want to mount. *This will restart your docker daemon, stopping all containers.*
![docker-windows-settings](https://i.imgur.com/jaTXbzI.png "Docker For Windows => Settings")


#### 4. Let docker compose your environment
If you need to install additional packages from `apt` repositories, you can add them int a text file with `.list` extension into `apt.d` directory. It will be ignored by `git`.

This list should be `newline` separated. Example:
```bash
> apt.d/YourOwnPackage.list cat <<EOF
nano
vim
bc
ffmpeg
EOF
```

If you are mounting Windows disks, you need to run it with an environment variable. To avoid doing this manually in a `cmd` or `powershell` window, you can simply click and run `compose.bat`

*Note:* If your package list changes, `docker` `image` needs to be re-built. Simply run `re-compose.bat`, your environment will be based on freshly built image.

I'd recommend to keep this `repo` with your personal `customizations` on a Dropbox or Google Drive share, so you can sync across all of your devices. Goes without saying, `docker volume` itself won't be synced. So stuff you need everywhere should be in your shared directory and should be mounted to your workstation container. Doing so will enable `rwx` on *`ALL`* files within that directory.

#### 5. Accessing to your environment and other misc. stuff
You will need a `terminal emulator`, ideally one which can start new tabs with given command, so whenever you launch this terminal emulator or a new tab on it, you will be straight in your dockerized workstatin.

I'm using [cmder](https://github.com/cmderdev/cmder), I can drop into my environment in less than half a second time on a light notebook despite all of `zsh` customizations. Which is pretty good considering I have to wait 2-3 seconds till I can see my terminal prompt on WSL.

If you are using `cmder` just add this as a startup command and make it default
```
{cmd::sshShell} => ssh localhost -p 2222
```
Mine looks like this
![cmder-settings](https://i.imgur.com/0Eyu5qq.png "cmder settings")

##### What about `docker` in `docker`
If you need to run `docker` within your container, you need to add the docker binaries into your `$PATH`.

It's also useful to make an alias to run `docker` as `sudo docker` since after every container start, mounted `docker.sock` ownership defaults to `root`

You could use an `alias` like this (if it's in your $PATH)
`alias docker='sudo docker'`
or like this:
`alias docker='sudo ~/.local/bin/docker'`

First approach is preferable because then you can run other docker binaries like `docker-compose` within your workstation container.

Pre-built official docker binaries can be found [here](https://docs.docker.com/install/linux/docker-ce/binaries/)

#### PS
Made into repo from [this](https://gist.github.com/sdkks/c505874bbf667f7ba79843d55ef3ba9a) gist for further improvements 

### Questions?
If you have questions, submit them as issues, if anything is broken, it can be fixed or further explanation can be added as FAQ here.
