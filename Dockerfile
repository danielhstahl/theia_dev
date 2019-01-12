FROM node:8-stretch

RUN apt-get update \
    && apt-get install -y python python-dev python-pip \ 
    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org \
    python-language-server \
    flake8 \
    autopep8 \
    impyla \
    pandas \
    numpy \
    sklearn \
    h2o \
    dvc

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get install --fix-missing
RUN apt-get install -y default-jre
RUN git config --global user.email "someuser@regions.com"
RUN git config --global user.name "someuser"

WORKDIR /home/theia
ADD package.json ./package.json
RUN yarn --cache-folder ./ycache && rm -rf ./ycache
RUN yarn theia build
RUN useradd -ms /bin/bash developer
ENV HOME /home/developer
## Rust
RUN curl https://sh.rustup.rs -fk | sh -s -- -v -y --default-host=x86_64-unknown-linux-gnu --default-toolchain=stable
RUN echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /home/developer/.bashrc
RUN $HOME/.cargo/bin/rustup component add rls rust-analysis rust-src
## Permissions
RUN chmod -R 775 /home/developer
RUN chmod -R 775 /home/theia
RUN chown -R developer:root /home/developer
RUN chown -R developer:root /home/theia
EXPOSE 3000
EXPOSE 3001
ENV SHELL /bin/bash
USER 1001
CMD [ "yarn", "theia", "start", "/home/developer", "--hostname=0.0.0.0" ]