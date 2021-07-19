FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM='xterm-256color'

# Some basic shit:
RUN apt-get update && apt-get install -yq \
    zsh \
    ripgrep \
    fd-find \
    software-properties-common \
    ca-certificates \
    stow \
    curl \
    wget \
    git \
    fonts-firacode \
    locales \
    fzf

# Set locale:
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY PKI-BR_ROOTCA.crt /usr/local/share/ca-certificates/PKI-BR_ROOTCA.crt
RUN update-ca-certificates

# Latest nvim:
RUN add-apt-repository ppa:neovim-ppa/unstable \
    && apt-get update \
    && apt-get install -yq neovim

# buildenv user:
RUN useradd -m -s /bin/zsh buildenv \
    && echo "buildenv:buildenv" | chpasswd \
    && echo usermod -aG sudo buildenv

# starship.rs:
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

USER buildenv
WORKDIR /home/buildenv

# Dotfiles:
RUN git clone https://github.com/WernerWessely/.dotfiles.git \
    && cd .dotfiles \
    && stow -vt ~ git \
    && stow -vt ~ nvim \
    && stow -vt ~ starship \
    && stow -vt ~ zsh

# Zplug:
ENV ZPLUG_HOME=/home/buildenv/.zplug
RUN git clone https://github.com/zplug/zplug ${ZPLUG_HOME}
# RUN zsh -ic 'zplug install'

CMD tail -f /dev/null
