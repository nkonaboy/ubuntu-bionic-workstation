[![Build Status](https://travis-ci.org/sdkks/DockerizedUbuntuWS.svg?branch=master)](https://travis-ci.org/sdkks/DockerizedUbuntuWS)

# Dockerized Terminal/Workstation
Made into repo from this Gist https://gist.github.com/sdkks/c505874bbf667f7ba79843d55ef3ba9a

Objective of this project is to provide `docker`ized Ubuntu (headless) Workstation for development/operations on Windows. 

That being said, with minor modification it will work on OSX and Linux as well but it will probably be very unnecessary, unless you need to quickly bootstrap a working dev environment on a shared machine, borrowed laptop etc.

Note: For now there will be no GUI/X11 support

# HOW TO
You can use `cmd` or `powershell` to run `compose.bat` which sets a required environment variable then brings it up.

In my example, `home` is a volume managed by docker, that is where my all work stuff is. (Some is synced to private git repos, some to Dropbox, some are discardable etc.)

You can create a docker volume using `docker volume create <volumeName>`

You will need to modify example `docker-compose.yml` file to fit your local dev machin needs, probably sync it across environments on Dropbox or Google Drive.

I'm using `cmder` as terminal, which can be found here: https://github.com/cmderdev/cmder

My startup command for the terminal tabs is: 
```
{cmd::sshShell} => ssh localhost -p 2222
```

If you download `docker` binary to a directory, you can add this to your .zshrc
`alias docker='sudo ~/.local/bin/docker'`

Because docker.sock is mounted every time container runs fresh, permissions are 'root-only'. 

Pre-built official docker binaries download URL:
https://docs.docker.com/install/linux/docker-ce/binaries/

Once you put the docker binaries (docker, docker-compose, etc..) to your local `bin` dir within your `$HOME`, you won't need to repeat it.

