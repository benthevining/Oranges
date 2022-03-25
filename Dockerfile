FROM ubuntu:bionic AS base

FROM base AS dev_machine

# Make sure tzdata won't hang our script
ARG TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install cmake and sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive yes | apt-get upgrade && apt-get -y install sudo --no-install-recommends && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# make sudo usable by this script
ARG user=foo
RUN groupadd -g 999 $user && useradd -u 999 -g $user -G sudo -m -s /bin/bash $user && \
	sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
	sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
	sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
	echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	echo "$user user:";  su - $user -c id

USER $user

COPY . /Oranges

WORKDIR /Oranges

# conan install...

# Make sure clang is the default compiler
RUN DEBIAN_FRONTEND=noninteractive update-alternatives --install /usr/bin/cc cc /usr/bin/clang-13 100 && \
	DEBIAN_FRONTEND=noninteractive update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100

# install Oranges on the dev machine
RUN make install

WORKDIR /

RUN rm -rf Oranges
