# docker build -t pdevenv .
# docker run -d -P --name test_python pdevenv
# docker port test_python 22

FROM python:3.7-slim-buster

# curl and wget is required for VS Code
RUN apt-get update && apt-get install -y openssh-server curl wget

# Install SSH

RUN mkdir /var/run/sshd

RUN echo 'root:root' | chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install PYTHON

RUN pip install virtualenv

ENV TARGET_ENV=/opt/myapp

WORKDIR ${TARGET_ENV}

ENV VIRTUAL_ENV=/opt/myapp/venv

RUN python3 -m virtualenv --python=/usr/local/bin/python3 $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY src/main.py .

EXPOSE 22 5000
CMD ["/usr/sbin/sshd", "-D"]