# Docker Ubuntu 18.04 Harden With SSH - OpenSSH

This is my testing docker. Used at your own risk.

Docker Container With Ubuntu 18.04 LTS harden and secure. Include SSH OpenSSH to access the server. The default user is user1 and the password is here :-

[https://hub.docker.com/repository/docker/linuxmalaysia/docker-ubuntu-18.04-harden](https://hub.docker.com/repository/docker/linuxmalaysia/docker-ubuntu-18.04-harden)

This docker is installed with :-

- OpenSSH

Latest information in the docker/Dockerfile and hardening[.]sh

[https://github.com/HarisfazillahJamel/docker-ubuntu-18.04-harden](https://github.com/HarisfazillahJamel/docker-ubuntu-18.04-harden)

Dockerfile still with this warning.

[WARNING]: Empty continuation lines will become errors in a future release.

### To Install On Your Server
```sh
docker pull linuxmalaysia/docker-ubuntu-18.04-harden
```
```sh
docker run --privileged=true -it -d -P --name my_ubuntu1 linuxmalaysia/docker-ubuntu-18.04-harden
```
You can then use docker port to find out what host port, the container's port 22 is mapped to :-

```sh
docker port my_ubuntu1
```

```sh
docker port my_ubuntu1 port 22/tcp
```

```sh
ssh user1@localhost -p ?????
```
### To build yourself
```sh
git clone https://github.com/HarisfazillahJamel/docker-ubuntu-18.04-harden.git
```
```sh
cd docker-ubuntu-18.04-harden
```
```sh
docker build -t docker-ubuntu-18.04-harden .
```
```sh
docker run --privileged=true -it -d -P --name my_ubuntu18 docker-ubuntu-18.04-harden
```
haris @ Harisfazillah Jamel @ LinuxMalaysia

25 Jan 2020
