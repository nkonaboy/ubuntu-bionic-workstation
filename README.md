# DockerizedUbuntuWS
Objective of this project is to provide `docker`ized Ubuntu (headless) Workstation for development/operations on Windows

# HOW TO
You can use `cmd` or `powershell` to run `compose.bat` which sets a required environment variable then brings it up.

In my example, `home` is a volume managed by docker, that is where my all work stuff is. (Some is synced to private git repos, some to Dropbox, some are discardable etc.)

You can create a docker volume using `docker volume create <volumeName>`

I'm using `cmder` as terminal, which can be found here: https://github.com/cmderdev/cmder

My startup command for the terminal tabs is: 
```
{cmd::sshShell} => ssh localhost -p 2222
```

If you download `docker` binary to a directory, you can add this to your .zshrc
`alias docker='sudo ~/.local/bin/docker'`

Because docker.sock is mounted every time container runs fresh, permissions are 'root-only'. 

Docker binary download URL:
https://docs.docker.com/install/linux/docker-ce/binaries/

# TODO 
- Less hacky way of adding user
- Instructions for Windows SSH (cmd) client and public/private key setup
- Make readme.md less crappy
