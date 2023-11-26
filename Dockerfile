# Use the latest version of Ubuntu
FROM ubuntu:latest

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Run package updates and install packages
RUN apt-get update \
    && apt-get install -y \
    git \
    nmap \
    net-tools \
    make \
    sudo \
    python3 \
    python3-pip \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    libmagic1 \
    zsh \
    && apt-get clean


RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -p pyenv \
    -p docker \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# SHELL ["/usr/bin/zsh", "-c"]
RUN export PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH
RUN echo "export PATH=/root/.local/bin:$PATH" >> /root/.zshrc

RUN mkdir -p /app/manspider
RUN mkdir -p /app/sharing_is_caring_v2
COPY . /app/sharing_is_caring_v2

WORKDIR /root


RUN git clone https://github.com/pyenv/pyenv.git /root/.pyenv
WORKDIR /root/.pyenv
RUN src/configure
RUN make -C src
WORKDIR /root

RUN git clone https://github.com/pyenv/pyenv-virtualenv.git /root/.pyenv/plugins/pyenv-virtualenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# RUN echo 'export PYENV_ROOT="/root/.pyenv"' >> /root/.zshrc
# RUN echo 'export PATH="/root/.pyenv/bin:$PATH"' >> /root/.zshrc
# RUN echo 'eval "$(pyenv init -)"' >> /root/.zshrc
# RUN echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.zshrc
# RUN exec "$SHELL"
# RUN source /root/.zshrc

RUN pyenv install 3.10.12
RUN pyenv virtualenv 3.10.12 sharing_is_caring_v2
RUN pyenv install 3.6.15
RUN pyenv virtualenv 3.6.15 manspider


WORKDIR /app/sharing_is_caring_v2
RUN echo 'sharing_is_caring_v2' > .python-version
RUN git clone --recursive https://github.com/yack-security/sharing_is_caring_v2.git
# RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /app/manspider
RUN echo 'manspider' > .python-version
# RUN pip3 install pipx
# RUN pipx install git+https://github.com/blacklanternsecurity/MANSPIDER
# pip3 install --upgrade pip

WORKDIR /root
RUN echo 'export PYENV_ROOT="/root/.pyenv"' >> /root/.zshrc
RUN echo 'export PATH="/root/.pyenv/bin:$PATH"' >> /root/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> /root/.zshrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.zshrc

# https://github.com/romkatv/powerlevel10k/issues/679
RUN echo "POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false" >> /root/.zshrc

# reset workdir for entrypoint
WORKDIR /app
# WORKDIR /app/sharing_is_caring_v2
ENTRYPOINT ["/bin/bash", "-c", "/usr/bin/zsh"]
